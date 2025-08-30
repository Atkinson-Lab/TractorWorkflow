---
layout: default
title: Launching an NXF Workflow
nav_order: 2
parent: Documentation
---

# Pipeline Summary

The pipeline is designed into three independent modules:
1. **Module 1: Phasing** (using SHAPEIT5)
2. **Module 2: Local Ancestry Inference** (choice of RFMix2, GNomix, FLARE)
3. **Module 3: Tractor GWAS**

This page describes launching Tractor NXF Workflow for the complete pipeline, and will thus run all steps from Module 1 to 3.

-----------------------------------

1. [Input Expectations](#input-expectations)
    1. [Input Data Requirements](#1-input-data-requirements)
    2. [Chromosome-Specific Design](#2-chromosome-specific-design)
    3. [Output Naming](#3-output-naming)
    4. [Dependencies and Installation](#4-dependencies-and-installation)
    5. [Required Reference Files](#5-required-reference-files)
2. [Parameters Documentation](#parameters-documentation)
    * [Complete Workflow Parameters (Module 1, 2 and 3)](#complete-workflow-parameters-module-1-2-and-3)
        * [Initialization inputs](#initialization-inputs)
        * [SHAPEIT5 specific inputs](#shapeit5-specific-inputs)
        * Local Ancestry Inference
            * [RFMix2 specific inputs](#rfmix2-specific-inputs)
            * [GNomix specific inputs](#gnomix-specific-inputs)
            * [FLARE specific inputs](#flare-specific-inputs)
        * [Pre-Tractor-specific inputs](#pre-tractor-specific-inputs)
        * [Tractor-specific inputs](#tractor-specific-inputs)
3. [Launching an NXF Workflow (Assume RFMix2 for LAI)](#launching-an-nxf-workflow-assume-rfmix2-for-lai)
   * [Running a Nextflow Workflow](#running-a-nextflow-workflow)
     * [Example command](#example-command)
     * [Example config file (minimal profile)](#example-config-file-minimal-profile)
     * [What’s happening here?](#whats-happening-here)
   * [Example implementation on SLURM](#example-implementation-on-slurm)
     * [Assumptions](#lets-assume-the-following)
     * [Steps for the code below](#steps-for-the-code-below)
     * [SLURM Job Script Example](#slurm-job-script-example)
   * [Key Parameters in the Nextflow Command](#key-parameters-in-the-nextflow-command)
   * [`config` file for Tractor NXF Workflow](#config-file-for-tractor-nxf-workflow)
4. [Output/Results Overview](#outputresults-overview)
    * [Directory Structure](#directory-structure)

-----------------------------------

# Input Expectations

### 1. Input Data Requirements

* The workflow expects the **input VCF file to be QC’d**. While exact QC steps may vary depending on your dataset, we recommend:
  * Filter for sample/variant missingness
  * Filter for high-quality variants
  * Filter for common variants, i.e. apply a MAF threshold (0.5%–1%) for GWAS
  * Optionally, keep only high-quality SNPs (no indels)
* While SHAPEIT5 can phase rare variants, this workflow is designed to phase **common variants only** using SHAPEIT5's `phase_common`.

### 2. Chromosome-Specific Design

* Many reference files (genetic map files, chunk files) are specific to chromosomes, so our workflow is designed to operate per chromosome. **Please split your QC'd Input VCF file by chromosomes.**
* To analyze all chromosomes, you must **launch separate workflow jobs** for each one.

### 3. Output Naming

* Use the argument `--output_prefix` to specify the desired output name.
* The workflow will automatically append the chromosome number to output prefix before saving, **you do not need to add chr no. to the output prefix**.

### 4. Dependencies and Installation

* Ensure that all required dependencies and tools are **installed, tested, and in your PATH**.
* See [Installation instructions](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html).

### 5. Required Reference Files

Download the following reference files before running the workflow:

* **SHAPEIT5**: [Genomic chunk file](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/genomic_chunks), [Genetic map file](https://github.com/odelaneau/shapeit5/tree/main/resources/maps).
* **RFMix2/GNomix**: [Genetic map file](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/genetic_maps). SHAPEIT5 genetic map files have been adapted to meet requirements of these tools.
* **FLARE**: Genetic map file (Must be in PLINK format, see [FLARE README](https://github.com/browning-lab/flare#required-parameters))
* **Reference panels for LAI:** Sample map files for **2-way AFR–EUR** and **3-way AFR–EUR–AMR** panels, based on the TGP–HGDP joint-call dataset are available [here](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/lai_reference_panels).
* **TGP–HGDP joint-call dataset:** Released as part of [Koenig et al. 2024](https://genome.cshlp.org/content/34/5/796) in GRCh38 format (TBD: where). We have lifted this dataset to GRCh37 using GATK Picard’s `liftOver` tool and re-phased it using SHAPEIT5 on a set of filtered variants. We are working on making this version publicly available, please reach out if you’re in need of access until these are publicly released.


# Parameters Documentation

{: .important }
`false` value as a default in Nextflow worfklow simply implies that specific parameter is not being utilized. These flags might have their own defaults for specific softwares. For example, Tractor step's `--chunksize` default argument is 10000. A false value simply allows the script/software to use its default, if any.

## Complete Workflow Parameters (Module 1, 2 and 3)

### Initialization inputs

| **Flag**  <img width=200/>   | **Required / Optional (Default)**  | **Description**                         |
| ---------------------------- | ---------------------------------- | --------------------------------------- |
| `--outdir`                   | Required         | Path to the output directory. Can be the same for all chromosomes. |
| `--output_prefix`            | Required         | Prefix for naming output files. The chromosome number will be automatically appended before saving.  |
| `--mode`                     | Required         | Workflow mode to run. Use `complete` for the full workflow. Other modes are listed in the [Modular Workflow Execution](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html) section. |
| `--lai_tool`                 | Required (except in `phasing_only` or `tractor_only` mode) | Choice of LAI method: `rfmix2`, `gnomix`, or `flare`. |

### SHAPEIT5 specific inputs

| Flag <img width=145/> | Required/Optional (Default) | Description                     | Original Tool Equivalent Flag |
|-----------------|-------------------|---------------------------------------|--------------------------------|
| `--input_vcf`   | Required          | Path to input VCF file                | `--input`                      |
| `--chunkfile`   | Required          | Path to genomic chunk file            | Each chunk within the chunkfile will be passed to `--region` |
| `--genetic_map` | Required          | Path to SHAPEIT5-compatible Genetic Map File | `--map`                 |
| `--reference_vcf`| Optional         | Path to reference VCF file            | `--reference`                  |
| `--filter_maf`  | Optional          | float value of MAF threshold          | `--filter-maf`                 |

* For links to SHAPEIT5 genomic chunks and genetic map files, please take a look at [Required Reference File](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/launching_nxf_workflow.html#5-required-reference-files) section.

### RFMix2 specific inputs

- RFMix2 repository is available through its [Github link](https://github.com/slowkoni/rfmix) 

| Flag  <img width=165/>   | Required/Optional  (Default) | Description                                  | Original Tool Equivalent Flag |
|--------------------------|-------------------|---------|----------------------------------------------|--------------------------------|
| `--rfmix2_ref_vcf`       | Required         | Path to Reference VCF                        | `--reference-file`             |
| `--rfmix2_sample_map`    | Required         | Path to Sample Map file                      | `--sample-map`                 |
| `--rfmix2_genetic_map`   | Required         | Path to RFMix2-compatible Genetic Map file   | `--genetic-map`                |
| `--reanalyze_ref`        | Optional         | true,false - Whether reference file should be reanalzyed | `--reanalyze-reference`  |
| `--em_iterations`        | Optional         | int value of number of EM iterations         | `-e`                           |
| `--crf_spacing`          | Optional         | CRF spacing (# of SNPs)                      | `-c`                           |
| `--rf_window_size`       | Optional         | RF window size (class estimation window size) | `-s`                          |
| `--node_size`            | Optional         | Terminal node size for RF trees              | `-n`                           |
| `--trees`                | Optional         | # of tree in RF to estimate population class probability | `-t`               |

### GNomix specific inputs

- GNomix repository is available through its [Github link](https://github.com/AI-sandbox/gnomix/) 
- `config.yaml` from this repository is used to define model parameters (`--gnomix_config`).
    - Advanced users may edit this file if they wish to change model parameters.

| Flag  <img width=200/>   | Required/Optional | Description                                  | Original Tool Argument |
|--------------------------|-------------------|---------|----------------------------------------------|--------------------------------|
| `--gnomix_dir`           | Required          | Path to GNomix repository (must contain gnomix.py)     | Path to GNomix's Github repository      |
| `--gnomix_config`        | Required          | Path to GNomix config file (in gnomix directory)       | config.yaml file as found in Github repository   |
| `--gnomix_ref_vcf`       | Required          | Path to Reference VCF                                  | `reference_file`               |
| `--gnomix_sample_map`    | Required          | Path to Sample Map file                                | `sample_map_file`              |
| `--gnomix_genetic_map`   | Required          | Path to GNomix-compatible Genetic Map file             | `genetic_map_file`             |
| `--gnomix_phase`         | Required          | true, false - whether GNomix phasing correction should be performed  | `phase`                 |

{: .note }
> If the user opts for GNomix-based workflow, the model will be trained from scratch before estimates are predicted. i.e. previously generated model cannot be used using this option.
>
> If phasing correction is enabled with --gnomix_phase true, a new VCF with corrected phase is generated. The ancestry estimates correspond to this corrected VCF file, hence this file is subsequently used in the `extract_tracts` step.


### FLARE specific inputs

- FLARE repository is available through its [Github link](https://github.com/browning-lab/flare)
- Defaults for optional arguments will be used as per FLARE's own defaults

| Flag  <img width=240/>   | Required/Optional  (Default)  | Description                                 | Original Tool Equivalent Flag  |
|--------------------------|------------------|---------|------------------------------------------------|--------------------------------|
| `--flare_dir`            | Required         | Path to FLARE directory (must contain flare.jar)         | FLARE's Github repository      |
| `--flare_ref_vcf`        | Required         | Path to Reference VCF                                    | `ref`                          |
| `--flare_sample_map`     | Required         | Path to Sample Map File                                  | `ref-panel`                    |
| `--flare_genetic_map`    | Required         | Path to FLARE-compatible Genetic Map file                | `map`                          |
| `--flare_array`          | Optional (false) | true,false - Is input data a SNP array?                  | `array`                        |
| `--flare_min_maf`        | Optional         | Min. MAF in reference VCF for a marker to be included    | `min-maf`                      |
| `--flare_min_mac`        | Optional         | Min. MAC in reference VCF for a marker to be included    | `min-mac`                      |
| `--flare_probs`          | Optional (false) | true,false - Output posterior ancestry probabilities?    | `probs`                        |
| `--flare_gen`            | Optional         | No. of generations since admxiture                       | `gen`                          |
| `--flare_model`          | Optional         | Path to model parameter file                             | `model`                        |
| `--flare_em`             | Optional (true)  | true,false - Should EM algorithm be used?                | `em`                           |
| `--flare_gt_samples_include`<sup>*</sup> | Optional   | Path to list of samples to be included         | `gt-samples`                   |
| `--flare_gt_samples_exclude`<sup>*</sup> | Optional   | Path to list of samples to be excluded         | `gt-samples=^`                 |
| `--flare_gt_ancestries`        | Optional   | Path to file containing ancestry proportions             | `gt-ancestries`                |
| `--flare_excludedmarkers`      | Optional   | Path to file with markers to be excluded                 | `excludemarkers`               |
| `--flare_seed`           | Optional         | int, sets seed for random number generation              | `seed`                         |

{: .note }
>When the workflow runs FLARE, it automatically applies three optional arguments in the default stage: `--flare_array "false"`, `--flare_probs "false"`, and `--flare_em "true"`. These correspond to FLARE v0.5.3's default arguments.
>
> <sup>\*</sup>Only one of these arguments can be used.

### Pre-Tractor-specific inputs

- Can be `extract_tracts` for RFMix2/GNomix or `extract_tracts_flare` for FLARE

| Flag <img width=120/> | Required/Optional (Default) | Description                        | Original Tool Equivalent Flag |
|-----------------------|-------------------|---------|------------------------------------|-------------------------------|
| `--num_ancs`          | Required          | Number of ancestries in this dataset         | `--num-ancs`                  |
| `--output_vcf`        | Optional          | true,false - Whether ancestry-specific VCF files should be generated.   | `--output-vcf`         |
| `--compress_output`   | Optional          | true,false - Whether output files should be compressed?                 | `--compress-ouptut`    |

### Tractor specific inputs

| Flag <img width=270/> | Required/Optional (Default) | Description                                | Original Tool Equivalent Flag |
|-----------------------|-------------------|---------|--------------------------------------------|-------------------------------|
| `--phenotype`         | Required          | Path to phenotype file                               | `--phenofile`                 |
| `--phenocol`          | Required<sup>*</sup>  | Name of Phenotype column to be used              | `--phenocol`                  |
| `--phenolist_file`    | Required<sup>*</sup>  | Path to list of phenotypes to be analyzed. If provided, `--phenocol` flag is ignored | If provided, each phenotype will be iterated through `--phenocol` argument | 
| `--covarcollist`      | Required          | List of covariates, separated by commas       | `--covarcollist`              |
| `--regression_method` | Required          | linear, logistic                              | `--method`                    |
| `--sampleidcol`       | Optional          | Name of Sample ID column to be used           | `--sampleidcol`               |
| `--chunksize`         | Optional          | Number of variants to process on each thread  | `--chunksize`                 |
| `--totallines`        | Optional          | Total number of variants                      | `--totallines`                |

{: .note }
>By default, the phenotype file must have `IID`/`#IID` as the **sample ID column** and `y` as the **phenotype column**. Use `--sampleidcol` and `--phenocol` to override these.
>
><sup>\*</sup>If user has multiple phenotypes within the same file, user can list them in a new file and pass it with `--phenolist_file` (and skip the `--phenocol` argument).


-----------------------------------


# Launching an NXF Workflow (Assume RFMix2 for LAI)

{: .important }
> Nextflow scripts have a different syntax than normal bash scripts. In Nextflow (which follows groovy), `//` is used for commenting.


## Running a Nextflow Workflow

To run a Nextflow workflow, you need two things:

1. **A main script** (`main.nf`) that defines the workflow. This is provided in the `workflows/` directory in the [TractorWorkflow repository](https://github.com/Atkinson-Lab/TractorWorkflow).
2. **A configuration file** (`nextflow.config`) that specifies resources and execution settings.

### Example command

```bash
nextflow run workflows/main.nf \
    -c workflows/nextflow.config \
    -profile local \
    --outdir /path/to/output/tractor_run1 \
    --output_prefix "output1" \
    --mode "complete" \
    --lai_tool "rfmix2" \
    <add other relevant arguments>
```

### Example config file (minimal profile)

```groovy
// nextflow.config
profiles {
    local {
        process {
            executor = 'local'
            cpus     = 4
            memory   = '16.GB'
            time     = '12h'
        }
    }
}
```

### What’s happening here?

1. Nextflow runs `main.nf`, which contains the main workflow, and will automatically take care of running all necessary jobs (Phasing, LAI, Tractor).

2. The workflow uses a specific `nextflow.config` file that defines resources (CPUs, memory, runtime, etc.) and execution settings. **Every user should adapt this file based on the resources available in their environment.** We discuss config file in detail later in this documentation.

3. The `-profile local` flag tells Nextflow to use the `local` profile defined in the config file.
   * Config files can contain multiple profiles (e.g., `local` for testing, `slurm` for HPC clusters).
   * You can define different profiles for [different executors](https://www.nextflow.io/docs/latest/executor.html) depending on your environment.

4. Additional parameters as [defined above](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/launching_nxf_workflow.html#parameters-documentation) are passed with `--param_name value` (E.g. `--outdir /path/to/output/tractor_run1` or `--lai_tool "rfmix2"`)
   * At minimum, you must provide all **required arguments**; others are optional depending on your use case.

## Example implementation on SLURM

In this section, we provide a more detailed walkthrough of how to run the workflow on a High-Performance Computing (HPC) system with the SLURM job scheduler.

### Let's assume the following:
* We will run the complete workflow, i.e. `--mode "complete"`
* We will perform Local Ancestry Inference (LAI) using RFMix2, i.e. `--lai_tool "rfmix2"`
* The workflow will be run across 22 chromosomes
    * **Since the workflow is chromosome-specific, each chromosome will be run as a separate job in its own `run` directory.**
* Execution will happen on an HPC cluster managed by SLURM.

### Steps for the code below
1. Iterate across all chromosomes
2. Load all required software modules - will vary by systems (e.g. Java, Nextflow, any software/tool dependencies)
3. Create separate run/work directories for each chromosome run
4. Define required and optional parameters (e.g. output prefix, mode, LAI tool)
5. Launch Nextflow workflow (with all necessary arguments)

### SLURM Job Script Example

**We recommend testing this workflow with a [test dataset](https://github.com/Atkinson-Lab/Tractor-tutorial/blob/main/test_data.zip)**, which includes a README describing all the files.

When you are reading to run analyses on your own dataset, please review the [Run Readiness Checklist](https://atkinson-lab.github.io/TractorWorkflow/docs/run_readiness_checklist.html).

```bash
#!/usr/bin/bash
#SBATCH --time=5-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --partition=<ATTN: add-partition-name>
#SBATCH --job-name=launch_nxf_tractor
#SBATCH --output=launch_nxf_tractor_%a_%j.out
#SBATCH --array=1-22

# Step 1: Iterate across all chromosomes
#   #SBATCH --array command will launch 22 independent jobs for each array ID
# Capture the chromosome number from the SLURM array task ID.
chr=${SLURM_ARRAY_TASK_ID}

# Step 2: Load all necessary modules (not required if in PATH)
## We only load java here, but you can load all necessary modules
module load java/jdk-21.0.2
## Print versions (for documentation)
java -version && echo
nextflow info && echo && echo

# ATTN: Update variables and paths in Step 3, 4 and 5

# Step 3: Create separate run/work directories for each run/chromosome
basedir="/path/to/project_dir"
workdir="${basedir}/nxf_runs/work_chr${chr}"                # Work directory for chromosome ${chr}
rundir="${basedir}/nxf_runs/run_chr${chr}"                  # Run directory for chromosome ${chr}

## Create run directories and navigate to them to launch the workflow.
mkdir -p ${rundir}
cd ${rundir}

# Step 4: Define all required and optional variables for each step
workflow_dir="/path/softwares/TractorWorkflow/workflows/"  # Location of the Nextflow workflow
outdir="${basedir}/results1"
output_prefix="output_prefix"
workflow_mode="complete"          # Select any of the modes described here: https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html
lai_tool="rfmix2"                 # not required if "phasing_only" or "tractor_only"

## SHAPEIT5 (Mandatory Arguments)
shapeit5_input_vcf="/path/to/test_data/admixed_cohort/ASW.unphased.vcf.gz"
shapeit5_chunkfile="/path/to/TractorWorkflow/resources/genomic_chunks/chunks_fullchromosome/chunks_chr${chr}.txt"
shapeit5_genetic_map="/path/to/shapeit5/resources/maps/b37/chr${chr}.b37.gmap.gz"

## SHAPEIT5 (Optional Arguments)
# shapeit5_ref_vcf=""
# shapeit5_filter_maf=""

# NOTE: Update LAI-related arguments below to match your chosen LAI tool.  
# NOTE: Mandatory arguments must be provided exactly as described in
#       the Parameters section above
# NOTE: Step 5 in this example shows arguments for RFMix2.  
#       If you are using GNomix or FLARE, replace these with the correct arguments.  
# NOTE: If you need additional (optional) arguments, add them in Step 5 as well.  

## RFMix2 (Mandatory Arguments)
rfmix2_ref_vcf="/path/to/test_data/references/TGP_HGDP_QC_hg19_chr${chr}.vcf.gz"
rfmix2_sample_map="/path/to/test_data/references/YRI_GBR_samplemap.txt"
rfmix2_genetic_map="/path/to/TractorWorkflow/resources/genetic_maps/shapeit5_genetic_map_b37_LAIformat1.txt"

## RFMix2 (Optional Arguments)
# rfmix2_reanalyze_ref=""
# rfmix2_em_iterations=""
# rfmix2_crf_spacing=""
# rfmix2_rf_window_size=""
# rfmix2_node_size=""
# rfmix2_trees=""

## GNomix (Mandatory Arguments)
# gnomix_dir="/path/software/gnomix"
# gnomix_config="${gnomix_dir}/config.yaml"
# gnomix_ref_vcf="/path/to/test_data/references/TGP_HGDP_QC_hg19_chr${chr}.vcf.gz"
# gnomix_sample_map="/path/to/test_data/references/YRI_GBR_samplemap.txt"
# gnomix_genetic_map="/path/to/TractorWorkflow/resources/genetic_maps/shapeit5_genetic_map_b37_LAIformat1.txt"
# gnomix_phase="false"

## FLARE (Mandatory Arguments)
# flare_dir="/path/softwares/flare"
# flare_ref_vcf="/path/to/test_data/references/TGP_HGDP_QC_hg19_chr${chr}.vcf.gz"
# flare_sample_map="/path/to/test_data/references/YRI_GBR_samplemap.txt"
# flare_genetic_map="/path/beagle_genetic_map_files/plink.chr${chr}.GRCh37.map"

# FLARE (Optional Arguments)
# flare_array="false"            # FLARE’s default (v0.5.3) is false (https://github.com/browning-lab/flare)
# flare_min_maf=""
# flare_min_mac=""
# flare_probs="false"            # FLARE’s default (v0.5.3) is false (https://github.com/browning-lab/flare)
# flare_gen=""
# flare_model=""
# flare_em="true"                # FLARE’s default (v0.5.3) is true (https://github.com/browning-lab/flare)
# flare_gt_samples_include=""    # Either flare_gt_samples_include or flare_gt_samples_exclude can be used.
# flare_gt_samples_exclude=""    # Either flare_gt_samples_include or flare_gt_samples_exclude can be used.
# # flare_gt_ancestries=""
# flare_excludedmarkers=""
# flare_seed=""

## Extract Tracts (Mandatory Arguments)
extracts_num_ancs=2

## Extract Tracts (Optional Arguments)
# extracts_output_vcf=""
# extracts_compress=""

## Tractor (Mandatory Arguments)
tractor_phenotype="/path/to/test_data/phenotype/Phe_linear_covars_mod1.txt"
tractor_covarcollist="age,sex"
tractor_regression_method="linear"

## Tractor (one of the following arguments is Mandatory, unless "y" is used as phenocol bc that's default)
# tractor_phenocol=""
tractor_phenolist_file="/path/to/test_data/phenotype/Phe_linear_covars_mod1_phenolist.txt"

## Tractor (Optional Arguments)
# tractor_sampleidcol=""
# tractor_chunksize=""
# tractor_totallines=""


# Step 5: Launch the Nextflow workflow
nextflow run ${workflow_dir}/main.nf \
-c ${workflow_dir}/nextflow.config \
-profile slurm \
-ansi-log false \
-resume \
-work-dir ${workdir} \
--outdir ${outdir} \
--output_prefix ${output_prefix} \
--mode ${workflow_mode} \
--lai_tool ${lai_tool} \
--input_vcf ${shapeit5_input_vcf} \
--chunkfile ${shapeit5_chunkfile} \
--genetic_map ${shapeit5_genetic_map} \
--rfmix2_ref_vcf ${rfmix2_ref_vcf} \
--rfmix2_sample_map ${rfmix2_sample_map} \
--rfmix2_genetic_map ${rfmix2_genetic_map} \
--num_ancs ${extracts_num_ancs} \
--phenotype ${tractor_phenotype} \
--phenolist_file ${tractor_phenolist_file} \
--covarcollist ${tractor_covarcollist} \
--regression_method ${tractor_regression_method}
# ATTN: Optional arguments can be added here. Only mandatory arguments have been included above.

```

**Explanation of SLURM Directives**

Note that the SLURM directives are used to launch the Tractor workflow, which in turn will schedule SLURM jobs. This will have to be configured by the user. Thus, this launch job itself doesn't have large CPU memory requirements.

| Flag (`#SBATCH`)     <img width=250/>              | Description           |
|----------------------------------------------------|----------------------------------------------------------------------|
| `--time=5-00:00:00`                                | Maximum runtime for the job (here: 5 days). Adjust based on pipeline needs. |
| `--mem=4G`                                         | Memory allocated per task; 2 GB may be sufficient.                   |
| `--cpus-per-task=1`                                | Allocates 1 CPU per task.                                            |
| `--partition=<ATTN: add-partition-name>`           | Specifies the partition or queue for job submission.                 |
| `--job-name=launch_nxf_tractor`                    | Custom name for the job.                                             |
| `--output=launch_nxf_tractor_%a_%j.out`            | File to store job logs, `%a`: array index (chr no.) and `%j`: job ID.|
| `--array=1-22`                                     | Runs the job as an array i.e. 22 jobs are launched, with one task per chromosome (1–22).  |

**Explanation of Nextflow directives**

| Flag         <img width=150/>          | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| `-c nextflow.config`   | Path to the config file. Users must edit config files to match system requirements.                  |
| `-profile slurm`       | Use the `slurm` profile from the config file.                |
| `-ansi-log false`      | Turns off colored/ANSI logging (cleaner logs).               |
| `-resume`              | Reuses results if same parameters are used instead of starting over. Useful when a job fails in middle of the workflow. |
| `-work-dir ${workdir}` | Directory for temporary and intermediate files.              |

## Key Parameters in the Nextflow Command

{: .note }
> **The example above only includes mandatory parameters.**
> 
> Optional parameters can be added directly to the `nextflow run` command (in [Step 6](#launching-an-nxf-workflow-assume-rfmix2-for-lai)).<br><br>
> **For example:**
> * For RFMix2: `--reanalyze_ref "true" --em_iterations 1`
> * Tractor GWAS for multiple phenotypes in the phenotype file: `--phenolist_file list_of_phenotypes.txt`
>     * `list_of_phenotypes.txt` -- each phenotype in new line.
> 
> **The choice of optional parameters depends on your analysis goals. We recommend reviewing the documentation for the original tools (SHAPEIT5, RFMix2, Tractor) to select the most appropriate options for your workflow.**

## `config` file for Tractor NXF Workflow

We provide an example configuration file for running Tractor with the **SLURM** job scheduler, which is one of the common schedulers on HPC systems.

If you are using a different scheduler (e.g. PBS, SGE, LSF), please refer to the [Nextflow executor documentation](https://www.nextflow.io/docs/latest/executor.html) for guidance on adapting this configuration to your environment. More information on additional options for config file is available in [config documentation](https://www.nextflow.io/docs/latest/config.html#configuration-file).

{: .important }
> **Reminder:** Nextflow scripts use **Groovy syntax**, not Bash.  
> Nextflow uses `//` for comments instead of `#`.

Below is an example Tractor Nextflow `config` file with descriptions for each section for **SLURM** and **local** modes:
```groovy
// ============================================================
//               NEXTFLOW CONFIGURATION TEMPLATE               
// ============================================================
//
// This file tells Nextflow where to find Java, how to run your jobs,
// and how much CPU, memory, and time to give each step of the workflow.
//
// IMPORTANT: You MUST edit this file to fit your system
// before running the workflow. Everyone’s setup is a little different.
//
// - If you are running on your **laptop**, you can set everything
//   up locally (ignore the SLURM profile).
// - If you are running on an **HPC cluster with SLURM**, you need
//   to update the SLURM section (see below).
//
// If you have a different executor on HPC than SLURM, you can create
// and use a new profile. Reference: https://www.nextflow.io/docs/latest/executor.html


// ---- Java Path ----
// Nextflow needs Java to run.
// If you’re not sure about the path, run: `which java`
// Example output: /path/to/java/jdk-21.0.2/bin/java
NXF_JAVA_HOME = '/path/to/java/jdk-21.0.2/'

// ---- Reports ----
// Nextflow will automatically create these reports in each run directory.
// They are helpful for debugging and seeing how the workflow ran.
dag.enabled = true
report.enabled = true
timeline.enabled = true

trace {
    enabled = true
    // you can add "script" to log the code that was executed. Can be helpful to confirm that the correct code was run for each of the steps.
    fields = 'task_id,hash,native_id,process,tag,name,status,exit,module,container,cpus,time,disk,memory,attempt,submit,start,complete,duration,realtime,queue,%cpu,%mem,rss,vmem,peak_rss,peak_vmem,rchar,wchar,syscr,syscw,read_bytes,write_bytes,vol_ctxt,inv_ctxt,env,workdir,scratch,error_action'
}

// ===========================================================
// PROFILES
// ===========================================================
//
// A "profile" is a set of rules for where and how jobs run for each step.
// 
// You can make your own profile if needed. For example:
//   - local (laptop/desktop)
//   - slurm (HPC cluster)
//
// To use a profile, run:
//   nextflow run main.nf -profile slurm
//
// The example below is for SLURM. If you don’t use SLURM,
// you can either delete this or copy it to make your own "local" profile.
// ===========================================================

// ATTN: User must edit all sections below, and uncomment certain code as required.

profiles {

    // profile: slurm
    slurm {
        // Use Conda to manage dependencies (recommended).
        // Set this to your own Conda path.
        conda {
            enabled = true
            cacheDir = '/path/anaconda3/envs'
        }
        process {
            // Tell Nextflow to use SLURM as the job scheduler.
            executor = 'SLURM'

            // ===========================================================
            // EXAMPLES FOR DIFFERENT TOOLS / STEPS
            //
            // IMPORTANT:
            // - You must set cpus, memory, time, and queue to match 
            //   what your cluster allows.
            //
            // - "withLabel" means the settings apply to that step.
            //    - Phasing: shapeit5, shapeit5_ligate
            //    - LAI: rfmix2, gnomix or flare
            //    - Pre-Tractor: extract_tracts (for rfmix2,gnomix); extract_tracts_flare (for flare)
            //    - Tractor: run_tractor
            //
            // - Different tools may require different software dependencies.
            //   These can be managed with Conda environments. You can specify
            //   the path to the environment for each step if needed.
            //
            // - You may also define an error handling strategy (see the 
            //   run_tractor example below).
            // ===========================================================

            // Module 1: Phasing
            withLabel: shapeit5 {
                // conda = ''                          // Path to conda environment to use. Uncomment for use.
                cpus           = 4                     // e.g. 4 CPUs
                memory         = '16.GB'               // e.g. 16 GB RAM
                queue          = 'partition-name-here' // Replace with your SLURM partition names
                time           = '12h'                 // e.g. 12 hours. For 2 days, you can use '2d'
                // Can provide any additional cluster arguments using clusterOptions
                // Check out: https://www.nextflow.io/docs/latest/executor.html#slurm
                // Example:
                // clusterOptions = '--exclude=<partition>'
            }

            // Module 1: Phasing
            withLabel: shapeit5_ligate {
                // conda = ''
                cpus           = 1
                memory         = '10.GB'
                queue          = 'partition-name-here'
                time           = '1h'
                // clusterOptions = ''
            }

            // Module 2: LAI w/ RFMix2
            withLabel: rfmix2 {
                // conda = ''
                cpus           = 4
                memory         = '16.GB'
                queue          = 'partition-name-here'
                time           = '1d'
                // clusterOptions = ''
            }

            // Module 2: LAI w/ GNomix
            withLabel: gnomix {
                // conda = '/home/username/anaconda3/envs/py3_gnomix'
                cpus           = 8
                memory         = '32.GB'
                queue          = 'partition-name-here'
                time           = '1d'
                // clusterOptions = ''
            }

            // Module 2: LAI w/ FLARE
            withLabel: flare {
                // conda = ''
                cpus           = 4
                memory         = '16.GB'
                queue          = 'partition-name-here'
                time           = '12h'
                // clusterOptions = ''
            }

            // Module 3: Pre-Tractor
            withLabel: extract_tracts {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = 1
                memory         = '10.GB'
                queue          = 'partition-name-here'
                time           = ''
                // clusterOptions = ''
            }

            // Module 3: Pre-Tractor (for FLARE)
            withLabel: extract_tracts_flare {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = 1
                memory         = '10.GB'
                queue          = 'partition-name-here'
                time           = ''
                // clusterOptions = ''
            }

            // Module 3: Tractor
            withLabel: run_tractor {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = { 4     * task.attempt }      // retry with more CPUs, based on errorStrategy
                memory         = { 20.GB * task.attempt }      // retry with more RAM, based on errorStrategy
                queue          = 'partition-name-here'
                time           = ''
                // clusterOptions = ''
                // errorStrategy  = 'retry'
                errorStrategy  = {task.attempt <= 2 ? 'retry' : 'finish'}
                maxRetries     = 3
            }
        }
    }

    // profile: local
    local {
        conda {
            enabled  = true
            cacheDir = '/path/to/your/anaconda3/envs'   // ATTN: update this
        }
        process {
            // Runs locally
            executor = 'local'

            // ATTN: Update resources for all steps (based on your local resources)
            //       Reference: https://www.nextflow.io/docs/latest/executor.html#local

            // Module 1: Phasing
            withLabel: shapeit5 {
                // conda = ''                          // Path to conda environmnet, update to use
                cpus           = 4                     // e.g. 4 CPUs
                memory         = '16.GB'               // e.g. 16 GB RAM
                time           = '12h'                 // e.g. 12 hours. Use '2d' for 2 days.
            }
            // Module 1: Phasing
            withLabel: shapeit5_ligate {
                // conda = ''
                cpus           = 1
                memory         = '10.GB'
            }
            // Module 2: LAI w/ RFMix2
            withLabel: rfmix2 {
                // conda = ''
                cpus           = 4
                memory         = '16.GB'
            }
            // Module 2: LAI w/ GNomix
            withLabel: gnomix {
                // conda = '/home/username/anaconda3/envs/py3_gnomix'
                cpus           = 4
                memory         = '16.GB'
            }
            // Module 2: LAI w/ FLARE
            withLabel: flare {
                // conda = ''
                cpus           = 4
                memory         = '16.GB'
            }
            // Module 3: Pre-Tractor
            withLabel: extract_tracts {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = 1
                memory         = '10.GB'
            }
            // Module 3: Pre-Tractor (for FLARE)
            withLabel: extract_tracts_flare {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = 1
                memory         = '10.GB'
            }
            // Module 3: Tractor
            withLabel: run_tractor {
                // conda = '/home/username/anaconda3/envs/py3_tractor'
                cpus           = { 4     * task.attempt }      // retry with more CPUs, based on errorStrategy
                memory         = { 10.GB * task.attempt }      // retry with more RAM, based on errorStrategy
                errorStrategy  = {task.attempt <= 1 ? 'retry' : 'finish'}
                maxRetries     = 2
            }
        }
    }

}
```

{: .important }
> **Helpful Nextflow Documentation**
> 1. Execution Environments
>      - [Using conda](https://www.nextflow.io/docs/latest/process.html#conda)
>      - [Using docker/containers](https://www.nextflow.io/docs/latest/process.html#container)
>      - [SLURM executor](https://www.nextflow.io/docs/latest/executor.html#slurm)
>      - [Other supported executors](https://www.nextflow.io/docs/latest/process.html#executor)
> 2. Process Directives
>      * [Overview of Directives](https://www.nextflow.io/docs/stable/process.html#directives)
>      * [cpus](https://www.nextflow.io/docs/stable/process.html#cpus), [memory](https://www.nextflow.io/docs/stable/process.html#memory), [time](https://www.nextflow.io/docs/stable/process.html#time), [queue](https://www.nextflow.io/docs/stable/process.html#queue) (partition in SLURM)
> 3. Advanced
>      * [Dynamic computing resources](https://www.nextflow.io/docs/stable/process.html#dynamic-computing-resources)

-----------------------------------

# Output/Results Overview

Once the Tractor NXF Workflow completes running, the output/results directory will be organized as follows. Most of these files are symbolic links to files within the `work` directory, except for the final summary statistics in the `5_run_tractor` directory, which are the definitive output files that the user would need.

The directory structure provided below assumes the workflow has iterated through chr 1 to 22, with two ancestries in the dataset.

## Directory Structure
1. **1_chunks_phased**
2. **2_chunks_ligated**
3. **3_lai**
4. **4_extract_tracts**
5. **5_run_tractor**

{: .note }
> In all directory listings, [1-22] indicates chromosome numbers 1 to 22.
> 
> `*.log` files capture the standard output and error messages from each run. We strongly recommended reviewing these logs to ensure that no warnings or errors occurred.

**1_chunks_phased**
* SHAPEIT5 supports phasing chromosomes in smaller genomic segments ("chunks"), which can later be ligated into full chromosomes.
* The `--chunkfile` parameter specifies the coordinates for chunking, it's designed such that successive chunks of data has overlapping genetic regions.
* Phasing can be performed on an entire chromosome at once or split into multiple chunks. For large datasets, chunk-based phasing is strongly recommended for efficiency.
* This directory contains the chunk-level phased outputs (`.bcf`), its index and log files.

```tree
    1_chunks_phased
    ├── output_prefix_[1-22].chunk_0.shapeit5_common.bcf[.csi]
    ├── output_prefix_[1-22].chunk_0.shapeit5_common.log
    ├── output_prefix_[1-22].chunk_1.shapeit5_common.bcf[.csi]
    ├── output_prefix_[1-22].chunk_1.shapeit5_common.log
    ├── ...
    ├── output_prefix_[1-22].chunk_n.shapeit5_common.bcf[.csi]
    └── output_prefix_[1-22].chunk_n.shapeit5_common.log
```

**2_chunks_ligated**
* Once data is phased in chunks, these chunks are ligated (merged) to reconstruct complete chromosomes.
* This directory contains the ligated phased data for each chromosome in `vcf.gz` format, its index and log files.
* The chunking scheme (`--chunkfile`) includes overlapping regions between adjacent chunks. The log files report the switch rate, which measures the consistency of phasing across these overlaps. Values above 80–90% are typically expected and indicate good phasing quality.
    * Please see [SHAPEIT5 ligate documentation](https://odelaneau.github.io/shapeit5/docs/documentation/ligate/)

```tree
    2_chunks_ligated
    ├── list_ligate.[1-22].txt
    ├── output_prefix_[1-22].shapeit5_common_ligate.vcf.gz[.csi]
    └── output_prefix_[1-22].shapeit5_common_ligate.log
```

**3_lai**
* The contents of the directory depend on the LAI tool used.
* **RFMix2 and GNomix**: The `.msp` files contain the ancestry estimates. This along with the phased VCFs from the previous step will be used for the next step, `extract_tracts`. In case, `--gnomix_phase true` is used, which corrects the VCF, we'll use this VCF file along with the ancestry estimates for the next step.
* **FLARE**: Ancestry estimates are annotated directly within the VCFs alongside genotype and saved as `*.anc.vcf.gz`. Since genotype and ancestry estimates are within the same file, it is sufficient for the `extract_tracts_flare` step.

*Output for RFMix2:*
```tree
    3_lai
    ├── output_prefix_[1-22].fb.tsv
    ├── output_prefix_[1-22].msp.tsv
    ├── output_prefix_[1-22].rfmix.Q
    ├── output_prefix_[1-22].sis.tsv
    └── output_prefix_[1-22].rfmix2.log
```

*Output for GNomix:*
```tree
    3_lai
    ├── output_prefix_[1-22].msp
    ├── output_prefix_[1-22].fb
    ├── output_prefix_[1-22]_config.yaml        # Model parameters used
    ├── output_prefix_[1-22]_generated_data
    ├── output_prefix_[1-22]_models
    ├── output_prefix_[1-22]_phased.vcf         # Generated only if gnomix_phase="true"
    └── output_prefix_[1-22].log
```

*Output for FLARE:*
```tree
    3_lai
    ├── output_prefix_[1-22].anc.vcf.gz
    ├── output_prefix_[1-22].flare.log
    ├── output_prefix_[1-22].log
    └── output_prefix_[1-22].model
```

**4_extract_tracts**
* This step extracts ancestry-specific tracts using the ancestry calls and genotypic data.
* **Two files per ancestry** are generated: `.dosage.txt` for dosage information and `.hapcount.txt` for haplotype counts.
* These files can be reused as starting points for analyzing additional phenotypes in the same dataset with Tractor GWAS, avoiding the need to repeat earlier steps like phasing and LAI.
* The `*.vcf` files will only be generated if `--output_vcf "true"` is used.
* Following output file structure assumes 2-way admixture, but additional files be generated if more than 2-way admixed.

```tree
    4_extract_tracts
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc0.dosage.txt
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc0.hapcount.txt
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc0.vcf
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc1.dosage.txt
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc1.hapcount.txt
    ├── output_prefix_[1-22].shapeit5_common_ligate.anc1.vcf
    └── output_prefix_[1-22].extract_tracts.log
```

**5_run_tractor**
* Tractor GWAS summary statistics are generated for the phenotypes specified in the `phenolist_file`, covering all chromosomes.
* `samples_excluded_from_phenotype.txt` is generated only if samples present in the phenotype not present in the hapcount/dosage files.

```tree
    5_run_tractor
    ├── output_prefix_pheno1_[1-22]_sumstats.txt
    ├── output_prefix_pheno1_[1-22].run_tractor.log
    └── samples_excluded_from_phenotype.txt
```
