#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Perform Tractor GWAS
process RUN_TRACTOR {
    // debug true
    label 'run_tractor'
    // tag "${phenocol}_${chr}"
    tag { phenocol ? "${phenocol}_${chr}" : "${chr}" }

    publishDir "${params.outdir}/5_run_tractor", pattern: '*.log', mode: 'copy', failOnError: true, overwrite: true
    publishDir "${params.outdir}/5_run_tractor", pattern: '*sumstats.txt', mode: 'move', failOnError: true, overwrite: true
    publishDir "${params.outdir}/5_run_tractor", pattern: 'samples_excluded_from_phenotype.txt', mode: 'move', failOnError: true, overwrite: true

    input:
    val output_prefix
    tuple val(chr), path(hapdos_files)
    path phenotype
    val covarcollist
    val regression_method
    val sampleidcol
    val phenocol
    val chunksize
    val totallines

    output:
    path '*.log'                                      , emit: log
    path '*sumstats.txt'                              , emit: sumstats
    path "samples_excluded_from_phenotype.txt"        , optional:true , emit: excluded_samples

    script:
    def args                    = task.ext.args ?: ''
    def sampleidcol_command     = sampleidcol   ? "--sampleidcol ${sampleidcol}" : ""
    def phenocol_command        = phenocol      ? "--phenocol ${phenocol}"       : ""
    def chunksize_command       = chunksize     ? "--chunksize ${chunksize}"     : ""
    def totallines_command      = totallines    ? "--totallines ${totallines}"   : ""
    
    def output_filename         = phenocol      ? "${output_prefix}_${phenocol}_${chr}_sumstats.txt"     : "${output_prefix}_${chr}_sumstats.txt"
    def log_filename            = phenocol      ? "${output_prefix}_${phenocol}_${chr}.run_tractor.log"  : "${output_prefix}_${chr}.run_tractor.log"
    
    // Following is critical, especially if starting not from phasing step (i.e. lai_pretractor_tractor, or tractor_only) where input files may not necessarily will follow the pattern ${output_prefix}_${chr} 
    def hapdos_prefix = hapdos_files[0].getName().replaceAll(/(\.anc\d+\.(dosage|hapcount)\.txt.*)$/, "")
    """
    run_tractor.R \\
    --hapdose ${hapdos_prefix} \\
    --phenofile ${phenotype} \\
    --covarcollist ${covarcollist} \\
    --method ${regression_method} \\
    ${sampleidcol_command} \\
    ${phenocol_command} \\
    ${chunksize_command} \\
    --nthreads ${task.cpus} \\
    ${totallines_command} \\
    --output ${output_filename}

    cp .command.log ${log_filename}
    """

    stub:
    def sampleidcol_command     = sampleidcol   ? "--sampleidcol ${sampleidcol}" : ""
    def phenocol_command        = phenocol      ? "--phenocol ${phenocol}"       : ""
    def chunksize_command       = chunksize     ? "--chunksize ${chunksize}"     : ""
    def totallines_command      = totallines    ? "--totallines ${totallines}"   : ""
    
    def output_filename         = phenocol      ? "${output_prefix}_${phenocol}_${chr}_sumstats.txt"     : "${output_prefix}_${chr}_sumstats.txt"
    def log_filename            = phenocol      ? "${output_prefix}_${phenocol}_${chr}.run_tractor.log"  : "${output_prefix}_${chr}.run_tractor.log"

    """
    echo "run_tractor.R \\
    --hapdose ${hapdos_prefix} \\
    --phenofile ${phenotype} \\
    --covarcollist ${covarcollist} \\
    --method ${regression_method} \\
    ${sampleidcol_command} \\
    ${phenocol_command} \\
    ${chunksize_command} \\
    --nthreads ${task.cpus} \\
    ${totallines_command} \\
    --output ${output_filename}"

    touch ${output_filename}
    touch ${log_filename}
    touch samples_excluded_from_phenotype.txt
    """
}


