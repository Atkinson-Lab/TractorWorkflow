---
layout: default
title: Documentation
nav_order: 3
has_children: true
---

# Documentation

Command-line documentation and usage of Tractor NXF Workflow

The **Tractor Nextflow (NXF) Workflow** is designed to perform local ancestry-inferred GWAS using Tractor. This Nextflow pipeline enables users to run workflows in a reproducible manner across multiple computing infrastructures and is compatible with various job schedulers. Additionally, the workflow's portability, along with its support for Docker containers and Conda environments, allows users to easily modify the pipeline to suit their specific needs.

To allow customizability of the Tractor NXF Workflow, we have divided it into **three modules**:

1. **Module 1: Phasing** (using SHAPEIT5)
2. **Module 2: Local Ancestry Inference** (choice of RFMix2, G-Nomix, FLARE)
3. **Module 3: Tractor GWAS**

The complete Tractor workflow executes all modules sequentially, passing the output from each module to the next. However, users can opt to use their own tools or packages that might not be currently supported within the workflow. For instance, if a user prefers a different phasing method instead of SHAPEIT5, they can start from Module 2. Similarly, if local ancestry inference has already been performed, they can begin with Module 3. These modules are independent, allowing users to run them separately if desired.

{: .note }
**What does running this workflow on Linux Server with SLURM Job Scheduler look like?**
<br>
If a user chooses to run the entire pipeline, they can schedule a job that initiates the workflow with all necessary parameters. This will automatically launch the required SLURM jobs for each step: phasing, local ancestry inference, and finally, running Tractor GWAS. Users can configure CPU and memory requirements for each step, as well as any additional SLURM-specific settings, through the NXF config file, which will be detailed later in the documentation.

One of the key advantages of using a Nextflow Workflow is its ability to resume from the last successful step if a specific step fails—whether due to insufficient memory, CPU limitations, or any other error. Users can simply re-run the job with the `-resume` parameter, and the workflow will skip the steps that have already been completed, resuming from where it left off.

{: .warning }
The `-resume` parameter in Nextflow is sensitive. Any modification to directories or files can disrupt the workflow’s ability to resume its run successfully, and the pipeline might begin the run from scratch.







