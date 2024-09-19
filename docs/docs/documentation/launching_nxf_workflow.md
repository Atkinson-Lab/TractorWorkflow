---
layout: default
title: Launching an NXF Workflow
nav_order: 2
parent: Documentation
---

# Pipeline Summary

The pipeline is designed into three independent modules:
1. **Module 1: Phasing** (using SHAPEIT5)
2. **Module 2: Local Ancestry Inference** (using RFMix2, G-Nomix, FLARE)
3. **Module 3: Tractor GWAS**

This page describes launching Tractor NXF Workflow for the complete pipeline, and will thus run all steps from Module 1 to 3.

-----------------

1. [Input Expectations](#input-expectations)
2. [Parameters Documentation](#parameters-documentation)
    * [Complete Workflow Parameters (Module 1, 2 and 3) -- Here we assume Module 2 with RFMix2](#complete-workflow-parameters-module-1-2-and-3--here-we-assume-module-2-with-rfmix2)
        * [SHAPEIT5 specific inputs](#shapeit5-specific-inputs)
        * [RFMix2 specific inputs](#rfmix2-specific-inputs)
        * [Tractor-specific inputs (extract_tracts.py, run_tractor.R)](#tractor-specific-inputs-extract_tracts.py-run_tractor.r)
3. [Launching an NXF Workflow](#launching-an-nxf-workflow)
    * [Explanation of SLURM Directives](#explanation-of-slurm-directives)
    * [Nextflow directives](#nextflow-directives)
    * [Key Parameters in the Nextflow Command](#key-parameters-in-the-nextflow-command)
    * [`config` file for Tractor NXF Workflow](#config-file-for-tractor-nxf-workflow)
4. [Output/Results Overview](#outputresults-overview)
    * [Directory Structure](#directory-structure)

-----------------

# Input Expectations

Assuming that the workflow is being initiated from Module 1, we expect the **input VCF file to be adequately QC'd**. While the specific QC steps may vary depending on your dataset, **we recommend filtering for sample/variant missingness, maintaing high-quality variants, SNPs only, and applying a reasonable MAF threshold (0.5% - 1%)** as this is a GWAS. Although SHAPEIT5 can phase rare variants, this workflow is designed to phase only common variants using the `phase_common` software.

Additionally, **we recommend splitting the input VCF files by chromosome, as the current workflow is designed to analyze one chromosome at a time**. Therefore, if you need to run analyses for all 22 or 23 chromosomes, **you will need to launch separate workflow jobs for each chromosome.**

# Parameters Documentation

## Complete Workflow Parameters (Module 1, 2 and 3) -- Here we assume Module 2 with RFMix2

* `--outdir`: Output directory for all results.
* `--logdir`: Log directory for all run logs, including `*.time` files and standard output.

### SHAPEIT5 specific inputs

| Flag <img width=145/> | Required/Optional (Default) | Description                     | Original Tool Equivalent Flag |
|-----------------|-------------------|---------------------------------------|--------------------------------|
| `--input_vcf`   | Required          | Path to input VCF file                | `--input`                      |
| `--chunkfile`   | Required          | Path to genomic chunk file            | Each chunk within the chunkfile will be passed to `--region` |
| `--genetic_map` | Required          | Path to SHAPEIT5-compatible Genetic Map File | `--map` |
| `--output_prefix`| Required         | Output Prefix to be used for naming output VCF file | |
| `--reference_vcf`| Optional (false) | Path to reference VCF file            | `--reference`                  |
| `--filter_maf`  | Optional (false)  | float value of MAF threshold          | `--filter-maf`                 |

* SHAPEIT-5 compatible genomics chunks for `--chunkfile` can be found [here](https://github.com/Atkinson-Lab/Tractor/tree/master/resources/genomic_chunks) for GRCh37 and GRCh38.
* SHAPEIT-5 compatible genetic map files can be found [here](https://github.com/odelaneau/shapeit5/tree/main/resources/maps)
    * These genetic map files can be modified to be made compatible with RFMix2 or G-Nomix.

### RFMix2 specific inputs

| Flag  <img width=165/>   | Required/Optional  (Default) | Description                                  | Original Tool Equivalent Flag |
|--------------------------|-------------------|---------|----------------------------------------------|--------------------------------|
| `--rfmix2_ref_vcf`       | Required         | Path to Reference VCF                        | `--reference-file`             |
| `--rfmix2_sample_map`    | Required         | Path to Sample Map file                      | `--sample-map`                 |
| `--rfmix2_genetic_map`   | Required         | Path to RFMix2-compatible Genetic Map file   | `--genetic-map`                |
| `--reanalyze_ref`        | Optional (false) | true, false                                  | `--reanalyze-reference`        |
| `--em_iterations`        | Optional (false) | int value of number of EM iterations         | `-e`                           |
| `--crf_spacing`          | Optional (false) | CRF spacing (# of SNPs)                      | `-c`                           |
| `--rf_window_size`       | Optional (false) | RF window size (class estimation window size) | `-s`                          |
| `--node_size`            | Optional (false) | Terminal node size for RF trees              | `-n`                           |
| `--trees`                | Optional (false) | # of tree in RF to estimate population class probability | `-t`               |

### Tractor-specific inputs (extract_tracts.py, run_tractor.R)**

| Flag <img width=270/>    | Required/Optional (Default) | Description                                   | Original Tool Equivalent Flag |
|-----------------------|-------------------|---------|-----------------------------------------------|--------------------------------|
| `--num_ancs`          | Required          | Number of ancestries in this dataset         | `--num_ancs`                   |
| `--phenotype`         | Required          | Path to phenotype file                       | `--phenofile`                  |
| `--phenolist_file`    | Optional (false)  | Path to list of phenotypes to be analyzed. If provided, `--phenocol` flag is ignored | If provided, each phenotype will be iterated through `--phenocol` argument |
| `--covarcollist`      | Required          | List of covariates, separated by commas       | `--covarcollist`               |
| `--regression_method` | Required          | linear, logistic                             | `--method`                     |
| `--sampleidcol`       | Optional (false)  | Name of Sample ID column to be used           | `--sampleidcol`                |
| `--phenocol`          | Optional (false)  | Name of Phenotype column to be used           | `--phenocol`                   |
| `--chunksize`         | Optional (false)  | Number of variants to process on each thread | `--chunksize`                  |
| `--totallines`        | Optional (false)  | Total number of variants                      | `--totallines`                 |


{: .note }
`false` value as a default in Nextflow worfklow simply implies that specific parameter is not being utilized. These flags might have their own defaults for specific softwares. For example, `run_tractor.R`'s `--chunksize` default argument is 10000. A false value implies we don't use that flag, which allows the script/software to use its default.


# Launching an NXF Workflow

For simplicity purposes, let's assume we plan to launch this Nextflow workflow on a Linux server with SLURM job scheduler, across 22 chromosomes.
1. We need to launch Nextflow workflow for each chromosome in its own directory (discussed above)
2. Load all necessary modules
3. Create separate run/work directories for each run/chromosome
4. Launch Nextflow workflow


```bash
#!/usr/bin/bash
#SBATCH --partition=<add-partition-name>
#SBATCH --qos=debug
#SBATCH --time=5-00:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=launch_mod123
#SBATCH --output=nxf_runs/logs/launch_mod123_s5_r2_tr_v01_%a_%j.out
#SBATCH --array=1-22

# Capture the chromosome number from the SLURM array task ID
chr=${SLURM_ARRAY_TASK_ID}

# Step 1: Load necessary modules (not required if Java in PATH)
module load java/jdk-21.0.2

# Step 2: Print versions (for documentation purposes)
java -version && echo
nextflow info && echo && echo

# Step 3: Define directories (user must edit this)
basedir="/path/to/project_dir"
workdir="${basedir}/nxf_runs/work_chr${chr}"                # Work directory for chromosome ${chr}
rundir="${basedir}/nxf_runs/run_chr${chr}"                  # Run directory for chromosome ${chr}
workflow_dir="/path/softwares/tractor-workflow/workflows/"  # Location of the Nextflow workflow

# Step 4: Create run directories and navigate to them to launch the workflow.
mkdir -p ${rundir}
cd ${rundir}

# Step 5: Define necessary variables

## Basic variables (Mandatory Arguments)
outdir="${basedir}/results1"
logdir="${basedir}/results1/logs"
output_prefix="output_prefix"

## SHAPEIT5 (Mandatory Arguments)
shapeit5_input_vcf="/path/input_QC.vcf.gz"
shapeit5_chunkfile="/path/chunks_chr${chr}.txt"
shapeit5_genetic_map="/path/maps/b37/chr${chr}.b37.gmap.gz"

## SHAPEIT5 (Optional Arguments)
shapeit5_ref_vcf="/path/reference/reference_chr${chr}_phased.vcf.gz"
shapeit5_filter_maf=0.005

## RFMix2 (Mandatory Arguments)
rfmix2_ref_vcf="/path/reference/reference_rfmix2_chr${chr}_phased.vcf.gz"
rfmix2_sample_map="/path/reference/TGP_HGDP_2way_AFR_EUR.txt"
rfmix2_genetic_map="/path/maps/b37/shapeit5_genetic_map_LAIformat1.txt"

## RFMix2 (Optional Arguments)
rfmix2_reanalyze_ref="true"
rfmix2_em_iterations=1
# rfmix2_crf_spacing=""
# rfmix2_rf_window_size=""
# rfmix2_node_size=""
# rfmix2_trees=""

## Tractor (Mandatory Arguments)
tractor_num_ancs=2
tractor_phenotype="/path/phenotype_files/pheno_irnt.txt"   # Contains eid (sample ID), covariates, and 3 phenotype columns - pheno1, pheno2, pheno3
tractor_covarcollist="age,sex,PC1,PC2,PC3,PC4,PC5"
tractor_regression_method="linear"

## Tractor (one of the following arguments is Mandatory)
# tractor_phenocol=""
tractor_phenolist_file="/path/pheno_irnt_phenolist.txt"

## Tractor (Optional Arguments)
tractor_sampleidcol="eid"
tractor_chunksize=20000
# tractor_totallines=""

# Step 6: Launch the Nextflow workflow
nextflow run ${workflow_dir}/mod123_s5_r2_tr_v01.nf \
    -c ${workflow_dir}/nextflow_slurm_taco_v01.config \
    -ansi-log false \
    -resume \
    -work-dir ${workdir} \
    --outdir ${outdir} \
    --logdir ${logdir} \
    --input_vcf ${shapeit5_input_vcf} \
    --chunkfile ${shapeit5_chunkfile} \
    --genetic_map ${shapeit5_genetic_map} \
    --output_prefix ${output_prefix} \
    --reference_vcf ${shapeit5_ref_vcf} \
    --filter_maf ${shapeit5_filter_maf} \
    --rfmix2_ref_vcf ${rfmix2_ref_vcf} \
    --rfmix2_sample_map ${rfmix2_sample_map} \
    --rfmix2_genetic_map ${rfmix2_genetic_map} \
    --reanalyze_ref ${rfmix2_reanalyze_ref} \
    --em_iterations ${rfmix2_em_iterations} \
    --num_ancs ${tractor_num_ancs} \
    --phenotype ${tractor_phenotype} \
    --phenolist_file ${tractor_phenolist_file} \
    --covarcollist ${tractor_covarcollist} \
    --regression_method ${tractor_regression_method} \
    --sampleidcol ${tractor_sampleidcol} \
    --chunksize ${tractor_chunksize}

```

## Explanation of SLURM Directives

Note that the SLURM directives are used to launch the Tractor workflow, which in turn will schedule SLURM jobs. Thus, this launch job itself doesn't have large CPU memory requirements.

| Flag (`#SBATCH`)                                   | Description           |
|----------------------------------------------------|----------------------------------------------------------------------|
| `--partition=<add-partition-name>`                 | Specifies the partition or queue for job submission.                 |
| `--time=5-00:00:00`                                | Sets a 5-day time limit. Consider the total pipeline runtime, including potential PENDING time before jobs start running.  |
| `--mem=4G`                                         | Allocates 4GB of memory (2GB may also suffice).                      |
| `--cpus-per-task=1`                                | Allocates 1 CPU per task.                                            |
| `--job-name=launch_mod123`                         | Assigns a name to the job.                                           |
| `--output=nxf_runs/logs/launch_mod123_%a_%j.out`   | Specifies the output file for job logs, with `%a` as the array index (chromosome number) and `%j` as the job ID. |
| `--array=1-22`                                     | Runs the job as an array with tasks for chromosomes 1 through 22.    |


## Nextflow directives

| Flag                                        | Description                                                                                                           |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `-c ${workflow_dir}/nextflow_slurm_taco_v01.config` | Explicitly specifies the config file to use. Modification of the config file will be discussed later in the documentation. |
| `-ansi-log false`                           | Disables ANSI console logging. It is highly recommended to set this to false.                                          |
| `-resume`                                   | Allows Nextflow to pre-cache already run jobs. Even if a job is not run, it can be included in the workflow.            |
| `-work-dir ${workdir}`                      | Specifies the work directory for Nextflow to store intermediate files.                                                 |


## Key Parameters in the Nextflow Command

The parameters used are described in the [Parameters Documentation](#parameters-documentation) above.

<!-- | Flag   <img width=140/>       | Description                                                                                          |
|-------------------------------|------------------------------------------------------------------------------------------------------|
| `--outdir`                    | Directory where results/output files will be saved.                                                  |
| `--logdir`                    | Directory for saving log files.                                                                      |
| `--input_vcf`                 | Path to the QC'd input VCF file.                                                                     |
| `--chunkfile`                 | Chunks for phasing; each chunk is phased and then ligated.                                           |
| `--genetic_map`               | Path to SHAPEIT5-compatible genetic map files.                                                       |
| `--reference_vcf`             | (Optional) Reference VCF file for phasing.                                                           |
| `--filter_maf`                | (Optional) Minimum MAF filter for SHAPEIT5 to filter SNPs.                                           |
| `--rfmix2_ref_vcf`            | Reference VCF file for RFMix2.                                                                       |
| `--rfmix2_sample_map`         | Path to sample map file for RFMix2.                                                                  |
| `--rfmix2_genetic_map`        | Path to RFMix2-compatible genetic map file.                                                          |
| `--reanalyze_ref`             | (Optional) Whether to reanalyze the reference for RFMix2.                                            |
| `--em_iterations`             | (Optional) Number of EM iterations.                                                                  |
| `--num_ancs`                  | Known number of ancestries in the dataset for extract_tracts.py.                                     |
| `--phenotype`                 | Phenotype file for GWAS analysis (should include sample ID, covariates, and 1 or more phenotype columns).|
| `--phenolist_file`            | (Optional) List of phenotypes to run Tractor on, if more than one phenotype is analyzed.             |
| `--covarcollist`              | Covariates for analysis; these columns should exist in the `--phenotype` file.                       |
| `--regression_method`         | Method of GWAS regression.                                                                           |
| `--sampleidcol "eid"`         | (Optional) Sample ID column to use.                                                                  |
| `--chunksize 20000`           | (Optional) Number of variants to process at once for each thread.                                    |
 -->

{: .note }
> In the above example, following optional parameters **were used:**
> * `--reference_vcf`
> * `--filter_maf`
> * `--reanalyze_ref`
> * `--em_iterations`
> * `--phenolist_file` 
> * `--sampleidcol`
> * `--chunksize`
>
> And the following optional parameters **were not used:**
> * `--crf_spacing`
> * `--rf_window_size`
> * `--node_size`
> * `--trees`
> * `--phenocol`: Not required since `--phenolist_file` was provided
> * `--totallines`
>
> Which optional parameters to use or not use depends on your dataset and the analyses you are trying to run. We recommend familiarizing yourselves with the original tools, and identifying the best set of parameters for the run.

## `config` file for Tractor NXF Workflow

An example Tractor NXF `config` file for SLURM should look like this:
```groovy
// Recommended: Set path to Java to NXF_JAVA_HOME variable
NXF_JAVA_HOME = '/share/apps/java/jdk-21.0.2/'

// Create several reports - report, timeline, DAG and trace report for all runs
// These reports will be created and saved in the run directories.
dag.enabled = true
report.enabled = true
timeline.enabled = true
trace {
    enabled = true
    // fields = 'task_id,hash,native_id,process,tag,name,status,exit,module,container,cpus,time,disk,memory,attempt,submit,start,complete,duration,realtime,queue,%cpu,%mem,rss,vmem,peak_rss,peak_vmem,rchar,wchar,syscr,syscw,read_bytes,write_bytes,vol_ctxt,inv_ctxt,env,workdir,script,scratch,error_action'
    fields = 'task_id,hash,native_id,process,tag,name,status,exit,module,container,cpus,time,disk,memory,attempt,submit,start,complete,duration,realtime,queue,%cpu,%mem,rss,vmem,peak_rss,peak_vmem,rchar,wchar,syscr,syscw,read_bytes,write_bytes,vol_ctxt,inv_ctxt,env,workdir,scratch,error_action'
}


// Activate conda environment and provide conda environment directory
// **User must edit this**
conda {
    enabled = true
    cacheDir = '/home/username/anaconda3/envs'
}

// Provide all SLURM specifications here
// **User must edit this**
process {
    executor = 'SLURM'
    withLabel: shapeit5 {
        cpus           = 8
        memory         = '32.GB'
        queue          = 'partition-name-here'
        time           = '4d'
        // clusterOptions = ''     // can be used to provide options for SLURM that are not otherwise supported by Nextflow.
    }
    withLabel: shapeit5_ligate {
        cpus           = 4
        memory         = '16.GB'
        queue          = 'partition-name-here'
        time           = '1h'
        clusterOptions = '--exclude=partition-m00'
    }
    withLabel: rfmix2 {
        cpus           = 16
        memory         = '64.GB'
        queue          = 'partition-name-here'
        time           = '3d'
        // clusterOptions = ''
    }
    withLabel: extract_tracts {
        cpus           = 1
        memory         = '10.GB'
        queue          = 'partition-name-here'
        time           = '3d'
        // clusterOptions = ''
    }
    withLabel: run_tractor {
        cpus           = { 4     * task.attempt }
        memory         = { 20.GB * task.attempt }
        queue          = 'partition-name-here'
        time           = '12h'
        // clusterOptions = ''
        // errorStrategy  = 'retry'
        errorStrategy  = {task.attempt <= 3 ? 'retry' : 'ignore'}
        maxRetries     = 3
    }
}
```

{: .important }
> **Helpful Documentation Links for Nextflow**
> 1. [conda](https://www.nextflow.io/docs/latest/process.html#conda)
> 2. [docker](https://www.nextflow.io/docs/latest/process.html#container)
> 3. [SLURM](https://www.nextflow.io/docs/latest/executor.html#slurm)
> 4. [Other supported executors](https://www.nextflow.io/docs/latest/process.html#executor)
> 5. [Directives](https://www.nextflow.io/docs/stable/process.html#directives)
>       * [cpus](https://www.nextflow.io/docs/stable/process.html#cpus)
>       * [memory](https://www.nextflow.io/docs/stable/process.html#memory)
>       * [time](https://www.nextflow.io/docs/stable/process.html#time)
>       * [queue](https://www.nextflow.io/docs/stable/process.html#queue) (equivalent to partition on SLURM)
> 6. [Dynamic computing resources](https://www.nextflow.io/docs/stable/process.html#dynamic-computing-resources)

# Output/Results Overview

Once Tractor NXF Workflow completes running, the output/results directory will be organized as follows. Most of these files are symbolic links to files within the `work` directory, except for the final summary statistics in the `5_run_tractor` directory, which are the definitive output files that the user would need.

The directory structure provided below assumes the workflow has iterated through chr 1 to 22, with two ancestries in the dataset.

## Directory Structure

**1_chunks_phased**
* SHAPEIT5 has the capability to phase input data in smaller segments, or "chunks," and then ligate these chunks together.
* The `--chunkfile` argument is used to reference the genomic chunk file, which defines how the data is split for phasing.
* You can phase each chromosome in one (entire chromosome) or multiple chunks.
* This directory contains the phased data organized by chunks, along with their corresponding index files.

```tree
    1_chunks_phased
    ├── output_prefix_1.chunk_0.shapeit5_common.bcf[.csi]
    ├── output_prefix_1.chunk_1.shapeit5_common.bcf[.csi]
    ├── output_prefix_1.chunk_2.shapeit5_common.bcf[.csi]
    ├── output_prefix_1.chunk_3.shapeit5_common.bcf[.csi]
    ├── ...
    └── output_prefix_22.chunk_0.shapeit5_common.bcf[.csi]
```

**2_chunks_ligated**
* After SHAPEIT5 phases the data in chunks, these chunks are ligated (joined) by chromosome.
* The directory contains the phased data for each chromosome in `vcf.gz` format, along with their corresponding index files.

```tree
    2_chunks_ligated
    ├── output_prefix_1.shapeit5_common_ligate.vcf.gz[.csi]
    ├── ...
    └── output_prefix_22.shapeit5_common_ligate.vcf.gz[.csi]
```

**3_lai_rfmix2**
* This step performs RFMix2-based LAI on the phased data from the `2_chunks_ligated` directory.
* For each chromosome, four output files are generated:
  * `*.msp.tsv`: Contains the ancestry calls.
  * `*.rfmix.Q`: Provides the global ancestry proportions for that chromosome.

```tree
    3_lai_rfmix2
    ├── output_prefix_1.fb.tsv
    ├── output_prefix_1.msp.tsv
    ├── output_prefix_1.rfmix.Q
    ├── output_prefix_1.sis.tsv
    ├── ...
    ├── output_prefix_22.fb.tsv
    ├── output_prefix_22.msp.tsv
    ├── output_prefix_22.rfmix.Q
    └── output_prefix_22.sis.tsv
```

**4_extract_tracts**
* This step extracts ancestry-specific tracts based on the ancestry calls from `3_lai_rfmix2` using the phased data from `2_chunks_ligated`.
* Two files per ancestry are generated: `.dosage.txt` for dosage information and `.hapcount.txt` for haplotype counts.
* If additional phenotypes require Tractor GWAS, these files can be used as starting points, avoiding the need to repeat phasing and LAI steps.

```tree
    4_extract_tracts
    ├── output_prefix_1.shapeit5_common_ligate.anc0.dosage.txt
    ├── output_prefix_1.shapeit5_common_ligate.anc0.hapcount.txt
    ├── output_prefix_1.shapeit5_common_ligate.anc1.dosage.txt
    ├── output_prefix_1.shapeit5_common_ligate.anc1.hapcount.txt
    ├── ...
    ├── output_prefix_22.shapeit5_common_ligate.anc0.dosage.txt
    ├── output_prefix_22.shapeit5_common_ligate.anc0.hapcount.txt
    ├── output_prefix_22.shapeit5_common_ligate.anc1.dosage.txt
    └── output_prefix_22.shapeit5_common_ligate.anc1.hapcount.txt
```

**5_run_tractor**
* Tractor GWAS summary statistics are generated for the phenotypes specified in the `phenolist_file`, covering all chromosomes.

```tree
    5_run_tractor
    ├── output_prefix_pheno1_1_sumstats.txt
    ├── output_prefix_pheno1_2_sumstats.txt
    ├── ...
    ├── output_prefix_pheno1_22_sumstats.txt
    ├── ...
    ├── ...
    ├── output_prefix_pheno3_1_sumstats.txt
    ├── output_prefix_pheno3_2_sumstats.txt
    ├── ...
    └── output_prefix_pheno3_22_sumstats.txt
```

**logs**
* Logs for all aforementioned runs can be found in the `logs/` directory.

<!-- logs
├── chunks
│   └── output_prefix_1.chunk_0.shapeit5_common.[log|time]
├── ligate
│   ├── list_ligate.1.txt
│   ├── output_prefix_1.shapeit5_common_ligate.log
│   └── output_prefix_1.shapeit5_common_ligate.[log|time]
├── rfmix2
│   └── output_prefix_1.rfmix2.time
├── extract_tracts
│   └── output_prefix_1.extract_tracts.log
└── tractor
    ├── output_prefix_pheno1_1.run_tractor.[log|time]
    ├── output_prefix_pheno2_1.run_tractor.[log|time]
    └── output_prefix_pheno3_1.run_tractor.[log|time] -->