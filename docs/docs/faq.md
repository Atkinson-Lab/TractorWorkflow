---
layout: home
title: FAQ
nav_order: 4
---

# FAQs

**1. How do I port this across other infrastructures if I have a different setup than the Linux/SLURM server used in the documentation?**

Thank you for your question! One of the primary advantages of using Nextflow is its portability across various job schedulers and infrastructure systems, including cloud computing. While it’s challenging to provide examples for all possible variations, we recommend referring to the [Nextflow executors](https://www.nextflow.io/docs/latest/executor.html) for detailed information on how to modify the configuration file to work across different systems. Additionally, you can utilize conda environments or Docker containers to further enhance compatibility.

**2. Where can I find helpful resources if I'm new to Nextflow?**

If you're new to Nextflow, we recommend checking out [Nextflow's Training](https://training.nextflow.io), which offers valuable links and resources to help you understand workflows and get started.

**3. What do the summary statistic columns created by Tractor GWAS in output files represent?**

The output files are described in detail on [Tractor’s GitHub](https://github.com/Atkinson-Lab/Tractor/tree/master?tab=readme-ov-file#output-files-running-tractor). You can find explanations for the summary statistic columns there.

**4. What LAI tools are currently supported for running Tractor?**

Tractor currently supports several Local Ancestry Inference (LAI) tools, including RFMix2, G-Nomix, and FLARE. Tractor operates in two main steps:  
1. Extracting ancestry-specific tracts using ancestry calls and phased VCF files.
2. Running Tractor GWAS.

If the LAI tool you are using generates an `*.msp` file, you can use `extract_tracts.py` to generate the necessary inputs and then run Tractor GWAS. For FLARE, which outputs a VCF file with both ancestry calls and genotypes, we have created a new script, `extract_tracts_flare.py`, to support this process.

If you want to experiment with a new LAI tool, you can run the workflow modularly (one module at a time) and test the tool out. Check [here](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/modular_workflow_execution.html) for modular workflow runs.

**5. If I want to run additional phenotypes on the same dataset I've previously used with Tractor, do I need to rerun the entire pipeline?**

No, you don’t need to rerun the complete pipeline. The extracted tracts in your output directory, specifically within the **4_extract_tracts** folder, can serve as the input for running additional phenotypes.

**6. Where can I find genomic chunk files for SHAPEIT5?**

We have provided genomic chunk files for the b37 and b38 genomes on Tractor’s GitHub [here](https://github.com/Atkinson-Lab/Tractor/tree/master/resources/genomic_chunks). It's important to note that the chromosome nomenclature (chr1 v/s 1) should be consistent across your input VCF, reference VCF, genomic chunk file, and genetic map files.

**7. Where can I find genetic map files for phasing/LAI?**

For SHAPEIT5, genetic map files are available on SHAPEIT5's GitHub under their [resources](https://github.com/odelaneau/shapeit5/tree/main/resources). Please note that these files need to be reformatted to make them compatible with RFMix2 and G-Nomix requirements. For FLARE, genetic map files in PLINK format are required, as described in [FLARE's README](https://github.com/browning-lab/flare).


