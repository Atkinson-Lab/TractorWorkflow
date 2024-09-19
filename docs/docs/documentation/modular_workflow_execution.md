---
layout: default
title: Modular Workflow Execution
nav_order: 7
parent: Documentation
---

## TBD: Modular Workflow Execution
- Running individual modules:
  - Starting from Module 2 if data is already phased.
  - Skipping to specific stages if local ancestry estimates are available.
- Sequential Execution: Running the workflow one module at a time.


The pipeline is designed into three independent modules:
1. **Module 1: Phasing** (using SHAPEIT5)
2. **Module 2: Local Ancestry Inference** (using RFMix2, G-Nomix, FLARE)
3. **Module 3: Tractor GWAS**

The whole workflow can be run together, as we discussed in [Launching an NXF Workflow](https://atkinson-lab.github.io/TractorWorkflow/docs/docs/documentation/launching_nxf_workflow.html), but these modules can also be run indepdendently or two at a time.

Here we discuss the scripts to be able to independently run these modules:

**This section will soon be updated.**