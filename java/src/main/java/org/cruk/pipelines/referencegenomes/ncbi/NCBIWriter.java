package org.cruk.pipelines.referencegenomes.ncbi;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.LinkedList;
import java.util.Queue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NCBIWriter
{
    private Logger logger = LoggerFactory.getLogger(NCBIWriter.class);

    private NCBIQueue inQueue;
    private Queue<byte[]> outQueue;

    private File outputFile;

    private int readerCount;

    public NCBIWriter(NCBIQueue queue, File outputFile)
    {
        this.outputFile = outputFile;
        inQueue = queue;
        outQueue = new LinkedList<>();
    }

    public NCBIQueue getQueue()
    {
        return inQueue;
    }

    public synchronized void registerReader()
    {
        ++readerCount;
    }

    public synchronized void readerDone()
    {
        --readerCount;
        notify();
    }

    public synchronized void write(byte[] record)
    {
        outQueue.add(record);
        notify();
    }

    public void run()
    {
        try (OutputStream out = new BufferedOutputStream(new FileOutputStream(outputFile), 8192))
        {
            do
            {
                byte[] record;
                synchronized (this)
                {
                    record = outQueue.poll();
                }

                if (record != null)
                {
                    out.write(record);
                }

                synchronized (this)
                {
                    while (readerCount > 0 && outQueue.isEmpty())
                    {
                        wait();
                    }
                }
            }
            while (readerCount > 0);
        }
        catch (IOException e)
        {
            logger.error("Failed to open or write to {}: {}", outputFile.getAbsolutePath(), e.getMessage());
        }
        catch (InterruptedException e)
        {
            // Just end.
        }
    }
}
