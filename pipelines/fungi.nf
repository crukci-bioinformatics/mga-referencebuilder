include { bowtiePath; bowtieExists } from '../functions/functions'
include { fetchAssemblySummary; fetchAndCreateFasta } from '../processes/ncbi'

workflow fungiWF
{
    main:
        def id = 'fungi.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                !bowtieExists(it)
            }

        fetchAssemblySummary(infoChannel, 'fungi')

        urlChannel = fetchAssemblySummary.out
            .splitCsv(sep: '\t', skip: 2)
            .filter
            {
                row ->
                return row[4] != 'na' && row[11] != 'Scaffold' && row[11] != 'Contig'
            }
            .map { row -> row[19] }
            .collectFile(storeDir: "${workDir}", name: "fungi_ncbi_url_list.txt", newLine: true)

        fetchAndCreateFasta(id, urlChannel)

        indexChannel = fetchAndCreateFasta.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        fungiChannel = indexChannel
}
