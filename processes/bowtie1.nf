include { bowtiePath } from '../functions/functions'

process bowtie1Index
{
    label 'builder'

    publishDir "${bowtiePath(genomeInfo)}", mode: 'copy'

    input:
        tuple val(genomeInfo), path(fastaFile)

    output:
        tuple val(genomeInfo), path('*.ebwt')

    shell:
        """
        !{params.BOWTIE1} \
            "!{fastaFile}" \
            "!{genomeInfo.base}"
        """
}
