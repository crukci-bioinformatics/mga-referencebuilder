include { bowtiePath } from '../functions/functions'

process bowtie1Index
{
    label 'builder'
    maxForks 4

    errorStrategy = {
        task.exitStatus in [ 104, 134, 137..140 ] ? 'retry' : 'finish'
    }

    publishDir "${bowtiePath()}", mode: 'copy'

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
