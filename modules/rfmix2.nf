#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Perform RFMIX v2.03-r0 - Local Ancestry and Admixture Inference
process RUN_RFMIX2 {
    // debug true
    label 'rfmix2'
    tag {chr}

    publishDir "${params.outdir}/3_lai", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.{fb.tsv,sis.tsv}', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.{Q,msp.tsv}', mode: 'copy', failOnError: true, overwrite: true

    input:
    val output_prefix
    tuple val(chr),path(vcf),path(vcf_idx)
    tuple path(ref_vcf),path(ref_vcf_idx)
    path sample_map
    path rfmix2_genetic_map
    val reanalyze_ref
    val em_iterations
    val crf_spacing
    val rf_window_size
    val node_size
    val trees

    output:
    path "${output_prefix}_${chr}.rfmix2.log"           , emit: log
    path "${output_prefix}_${chr}.rfmix.Q"              , emit: q_file
    tuple val(chr),
          path("${output_prefix}_${chr}.msp.tsv")       , emit: msp
    path "${output_prefix}_${chr}.fb.tsv"               , emit: fb
    path "${output_prefix}_${chr}.sis.tsv"              , emit: sis

    script:
    
    def args   = task.ext.args   ?: ''
    def reanalyze_ref_command   = reanalyze_ref  ? "--reanalyze-reference"     : ""
    def em_iterations_command   = em_iterations  ? "-e $em_iterations"         : ""
    def crf_spacing_command     = crf_spacing    ? "-c $crf_spacing"           : ""
    def rf_window_size_command  = rf_window_size ? "-s $rf_window_size"        : ""
    def node_size_command       = node_size      ? "-n $node_size"             : ""
    def trees_command           = trees          ? "-t $trees"                 : ""

    """
    rfmix \\
    --query-file=${vcf} \\
    --reference-file=${ref_vcf} \\
    --genetic-map=${rfmix2_genetic_map} \\
    --sample-map=${sample_map} \\
    --output-basename=${output_prefix}_${chr} \\
    $reanalyze_ref_command \\
    $em_iterations_command \\
    $crf_spacing_command \\
    $rf_window_size_command \\
    $node_size_command \\
    $trees_command \\
    --chromosome=${chr} \\
    --n-threads=${task.cpus}

    cp .command.log ${output_prefix}_${chr}.rfmix2.log
    """

    stub:
    def reanalyze_ref_command   = reanalyze_ref    ? "--reanalyze-reference"     : ""
    def em_iterations_command   = em_iterations    ? "-e $em_iterations"         : ""
    def crf_spacing_command     = crf_spacing     ? "-c $crf_spacing"           : ""
    def rf_window_size_command  = rf_window_size  ? "-s $rf_window_size"        : ""
    def node_size_command       = node_size       ? "-n $node_size"             : ""
    def trees_command           = trees           ? "-t $trees"                 : ""

    """
    echo "rfmix \\
    --query-file=${vcf} \\
    --reference-file=${ref_vcf} \\
    --genetic-map=${rfmix2_genetic_map} \\
    --sample-map=${sample_map} \\
    --output-basename=${output_prefix}_${chr} \\
    $reanalyze_ref_command \\
    $em_iterations_command \\
    $crf_spacing_command \\
    $rf_window_size_command \\
    $node_size_command \\
    $trees_command \\
    --chromosome=${chr} \\
    --n-threads=${task.cpus}"

    touch ${output_prefix}_${chr}.rfmix2.log
    touch ${output_prefix}_${chr}.rfmix.Q
    touch ${output_prefix}_${chr}.msp.tsv
    touch ${output_prefix}_${chr}.fb.tsv
    touch ${output_prefix}_${chr}.sis.tsv
    """
}
