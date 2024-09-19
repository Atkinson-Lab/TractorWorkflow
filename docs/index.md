---
title: Home
layout: home
nav_order: 1
---

# Tractor GWAS Nextflow (NXF) Workflow

The complex genetic makeup of admixed individuals has historically made it challenging to include them in traditional GWAS studies. Tractor, a GWAS method that accounts for the local ancestral background of alleles in association analyses, addresses this issue, enabling the inclusion of admixed individuals in our research.

To run Tractor, local ancestry estimates are required, which necessitates phasing of the input data. The process is further complicated by the variety of available software tools for Phasing and Local Ancestry Inference, as well as the importance of selecting the appropriate reference datasets.

The Tractor Nextflow (NXF) Workflow is designed to simplify this process for users. Nextflow is a workflow language that operates across various system infrastructures, including a wide range of job schedulers. This portability enhances user-friendliness and lowers the barrier to adoption.

## New Releases

<!-- {: .new }
**Tractor Nextflow (NXF) Workflow: v0.0.0.TBD.** See the [TBD-CHANGELOG](tbd) for details. -->

{: .new }
**Tractor GWAS: v1.4.0.** See the [CHANGELOG](https://atkinson-lab.github.io/TractorWorkflow/docs/docs/CHANGELOG.html) for details.

## Description
The goal of creating a Tractor Nextflow (NXF) workflow was threefold:
* **Lowering the barrier of adoption:** We wanted to streamline the process by simplifying the numerous steps involved while offering support for most commonly used tools for each of the steps.
* **Enable customization:** We wanted to give users the flexibility to customize the workflow, allowing them to run specific steps via Nextflow based on their needs. We have the split the workflow into <u><b>three modules</b></u> which allows for this. Please see [Documentation](https://atkinson-lab.github.io/TractorWorkflow/docs/docs/documentation/documentation_home.html)
* **Tutorial:** We also wanted to provide a clear tutorial of what a Tractor run typically looks like, to guide users through the process

## Citation
The methodology and utility of Tractor are more fully described in our manuscript. If you use Tractor in your research, please cite the following article:

> Atkinson, E.G., Maihofer, A.X., Kanai, M. et al. Tractor uses local ancestry to enable the inclusion of admixed individuals in GWAS and to boost power. Nat Genet 53, 195–204 (2021). [Link](https://doi.org/10.1038/s41588-020-00766-y)

-------------------------

### License
The Tractor program is licensed under the MIT License. You may obtain a copy of the License [here](https://github.com/Atkinson-Lab/Tractor-New/blob/main/LICENSE).

### Contributing
If you would like to contribute by making changes or adding functionalities to our Tractor GWAS or Tractor NXF workflow, please reach out to us via email, or some other means to discuss your proposed changes.

### Thank you!
We are grateful to the Just-The-Docs theme for creating the beautiful Jekyll theme that powers our documentation. For more information, please visit [their webpage](https://just-the-docs.com).

