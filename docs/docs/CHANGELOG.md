---
title: CHANGELOG
layout: default
---

# CHANGELOG

All notable changes to this project are documented in this file.

{: .highlight }
Tractor v1.4.0 is now available [here](https://github.com/Atkinson-Lab/Tractor).

{: .highlight }
Tractor Workflow, that wraps 3 modules (phasing, local ancestry inference, and Tractor GWAS) will be updated [here](https://github.com/Atkinson-Lab/TractorWorkflow).


## TractorWorkflow v0.0.0
* Tractor Workflow will be updated.

## Tractor v1.4.0 (released May 10, 2024)
	* Added support for compressed (gz) hapcount/dosage and phenotype files.
	* Improved file reading efficiency by implementing fread in chunks, mitigating memory errors.
	* Implemented parallel processing for regression, resulting in significant speed improvements with multi-core systems.
	* Enhanced flexibility in organizing phenotype files:
	* Users can specify sample ID column (--sampleidcol), phenotype ID column (--phenocol), and covariate column list (--covarcollist)
	* Updated output summary statistics to include SE and t-val, with column names adjusted to adhere to GWAS standards.
