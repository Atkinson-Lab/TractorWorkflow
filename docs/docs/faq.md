---
layout: home
title: FAQ
nav_order: 4
---

# FAQs

**1. Where can I find helpful resources if I'm new to Nextflow?**

For most users, this documentation provides everything you need to run the Tractor workflow. If you'd like to dive deeper, we recommend checking out [Nextflow's Training](https://training.nextflow.io), which offers valuable links and resources to help you understand workflows and get started.

**2. How do I port this across other infrastructures if I have a different setup than the Linux/SLURM server used in the documentation?**

One of the primary advantages of using Nextflow is its portability across various job schedulers and infrastructure systems, including cloud computing. While it’s challenging to provide examples for all possible variations, we recommend referring to the [Nextflow executors](https://www.nextflow.io/docs/latest/executor.html) for detailed information on how to modify the configuration file to work across different systems. Additionally, you can utilize conda environments or Docker containers to further enhance compatibility.

**3. What LAI tools are currently supported for running Tractor?**

Tractor Nextflow Workflow currently supports several Local Ancestry Inference (LAI) tools, including RFMix2, GNomix, and FLARE. Each of those have independent workflows that users can decide to use.

If you want to experiment with a new LAI tool, you can run the workflow modularly (one module at a time) and test the tool out. Check [here](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html) for modular workflow runs.

**4. If I want to run additional phenotypes on the same dataset I've previously used with Tractor, do I need to rerun the entire pipeline?**

No, you don’t need to rerun the full pipeline. All steps except the final Tractor GWAS regression step only need to be run once for a given genotypic dataset. If you are adding a new phenotype, you can reuse the output from the **`4_extract_tracts`** folder to run Tractor directly.

**5. How much computational resources (CPU, memory) are recommended for each step?**

The computational resources would depend on the size of your dataset and references, but here are some general guidelines:
- **SHAPEIT5 Phasing** (`phase_common`): CPU- and memory-intensive. For large datasets, consider phasing in chunks. `phase_ligate` simply combines these chunks and requires much less resources.
- Local Ancestry Inference (LAI):
	- **GNomix**: Very resource-intensive, as it trains a model before prediction. Runtime varies significantly for large datasets. Takes about 20-30 mins for small test datasets.
	- **RFMix2**: Moderately resource-intensive; runtime ~10 min–1 hr for small test datasets.
	- **FLARE**: Lightweight; much lower CPU and memory requirements.
- **Pre-Tractor step** (`extract_tracts`, `extract_tracts_flare`)
	- Does not support multi-threading, so 1 CPU and reasonable amount of memory should be sufficient.
	- Depending on the dataset, this can be a very time-intensive process.
- **Tractor step**
	- Moderately resource intensive, and supports multi-threading. However, more threads might require larger amounts of memory. A balance between threads and `--chunksize` is recommended.

**6. Are there example datasets I can test before running my own data?**
- Yes, we provide a small test dataset for chr22 [here](https://github.com/Atkinson-Lab/Tractor-tutorial/blob/main/test_data.zip).
	- The README file within the test dataset describes all files.
	- The admixed dataset includes 61 African American individuals from the 1000 Genomes Project, known to be two-way AFR-EUR admixed.
	- Phenotypes and covariates have been simulated, with multiple phenotype files available to test.
	- The haplotype reference panel from SHAPEIT is included for demonstration purposes. For our internal analyses, we use more up-to-date reference panels and recommend using the publicly available TGP-HGDP joint-call dataset if it fits your needs. [Article here](http://dx.doi.org/10.1101/gr.278378.123).

**7. How can I troubleshoot failed jobs or errors in the pipeline?**
1. First, we recommend going through the [Run Readiness Checklist](https://atkinson-lab.github.io/TractorWorkflow/docs/run_readiness_checklist.html), it should cover most of the issues a user might face.
2. Examine log files for any warnings or errors that may indicate the source of the problem.
3. Verify that all tools and dependencies are installed and working correctly.
4. Investigate specific workflow stages:
	- Examine the log files for the stage where the workflow failed.
	- Review reports generated in the `run` directory to understand the results of each step.
	- Access the `work` directories and study the `.command.sh` to make sure the intended code is run and `.command.log` to understand the reason of the error. The actual path to `work` directory is often available in the reports generated in the `run` directory

**8. Can I run the pipeline on a subset of chromosomes or variants?**

Absolutely, the only requirement for the workflow is that files should be split by chromosome.

Note that phasing and LAI performs best when sufficiently long haplotypic information is present. For extremely large datasets, SHAPEIT5 offers the option to phase data in chunks.

**9. Where can I download the reference files (genetic maps, panels, datasets) used in this workflow?**

* **Genomic chunk files for SHAPEIT5:** They are available in the Tractor Workflow repository [here](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/genomic_chunks). Make sure to use the correct chromosome naming convention.
* **Genetic map files for SHAPEIT5:** Available in the SHAPEIT5 repository [here](https://github.com/odelaneau/shapeit5/tree/dev_olivier/resources/maps).
* **Genetic map files for RFMix2/GNomix:** We adapted SHAPEIT5 genetic map files to meet these tools’ requirements. They are available in the Tractor Workflow repository [here](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/genetic_maps).
* **Genetic map files for FLARE:** FLARE uses PLINK-format genetic map files. Described in the FLARE repository [here](https://github.com/browning-lab/flare#required-parameters) with links.
* **Reference panels for LAI:** Sample map files for **2-way AFR–EUR** and **3-way AFR–EUR–AMR** panels, based on the TGP–HGDP joint-call dataset are available [here](https://github.com/Atkinson-Lab/TractorWorkflow/tree/main/resources/lai_reference_panels).
* **TGP–HGDP joint-call dataset:** Released as part of [Koenig et al. 2024](https://genome.cshlp.org/content/34/5/796) in GRCh38 format. We have lifted this dataset to GRCh37 using GATK Picard’s `liftOver` tool and re-phased it using SHAPEIT5 on a set of filtered variants. We are working on making this version publicly available, please reach out if you’re in need of access until these are publicly released.

**11. How do I understand the ouptut files for each step?**

The output files are generated by the tools used in the workflow, and we recommend users go to the original tool's documentation to best understand outputs.
For example, if a user wishes to understand the sumstats columns created by Tractor GWAS in output files, [Tractor’s GitHub](https://github.com/Atkinson-Lab/Tractor/tree/master#output-files-running-tractor) provides explanation for each of the sumstats columns

**13. Which software should I use to view the output summary statistics?**

- we strongly recommend reviewing the output summary statistics in a software that can read the tab-delimited files correctly
- Some softwares (e.g. JMP) may not handle empty values correctly, which can lead to misinterpretation of the results.
- Please note that summary statistics for certain variants within specific ancestries may be absent if that variant was not found within that ancestry background and hence couldn't be regressed.

**14. The output files are very large in size, any recommendations on how I can save ond disk space?**

- **First, review all files (especially log files)** to confirm runs have completed successfully and no warnings/errors were overlooked.
- Here are some recommendations on where space can be saved. **Please note many of these files are symbolically linked, so be sure to delete the original file.**
	- **`1_chunks_phased`**
		- Contains BCF files for phased chunks. These are ligated into `2_chunks_ligated`, which reports switch rate and avg. phase Q (should be >80–90 per [SHAPEIT5 manual](https://odelaneau.github.io/shapeit5/docs/documentation/ligate/)).
		- If results look good, you can safely delete all `*.bcf` and `*.bcf.csi` files, as you already have the ligated VCF files per chromosome in `2_chunks_ligated`.
	- **`3_lai`**
		- Output varies by tool ([docs](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/launching_nxf_workflow.html#outputresults-overview))
			- For **RFMix2/GNomix**, the MSP file provides the local ancestry estimates which are used later.
				- `*.fb.tsv` and `*.sis.tsv` files are often large and can be deleted if not relevant.
			- For **GNomix**, if `gnomix_phase=true` is used, a phase-corrected VCF (same size as the input) will be generated. This is later used for extracting tracts. This file can be compressed.
				- `*_generated_data` and `*_models` directory can usually be deleted unless you plan to reuse the model for future LAI runs.
	- **`4_extract_tracts`**
		- By default, these files are **uncompressed**. If these files are not being actively used, they can be compressed. Generation of these files often take a long time, so we don't recommend deleting them unless you're very certain you won't need them. These files can always be regenerated with the phased VCF and the local ancestry estimates.
		- Optional VCF outputs can also be very large, which can be useful for chromosome painting but is not required for later steps, so they can be deleted.
- **These are general guidelines. Be cautious, especially with large datasets, to avoid deleting files that may be needed later.**

