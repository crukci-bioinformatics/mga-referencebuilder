#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { standardWF } from './pipelines/standard'
include { fungiWF } from './pipelines/fungi'
include { bowtie1Index } from './processes/bowtie1'

workflow
{
    fungiWF()
    standardWF()

    bowtieChannel = standardWF.out.mix(fungiWF.out)

    bowtie1Index(bowtieChannel)
}
