# bettercallsal

`bettercallsal` is an automated workflow to assign Salmonella serotype based on [NCBI Pathogens Database](https://www.ncbi.nlm.nih.gov/pathogens). It uses `MASH` to reduce the search space followed by additional genome filtering with `sourmash`. It then performs genome based alignment with `kma` followed by count generation using `salmon`. This workflow is especially useful in a case where a sample is of multi-serovar mixture.

\
&nbsp;

<!-- TOC -->

- [Minimum Requirements](#minimum-requirements)
- [CFSAN GalaxyTrakr](#cfsan-galaxytrakr)
- [Usage and Examples](#usage-and-examples)
  - [Database](#database)
  - [Input](#input)
  - [Output](#output)
  - [Computational resources](#computational-resources)
  - [Runtime profiles](#runtime-profiles)
  - [your_institution.config](#your_institutionconfig)
  - [Cloud computing](#cloud-computing)
  - [Example data](#example-data)
- [Using sourmash](#using-sourmash)
- [bettercallsal CLI Help](#bettercallsal-cli-help)

<!-- /TOC -->

\
&nbsp;

## Minimum Requirements

1. [Nextflow version 22.10.0](https://github.com/nextflow-io/nextflow/releases/download/v22.10.0/nextflow).
    - Make the `nextflow` binary executable (`chmod 755 nextflow`) and also make sure that it is made available in your `$PATH`.
    - If your existing `JAVA` install does not support the newest **Nextflow** version, you can try **Amazon**'s `JAVA` (OpenJDK):  [Corretto](https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz).
2. Either of `micromamba` or `docker` or `singularity` installed and made available in your `$PATH`.
    - Running the workflow via `micromamba` software provisioning is **preferred** as it does not require any `sudo` or `admin` privileges or any other configurations with respect to the various container providers.
    - To install `micromamba` for your system type, please follow these [installation steps](https://mamba.readthedocs.io/en/latest/installation.html#manual-installation) and make sure that the `micromamba` binary is made available in your `$PATH`.
    - Just the `curl` step is sufficient to download the binary as far as running the workflows are concerned.
3. Minimum of 10 CPU cores and about 16 GBs for main workflow steps. More memory may be required if your **FASTQ** files are big.

\
&nbsp;

## CFSAN GalaxyTrakr

The `bettercallsal` pipeline is also available for use on the [Galaxy instance supported by CFSAN, FDA](https://galaxytrakr.org/). If you wish to run the analysis using **Galaxy**, please register for an account, after which you can run the workflow using some test data by following the instructions
[from this PDF](https://research.foodsafetyrisk.org/bettercallsal/galaxytrakr/bettercallsal_on_cfsan_galaxytrakr.pdf).

Please note that the pipeline on [CFSAN GalaxyTrakr](https://galaxytrakr.org) in most cases may be a version older than the one on **GitHub** due to testing prioritization.

\
&nbsp;

## Usage and Examples

Clone or download this repository and then call `cpipes`.

```bash
cpipes --pipeline bettercallsal [options]
```

Alternatively, you can use `nextflow` to directly pull and run the pipeline.

```bash
nextflow pull CFSAN-Biostatistics/bettercallsal
nextflow list
nextflow info CFSAN-Biostatistics/bettercallsal
nextflow run CFSAN-Biostatistics/bettercallsal --pipeline bettercallsal_db --help
nextflow run CFSAN-Biostatistics/bettercallsal --pipeline bettercallsal --help
```

\
&nbsp;

**Example**: Run the default `bettercallsal` pipeline in single-end mode.

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes
      --pipeline bettercallsal \
      --input /path/to/illumina/fastq/dir \
      --output /path/to/output \
      --bcs_root_dbdir /data/Kranti_Konganti/bettercallsal_db
```

\
&nbsp;

**Example**: Run the `bettercallsal` pipeline in paired-end mode. In this mode, the `R1` and `R2` files are concatenated. We have found that concatenated reads yields better calling rates. Please refer to the **Methods** and the **Results** section in our [paper](https://www.frontiersin.org/articles/10.3389/fmicb.2023.1200983/full) for more information. Users can still choose to use `bbmerge.sh` by adding the following options on the command-line: `--bbmerge_run true --bcs_concat_pe false`.

```bash
cd /data/scratch/$USER
mkdir nf-cpipes
cd nf-cpipes
cpipes \
      --pipeline bettercallsal \
      --input /path/to/illumina/fastq/dir \
      --output /path/to/output \
      --bcs_root_dbdir /data/Kranti_Konganti/bettercallsal_db \
      --fq_single_end false \
      --fq_suffix '_R1_001.fastq.gz'
```

\
&nbsp;

### Database

---

The successful run of the workflow requires certain database flat files specific for the workflow.

Please refer to `bettercallsal_db` [README](./bettercallsal_db.md) if you would like to run the workflow on the latest version of the **PDG** release.

&nbsp;

### Input

---

The input to the workflow is a folder containing compressed (`.gz`) FASTQ files. Please note that the sample grouping happens automatically by the file name of the FASTQ file. If for example, a single sample is sequenced across multiple sequencing lanes, you can choose to group those FASTQ files into one sample by using the `--fq_filename_delim` and `--fq_filename_delim_idx` options. By default, `--fq_filename_delim` is set to `_` (underscore) and `--fq_filename_delim_idx` is set to 1.

For example, if the directory contains FASTQ files as shown below:

- KB-01_apple_L001_R1.fastq.gz
- KB-01_apple_L001_R2.fastq.gz
- KB-01_apple_L002_R1.fastq.gz
- KB-01_apple_L002_R2.fastq.gz
- KB-02_mango_L001_R1.fastq.gz
- KB-02_mango_L001_R2.fastq.gz
- KB-02_mango_L002_R1.fastq.gz
- KB-02_mango_L002_R2.fastq.gz

Then, to create 2 sample groups, `apple` and `mango`, we split the file name by the delimitor (underscore in the case, which is default) and group by the first 2 words (`--fq_filename_delim_idx 2`).

This goes without saying that all the FASTQ files should have uniform naming patterns so that `--fq_filename_delim` and `--fq_filename_delim_idx` options do not have any adverse effect in collecting and creating a sample metadata sheet.

\
&nbsp;

### Output

---

All the outputs for each step are stored inside the folder mentioned with the `--output` option. A `multiqc_report.html` file inside the `bettercallsal-multiqc` folder can be opened in any browser on your local workstation which contains a consolidated brief report.

\
&nbsp;

### Computational resources

---

The workflow `bettercallsal` requires at least a minimum of 16 GBs of memory to successfully finish the workflow. By default, `bettercallsal` uses 10 CPU cores where possible. You can change this behavior and adjust the CPU cores with `--max_cpus` option.

\
&nbsp;

Example:

```bash
cpipes \
    --pipeline bettercallsal \
    --input /path/to/bettercallsal_sim_reads \
    --output /path/to/bettercallsal_sim_reads_output \
    --bcs_root_dbdir /path/to/PDG000000002.2537
    --kmaalign_ignorequals \
    --max_cpus 5 \
    -profile stdkondagac \
    -resume
```

\
&nbsp;

### Runtime profiles

---

You can use different run time profiles that suit your specific compute environments i.e., you can run the workflow locally on your machine or in a grid computing infrastructure.

\
&nbsp;

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

In the above example, we can see that we have mentioned the run time profile as `your_institution`. For this to work, add the following lines at the end of [`computeinfra.config`](../conf/computeinfra.config) file which should be located inside the `conf` folder. For example, if your institution uses **SGE** or **UNIVA** for grid computing instead of **SLURM** and has a job queue named `normal.q`, then add these lines:

\
&nbsp;

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

In the above example, by default, all the software provisioning choices are disabled except `conda`. You can also choose to remove the `process.queue` line altogether and the `bettercallsal` workflow will request the appropriate memory and number of CPU cores automatically, which ranges from 1 CPU, 1 GB and 1 hour for job completion up to 10 CPU cores, 1 TB and 120 hours for job completion.

\
&nbsp;

### Cloud computing

---

You can run the workflow in the cloud (works only with proper set up of AWS resources). Add new run time profiles with required parameters per [Nextflow docs](https://www.nextflow.io/docs/latest/executor.html):

\
&nbsp;

Example:

```groovy
my_aws_batch {
    executor = 'awsbatch'
    queue = 'my-batch-queue'
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    aws.batch.region = 'us-east-1'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = true
    params.conda_enabled = false
    params.enable_module = false
}
```

\
&nbsp;

### Example data

---

After you make sure that you have all the [minimum requirements](#minimum-requirements) to run the workflow, you can try the `bettercallsal` pipeline on some simulated reads. The following input dataset contains simulated reads for `Montevideo` and `I 4,[5],12:i:-` in about roughly equal proportions.

- Download simulated reads: [S3](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/bettercallsal_sim_reads.tar.bz2) (~ 3 GB).
- Download pre-formatted test database: [S3](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/PDG000000002.2491.test-db.tar.bz2) (~ 75 MB). This test database works only with the simulated reads.
- Download pre-formatted full database (**Optional**): If you would like to do a complete run with your own **FASTQ** datasets, you can either create your own [database](./bettercallsal_db.md) or use [PDG000000002.2537](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/PDG000000002.2537.tar.bz2) version of the database (~ 37 GB).
- After succesful run of the workflow, your **MultiQC** report should look something like [this](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/bettercallsal_sim_reads_mqc.html).

Now run the workflow by ignoring quality values since these are simulated base qualities:

\
&nbsp;

```bash
cpipes \
    --pipeline bettercallsal \
    --input /path/to/bettercallsal_sim_reads \
    --output /path/to/bettercallsal_sim_reads_output \
    --bcs_root_dbdir /path/to/PDG000000002.2537
    --kmaalign_ignorequals \
    -profile stdkondagac \
    -resume
```

Please note that the run time profile `stdkondagac` will run jobs locally using `micromamba` for software provisioning. The first time you run the command, a new folder called `kondagac_cache` will be created and subsequent runs should use this `conda` cache.

\
&nbsp;

## Using `sourmash`

Beginning with `v0.3.0` of `bettercallsal` workflow, `sourmash` sketching is used to further narrow down possible serotype hits. It is **ON** by default. This will enable the generation of **ANI Containment** matrix for **Samples** vs **Genomes**. There may be multiple hits for the same serotype in the final **MultiQC** report as multiple genome accessions can belong to a single serotype.

You can turn **OFF** this feature with `--sourmashsketch_run false` option.

\
&nbsp;

## `bettercallsal` CLI Help

```text
[Kranti_Konganti@my-unix-box ]$ cpipes --pipeline bettercallsal --help
N E X T F L O W  ~  version 22.10.7
Launching `./bettercallsal/cpipes` [awesome_chandrasekhar] DSL2 - revision: 8da4e11078
================================================================================
             (o)                  
  ___  _ __   _  _ __    ___  ___ 
 / __|| '_ \ | || '_ \  / _ \/ __|
| (__ | |_) || || |_) ||  __/\__ \
 \___|| .__/ |_|| .__/  \___||___/
      | |       | |               
      |_|       |_|
--------------------------------------------------------------------------------
A collection of modular pipelines at CFSAN, FDA.
--------------------------------------------------------------------------------
Name                            : CPIPES
Author                          : Kranti Konganti
Version                         : 0.6.0
Center                          : CFSAN, FDA.
================================================================================


--------------------------------------------------------------------------------
Show configurable CLI options for each tool within bettercallsal
--------------------------------------------------------------------------------
Ex: cpipes --pipeline bettercallsal --help
Ex: cpipes --pipeline bettercallsal --help fastp
Ex: cpipes --pipeline bettercallsal --help fastp,mash
--------------------------------------------------------------------------------
--help bbmerge                  : Show bbmerge.sh CLI options
--help fastp                    : Show fastp CLI options
--help mash                     : Show mash `screen` CLI options
--help tuspy                    : Show get_top_unique_mash_hit_genomes.py CLI
                                  options
--help sourmashsketch           : Show sourmash `sketch` CLI options
--help sourmashgather           : Show sourmash `gather` CLI options
--help sourmashsearch           : Show sourmash `search` CLI options
--help sfhpy                    : Show sourmash_filter_hits.py CLI options
--help kmaindex                 : Show kma `index` CLI options
--help kmaalign                 : Show kma CLI options
--help megahit                  : Show megahit CLI options
--help mlst                     : Show mlst CLI options
--help abricate                 : Show abricate CLI options
--help salmon                   : Show salmon `index` CLI options
--help gsrpy                    : Show gen_salmon_res_table.py CLI options

```
