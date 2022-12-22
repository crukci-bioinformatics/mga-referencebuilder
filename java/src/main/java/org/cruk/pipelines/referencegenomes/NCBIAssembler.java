package org.cruk.pipelines.referencegenomes;

import static java.nio.charset.StandardCharsets.US_ASCII;
import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.stream.Collectors;

import org.apache.commons.io.FileUtils;
import org.cruk.pipelines.referencegenomes.ncbi.NCBIQueue;
import org.cruk.pipelines.referencegenomes.ncbi.NCBIReader;
import org.cruk.pipelines.referencegenomes.ncbi.NCBIWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.ExitCode;
import picocli.CommandLine.Option;

@Command(name = "NCBIAssembler",
         descriptionHeading = "Fetch small FASTA files from NCBI and assemble them into one file.",
         mixinStandardHelpOptions = true)
public class NCBIAssembler implements Callable<Integer>
{
    private static final Logger logger = LoggerFactory.getLogger(NCBIAssembler.class);

    @Option(names = { "-o", "--output" }, paramLabel = "file", description = "File to write the output to.")
    File outputFile;

    @Option(names = { "-u", "--urls" }, paramLabel = "file", description = "A file containing the URLs to fetch, one per line.")
    File urlFile;

    @Option(names = { "-r", "--readers" }, paramLabel = "num", description = "The number of reader threads to use.")
    int readers = 1;

    public NCBIAssembler()
    {
    }

    private URI toURI(String s)
    {
        try
        {
            int lastSlash = s.lastIndexOf('/');
            String id = s.substring(lastSlash + 1);
            String fullUri = s + "/" + id + "_genomic.fna.gz";
            return new URI(fullUri);
        }
        catch (URISyntaxException e)
        {
            logger.warn("Have a URL that is invalid: {}", s);
            return null;
        }

    }

    @Override
    public Integer call() throws Exception
    {
        if (readers < 1)
        {
            logger.warn("Cannot have fewer than one reader.");
            readers = 1;
        }

        List<URI> urls =
                FileUtils.readLines(urlFile, US_ASCII).stream()
                .filter(url -> isNotBlank(url))
                .map(url -> toURI(url))
                .filter(url -> url != null)
                .collect(Collectors.toList());

        NCBIQueue queue = new NCBIQueue(urls);
        NCBIWriter writer = new NCBIWriter(queue, outputFile);

        ThreadGroup tg = new ThreadGroup("NCBIReaders");
        for (int i = 0; i < readers; i++)
        {
            NCBIReader reader = new NCBIReader(writer);
            Thread t = new Thread(tg, reader, "NCBIReader" + i);
            t.start();
        }

        writer.run();

        return ExitCode.OK;
    }

    public static void main(String[] args)
    {
        int returnCode = ExitCode.SOFTWARE;
        try
        {
            returnCode = new CommandLine(new NCBIAssembler()).execute(args);
        }
        catch (OutOfMemoryError e)
        {
            returnCode = 104;
            e.printStackTrace();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
        finally
        {
            System.exit(returnCode);
        }
    }
}
