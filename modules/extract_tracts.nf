#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Perform extract_tracts
process RUN_EXTRACT_TRACTS {
    // debug true
    label 'extract_tracts'
    tag {chr}

    publishDir "${params.outdir}/4_extract_tracts", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/4_extract_tracts", pattern: '*.{hapcount,dosage}.txt*', failOnError: true, overwrite: true
    publishDir "${params.outdir}/4_extract_tracts", pattern: '*.vcf*', failOnError: true, overwrite: true

    input:
    val output_prefix
    tuple val(chr),path(vcf),path(vcf_idx)
    tuple val(chr2),path(msp)
    val num_ancs
    val output_vcf
    val compress_output

    output:
    path "${output_prefix}_${chr}.extract_tracts.log"        , emit: log
    tuple val(chr),
          path("*.{hapcount,dosage}.txt*")                   , emit: hapdos
    path "${params.output_prefix}_${chr}.*.vcf*"             , optional:true , emit: anc_vcf // ancestry-specific VCF files for viewing/painting


    script:
    def args   = task.ext.args   ?: ''
    def output_vcf_cmd      = output_vcf         ? "--output-vcf"                 : ""
    def compress_op_cmd     = compress_output    ? "--compress-output"            : ""
    """
    extract_tracts.py \\
    --vcf ${vcf} \\
    --msp ${msp} \\
    --num-ancs ${num_ancs} \\
    $output_vcf_cmd \\
    $compress_op_cmd

    cp .command.log ${output_prefix}_${chr}.extract_tracts.log
    """

    stub:
    def output_vcf_cmd      = output_vcf         ? "--output-vcf"                 : ""
    def compress_op_cmd     = compress_output    ? "--compress-output"            : ""
    """
    echo "extract_tracts.py \\
    --vcf ${vcf} \\
    --msp ${msp} \\
    --num-ancs ${num_ancs} \\
    $output_vcf_cmd \\
    $compress_op_cmd

    cp .command.log ${output_prefix}_${chr}.extract_tracts.log"

    touch ${params.output_prefix}_${chr}.anc0.dosage.txt
    touch ${params.output_prefix}_${chr}.anc0.hapcount.txt
    touch ${params.output_prefix}_${chr}.anc1.dosage.txt
    touch ${params.output_prefix}_${chr}.anc1.hapcount.txt
    touch ${params.output_prefix}_${chr}.vcf
    touch ${output_prefix}_${chr}.extract_tracts.log
    """
}