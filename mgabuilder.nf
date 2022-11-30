#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { standardWF } from './pipelines/standard'
include { fungiWF } from './pipelines/fungi'
include { mycoplasmaWF } from './pipelines/mycoplasma'
include { ribosomalRnaWF } from './pipelines/ribosomalrna'
include { virusesWF } from './pipelines/viruses'
include { bowtie1Index } from './processes/bowtie1'

workflow
{
    fungiWF()
    mycoplasmaWF()
    ribosomalRnaWF()
    //virusesWF()
    //standardWF()

    //bowtieChannel = standardWF.out.mix(fungiWF.out)
    bowtieChannel = mycoplasmaWF.out.mix(fungiWF.out).mix(ribosomalRnaWF.out)

    bowtie1Index(bowtieChannel)
}
