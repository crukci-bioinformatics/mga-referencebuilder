#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { bacteriaWF } from './pipelines/bacteria'
include { fungiWF } from './pipelines/fungi'
include { mycoplasmaWF } from './pipelines/mycoplasma'
include { ribosomalRnaWF } from './pipelines/ribosomalrna'
include { standardWF } from './pipelines/standard'
include { virusesWF } from './pipelines/viruses'

include { bowtie1Index } from './processes/bowtie1'

process supporting
{
    label 'tiny'
    tag { theFile.name }

    publishDir params.referenceTop, mode: 'copy'

    input:
        path(theFile)

    output:
        path(theFile)

    shell:
        // Nothing to actually do. publishDir does the work.
        """
        echo "Publish supporting file !{theFile.name}"
        """
}

workflow
{
    supporting(channel.fromPath("${projectDir}/resources/*", type: 'file'))

    bacteriaWF()
    fungiWF()
    // mycoplasmaWF()
    ribosomalRnaWF()
    virusesWF()
    standardWF()

    bowtieChannel = standardWF.out
        .mix(bacteriaWF.out)
        .mix(fungiWF.out)
        // .mix(mycoplasmaWF.out)
        .mix(ribosomalRnaWF.out)
        .mix(virusesWF.out)

    bowtie1Index(bowtieChannel)
}
