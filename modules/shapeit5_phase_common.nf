#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Performing phase_common_static from SHAPEIT5 (Tested on v5.1.1)
process RUN_SHAPEIT5_PHASE_COMMON {
    // debug true
    label 'shapeit5'
    tag {data[1]}
    
    publishDir "${params.outdir}/1_chunks_phased", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/1_chunks_phased", pattern: '*.bcf*', failOnError: true, overwrite: true

    input:
    tuple path(input_vcf), path(input_vcf_idx)
    tuple path(ref_vcf), path(ref_vcf_idx)
    path genetic_map
    val filter_maf
    val output_prefix
    tuple val(chr), val(data)
    // tuple val(chr), val(chunk_idx), val(region)

    output:
    tuple val(chr),
          path("${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf"),
          path("${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf.csi")     , emit: phased_bcf
    path "${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log"                , emit: log

    script:
    def args                = task.ext.args   ?: ''
    def ref_vcf_command     = ref_vcf         ? "--reference ${ref_vcf}"     : ""
    def filter_maf_command  = filter_maf      ? "--filter-maf ${filter_maf}" : ""
    """
    echo "# Running SHAPEIT5 Phasing..."

    if command -v SHAPEIT5_phase_common &> /dev/null; then
        SHAPEIT5_phase_common \
        --input ${input_vcf} \
        ${ref_vcf_command} \
        --map ${genetic_map} \
        --output ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf \
        --thread ${task.cpus} \
        --log ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log \
        ${filter_maf_command} \
        --region ${data[1]}
    else
        phase_common_static \
        --input ${input_vcf} \
        ${ref_vcf_command} \
        --map ${genetic_map} \
        --output ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf \
        --thread ${task.cpus} \
        --log ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log \
        ${filter_maf_command} \
        --region ${data[1]}
    fi

    """
    stub:
    def ref_vcf_command     = ref_vcf         ? "--reference ${ref_vcf}"     : ""
    def filter_maf_command  = filter_maf      ? "--filter-maf ${filter_maf}" : ""
    """
    echo "# Running SHAPEIT5 Phasing..."

    echo "SHAPEIT5_phase_common \\
    --input ${input_vcf} \\
    $ref_vcf_command \\
    --map ${genetic_map} \\
    --output ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf \\
    --thread ${task.cpus} \\
    --log ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log \\
    ${filter_maf_command} \\
    --region ${data[1]}"

    echo "phase_common_static \\
    --input ${input_vcf} \\
    ${ref_vcf_command} \\
    --map ${genetic_map} \\
    --output ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf \\
    --thread ${task.cpus} \\
    --log ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log \\
    ${filter_maf_command} \\
    --region ${data[1]}"

    touch ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf
    touch ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.bcf.csi
    touch ${output_prefix}_${chr}.chunk_${data[0]}.shapeit5_common.log
    """

}

