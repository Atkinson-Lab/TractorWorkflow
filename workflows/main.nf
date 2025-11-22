#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// This code is still TBD

/*
 * Steps Involved (Complete Tractor Workflow):
 *   - SHAPEIT5-based phasing for chunks
 *   - SHAPEIT5-based ligation of chunks
 *   - LAI using either RFMix2, GNomix, or FLARE
 *   - Pre-Tractor hapcount/dosage file extraction
 *   - Run Tractor
 */

/*
 *  Default pipeline parameters. They can be overriden on the command line and config file.
 */

// TBD
params.lai_tool      = false  // can be rfmix2,gnomix,flare
params.mode          = false  // TBD: can be complete,phasing_only,phasing_lai,phasing_lai_pretractor,lai_only,lai_pretractor,lai_pretractor_tractor,pretractor_tractor,tractor_only

// Output directory
params.outdir        = "results"

// SHAPEIT5 specific inputs
// params.chunkfile     = ""
// params.input_vcf     = ""
// params.genetic_map   = ""
// params.output_prefix = ""
params.reference_vcf = false  // some value must be definied, cannot be null or ""
params.filter_maf    = false  // some value must be definied, cannot be null or ""

// RFMix2 specific inputs
// params.rfmix2_ref_vcf     = ""
// params.rfmix2_sample_map  = ""
// params.rfmix2_genetic_map = ""
params.reanalyze_ref      = false
params.em_iterations      = false
params.crf_spacing        = false
params.rf_window_size     = false
params.node_size          = false
params.trees              = false

// GNomix specific inputs
// params.gnomix_dir         = ""
// params.gnomix_config      = ""
// params.gnomix_ref_vcf     = ""
// params.gnomix_sample_map  = ""
// params.gnomix_genetic_map = ""
// params.gnomix_phase       = ""

// FLARE specific inputs
// params.flare_dir               = ""
// params.flare_ref_vcf           = ""
// params.flare_sample_map        = ""
// params.flare_genetic_map       = ""
params.flare_array             = false      // FLARE’s default (v0.5.3) is false (https://github.com/browning-lab/flare)
params.flare_min_maf           = false
params.flare_min_mac           = false
params.flare_probs             = false      // FLARE’s default (v0.5.3) is false (https://github.com/browning-lab/flare)
params.flare_gen               = false
params.flare_model             = false
params.flare_em                = true       // FLARE’s default (v0.5.3) is true (https://github.com/browning-lab/flare)
params.flare_gt_samples_include = false
params.flare_gt_samples_exclude = false
params.flare_gt_ancestries     = false
params.flare_excludedmarkers   = false
params.flare_seed              = false

// extract_tracts.py specific inputs
// params.num_ancs           = 
params.output_vcf         = false
params.compress_output    = false

// run_tractor.R specific inputs
// params.phenotype          = ""
params.phenolist_file     = false
// params.covarcollist       = ""
// params.regression_method  = ""
params.sampleidcol        = false
params.phenocol           = false
params.chunksize          = false
params.totallines         = false

if (params.mode == "tractor_only") {
    // Mandatory arguments, since this step begins at Module 3
    // params.chr                = ""
    // Create hapdos parameter to detect all hapcount and dosage files
    // params.hapdos             = ""
    params.hapdos_files       = "${params.hapdos}_${params.chr}.*{hapcount,dosage}.txt*"
}

def phased_vcf_idx
if (params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
    // Mandatory arguments, since this step begins at Module 2
    // params.chr           = ""
    // params.output_prefix = ""
    // params.phased_vcf    = ""

    def phased_vcf_csi = "${params.phased_vcf}.csi"
    def phased_vcf_tbi = "${params.phased_vcf}.tbi"
    // Check if the .csi index file exists, if not, check for .tbi
    if (file(phased_vcf_csi).exists()) {
        phased_vcf_idx = phased_vcf_csi
    } else if (file(phased_vcf_tbi).exists()) {
        phased_vcf_idx = phased_vcf_tbi
    } else {
        // Handle the case when neither index file exists
        error "Neither .csi nor .tbi index file found for ${params.phased_vcf}"
    }
}

