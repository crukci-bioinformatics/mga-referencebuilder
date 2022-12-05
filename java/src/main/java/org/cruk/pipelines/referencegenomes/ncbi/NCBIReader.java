package org.cruk.pipelines.referencegenomes.ncbi;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;

import org.apache.commons.compress.compressors.CompressorException;
import org.apache.commons.compress.compressors.CompressorStreamFactory;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.cruk.common.exception.ExceptionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NCBIReader implements Runnable
{
    private Logger logger = LoggerFactory.getLogger(NCBIReader.class);

    private NCBIWriter writer;
    private NCBIQueue queue;

    private CloseableHttpClient client;

    private CompressorStreamFactory compressorFactory;

    public NCBIReader(NCBIWriter writer)
    {
        this.writer = writer;
        this.queue = writer.getQueue();

        compressorFactory = CompressorStreamFactory.getSingleton();
        client = HttpClientBuilder.create().build();

        writer.registerReader();
    }

    @Override
    protected void finalize() throws Throwable
    {
        client.close();
    }

    @Override
    public void run()
    {
        try
        {
            URI url;
            while ((url = queue.take()) != null)
            {
                try
                {
                    HttpGet get = new HttpGet(url);
                    HttpResponse response = client.execute(get);
                    HttpEntity entity = response.getEntity();
                    int statusCode = response.getStatusLine().getStatusCode();

                    if (statusCode / 100 == 2)
                    {
                        try (InputStream stream = new BufferedInputStream(entity.getContent()))
                        {
                            InputStream decoding;
                            try
                            {
                                decoding = compressorFactory.createCompressorInputStream(stream);
                            }
                            catch (CompressorException e)
                            {
                                // Probably not a compressed stream.
                                decoding = stream;
                            }

                            byte[] content = IOUtils.toByteArray(decoding);
                            writer.write(content);

                            logger.debug("{}: fetched {}", Thread.currentThread().getName(), url);
                        }
                    }
                    else
                    {
                        logger.warn("Could not retrieve {}: status code {}", url, statusCode);
                    }
                }
                catch (IOException e)
                {
                    logger.warn("Could not retrieve {}: {}", url, e.getMessage());
                }
            }
        }
        catch (Throwable t)
        {
            t = ExceptionUtils.innermostThrowable(t);
            logger.error("{} failed: {}", Thread.currentThread().getName(), t.getMessage());
            logger.debug("", t);
        }
        finally
        {
            writer.readerDone();
        }
    }
}
