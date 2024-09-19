---
layout: default
title: Software Packages
nav_order: 1
parent: Installation
---

# Software Packages

This page provides a comprehensive overview of the installation processes for various software packages required for Nextflow workflow. Running Tractor GWAS requires one to perform phasing, local ancestry inference, running an extract ancestry-specific tract step, and finally running Tractor GWAS. Each section covers specific tools, detailing their installation, configuration, and verification to guarantee that all dependencies are met and the tools function as expected.

1. [Phasing using SHAPEIT5](#1-phasing-using-shapeit5)
2. [Local Ancestry Inference](#2-local-ancestry-inference)
   - [RFMix2](#1-rfmix2)
   - [G-Nomix](#2-g-nomix)
   - [FLARE](#3-flare)
3. [Tractor (via Tractor GitHub)](#3-tractor-via-tractor-github)


## 1. Phasing using SHAPEIT5

This workflow utilizes SHAPEIT 5 for phasing and requires it to be installed on the system where the workflow will run. While there are multiple installation methods available—such as building from source, downloading static binaries, or using Docker images—we recommend using the Static Binaries and adding them to your system’s `PATH` for simplicity.

### SHAPEIT 5 dependencies

- Ensure SHAPEIT 5 dependencies (AVX2, GCC > 4.4, bcftools) and required libraries (HTSLib, Boost, etc.) are installed on your system. More details are available in the [documentation](https://odelaneau.github.io/shapeit5/docs/installation/build_from_source).

### Installation Steps

1. **Download SHAPEIT 5 Static Binaries**  
   The latest version (as of August 15, 2024) is v5.1.1. Follow these steps to install:

   ```bash
   cd /path/to/software_downloads/
   git clone https://github.com/odelaneau/shapeit5.git
   cd shapeit5/static_bins/
   wget https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/phase_common_static
   wget https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/ligate_static
   ```

2. **Add to PATH**  
   Add the downloaded binaries to your `PATH` by running:

   ```bash
   echo 'export PATH="/path/to/software_downloads/shapeit5/static_bins:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Verify Installation**  
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

4. **Test the Tools**  
   Confirm that the tools work by running:

   ```bash
   phase_common_static -h
   ligate_static -h
   ```

### Alternative Installation Option

- You can [build from source and compile](https://odelaneau.github.io/shapeit5/docs/installation/build_from_source), and have these tools added to the `PATH`
- You can also use the [Docker image](https://odelaneau.github.io/shapeit5/docs/installation/docker) for this workflow, which can be configured in the Nextflow pipeline's config file.

--------------------------

## 2. Local Ancestry Inference


We support a range of Local Ancestry Inference (LAI) tools, including many of the most widely used ones. Selecting the right tool for calculating local ancestry estimates tailored to your dataset is essential. Accurate local ancestry estimates are vital for Tractor GWAS, as they enable the identification of ancestry-specific hits. Therefore, it's important to carefully choose both the LAI tool and the reference dataset.

Currently, we support the following LAI tools: RFMix2, G-Nomix, and FLARE. Be aware that each tool has different input requirements, often in different formats. We recommend users familiarize themselves with each tool thoroughly before attempting to run workflows.

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

### 2. G-Nomix

1. Visit the [G-Nomix GitHub page](https://github.com/AI-sandbox/gnomix) for installation instructions and dependency requirements.
2. Ensure the environment with all necessary dependencies is active when running G-Nomix jobs. If using a specific Conda environment, be sure to specify it in the Nextflow config file (see the Documentation section).
3. Note that G-Nomix requires significant CPU and memory resources due to its model pre-training phase.
4. Make sure to add G-Nomix executable to your PATH.

### 3. FLARE

1. FLARE is a recently published tool, and is known for its speed and memory efficiency.
2. Installation instructions and requirements can be found [here](https://github.com/browning-lab/flare).
3. Ensure the appropriate environment with all necessary dependencies (e.g. Java) is active when running FLARE jobs.
4. Add the FLARE executable to your PATH.

--------------------------

## 3. Tractor (via Tractor GitHub)

To set up Tractor, follow these instructions:

* For more details, please refer to the [Tractor GitHub](https://github.com/Atkinson-Lab/Tractor) page.

1. **Clone the Tractor GitHub Repository**

   Navigate to your desired directory and clone the Tractor repository:

   ```bash
   cd /path/to/software_downloads/
   git clone https://github.com/Atkinson-Lab/Tractor.git
   ```

2. **Create and Activate the Conda Environment**

   Change to the Tractor directory, then create and activate the Conda environment:

   ```bash
   cd Tractor/
   conda env create -f conda_py3_tractor.yml
   conda activate py3_tractor
   ```

3. **Add Tractor Scripts to PATH**

   To ensure you can run Tractor scripts from any directory, add them to your `PATH`. Use the following commands:

   ```bash
   echo 'export PATH="/path/to/software_downloads/Tractor/scripts:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

   Replace `/path/to/software_downloads` with the actual path where you cloned the repository.

4. **Verify the Installation**

   You can check if the scripts are accessible by running:

   ```bash
   cd
   which extract_tracts.py
   which run_tractor.R
   ```

   To confirm that the installation works and see the help instructions, use:

   ```bash
   extract_tracts.py --help
   extract_tracts_flare.py --help
   run_tractor.R --help
   ```

   If everything is set up correctly, these commands will display the help information for each script.


### Summary

Once all the necessary pre-requisites and softwares are installed and tested successfully, you are ready to run the Nextflow workflow pipeline.
Check out the Documentation page for instructions on how to get started.

