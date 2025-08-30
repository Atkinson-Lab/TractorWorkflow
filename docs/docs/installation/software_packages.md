---
layout: default
title: Software Packages
nav_order: 2
parent: Installation
---

# Software Packages

This page provides a comprehensive overview of the installation processes for various software packages required for Nextflow workflow. Running Tractor GWAS requires one to perform phasing, local ancestry inference, running an extract ancestry-specific tract step, and finally running Tractor GWAS. Each section covers specific tools, detailing their installation, configuration, and verification to guarantee that all dependencies are met and the tools function as expected.

1. [Phasing using SHAPEIT5](#1-phasing-using-shapeit5)
2. [Local Ancestry Inference](#2-local-ancestry-inference)
   - [RFMix2](#1-rfmix2)
   - [GNomix](#2-g-nomix)
   - [FLARE](#3-flare)
3. [Tractor (via Tractor GitHub)](#3-tractor-via-tractor-github)


## 1. Phasing using SHAPEIT5

This workflow utilizes SHAPEIT5 for phasing and requires it to be installed on the system where the workflow will run. While there are multiple installation methods available—such as building from source, downloading static binaries, or using Docker images—we recommend using the Static Binaries and adding them to your system’s `PATH` for simplicity.

### SHAPEIT5 dependencies

- Ensure SHAPEIT5 dependencies (AVX2, GCC > 4.4) and required libraries (HTSLib, Boost, etc.) are installed on your system and in `PATH`. More details are provided in the [SHAPEIT5 documentation](https://odelaneau.github.io/shapeit5/docs/installation/build_from_source).
{ .warning}
SHAPEIT5 requires AVX2 which is only available on x86-64 CPUs. Macs with Apple Silicon (ARM-based) do not support AVX2, so SHAPEIT5 cannot run natively on them. For this reason, we recommend using a Linux-based x86-64 system for testing and running this workflow.

### Installation Steps

1. **Download SHAPEIT5 Static Binaries**  
   The latest version (as of Aug 2025) is v5.1.1. Follow these steps to install:

   ```bash
   cd /path/to/software_downloads/
   git clone https://github.com/odelaneau/shapeit5.git
   cd shapeit5/static_bins/
   wget https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/phase_common_static
   wget https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/ligate_static
   ```
2. **Make the binaries executable**  
   To be able to run shapeit5 from the command line, run:

   ```bash
   chmod +x phase_common_static ligate_static
   ```
   
2. **Add to PATH**  
   Add the downloaded binaries to your `PATH` by running:

   ```bash
   echo 'export PATH="/path/to/software_downloads/shapeit5/static_bins:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify Installation**  
   Ensure the tools are correctly installed by running:

   ```bash
   cd
   which phase_common_static
   which ligate_static
   ```

   Expected output:

   ```
   /path/to/software_downloads/shapeit5/static_bins/phase_common_static
   /path/to/software_downloads/shapeit5/static_bins/ligate_static
   ```

5. **Test the Tools**  
   Confirm that the tools work by running:

   ```bash
   phase_common_static --help
   ligate_static --help
   ```

### Alternative Installation Option

- You can [build from source and compile](https://odelaneau.github.io/shapeit5/docs/installation/build_from_source), and have these tools added to the `PATH`
- You can also use the [Docker image](https://odelaneau.github.io/shapeit5/docs/installation/docker) for this workflow, which can be configured in the Nextflow pipeline's config file.
- Visit the [SHAPEIT5 Documentation](https://odelaneau.github.io/shapeit5/) for detailed installation instructions.

--------------------------

## 2. Local Ancestry Inference


We support a range of Local Ancestry Inference (LAI) tools, including many of the most widely used ones. Selecting the right tool for calculating local ancestry estimates tailored to your dataset is essential. Accurate local ancestry estimates are vital for Tractor GWAS, as they enable the identification of ancestry-specific hits. Therefore, it's important to carefully choose both the LAI tool and the reference dataset.

Currently, we support the following LAI tools: RFMix2, GNomix, and FLARE. Be aware that each tool has different input requirements, often in different formats. We recommend users familiarize themselves with each tool thoroughly before attempting to run workflows.

Below are the basic installation instructions for these tools. Please note that these instructions are meant to help you get started, but you should always refer to the original documentation of each tool to ensure all dependencies are properly installed.


### 1. RFMix2

1. Visit the [RFMix2 GitHub page](https://github.com/slowkoni/rfmix/tree/master) for the additional information and **ensure all dependencies are installed** (e.g., `bcftools`, etc.).
2. Refer to the [RFMix2 Manual](https://github.com/slowkoni/rfmix/blob/master/MANUAL.md) for detailed usage instructions.

To install RFMix2:

```bash
cd /path/to/software_downloads/
git clone https://github.com/slowkoni/rfmix.git

# Follow the instructions as described on GitHub (https://github.com/slowkoni/rfmix)
autoreconf --force --install # Creates the configure script and its dependencies
./configure                  # Generates the Makefile
make
```

To add RFMix2 to your PATH:
```bash
echo 'export PATH="/path/to/software_downloads/rfmix:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Test the installation:
```bash
cd
which rfmix
```

Expected output:
```
/path/to/software_downloads/rfmix/rfmix
```

To verify that RFMix2 is working correctly, run:

```bash
rfmix --help
```

### 2. GNomix

1. Visit the [GNomix GitHub repository](https://github.com/AI-sandbox/gnomix) for detailed installation instructions.
2. We recommend creating a dedicated conda environment (E.g. `py3_gnomix`) to install all required dependencies for GNomix.
   * The path to this environment can be provided in the Nextflow workflow [configuration file](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/launching_nxf_workflow.html#config-file-for-tractor-nxf-workflow)
4. **Verify Installation**  
   Ensure GNomix is correctly installed by running:
   ```bash
   cd /path/to/gnomix
   python3 gnomix.py --help
   ```

Expected output:
```
Error: Incorrect number of arguments.
Usage when training a model from scratch:
   $ python3 gnomix.py <query_file> <output_basename> <chr_nr> <phase> <genetic_map_file> <reference_file> <sample_map_file>
Usage when using a pre-trained model:
   $ python3 gnomix.py <query_file> <output_basename> <chr_nr> <phase> <path_to_model>
```

{: .warning }
Note that GNomix requires high CPU and memory as it trains it model from scratch for this workflow.


### 3. FLARE

1. Visit the [FLARE GitHub repository](https://github.com/browning-lab/flare) for detailed installation instructions.
2. **Verify Installation**  
   Ensure FLARE is correctly installed by running:
   ```bash
   cd /path/to/flare
   java -jar flare.jar
   ```

Expected output:
```
flare.jar  [ version 0.3.0, 20Oct22.2a6 ]
Syntax: java -jar flare.jar [arguments in format: parameter=value]
Required Parameters:
  ref=<VCF file with phased reference genotypes>       (required)
  ref-panel=<file with reference sample to panel map>  (required)
  gt=<VCF file with phased genotypes to be analyzed>   (required)
  map=<PLINK map file with cM units>                   (required)
  out=<output file prefix>                             (required)
...
```

--------------------------

## 3. Tractor (via Tractor GitHub)

To set up Tractor, follow these instructions:

* For more details, please refer to the [Tractor GitHub](https://github.com/Atkinson-Lab/Tractor) page.

1. **Clone the Tractor GitHub Repository**

   ```bash
   cd /path/to/software_downloads/
   git clone https://github.com/Atkinson-Lab/Tractor.git
   ```

2. **Create and Activate the Conda Environment**

   ```bash
   cd Tractor/
   conda env create -f conda_py3_tractor.yml
   conda activate py3_tractor
   ```

3. **Add Tractor Scripts to PATH**

   To ensure you can run Tractor scripts from any directory, add them to your `PATH`.
   Replace `/path/to/software_downloads` with the actual path of the repository in the following command:

   ```bash
   echo 'export PATH="/path/to/software_downloads/Tractor/scripts:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify the Installation**

   You can check if the scripts are accessible by running:

   ```bash
   cd
   which extract_tracts.py
   which run_tractor.R
   ```

   To verify that Tractor scripts are working correctly, test out a few scripts:

   ```bash
   extract_tracts.py --help
   extract_tracts_flare.py --help
   run_tractor.R --help
   ```

   If everything is set up correctly, these commands will display the help information for each script.


# Next Steps

Once all the necessary pre-requisites and softwares are installed and tested successfully, you are ready to run the Nextflow workflow pipeline.

Check out the [Documentation](https://atkinson-lab.github.io/TractorWorkflow/docs/documentation/documentation_home.html) page to learn more about launching a Nextflow job.