def input_vcf_idx
def reference_vcf_idx
if (params.mode == "complete" || params.mode == "phasing_only" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor") {
    /*
     * Identify respective indexes for input VCF files.
     */
    def input_vcf_csi = "${params.input_vcf}.csi"
    def input_vcf_tbi = "${params.input_vcf}.tbi"
    // def input_vcf_idx
    // Check if the .csi index file exists, if not, check for .tbi
    if (file(input_vcf_csi).exists()) {
        input_vcf_idx = input_vcf_csi
    } else if (file(input_vcf_tbi).exists()) {
        input_vcf_idx = input_vcf_tbi
    } else {
        // Handle the case when neither index file exists
        error "Neither .csi nor .tbi index file found for ${params.input_vcf}"
    }

    /*
     * Identify respective indexes for SHAPEIT5 reference VCF file, if provided.
     */
    // def reference_vcf_idx
    if (params.reference_vcf) {
        def reference_vcf_csi = "${params.reference_vcf}.csi"
        def reference_vcf_tbi = "${params.reference_vcf}.tbi"

        if (file(reference_vcf_csi).exists()) {
            reference_vcf_idx = reference_vcf_csi
        } else if (file(reference_vcf_tbi).exists()) {
            reference_vcf_idx = reference_vcf_tbi
        } else {
            // Handle the case when neither index file exists
            error "Neither .csi nor .tbi index file found for ${params.reference_vcf}"
        }
    } else {
        reference_vcf_idx = false
    }
}

def lai_ref_vcf
def lai_ref_vcf_idx
if (params.mode == "complete" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor" || params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
    /*
     * Identify respective indexes for LAI reference VCF
     */
    // TBD: different cases params.rfmix2_ref_vcf or prams.gnomix_ref_vcf
    // def lai_ref_vcf
    if (params.lai_tool == "rfmix2") {
        lai_ref_vcf     = params.rfmix2_ref_vcf
    } else if (params.lai_tool == "gnomix") {
        lai_ref_vcf     = params.gnomix_ref_vcf
    } else if (params.lai_tool == "flare") {
        lai_ref_vcf     = params.flare_ref_vcf
    }
    def lai_ref_vcf_csi = "${lai_ref_vcf}.csi"
    def lai_ref_vcf_tbi = "${lai_ref_vcf}.tbi"
    // def lai_ref_vcf_idx
    // Check if the .csi index file exists, if not, check for .tbi
    if (file(lai_ref_vcf_csi).exists()) {
        lai_ref_vcf_idx = lai_ref_vcf_csi
    } else if (file(lai_ref_vcf_tbi).exists()) {
        lai_ref_vcf_idx = lai_ref_vcf_tbi
    } else {
        // Handle the case when neither index file exists
        error "Neither .csi nor .tbi index file found for ${lai_ref_vcf}"
    }
}

// TBD: Hodify such that arguments used only in specific modes are printed correctly.
log.info """\
    ============================================
          T R A C T O R    W O R K F L O W      
    ============================================

    ==>   Initialization:
    Mode                  : ${params.mode}
    """
    .stripIndent()

if (params.mode != "phasing_only" && params.mode != "tractor_only") {
    log.info """\
        LAI Tool              : ${params.lai_tool}
        """
        .stripIndent()
}


log.info """\
    ==>   Initialization:
    Output Dir            : ${params.outdir}
    Output Prefix         : ${params.output_prefix}
    """
    .stripIndent()

if (params.mode == "complete" || params.mode == "phasing_only" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor") {
    log.info """\
        ==>   SHAPEIT5-specific inputs
        Input VCF             : ${params.input_vcf}
        Input VCF index       : ${input_vcf_idx}
        Genomic chunkfile     : ${params.chunkfile}
        SHAPEIT5 Genetic Map  : ${params.genetic_map}
        Output Prefix         : ${params.output_prefix}
        Reference VCF         : ${params.reference_vcf}
        Reference VCF index   : ${reference_vcf_idx}
        Filter MAF            : ${params.filter_maf}
        """
        .stripIndent()
}

