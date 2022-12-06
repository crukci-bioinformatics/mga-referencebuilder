include { bowtiePath } from '../functions/functions'
include { fetchAssemblySummary; fetchAndCreateFasta } from '../processes/ncbi'

workflow mycoplasmaWF
{
    main:
        def id = 'mycoplasma.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                def bowtieBase = "${bowtiePath()}/${id}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        fetchAssemblySummary(infoChannel, 'bacteria')

        urlChannel = fetchAssemblySummary.out
            .splitCsv(sep: '\t', skip: 2)
            .filter
            {
                row ->
                return row[7] =~ /^Mycoplasma /
            }
            .map { row -> row[19] }
            .collectFile(storeDir: "${workDir}", name: "mycoplasma_ncbi_url_list.txt", newLine: true)

        fetchAndCreateFasta(id, urlChannel)

        indexChannel = fetchAndCreateFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        mycoplasmaChannel = indexChannel
}
