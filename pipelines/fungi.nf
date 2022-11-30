include { javaMemMB; bowtiePath } from '../functions/functions'

process fetchAssemblySummary
{
    label 'fetcher'
    tag 'fungi'

    input:
        val(id)

    output:
        path(assemblySummary)

    shell:
        assemblySummary = 'assembly_summary.txt'

        """
        curl -s -o !{assemblySummary} "ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/fungi/!{assemblySummary}"
        """
}

process fetchFungi
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

process createFungiFasta
{
    tag 'fungi'

    input:
        path(inputFiles)

    output:
        path(outputFile)

    shell:
        javaMem = javaMemMB(task)
        outputFile = "fungi.fa"

        template "ConcatenateFiles.sh"
}

workflow fungiWF
{
    main:
        fungiChannel = channel.of('fungi')
            .filter
            {
                id ->
                def bowtieBase = "${bowtiePath()}/${id}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        fetchAssemblySummary(fungiChannel)

        urlChannel = fetchAssemblySummary.out
            .splitCsv(sep: '\t', skip: 2)
            .filter
            {
                row ->
                return row[4] != 'na' && row[11] != 'Scaffold' && row[11] != 'Contig'
            }
            .map
            {
                row ->
                def url = row[19]
                def urlParts = url.split('/')
                def id = urlParts[urlParts.length - 1]
                tuple id, url
            }

        fetchFungi(urlChannel)

        createFasta(fetchFungi.out.collect())

        indexChannel = createFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: 'fungi.NCBI' ]
                tuple genomeInfo, fastaFile
            }

    emit:
        fungiChannel = indexChannel
}
