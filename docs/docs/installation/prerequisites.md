---
layout: default
title: Pre-Requisites
nav_order: 1
parent: Installation
---

# Pre-Requisites

Before diving into installing the necessary software packages, please ensure the following tools and environments are correctly set up.

1. [Nextflow](#1-nextflow)
2. [Conda](#2-conda)

### 1. Nextflow

Our Tractor workflow has been developed using Nextflow due to its scalability and interoperability various platforms (AWS, Azure, Google Cloud), making data analyses harmonized and reproducible across research labs.

Using Nextflow, we have wrapped several necessary steps into one seamless workflow that users can run without having to check on each steps.

- **Installation**: Follow the detailed instructions available on the [Nextflow official website](https://www.nextflow.io/docs/latest/install.html#installation).
  
- **Dependencies**: Note that its important for users to meet all dependency requirements for Nextflow. For example, Nextflow requires Java v11 or above to be installed. While we've tested our pipeline with **Java v22** and **Nextflow v24.04.4**, we expect recent versions should work just as well. 

### 2. Conda

To manage software dependencies efficiently, we strongly recommend using Conda. This allows you to create isolated environments tailored specifically to our software's requirements.

- **Conda Installation**: If you don't already have Conda installed, you can do so by following the steps outlined in the [Anaconda installation guide](https://docs.anaconda.com/anaconda/install/). This installation provides the foundation for managing all the software dependencies needed for our workflow.

# Next Steps

Once you’ve confirmed that Nextflow and Conda are successfully installed, you can go ahead over to the **Software Packages** section, where we’ll cover the specific software required to run our workflows effectively. 
