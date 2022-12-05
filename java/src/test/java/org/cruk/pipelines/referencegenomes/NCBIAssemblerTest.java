package org.cruk.pipelines.referencegenomes;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

public class NCBIAssemblerTest
{
    File assembledFile = new File("target/viral_fetch_test.fa");

    public NCBIAssemblerTest()
    {
    }

    @AfterEach
    public void cleanup()
    {
        FileUtils.deleteQuietly(assembledFile);
    }

    @Test
    public void testAssemble() throws Exception
    {
        NCBIAssembler assembler = new NCBIAssembler();

        assembler.urlFile = new File("src/test/data/viruses/assembly_summary.txt");
        assembler.outputFile = assembledFile;
        assembler.readers = 2;

        assembler.call();

        assertEquals(1089679L, assembledFile.length(), "Assembled file differs from expected size.");

        List<String> headers = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(assembledFile)))
        {
            String line;
            while ((line = reader.readLine()) != null)
            {
                if (line.charAt(0) == '>')
                {
                    headers.add(line);
                }
            }
        }

        assertEquals(5, headers.size(), "Expected to find five references in the file.");

        // Order might be different with multiple threads.
        Collections.sort(headers);

        assertEquals(">AF482758.2 Cowpox virus strain Brighton Red, complete genome", headers.get(0));
        assertEquals(">KY569018.1 Cowpox virus strain CPXV CheHurley_DK_2012, complete genome", headers.get(1));
        assertEquals(">KY569020.1 Cowpox virus strain CPXV CheNuru_DK_2012, complete genome", headers.get(2));
        assertEquals(">MK035746.1 Cowpox virus strain CPXV/Boy Biederstein, complete genome", headers.get(3));
        assertEquals(">MK035747.1 Cowpox virus strain CPXV/Rat Marl, complete genome", headers.get(4));
    }
}