if (params.mode == "complete" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor" || params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
    if (params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
        log.info """\
            ==>   LAI-specific inputs
            Chromosome            : ${params.chr}
            Phased VCF            : ${params.phased_vcf}
            Phased VCF index      : ${phased_vcf_idx}
            """
            .stripIndent()
    }

    if (params.lai_tool == "rfmix2") {
        log.info """\
            ==>   RFMix2-specific inputs
            RFMix2 Ref. VCF       : ${lai_ref_vcf}
            RFMix2 Ref. VCF index : ${lai_ref_vcf_idx}
            Sample Map File       : ${params.rfmix2_sample_map}
            RFMix2 Genetic Map    : ${params.rfmix2_genetic_map}
            Reanalyze Refs        : ${params.reanalyze_ref}
            EM iterations         : ${params.em_iterations}
            CRF Spacing           : ${params.crf_spacing}
            RF Window Size        : ${params.rf_window_size}
            Node Size             : ${params.node_size}
            Trees                 : ${params.trees}
            """
            .stripIndent()
    } else if (params.lai_tool == "gnomix") {
        log.info """\
            ==>   GNomix-specific inputs
            GNomix Directory      : ${params.gnomix_dir}
            GNomix Config File    : ${params.gnomix_config}
            GNomix Ref. VCF       : ${lai_ref_vcf}
            GNomix Ref. VCF index : ${lai_ref_vcf_idx}
            Sample Map File       : ${params.gnomix_sample_map}
            GNomix Genetic Map    : ${params.gnomix_genetic_map}
            GNomix Phasing        : ${params.gnomix_phase}
            """
            .stripIndent()
    } else if (params.lai_tool == "flare") {
        log.info """\
            ==>   FLARE-specific inputs
            FLARE directory       : ${params.flare_dir}
            FLARE Ref. VCF        : ${lai_ref_vcf}
            FLARE Ref. VCF index  : ${lai_ref_vcf_idx}
            Sample Map File       : ${params.flare_sample_map}
            FLARE Genetic Map     : ${params.flare_genetic_map}
            Is VCF array?         : ${params.flare_array}     If not provided, uses FLARE’s default (v0.5.3): false (https://github.com/browning-lab/flare)
            EM                    : ${params.flare_em}      If not provided, uses FLARE’s default (v0.5.3): true (https://github.com/browning-lab/flare)
            Min MAF               : ${params.flare_min_maf}
            Min MAC               : ${params.flare_min_mac}      Note: --flare_min_mac flag is ignored if --flare_array is true.
            Prob. Estimates?      : ${params.flare_probs}      If not provided, uses FLARE’s default (v0.5.3): false (https://github.com/browning-lab/flare)
            No. of Generations    : ${params.flare_gen}      Note: --flare_gen flag is ignored if --flare_model is provided.
            Model File            : ${params.flare_model}
            Include Samples File  : ${params.flare_gt_samples_include}
            Exclude Samples File  : ${params.flare_gt_samples_exclude}
            GT Ancestries File    : ${params.flare_gt_ancestries}
            ExcludedMarkers File  : ${params.flare_excludedmarkers}
            Seed                  : ${params.flare_seed}
            """
        .stripIndent()
    }
}


