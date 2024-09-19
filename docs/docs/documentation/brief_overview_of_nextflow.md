---
layout: default
title: Brief Overview of Nextflow
nav_order: 1
parent: Documentation
---

# A brief overview of Nextflow

We provide a very brief and essentials-only overview here of running a Nextflow workflow. However, we strongly recommend acquainting with the Nextflow [Documentation](https://www.nextflow.io/docs/latest/index.html) and [Trainings](https://training.nextflow.io).

## NXF configuration (`*.config`) file
When a pipeline script is launched, NXF looks for a config file, which can be provided using `-c <config-file>` option. For more comprehensive info, please check out the [config documentation page](https://www.nextflow.io/docs/latest/config.html#)

The config file allows to configure the parameters of the workflow through various means. It helps define the following -- 
* Parameters for workflow
* Scopes for workflow
    * conda environment
    * docker/singularity containers
    * executors (e.g. SLURM) and their respective parameters

In addition, these config attributes can be wrapped in different `config profiles` to allow for usage of NXF workflow across different environments.

## `work` directory
Nextflow has a very specific way of operations. When an NXF workflow is launched, all the analyses is run in the `work` directory, unless mentioned through `-work-dir`. Once this is complete, most often, symbolic links to the final files generated in the `work` directory are linked in the output directory. This is done so as to allow cache task executions, or checkpointing. In case a specific workflow parameter is changed which only changes the last step of the workflow, Nextflow's `-resume` option allows to cache the previous tasks and only rerun the final step. 

{: .warning }
This makes the `work` directory crucial, and we strongly recommend against moving or deleting files within it unless you are familiar with Nextflow operations. The `-resume` option is particularly sensitive, and even minor changes can impact the workflow's ability to cache previously run tasks.

## `run` directory
By default, the current directory through which the Nextflow is run is considered its running directory. And **only one Nextflow workflow can run from one directory**. This means, if you want to iterate the Tractor workflow for 22 chromosomes, you must create separate 22 `run` directories, and initiate runs from each of these directories. Otherwise, once a specific workflow is run, the other workflow attempts will fail and have a LOCK error.

{: .important }
To keep the workflow clean and organized, we recommend creating a separate `run` and `work` directory for every iteration of the workflow run.
