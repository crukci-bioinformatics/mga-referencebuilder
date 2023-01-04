include { bowtiePath } from '../functions/functions'

process fetchFasta
{
    label 'fetcher'
    tag 'ribosomalRNA'

    output:
        path(fastaFile)

    shell:
        fastaFile = "hsa.hs37d5.fa"

        """
        set -eu

        wget -O "!{fastaFile}.gz" \
            "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz"

        gunzip "!{fastaFile}.gz"
        """
}

process fetchGTF
{
    label 'fetcher'
    tag 'ribosomalRNA'

    output:
        path(gtfFile)

    shell:
        release = 75
        gtfFile = "Homo_sapiens.GRCh37.${release}.gtf"

        """
        set -eu

        wget -O "!{gtfFile}.gz" \
            "https://ftp.ensembl.org/pub/release-!{release}/gtf/homo_sapiens/!{gtfFile}.gz"

        gunzip "!{gtfFile}.gz"
        """
}

process extractFasta
{
    label 'tiny'
    tag { region }

    input:
        val(region)
        each path(fastaFile)

    output:
        path(ribosomalRnaFile)

    shell:
        ribosomalRnaFile = "${region.replace(':', '-')}.region.fa"

        """
        samtools faidx \
            "!{fastaFile}" "!{region}" > "!{ribosomalRnaFile}"
        """
}

process combineRegions
{
    label 'assembler'
    tag 'ribosomalRNA'

    input:
        path(regionFiles)

    output:
        path(ribosomalRnaFile)

    shell:
        ribosomalRnaFile = "ribosomal_rna.fa"

        """
        cat !{regionFiles} > "!{ribosomalRnaFile}"
        """
}

workflow ribosomalRnaWF
{
    main:
        def id = 'ribosomal_RNA'

        infoChannel = channel.of(id)
            .filter
            {
                def bowtieBase = "${bowtiePath()}/${id}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        fetchFasta()
        fetchGTF()

        regionsChannel = fetchGTF.out
            .splitCsv(sep: '\t', skip: 5)
            .filter
            {
                row ->
                return (row[1] == 'rRNA' || row[2] == 'Mt_rRNA') && !(row[0].contains('PATCH') || row[0].contains('HSCHR'))
            }
            .map
            {
                row ->
                return "${row[0]}:${row[3]}-${row[4]}"
            }
            .unique()

        regionsChannel.collectFile(name: "${launchDir}/work/ribsomal_rna_regions.txt", newLine: true)

        extractFasta(regionsChannel, fetchFasta.out)

        combineRegions(extractFasta.out.collect())

        indexChannel = combineRegions.out
            .map
            {
                fastaFile ->
                def genomeInfo = [ base: id ]
                tuple genomeInfo, fastaFile
            }

    emit:
        ribosomalRNAChannel = indexChannel
}
