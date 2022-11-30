#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { standardWF } from './pipelines/standard'
include { fungiWF } from './pipelines/fungi'
include { mycoplasmaWF } from './pipelines/mycoplasma'
include { virusesWF } from './pipelines/viruses'
include { bowtie1Index } from './processes/bowtie1'

workflow
{
    fungiWF()
    mycoplasmaWF()
    virusesWF()
    //standardWF()

    //bowtieChannel = standardWF.out.mix(fungiWF.out)
    bowtieChannel = mycoplasmaWF.out.mix(fungiWF.out).mix(virusesWF.out)

    bowtie1Index(bowtieChannel)
}
