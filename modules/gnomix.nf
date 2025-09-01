#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Perform G-Nomix
process RUN_GNOMIX {
    // debug true
    label 'gnomix'
    tag {chr}

    publishDir "${params.outdir}/3_lai", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.msp', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.fb', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.yaml', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*.vcf*', failOnError: true, overwrite: true    
    publishDir "${params.outdir}/3_lai", pattern: '*_models', failOnError: true, overwrite: true
    publishDir "${params.outdir}/3_lai", pattern: '*_generated_data', failOnError: true, overwrite: true

    input:
    val output_prefix
    tuple val(chr),path(vcf),path(vcf_idx)
    tuple path(ref_vcf),path(ref_vcf_idx)
    path gnomix_dir
    path gnomix_config
    path sample_map
    path gnomix_genetic_map
    val gnomix_phase

    output:
    path "${output_prefix}_${chr}.gnomix.log"         , emit: log
    tuple val(chr),
          path("${output_prefix}_${chr}.msp")         , emit: msp
    path "${output_prefix}_${chr}.fb"                 , emit: fb
    path "${output_prefix}_${chr}_config.yaml"        , emit: gnomix_config
    tuple val(chr),
          path("${output_prefix}_${chr}.vcf"),
          path("dummy_index_file.txt")                , emit: phased_vcf
    path "${output_prefix}_${chr}_models"             , emit: models_dir
    path "${output_prefix}_${chr}_generated_data"     , emit: generated_data_dir

    script:
    
    def args   = task.ext.args   ?: ''

    """
    # Update config and replace symlink with new regular file
    sed -E "s/^\s*n_cores\s*:.*/\s\sn_cores: ${task.cpus}/" config.yaml > tmp_config.yaml
    mv tmp_config.yaml config.yaml

    python3 ${gnomix_dir}/gnomix.py \\
    ${vcf} \\
    ${output_prefix}_${chr} \\
    ${chr} \\
    ${gnomix_phase} \\
    ${gnomix_genetic_map} \\
    ${ref_vcf} \\
    ${sample_map}

    # All output is present in ${output_prefix}_${chr} directory, so moving files out...
    mv ${output_prefix}_${chr}/query_results.fb ${output_prefix}_${chr}.fb
    mv ${output_prefix}_${chr}/query_results.msp ${output_prefix}_${chr}.msp
    
    if [[ -f "${output_prefix}_${chr}/query_file_phased.vcf" ]]; then
        # Previously: ${output_prefix}_${chr}_phased.vcf, but this alters the hapdos prefix, causing issues
        # in downstream steps. extract_tracts will go through, but run_tractorwill expect
        # ${output_prefix}_${chr} as prefix for hapcount/dosage files, not ${output_prefix}_${chr}_phased.

        mv ${output_prefix}_${chr}/query_file_phased.vcf ${output_prefix}_${chr}.vcf
    fi
    mv ${output_prefix}_${chr}/models ${output_prefix}_${chr}_models
    mv ${output_prefix}_${chr}/generated_data ${output_prefix}_${chr}_generated_data
    mv config.yaml ${output_prefix}_${chr}_config.yaml

    cp .command.log ${output_prefix}_${chr}.gnomix.log
    touch dummy_index_file.txt
    """

    stub:
    """
    # Update config and replace symlink with new regular file
    sed -E "s/^\s*n_cores\s*:.*/\s\sn_cores: ${task.cpus}/" config.yaml > tmp_config.yaml
    mv tmp_config.yaml config.yaml

    echo "python3 ${gnomix_dir}/gnomix.py \\
    ${vcf} \\
    ${output_prefix}_${chr} \\
    ${chr} \\
    ${gnomix_phase} \\
    ${gnomix_genetic_map} \\
    ${ref_vcf} \\
    ${sample_map}

    # All output is present in ${output_prefix}_${chr} directory, so moving files out...
    mv ${output_prefix}_${chr}/query_results.fb ${output_prefix}_${chr}.fb
    mv ${output_prefix}_${chr}/query_results.msp ${output_prefix}_${chr}.msp
    
    if [[ -f "${output_prefix}_${chr}/query_file_phased.vcf" ]]; then
        # Previously: ${output_prefix}_${chr}_phased.vcf, but this alters the hapdos prefix, causing issues
        # in downstream steps. extract_tracts will go through, but run_tractorwill expect
        # ${output_prefix}_${chr} as prefix for hapcount/dosage files, not ${output_prefix}_${chr}_phased.

        mv ${output_prefix}_${chr}/query_file_phased.vcf ${output_prefix}_${chr}.vcf
    fi
    mv ${output_prefix}_${chr}/models ${output_prefix}_${chr}_models
    mv ${output_prefix}_${chr}/generated_data ${output_prefix}_${chr}_generated_data
    mv config.yaml ${output_prefix}_${chr}_config.yaml

    cp .command.log ${output_prefix}_${chr}.gnomix.log
    touch dummy_index_file.txt"

    touch ${output_prefix}_${chr}.gnomix.log
    touch ${output_prefix}_${chr}.msp
    touch ${output_prefix}_${chr}.fb
    touch ${output_prefix}_${chr}.vcf
    touch dummy_index_file.txt
    mkdir -p ${output_prefix}_${chr}_models/something && touch ${output_prefix}_${chr}_models/something/file.txt
    mkdir -p ${output_prefix}_${chr}_generated_data/something && touch ${output_prefix}_${chr}_generated_data/something/file.txt
    mv config.yaml ${output_prefix}_${chr}_config.yaml
    """
}