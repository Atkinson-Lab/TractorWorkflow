---
layout: home
title: Run Readiness Checklist
nav_order: 4
---

## Run Readiness Checklist for Tractor Workflow

1. **Input VCF**: Make sure VCF is QC’d and retains only common variants.

2. **File formats and indexing**: Confirm all VCFs are bgzipped and indexed.

3. **Split by chromosome**: Make sure input files are split by chromosome (the workflow id designed to run per chromosome).

4. **Reference build**: Verify all inputs (VCFs, references, maps) use the same genome build (e.g., GRCh38 vs GRCh37).

5. **Chromosome nomenclature**: Ensure chromosome numbering is consistent across all files (`chr1, chr2...` vs `1, 2...`).
	- At least check within your input VCF, any references that are used, chunk files used for phasing and genetic map files used for LAI

6. **Verify software setup**: Confirm all required dependencies are installed and accessible in your PATH. See [Installation Page](https://atkinson-lab.github.io/TractorWorkflow/docs/installation/installation_home.html)

7. **Config file**: Double-check resources, conda environments, and file paths are correctly specified. Ensure the configuration matches the executor you plan to use (e.g. SLURM, PBS, SGE). Documentation on possible [executors here](https://www.nextflow.io/docs/latest/executor.html)

8. **Disk space & runtime availability**: Make sure you have enough memory, storage, and walltime for your dataset size, and appropriately configure config file. We offer some general insights on how to think about computational resource allocation for each step -- check our [FAQs](https://atkinson-lab.github.io/TractorWorkflow/docs/faq.html)

9. **Mandatory parameters**: Ensure all required workflow parameters are set and input files exist.

10. **Optional parameters**: Only set optional parameters you need; remove extras to avoid errors (especially with Java in case of FLARE).
	- Confirm addition of required optional parameters to the `nextflow run` command
	- If an optional paramter that is undefined is used in `nextflow run` command, it might lead to an error.

11. **Genetic map files**: Confirm you are using the right genetic map files for phasing and LAI.
	- Different tools require diffrent formats
	- SHAPEIT5's [genetic map files](https://github.com/odelaneau/shapeit5/tree/main/resources/maps) can be adapted to RFMix2 and GNomix format
	- FLARE requires PLINK-format files. See [here](https://github.com/browning-lab/flare#required-parameters)

12. **Run a test**: Highly recommend running a test before scaling to the full dataset. You can download a [test dataset here](https://github.com/Atkinson-Lab/Tractor-tutorial/blob/main/test_data.zip).



