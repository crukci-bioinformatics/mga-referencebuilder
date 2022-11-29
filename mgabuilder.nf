#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

@Grab('org.apache.commons:commons-lang3:3.12.0')

import static org.apache.commons.lang3.StringUtils.isNotEmpty

include { bowtiePath } from './functions/functions'

include { fastaWF } from './pipelines/fasta'
include { bowtie1Index } from './processes/bowtie1'

def readGenomeInfo(propsFile)
{
    def genomeInfo = new Properties()
    propsFile.withReader { genomeInfo.load(it) }

    // Add some derived information for convenience.

    genomeInfo['species'] = genomeInfo['name.scientific'].toLowerCase().replace(' ', '_')
    genomeInfo['base'] = genomeInfo['abbreviation'] + '.' + genomeInfo['version']

    return genomeInfo
}

workflow
{
    genomeInfoChannel = channel
        .fromPath("${params.genomeInfoDirectory}/*.properties")
        .map { readGenomeInfo(it) }

    bowtieChannel = genomeInfoChannel
        .filter
        {
            genomeInfo ->
            def bowtieBase = "${bowtiePath(genomeInfo)}/${genomeInfo.base}"
            def requiredFiles = [ file("${bowtieBase}.1.ebwt"), file("${bowtieBase}.rev.1.ebwt") ]
            return requiredFiles.any { !it.exists() }
        }

    fastaWF(bowtieChannel) | bowtie1Index
}