if (params.mode == "complete" || params.mode == "phasing_lai_pretractor" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor" || params.mode == "pretractor_tractor") {

    if (params.mode == "pretractor_tractor") {
        if (params.lai_tool == "rfmix2" || params.lai_tool == "gnomix") {
            log.info """\
                ==>   extract_tracts specific inputs (pretractor_tractor)
                Chromosome            : ${params.chr}
                Phased VCF            : ${params.phased_vcf}
                Phased VCF index      : ${phased_vcf_idx}
                MSP                   : ${params.msp}
                """
                .stripIndent()
        } else if (params.lai_tool == "flare") {
            log.info """\
                ==>   extract_tracts specific inputs (pretractor_tractor)
                Chromosome            : ${params.chr}
                FLARE Ancestry VCF    : ${params.flare_anc_vcf}  // Must be a FLARE-ouptut VCF.
                """
                .stripIndent()
        }

    }

    log.info """\
        ==>   extract_tracts specific inputs
        Number of ancestries  : ${params.num_ancs}
        Output VCF            : ${params.output_vcf}
        Compress Output       : ${params.compress_output}
        """
        .stripIndent()
}

if (params.mode == "complete" || params.mode == "lai_pretractor_tractor" || params.mode == "pretractor_tractor" || params.mode == "tractor_only") {
    if (params.mode == "lai_pretractor_tractor" || params.mode == "pretractor_tractor" || params.mode == "tractor_only") {
        log.info """\
            ==>   run_tractor specific inputs (tractor_only)
            Chromosome            : ${params.chr}
            """
            .stripIndent()
    }

    if (params.mode == "tractor_only") {
        log.info """\
            Hapdos Prefix         : ${params.hapdos}
            """
            .stripIndent()
    }

    log.info """\
        ==>   run_tractor specific inputs
        Phenotype file        : ${params.phenotype}
        Phenotype list file   : ${params.phenolist_file}
        Covariate Columns     : ${params.covarcollist}
        Regression method     : ${params.regression_method}
        Sample ID Column Name : ${params.sampleidcol}
        Phenotype Column Name : ${params.phenocol}       Note: --phenocol flag is ignored if --phenolist_file is provided.
        Chunksize             : ${params.chunksize}
        Total Lines           : ${params.totallines}
        """
        .stripIndent()
}

log.info """\

    ============================================
          T R A C T O R    W O R K F L O W      
    ============================================
    """
    .stripIndent()

// import modules
include { RUN_SHAPEIT5_PHASE_COMMON } from '../modules/shapeit5_phase_common.nf'
include { RUN_SHAPEIT5_LIGATE } from '../modules/shapeit5_ligate.nf'

include { RUN_RFMIX2 } from '../modules/rfmix2.nf'
include { RUN_GNOMIX } from '../modules/gnomix.nf'
include { RUN_EXTRACT_TRACTS } from '../modules/extract_tracts.nf'

include { RUN_FLARE } from '../modules/flare.nf'
include { RUN_EXTRACT_TRACTS_FLARE } from '../modules/extract_tracts_flare.nf'

include { RUN_TRACTOR } from '../modules/tractor.nf'


