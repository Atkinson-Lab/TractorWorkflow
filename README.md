# Tractor Workflow: A Nextflow Workflow for Tractor GWAS

A Nextflow pipeline for running [Tractor GWAS](https://github.com/Atkinson-Lab/Tractor) on your cohort data with streamlined setup and execution.

The workflow is organized into three main modules:
- **Module 1:** **Phasing** (using SHAPEIT5)
- **Module 2:** **Local Ancestry Inference** (RFMix2, GNomix, or FLARE)
- **Module 3:** **Tractor GWAS**

-------------------------------------

# Table of Contents

1. [Documentation](#documentation)
2. [Test Run](#test-run)
    1. [Clone the Workflow Repository](#1-clone-the-workflow-repository)
    2. [Download the Test Dataset](#2-download-the-test-dataset)
    3. [Configure and Run the Test Workflow](#3-configure-and-run-the-test-workflow)
    4. [Additional Information](#4-additional-information)
4. [Resources](#resources)
5. [License](#license)

-------------------------------------

## Documentation
**Full documentation (installation instructions, available parameters, and examples) is available here:** <br>
[https://atkinson-lab.github.io/TractorWorkflow/](https://atkinson-lab.github.io/TractorWorkflow/)
<br>

## Test Run

Before starting, ensure all necessary tools and dependencies are installed as described in the [installation instructions of documentation](https://atkinson-lab.github.io/TractorWorkflow/docs/installation/installation_home.html).

### 1. Clone the Workflow Repository
```bash
git clone https://github.com/Atkinson-Lab/TractorWorkflow.git
cd TractorWorkflow
```

### 2. Download the Test Dataset
```bash
wget https://github.com/Atkinson-Lab/Tractor-tutorial/raw/refs/heads/main/test_data.zip
unzip test_data.zip
```

The **README file within the `test_data`** folder explains the contents. 
```
test_data/
├── 0_README.txt
├── admixed_cohort
│   ├── ASW.unphased.vcf.gz                   # Admixed cohort (can serve as input QC'd VCF)
│   └── ASW.unphased.vcf.gz.csi
├── phenotype
│   ├── Phe_logistic.txt                      # Phenotype file for logistic regression
│   ├── Phe_linear.txt                        # Phenotype file (no covariates)
│   ├── Phe_linear_covars.txt                 # Phenotype file with covariates
│   ├── Phe_linear_covars_mod1.txt            # Phenotype file with covariates and 3 phenotypes
│   └── Phe_linear_covars_mod1_phenolist.txt  # List of phenotypes to process (for Phe_linear_covars_mod1.txt)
└── references
    ├── chr22.b37.gmap.gz                     # Genetic map for SHAPEIT5
    ├── chr22.genetic_map.modified.txt        # Genetic map for RFMix2/GNomix (adapted from SHAPEIT5 genetic maps)
    ├── chunks_chr22.txt                      # Genomic chunks file, used for SHAPEIT5 phasing
    ├── TGP_HGDP_QC_hg19_chr22.vcf.gz         # Reference File for LAI (and optionally phasing)
    ├── TGP_HGDP_QC_hg19_chr22.vcf.gz.csi
    └── YRI_GBR_samplemap.txt                 # Sample map corresponding to aforementioned reference file
```

### 3. Configure and Run the Test Workflow

The **`workflows/nextflow.config`** file is used by Nextflow to define workflow behavior, including the computational resources allocated to each step within the workflow. This allows you to control the **CPU cores**, **memory**, and other runtime parameters for individual steps in the workflow.

1. Open the `local` profile in `workflows/nextflow.config` and adjust the resource settings to match your system. For example, for **`shapeit5` step**, you can set:

```groovy
process {
    executor = 'local'

    // Module 1: Phasing
    withLabel: shapeit5 {
        // conda = ''                           // Path to conda environmnet, uncomment to use
        cpus           = 4                      // Number of CPU cores for this process
        memory         = '16.GB'                // Maximum memory allocated
        time           = '12h'                  // Optional: max runtime for the process
    }
    ...
```
**Each step in the workflow can have its own `cpus` and `memory` values, allowing Nextflow to efficiently manage resources. Do this for all steps.**

2. Once the config is set, run the workflow with the test dataset:

```bash
nextflow run workflows/main.nf \
    -c workflows/nextflow.config \
    -profile "local" \
    --outdir results1 \
    --output_prefix "output1" \
    --mode "complete" \
    --lai_tool "rfmix2" \
    --input_vcf test_data/admixed_cohort/ASW.unphased.vcf.gz \
    --chunkfile test_data/references/chunks_chr22.txt \
    --genetic_map test_data/references/chr22.b37.gmap.gz \
    --rfmix2_ref_vcf test_data/references/TGP_HGDP_QC_hg19_chr22.vcf.gz \
    --rfmix2_sample_map test_data/references/YRI_GBR_samplemap.txt \
    --rfmix2_genetic_map test_data/references/chr22.genetic_map.modified.txt \
    --num_ancs 2 \
    --phenotype test_data/phenotype/Phe_linear_covars_mod1.txt \
    --phenolist_file test_data/phenotype/Phe_linear_covars_mod1_phenolist.txt \
    --covarcollist "age,sex" \
    --sampleidcol renamed_sampleid \
    --regression_method "linear"
```

The workflow will execute each step using the resources specified in the config file.<br>
**Results will be generated in the `results1` directory.**

### 4. Additional Information

**Here's a link to the [full documentation](https://atkinson-lab.github.io/TractorWorkflow/) for complete usage and advanced examples.**

The example shown above is a minimal test run, using only the mandatory arguments and RFMix2 for local ancestry inference (LAI). However, users can customize the following:
* Users can add additional parameters. A full list of supported parameters is available in the [Parameters documentation](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/launching_nxf_workflow.html#parameters-documentation).
  * For example, users can use a different LAI tool (gnomix,flare).
  * or use a different mode, i.e. run only specific steps within the workflow. More in [Modular Workflow Execution](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html)
* [Run Readiness Checklist](https://atkinson-lab.github.io/TractorWorkflow/docs/run_readiness_checklist.html) and [FAQs](https://atkinson-lab.github.io/TractorWorkflow/docs/faq.html) are available in the documentation for troubleshooting as well.

## Resources

Available in the **`resources/`** directory on this repository:

1. **genomic_chunks** – Predefined genomic chunk files for GRCh37 and GRCh38 (used by SHAPEIT5).
2. **genetic_maps** – [SHAPEIT5 Genetic Map](https://github.com/odelaneau/shapeit5/tree/main/resources/maps) files reformatted for RFMix2/GNomix.
3. **lai_reference_panels** – Optimized reference panels for local ancestry inference for 2-way(AFR–EUR and 3-way AFR–EUR–AMR individuals from the [TGP-HGDP joint-call dataset](https://genome.cshlp.org/content/34/5/796).

## Citation

If you use this workflow, please cite:
> Shah, N. N., Tan, T., Honorato-Mauer, J., Lin, Y.-S., Maihofer, A. X., Zai, C. C., Santoro, M., Nievergelt, C. M., & Atkinson, E. G. (2025). Tractor Workflow Pipeline: A Scalable Nextflow Framework for Local Ancestry-Aware Genome-Wide Association Studies. Cold Spring Harbor Laboratory. https://doi.org/10.1101/2025.09.02.673402


## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.


