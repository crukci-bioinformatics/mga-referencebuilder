/*
    Pipeline to fetch and process FASTA reference sequence.
*/

include { javaMemMB; bowtiePath } from '../functions/functions'

def readGenomeInfo(propsFile)
{
    def genomeInfo = new Properties()
    propsFile.withReader { genomeInfo.load(it) }

    // Add some derived information for convenience.

    genomeInfo['species'] = genomeInfo['name.scientific'].toLowerCase().replace(' ', '_')
    genomeInfo['base'] = genomeInfo['abbreviation'] + '.' + genomeInfo['version']

    return genomeInfo
}

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
        wget -O !{fastaFile} "!{genomeInfo['url.fasta']}"
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
    label 'assembler'

    input:
        tuple val(genomeInfo), path(fastaFile)

    output:
        tuple val(genomeInfo), path(correctedFile)

    shell:
        javaMem = javaMemMB(task)
        correctedFile = "${genomeInfo.base}.fa"

        template "fasta/RecreateFasta.sh"
}

workflow standardWF
{
    main:
        genomeInfoChannel = channel
            .fromPath("${params.genomeInfoDirectory}/*.properties")
            .map
            {
                readGenomeInfo(it)
            }
            .filter
            {
                genomeInfo ->
                def bowtieBase = "${bowtiePath()}/${genomeInfo.base}"
                def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
                return requiredFiles.any { !it.exists() }
            }

        fetchFasta(genomeInfoChannel) | recreateFasta

    emit:
        fastaChannel = recreateFasta.out
}