workflow {

    def ch_shapeit5_ref_vcf
    def lai_out_msp // MSP file output of LAI
    def extract_vcf // VCF to be used for extract_tracts

    if (params.mode == "complete" || params.mode == "phasing_only" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor") {
        ch_regions     = Channel.fromPath(params.chunkfile)
                                .splitCsv(header: false, sep: "\t")
                                .map{ row -> tuple(row[1], [row[0], row[2]])}
        // ch_regions.view()

        ch_input_vcf = Channel.of([
            file(params.input_vcf, checkIfExists: true),
            file(input_vcf_idx, checkIfExists: true)
            ]).first()
        // ch_input_vcf.view()

        // def ch_shapeit5_ref_vcf
        if (params.reference_vcf) {
            ch_shapeit5_ref_vcf = Channel.of([
                                        params.reference_vcf,
                                        reference_vcf_idx
                                ]).first()
        } else {
            ch_shapeit5_ref_vcf = Channel.of([[],[]]).first()
        }
        // ch_shapeit5_ref_vcf.view()
        // return
        
        RUN_SHAPEIT5_PHASE_COMMON(ch_input_vcf,
                                  ch_shapeit5_ref_vcf,
                                  params.genetic_map,
                                  params.filter_maf,
                                  params.output_prefix,
                                  ch_regions)
        // RUN_SHAPEIT5_PHASE_COMMON.out.phased_bcf.groupTuple(by:0).view()
        // return

        // Ligate chunked files. Even if there is only one chunk file/chromosome, the process will go through.
        RUN_SHAPEIT5_LIGATE(params.output_prefix,
                            RUN_SHAPEIT5_PHASE_COMMON.out.phased_bcf.groupTuple(by:0))
        // RUN_SHAPEIT5_LIGATE.out.phased_vcf.view()
        // return
    }

    if (params.mode == "complete" || params.mode == "phasing_lai" || params.mode == "phasing_lai_pretractor" || params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
        
        // If beginning at LAI step, setup ch_phased_vcf
        if (params.mode == "lai_only" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor") {
            ch_phased_vcf = Channel.of([
                params.chr,
                file(params.phased_vcf, checkIfExists: true),
                file(phased_vcf_idx, checkIfExists: true)
                ]).first()
            // ch_phased_vcf.view()
            ch_lai_phased_vcf = ch_phased_vcf
        } else {
            ch_lai_phased_vcf = RUN_SHAPEIT5_LIGATE.out.phased_vcf
        }



        ch_lai_ref_vcf = Channel.of([
            file(lai_ref_vcf, checkIfExists: true),
            file(lai_ref_vcf_idx, checkIfExists: true)
            ]).first()
        
        // def lai_out_msp
        // def extract_vcf
        if (params.lai_tool == "rfmix2") {
            RUN_RFMIX2(params.output_prefix,
                       ch_lai_phased_vcf,
                       ch_lai_ref_vcf,
                       params.rfmix2_sample_map,
                       params.rfmix2_genetic_map,
                       params.reanalyze_ref,
                       params.em_iterations,
                       params.crf_spacing,
                       params.rf_window_size,
                       params.node_size,
                       params.trees)
            // RUN_RFMIX2.out.msp.view()
            // return
            lai_out_msp = RUN_RFMIX2.out.msp
            extract_vcf = ch_lai_phased_vcf
            // lai_out_msp.view()
            // extract_vcf.view()
        } else if (params.lai_tool == "gnomix") {
            RUN_GNOMIX(params.output_prefix,
                       ch_lai_phased_vcf,
                       ch_lai_ref_vcf,
                       params.gnomix_dir,
                       params.gnomix_config,
                       params.gnomix_sample_map,
                       params.gnomix_genetic_map,
                       params.gnomix_phase)
            lai_out_msp = RUN_GNOMIX.out.msp
            if (params.gnomix_phase) {
                extract_vcf = RUN_GNOMIX.out.phased_vcf
            } else {
                extract_vcf = ch_lai_phased_vcf
            }
            // lai_out_msp.view()
            // extract_vcf.view()
        } else if (params.lai_tool == "flare") {
            RUN_FLARE(params.output_prefix,
                      ch_lai_phased_vcf,
                      ch_lai_ref_vcf,
                      params.flare_dir,
                      params.flare_sample_map,
                      params.flare_genetic_map,
                      params.flare_array,
                      params.flare_min_maf,
                      params.flare_min_mac,
                      params.flare_probs,
                      params.flare_gen,
                      params.flare_model,
                      params.flare_em,
                      params.flare_gt_samples_include,
                      params.flare_gt_samples_exclude,
                      params.flare_gt_ancestries,
                      params.flare_excludedmarkers,
                      params.flare_seed)
        } else {
            error "Invalid LAI tool: ${params.lai_tool}. Must be one of [rfmix2, gnomix, flare]"
        }

    }

    if (params.mode == "complete" || params.mode == "phasing_lai_pretractor" || params.mode == "lai_pretractor" || params.mode == "lai_pretractor_tractor" || params.mode == "pretractor_tractor") {
        if (params.lai_tool == "rfmix2" || params.lai_tool == "gnomix") {
            
            // If beginning at pretractor step:
            // msp and phased_vcf are required as arguments (for rfmix2/gnomix)
            if (params.mode == "pretractor_tractor" ) {
                // setup extract_vcf and lai_out_msp
                ch_phased_vcf = Channel.of([
                                    params.chr,
                                    file(params.phased_vcf, checkIfExists: true),
                                    []
                                    ]).first()
                extract_vcf = ch_phased_vcf
                lai_out_msp = Channel.of([
                                    params.chr,
                                    file(params.msp, checkIfExists: true)
                                    ]).first()
            }

            RUN_EXTRACT_TRACTS(params.output_prefix,
                               extract_vcf,
                               lai_out_msp,
                               params.num_ancs,
                               params.output_vcf,
                               params.compress_output)
            // RUN_EXTRACT_TRACTS.out.log.view()
            ch_RUN_EXTRACT_TRACTS_HAPDOS = RUN_EXTRACT_TRACTS.out.hapdos.first()
            // ch_RUN_EXTRACT_TRACTS_HAPDOS.view()
        } else if (params.lai_tool == "flare") {

            // If beginning at pretractor step:
            // (flare_anc_vcf) FLARE-output VCF file is required (with genotypes and ancestry calls)
            if (params.mode == "pretractor_tractor" ) {
                ch_flare_anc_vcf = Channel.of([
                                    params.chr,
                                    file(params.flare_anc_vcf, checkIfExists: true)
                                    ]) // removed .first()
            } else {
                // ch_flare_anc_vcf = Channel.of([
                //                     RUN_FLARE.out.anc_vcf
                //                     ])
                // RUN_FLARE.out.anc_vcf.view()
                // ch_flare_anc_vcf.view()
                ch_flare_anc_vcf = RUN_FLARE.out.anc_vcf
            }
            // ch_flare_anc_vcf.view()
            RUN_EXTRACT_TRACTS_FLARE(params.output_prefix,
                                     ch_flare_anc_vcf,
                                     params.num_ancs,
                                     params.output_vcf,
                                     params.compress_output)
            // RUN_EXTRACT_TRACTS_FLARE.out.log.view()
            ch_RUN_EXTRACT_TRACTS_HAPDOS = RUN_EXTRACT_TRACTS_FLARE.out.hapdos.first()
            // ch_RUN_EXTRACT_TRACTS_HAPDOS.view()
        }
    }


    if (params.mode == "complete" || params.mode == "lai_pretractor_tractor" || params.mode == "pretractor_tractor" || params.mode == "tractor_only") {

        if (params.mode == "tractor_only") {
            ch_HAPDOS = Channel.fromPath(params.hapdos_files).collect().map{[ params.chr, it ]}
            // ch_HAPDOS.view()
        } else {
            ch_HAPDOS = ch_RUN_EXTRACT_TRACTS_HAPDOS
            // ch_HAPDOS.view()
        }

        if (params.phenolist_file) {
            
            ch_pheno_col_list = Channel.fromPath(params.phenolist_file)
                                    .splitCsv(header: false, sep: "\t")
                                    .map{ row -> row[0]}
            // ch_pheno_col_list.view()

            RUN_TRACTOR(params.output_prefix,
                        ch_HAPDOS,
                        params.phenotype,
                        params.covarcollist,
                        params.regression_method,
                        params.sampleidcol,
                        ch_pheno_col_list,
                        params.chunksize,
                        params.totallines)
            
        } else {
            RUN_TRACTOR(params.output_prefix,
                        ch_HAPDOS,
                        params.phenotype,
                        params.covarcollist,
                        params.regression_method,
                        params.sampleidcol,
                        params.phenocol,
                        params.chunksize,
                        params.totallines)
            // RUN_TRACTOR.out.log.view()
            // RUN_TRACTOR.out.sumstats.view()
        }
    }

}

/* 
 * completion handler
 */
workflow.onComplete {
    log.info ( workflow.success ? "\nWorkflow completed successfully!\n\nPlease check the output directory for results.\n\n" : "\nWorkflow FAILED. Please check the log file.\n\n" )
}

