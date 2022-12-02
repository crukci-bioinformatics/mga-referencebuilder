include { bowtiePath } from '../functions/functions'
include { fetchAssemblySummary; fetchGenomic; createFasta } from '../processes/ncbi'

process selectGenomes
{
    label 'tiny'
    tag { id }

    input:
        val(id)
        path(refSpreadsheet)
        path(assemblySummary)

    output:
        path(filteredFile)

    shell:
        filteredFile = 'bacterial_reference_genomes.txt'

        """
        python3 "!{projectDir}/python/match_genomes.py" \
            "!{refSpreadsheet}" \
            "!{assemblySummary}" \
            "!{filteredFile}"
        """
}

workflow bacteriaWF
{
    main:
        def id = 'bacteria.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                def bowtieBase = "${bowtiePath()}/${id}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        selectionChannel = channel.fromPath("${projectDir}/resources/bacteria/nbt.3886.xlsx")

        fetchAssemblySummary(infoChannel, 'bacteria')

        selectGenomes(id, selectionChannel, fetchAssemblySummary.out)

        urlChannel = selectGenomes.out
            .splitCsv(sep: '\t', skip: 1)
            .map
            {
                row ->
                def url = row[6]
                def urlParts = url.split('/')
                def thisId = urlParts[urlParts.length - 1]
                tuple thisId, url
            }

        fetchGenomic(urlChannel)

        createFasta(id, fetchGenomic.out.collect())

        indexChannel = createFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        bacteriaChannel = indexChannel
}
