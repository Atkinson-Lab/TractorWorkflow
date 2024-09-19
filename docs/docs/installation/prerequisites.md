---
layout: default
title: Pre-Requisites
nav_order: 1
parent: Installation
---

# Pre-Requisites

Before diving into installing the necessary software packages, please ensure the following tools and environments are correctly set up. These prerequisites are crucial for the seamless execution of our workflows.

1. [Nextflow](#1-nextflow)
2. [Conda and `py3_tractor` Environment](#2-conda-and-py3_tractor-environment)
3. [`time` command](#3-time-command)

### 1. Nextflow

Our Tractor workflow has been developed using Nextflow due to several reasons. Nextflow is that is interoperable across various batch schedulers (SLURM, PBS, LSF), as well as cloud platforms (AWS, Azure, Google Cloud) making it scalable and reproducible across different environments.

Using Nextflow, we have wrapped several necessary steps into one seamless workflow that users can run without having to check on each steps.

- **Installation**: Follow the detailed instructions available on the [Nextflow official website](https://www.nextflow.io/docs/latest/install.html).
  
- **Dependencies**: Note that its important for users to meet all dependency requirements for Nextflow. For example, Nextflow requires Java v11 or above to be installed. While we've tested our pipeline with **Java v22** and **Nextflow v24.04.4**, we expect recent versions should work just as well. 


### 2. Conda and `py3_tractor` Environment

To manage software dependencies efficiently, we strongly recommend using Conda. This allows you to create isolated environments tailored specifically to our software's requirements.

- **Conda Installation**: If you don't already have Conda installed, you can do so by following the steps outlined in the [Anaconda installation guide](https://docs.anaconda.com/anaconda/install/). This installation provides the foundation for managing all the software dependencies needed for our workflow.

- **Setting Up the `py3_tractor` Environment**:
  - **Step 1**: Clone the Tractor repository from GitHub, which contains all necessary scripts and environment configurations: [Tractor GitHub Repository](https://github.com/Atkinson-Lab/Tractor).
  - **Step 2**: Use the provided YML file in the Tractor repository to create the `py3_tractor` environment. This file contains all the dependencies required to run the Tractor scripts:
    ```bash
    conda env create -f conda_py3_tractor.yml
    ```
  - **Step 3**: Activate the newly created environment:
    ```bash
    conda activate py3_tractor
    ```

  By using this environment, you ensure that all the necessary dependencies for running Tractor scripts are properly installed, avoiding potential conflicts with other software on your system.

### 3. `time` command

The `time` command is a simple yet essential tool in our workflow, used to measure the execution time of each step. Here’s how to ensure it’s available on your system:

- **Verification**: You can quickly check if `time` is installed by running the following command in your terminal:
  ```bash
  which time
  ```
  If installed, this should return a path like `/usr/bin/time`.

- **Purpose**: The `time` command is integral to our workflow as it logs the duration of each step in `.time` files. These logs are valuable for performance tracking and optimization.

## Summary

Once you’ve confirmed that Nextflow, Conda with the `py3_tractor` environment, and the `time` command are all correctly installed and functioning, you’re ready to proceed. Next, head over to the **Software Packages** section, where we’ll cover the specific software required to run our workflows effectively. 
