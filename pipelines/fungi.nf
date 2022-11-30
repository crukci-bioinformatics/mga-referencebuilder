include { bowtiePath } from '../functions/functions'
include { fetchAssemblySummary; fetchGenomic; createFasta } from '../processes/ncbi'

workflow fungiWF
{
    main:
        def id = 'fungi.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                def bowtieBase = "${bowtiePath()}/${id}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        fetchAssemblySummary(infoChannel, 'fungi')

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
        fungiChannel = indexChannel
}
