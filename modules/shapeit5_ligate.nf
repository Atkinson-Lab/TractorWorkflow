#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Performing ligate_static from SHAPEIT5 (Tested on v5.1.1)
process RUN_SHAPEIT5_LIGATE {
    // debug true
    label 'shapeit5_ligate'
    tag {chr}

    publishDir "${params.outdir}/2_chunks_ligated", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/2_chunks_ligated", pattern: '*.txt', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/2_chunks_ligated", pattern: '*.{vcf.gz,vcf.gz.csi}', failOnError: true, overwrite: true

    input:
    val output_prefix
    tuple val(chr),path(bcf),path(bcf_idx)

    output:
    path "${output_prefix}_${chr}.shapeit5_common_ligate.log"               , emit: log
    path "list_ligate.${chr}.txt"                                           , emit: ligate
    tuple val(chr),
          path("${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz"),
          path("${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz.csi") , emit: phased_vcf

    script:
    """
    ls -1v *.bcf > list_ligate.${chr}.txt

    if command -v SHAPEIT5_ligate &> /dev/null; then
        SHAPEIT5_ligate \\
        --input list_ligate.${chr}.txt \\
        --output ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz \\
        --thread ${task.cpus} \\
        --log ${output_prefix}_${chr}.shapeit5_common_ligate.log
        bcftools index ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz

    else
        ligate_static \\
        --input list_ligate.${chr}.txt \\
        --output ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz \\
        --thread ${task.cpus} \\
        --index \\
        --log ${output_prefix}_${chr}.shapeit5_common_ligate.log
    fi
    """

    stub:
    """
    ls -1v *.bcf > list_ligate.${chr}.txt

    echo "SHAPEIT5_ligate \\    
    --input list_ligate.${chr}.txt \\
    --output ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz \\
    --thread ${task.cpus} \\
    --log ${output_prefix}_${chr}.shapeit5_common_ligate.log
    bcftools index ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz"

    echo "ligate_static \\
    --input list_ligate.${chr}.txt \\
    --output ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz \\
    --thread ${task.cpus} \\
    --index \\
    --log ${output_prefix}_${chr}.shapeit5_common_ligate.log"

    touch ${output_prefix}_${chr}.shapeit5_common_ligate.log
    touch ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz
    touch ${output_prefix}_${chr}.shapeit5_common_ligate.vcf.gz.csi
    """
}

