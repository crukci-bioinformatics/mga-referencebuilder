include { bowtiePath } from '../functions/functions'
include { fetchAssemblySummary; fetchGenomic; createFasta } from '../processes/ncbi'

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
            .map
            {
                row ->
                def url = row[19]
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
        mycoplasmaChannel = indexChannel
}
