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
        wget -O !{assemblySummary} "https://ftp.ncbi.nlm.nih.gov/genomes/genbank/${type}/!{assemblySummary}"
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
        wget -O "!{fastaFile}" "!{url}/!{fastaFile}"
        """
}

process createFasta
{
    label 'assembler'
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

process fetchAndCreateFasta
{
    label 'assembler'
    tag { id }

    publishDir "${launchDir}/customFasta", mode: 'link'

    cpus 7
    time '4h'
    errorStrategy 'finish'
    cache 'deep'

    input:
        val(id)
        path(urlFile)

    output:
        path(outputFile)

    shell:
        javaMem = javaMemMB(task)
        outputFile = "${id}.fa"

        template "ncbi/FetchAndCreateFasta.sh"
}
