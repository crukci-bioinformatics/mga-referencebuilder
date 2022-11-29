/*
    Pipeline to fetch and process FASTA reference sequence.
*/

include { javaMemMB } from '../functions/functions'

process fetchFasta
{
    label 'fetcher'

    input:
        val(genomeInfo)

    output:
        tuple val(genomeInfo), path(fastaFile)

    shell:
        fastaFile = "downloaded.blob"

        """
        curl -s -o !{fastaFile} "!{genomeInfo['url.fasta']}"
        """
}

/*
    Processes a downloaded FASTA file or TAR of FASTA files and rebuilds them
    into a single FASTA file, optionally with some of the chromosomes/contigs
    ordered as given in the assembly's genome info file.

    Any contigs in the reference not present in the chromosome order argument,
    or if that argument is not given, will be ordered alpha-numerically
    (i.e. 2 comes before 10).

    Crucially though for this pipeline it handles inputs of both compressed and
    uncompressed files based on their content to produce an uncompressed file.
 */
process recreateFasta
{
    input:
        tuple val(genomeInfo), path(fastaFile)

    output:
        tuple val(genomeInfo), path(correctedFile)

    shell:
        javaMem = javaMemMB(task)
        correctedFile = "${genomeInfo.base}.fa"

        template "fasta/RecreateFasta.sh"
}

workflow fastaWF
{
    take:
        genomeInfoChannel

    main:
        fetchFasta(genomeInfoChannel) | recreateFasta

    emit:
        fastaChannel = recreateFasta.out
}
