---
layout: default
title: Brief Overview of Nextflow
nav_order: 1
parent: Documentation
---

# A brief overview of Nextflow

This section provides a concise, essentials-only overview of running a Nextflow workflow. For a more complete understanding, we strongly recommend consulting the official [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html) and [Trainings](https://training.nextflow.io).

## NXF configuration (`*.config`) file
When you launch a pipeline, Nextflow looks for a configuration file, which can be provided using `-c <config-file>` option. For deailed information, see the [config documentation page](https://www.nextflow.io/docs/latest/config.html#)

The configuration file controls how the workflow runs, including:
1. Workflow parameters -- Path to Java, user inputs, etc.
2. Execution environment
    * conda environment - path to pre-set conda environments, or set up required packages
    * docker/singularity containers – run tasks in isolated, reproducible environments.
    * executors - choose where tasks run (local machine, cloud, or using SLURM) and set related parameters
3. Profiles -- pre-defined groups of configuration settings that make it easy to run the same workflow in different environments.
   *Example:* a `local` profile for testing on your laptop, and a `slurm` profile for running on an HPC cluster.


## `work` directory

Nextflow (NXF) manages its workflows by running each task in a temporary location called the **`work` directory** (this is the default name, but you can change it with the `-work-dir` option).

Here’s how it works:

* When you run a workflow, Nextflow first executes each analysis step inside the `work` directory.
* The results you see in your chosen output folder are actually **symbolic links** (shortcuts) pointing back to the real files in `work`.
* This design allows Nextflow to keep track of what has already been computed. If you rerun the workflow with the `-resume` option, Nextflow will **reuse cached results** instead of recomputing everything from scratch. For example:

  * If you change only the last step of the workflow, Nextflow will recognize that earlier steps haven’t changed and will reuse their results.
  * Only the final step will be rerun, saving time and resources.

{: .warning }
The `work` directory is **essential** for this caching system. Moving or deleting its files can break Nextflow’s ability to resume workflows correctly. Unless you’re very familiar with Nextflow’s internals, we strongly recommend leaving the `work` directory untouched. Even small changes may prevent `-resume` from working as expected.


## `run` directory

By default, the directory where you launch Nextflow is treated as its **run directory**. It is **important to note that only one Nextflow workflow can run in a given directory at a time**.

What this means in practice:

* If you want to run the Tractor workflow for multiple chromosomes, **each workflow must be launched through its own, separate `run` directory.**
* If you try to start multiple runs in the same directory, the second run will fail with a LOCK error.

{: .important }
For a clean and reliable setup, we recommend creating a dedicated **`run`** directory and **`work`** directory for every workflow run. This keeps results separate, avoids conflicts, and makes troubleshooting easier.


