/*
 * Miscellaneous helper functions used all over the pipeline.
 */

def bowtiePath()
{
    return "${params.referenceTop}/bowtie_indexes"
}

/*
 * Function to test whether the Bowtie indexes exist. This is complicated
 * by the possibility that the suffix can be "ebwt" or "ebwtl".
 */
def bowtieExists(assembly)
{
    def base = "${bowtiePath()}/${assembly}"
    def suffixes = [ 'ebwt', 'ebwtl' ]

    def forwardRequires = suffixes.collect { file("${base}.1.${it}") }
    def forwardExists = forwardRequires.any { it.exists() }

    def reverseRequires = suffixes.collect { file("${base}.rev.1.${it}") }
    def reverseExists = reverseRequires.any { it.exists() }

    return forwardExists && reverseExists
}

/*
 * Get the size of a collection of things. It might be that the thing
 * passed in isn't a collection or map, in which case the size is 1.
 *
 * See https://github.com/nextflow-io/nextflow/issues/2425
 */
def sizeOf(thing)
{
    return (thing instanceof Collection || thing instanceof Map) ? thing.size() : 1
}

/**
 * Give a number for the Java heap size based on the task memory, allowing for
 * some overhead for the JVM itself from the total allowed.
 */
def javaMemMB(task)
{
    return task.memory.toMega() - 128
}
