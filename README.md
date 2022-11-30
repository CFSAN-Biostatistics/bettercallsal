# `bettercallsal`

`bettercallsal` is an automated workflow to assign Salmonella serotype based on [NCBI Pathogen Detection](https://www.ncbi.nlm.nih.gov/pathogens) Project for [Salmonella](https://www.ncbi.nlm.nih.gov/pathogens/isolates/#taxgroup_name:%22Salmonella%20enterica%22). It uses `MASH` to reduce the search space for genome based alignment with `kma` followed by count generation using `salmon`. This workflow can be used to analyze shotgun metagenomics datasets, quasi-metagenomic datasets (enriched for Salmonella) and target enriched datasets (enriched with molecular baits specific for Salmonella) and is especially useful in a case where a sample is of multi-serovar mixture.

It is written in **Nextflow** and is part of the modular data analysis pipelines (**CFSAN PIPELINES** or **CPIPES** for short) at **CFSAN**.

\
&nbsp;

## Workflows

**CPIPES**:

 1. `bettercallsal`       : [README](./readme/bettercallsal.md).
 2. `bettercallsal_db`    : [README](./readme/bettercallsal_db.md).

\
&nbsp;

### Acknowledgements

---
**NCBI Pathogen Detection**:

We gratefully acknowledge all data contributors, i.e., the Authors and their Originating laboratories responsible for obtaining the specimens, and their Submitting laboratories for generating the sequence and metadata and sharing it via the **NCBI Pathogen Detection** site, some of which this research utilizes.

\
&nbsp;

### Citing `bettercallsal`

---
This work is currently unpublished. If you are making use of this analysis pipeline, we would appreciate if you credit this repository.

\
&nbsp;

### Caveats

---

- The main workflow has not yet been fully validated and must be utilized for **research purposes** only.
- Analysis results should be interpreted with caution and should be treated as suspect, as the pipeline is dependent on the precision of metadata from the **NCBI Pathogen Detection** project for the `per_snp_cluster` and `per_computed_serotype` databases.
- Detection threshold i.e sequencing depth has not yet been established for `bettercallsal` analysis workflow and therefore **No genome hit** assignment should be interpreted with caution.
- Multiple Salmonella serotype assignments also should be dealt with caution as this pipeline has not been tested on samples with 3 or more serovar mixture.

\
&nbsp;

### Disclaimer

---
**CFSAN, FDA** assumes no responsibility whatsoever for use by other parties of the Software, its source code, documentation or compiled or uncompiled executables, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. Further, **CFSAN, FDA** makes no representations that the use of the Software will not infringe any patent or proprietary rights of third parties. The use of this code in no way implies endorsement by the **CFSAN, FDA** or confers any advantage in regulatory decisions.

\
&nbsp;

### Minimum Requirements

---

1. [Nextflow version 22.10.0](https://github.com/nextflow-io/nextflow/releases/download/v22.10.0/nextflow).
    - Make the `nextflow` binary executable (`chmod 755 nextflow`) and also make sure that it is made available in your `$PATH`.
    - If your existing `JAVA` install does not support the newest **Nextflow** version, you can try **Amazon**'s `JAVA` (OpenJDK):  [Corretto](https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz).
2. Either of `micromamba` or `docker` or `singularity` installed and made available in your `$PATH`.
    - Running the workflow via `micromamba` software provisioning is **preferred** as it does not require any `sudo` or `admin` privileges or any other configurations with respect to the various container providers.
    - To install `micromamba` for your system type, please follow these [installation steps](https://mamba.readthedocs.io/en/latest/installation.html#manual-installation) and make sure that the `micromamba` binary is made available in your `$PATH`.
    - Just the `curl` step is sufficient to download the binary as far as running the workflows are concerned.
3. Minimum of 10 CPUs and about 64 GB for main workflow steps. More memory may be required if your **FASTQ** files are big.

\
&nbsp;

### Workflow Usage

---
Clone or download this repository and then call `cpipes`.

Following is the example of how to run the `bettercallsal` pipeline using `conda` for software provisioning. This requires that the `micromamba` executable be available in your `$PATH`.

```bash
cpipes --pipeline bettercallsal --enable-conda -with-conda [options]
```

Example:

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes \
    --pipeline bettercallsal \
    --input /path/to/fastq_pass_dir \
    --output /path/to/where/output/should/go \
    -profile your_institution
```

The above command would run the pipeline and store the output at the location per the `--output` flag and the **NEXTFLOW** reports are always stored in the current working directory from where `cpipes` is run. For example, for the above command, a directory called `CPIPES-bettercallsal` would hold all the **NEXTFLOW** related logs, reports and trace files.

\
&nbsp;

### `your_institution.config`

---

In the above example, we can see that we have mentioned the run time profile as `your_institution`. For this to work, add the following lines at the end of [`computeinfra.config`](./conf/computeinfra.config) file which should be located inside the `conf` folder. For example, if your institution uses **SGE** or **UNIVA** for grid computing instead of **SLURM** and has a job queue named `normal.q`, then add these lines:

```groovy
your_institution {
    process.executor = 'sge'
    process.queue = 'normal.q'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = false
    params.enable_conda = true
    conda.enabled = true
    conda.useMicromamba = true
    params.enable_module = false
}
```

In the above example, by default, all the software provisioning choices are disabled except `conda`. You can also choose to remove the `process.queue` line altogether and the `bettercallsal` workflow will request the appropriate memory and number of CPUs automatically, which ranges from 1 CPU, 1 GB and 1 hour for job completion up to 10 CPUs, 1 TB and 120 hours for job completion.

\
&nbsp;

### Cloud computing

---

You can theoritically run the workflow in the cloud (not yet tested). Add new run time profiles with required parameters per [Nextflow docs](https://www.nextflow.io/docs/latest/executor.html):

Example:

```groovy
my_aws_batch {
    executor = 'awsbatch'
    queue = 'my-batch-queue'
    aws.$batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    aws.$batch.region = 'us-east-1'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = true
    params.conda_enabled = false
    params.enable_module = false
}
```

\
&nbsp;

### Output

---

All the outputs for each step are stored inside the folder mentioned with the `--output` option. A `multiqc_report.html` file inside the `bettercallsal-multiqc` folder can be opened in any browser on your local workstation which contains a consolidated brief report.
