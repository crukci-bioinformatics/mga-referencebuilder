include { bowtiePath; bowtieExists } from '../functions/functions'
include { fetchAssemblySummary; fetchAndCreateFasta } from '../processes/ncbi'

workflow virusesWF
{
    main:
        def id = 'viruses.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                !bowtieExists(it)
            }

        fetchAssemblySummary(infoChannel, 'viral')

        urlChannel = fetchAssemblySummary.out
            .splitCsv(sep: '\t', skip: 2)
            .map { row -> row[19] }
            .collectFile(storeDir: "${workDir}", name: "viruses_ncbi_url_list.txt", newLine: true)

        fetchAndCreateFasta(id, urlChannel)

        indexChannel = fetchAndCreateFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        virusesChannel = indexChannel
}
