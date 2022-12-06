include { bowtiePath } from '../functions/functions'
include { fetchAssemblySummary; fetchAndCreateFasta } from '../processes/ncbi'

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
            .map { row -> row[6] }
            .collectFile(storeDir: "${workDir}", name: "bacteria_ncbi_url_list.txt", newLine: true)

        fetchAndCreateFasta(id, urlChannel)

        indexChannel = fetchAndCreateFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        bacteriaChannel = indexChannel
}
