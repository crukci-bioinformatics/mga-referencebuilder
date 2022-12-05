package org.cruk.pipelines.referencegenomes.ncbi;

import java.net.URI;
import java.util.Collection;
import java.util.LinkedList;
import java.util.Queue;

public class NCBIQueue
{
    private Queue<URI> queue;

    public NCBIQueue(Collection<URI> urls)
    {
        queue = new LinkedList<>(urls);
    }

    public synchronized boolean isEmpty()
    {
        return queue.isEmpty();
    }

    public synchronized int size()
    {
        return queue.size();
    }

    public synchronized URI take()
    {
        return queue.poll();
    }
}
