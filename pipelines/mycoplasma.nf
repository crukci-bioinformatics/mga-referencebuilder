include { bowtiePath; bowtieExists } from '../functions/functions'
include { fetchAssemblySummary; fetchAndCreateFasta } from '../processes/ncbi'

workflow mycoplasmaWF
{
    main:
        def id = 'mycoplasma.NCBI'

        infoChannel = channel.of(id)
            .filter
            {
                !bowtieExists(it)
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
