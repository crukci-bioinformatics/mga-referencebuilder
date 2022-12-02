include { javaMemMB } from '../functions/functions'

process fetchAssemblySummary
{
    label 'tiny'
    tag { id }

    input:
        val(id)
        val(type)

    output:
        path(assemblySummary)

    shell:
        assemblySummary = 'assembly_summary.txt'

        """
        curl -s -o !{assemblySummary} "https://ftp.ncbi.nlm.nih.gov/genomes/genbank/${type}/!{assemblySummary}"
        """
}

process fetchGenomic
{
    label 'tiny'
    maxForks 25
    tag { id }

    input:
        tuple val(id), val(url)

    output:
        path(fastaFile)

    shell:
        fastaFile = "${id}_genomic.fna.gz"

        """
        curl -s -o "!{fastaFile}" "!{url}/!{fastaFile}"
        """
}

process createFasta
{
    tag { id }

    input:
        val(id)
        path(inputFiles)

    output:
        path(outputFile)

    shell:
        javaMem = javaMemMB(task)
        outputFile = "${id}.fa"

        template "ConcatenateFiles.sh"
}
