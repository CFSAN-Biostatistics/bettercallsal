# bettercallsal

`bettercallsal` is an automated workflow to assign Salmonella serotype based on [NCBI Pathogens Database](https://www.ncbi.nlm.nih.gov/pathogens). It uses `MASH` to reduce the search space followed by additional genome filtering with `sourmash`. It then performs genome based alignment with `kma` followed by count generation using `salmon`. This workflow is especially useful in a case where a sample is of multi-serovar mixture.

\
&nbsp;

<!-- TOC -->

- [Minimum Requirements](#minimum-requirements)
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

## Usage and Examples

Clone or download this repository and then call `cpipes`.

```bash
cpipes --pipeline bettercallsal [options]
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

**Example**: Run the `bettercallsal` pipeline in paired-end mode. In this mode, the `R1` and `R2` files are concatenated. We have found that concatenated reads yields better calling rates. Please refer to the **Methods** and the **Results** section in our [preprint](https://www.biorxiv.org/content/10.1101/2023.04.06.535929v1.full) for more information. Users can still choose to use `bbmerge.sh` by adding the following options on the command-line: `--bbmerge_run true --bcs_concat_pe false`.

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
N E X T F L O W  ~  version 22.10.0
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
Version                         : 0.5.0
Center                          : CFSAN, FDA.
================================================================================

Workflow                        : bettercallsal

Author                          : Kranti Konganti

Version                         : 0.5.0


Usage                           : cpipes --pipeline bettercallsal [options]


Required                        :

--input                         : Absolute path to directory containing FASTQ
                                  files. The directory should contain only
                                  FASTQ files as all the files within the
                                  mentioned directory will be read. Ex: --
                                  input /path/to/fastq_pass

--output                        : Absolute path to directory where all the
                                  pipeline outputs should be stored. Ex: --
                                  output /path/to/output

Other options                   :

--metadata                      : Absolute path to metadata CSV file
                                  containing five mandatory columns: sample,
                                  fq1,fq2,strandedness,single_end. The fq1
                                  and fq2 columns contain absolute paths to
                                  the FASTQ files. This option can be used in
                                  place of --input option. This is rare. Ex
                                  : --metadata samplesheet.csv

--fq_suffix                     : The suffix of FASTQ files (Unpaired reads
                                  or R1 reads or Long reads) if an input
                                  directory is mentioned via --input option.
                                  Default: .fastq.gz

--fq2_suffix                    : The suffix of FASTQ files (Paired-end reads
                                  or R2 reads) if an input directory is
                                  mentioned via --input option. Default:
                                  _R2_001.fastq.gz

--fq_filter_by_len              : Remove FASTQ reads that are less than this
                                  many bases. Default: 0

--fq_strandedness               : The strandedness of the sequencing run.
                                  This is mostly needed if your sequencing
                                  run is RNA-SEQ. For most of the other runs
                                  , it is probably safe to use unstranded for
                                  the option. Default: unstranded

--fq_single_end                 : SINGLE-END information will be auto-
                                  detected but this option forces PAIRED-END
                                  FASTQ files to be treated as SINGLE-END so
                                  only read 1 information is included in auto
                                  -generated samplesheet. Default: true

--fq_filename_delim             : Delimiter by which the file name is split
                                  to obtain sample name. Default: _

--fq_filename_delim_idx         : After splitting FASTQ file name by using
                                  the --fq_filename_delim option, all
                                  elements before this index (1-based) will
                                  be joined to create final sample name.
                                  Default: 1

--bcs_concat_pe                 : Concatenate paired-end files. Default: true

--bbmerge_run                   : Run BBMerge tool. Default: false

--bbmerge_reads                 : Quit after this many read pairs (-1 means
                                  all) Default: -1

--bbmerge_adapters              : Absolute UNIX path pointing to the adapters
                                  file in FASTA format. Default: false

--bbmerge_ziplevel              : Set to 1 (lowest) through 9 (max) to change
                                  compression level; lower compression is
                                  faster. Default: 1

--bbmerge_ordered               : Output reads in the same order as input.
                                  Default: false

--bbmerge_qtrim                 : Trim read ends to remove bases with quality
                                  below --bbmerge_minq. Trims BEFORE merging
                                  . Values: t (trim both ends), f (neither
                                  end), r (right end only), l (left end only
                                  ). Default: true

--bbmerge_qtrim2                : May be specified instead of --bbmerge_qtrim
                                  to perform trimming only if merging is
                                  unsuccesful. then retry merging. Default:
                                  false

--bbmerge_trimq                 : Trim quality threshold. This may be comma-
                                  delimited list (ascending) to try multiple
                                  values. Default: 10

--bbmerge_minlength             : (ml) Reads shorter than this after trimming
                                  , but before merging, will be discarded.
                                  Pairs will be discarded onlyif both are
                                  shorter. Default: 1

--bbmerge_tbo                   : (trimbyoverlap). Trim overlapping reads to
                                  remove right most (3') non-overlaping
                                  portion instead of joining Default: false

--bbmerge_minavgquality         : (maq). Reads with average quality below
                                  this after trimming will not be attempted
                                  to merge. Default: 30

--bbmerge_trimpolya             : Trim trailing poly-A tail from adapter
                                  output. Only affects outadapter.  This also
                                  trims poly-A followed by poly-G, which
                                  occurs on NextSeq. Default: true

--bbmerge_pfilter               : Ban improbable overlaps. Higher is more
                                  strict. 0 will disable the filter; 1 will
                                  allow only perfect overlaps. Default: 1

--bbmerge_ouq                   : Calculate best overlap using quality values
                                  . Default: false

--bbmerge_owq                   : Calculate best overlap without using
                                  quality values. Default: true

--bbmerge_strict                : Decrease false positive rate and merging
                                  rate. Default: false

--bbmerge_verystrict            : Greatly decrease false positive rate and
                                  merging rate. Default: false

--bbmerge_ultrastrict           : Decrease false positive rate and merging
                                  rate even more. Default: true

--bbmerge_maxstrict             : Maxiamally decrease false positive rate and
                                  merging rate. Default: false

--bbmerge_loose                 : Increase false positive rate and merging
                                  rate. Default: false

--bbmerge_veryloose             : Greatly increase false positive rate and
                                  merging rate. Default: false

--bbmerge_ultraloose            : Increase false positive rate and merging
                                  rate even more. Default: false

--bbmerge_maxloose              : Maximally increase false positive rate and
                                  merging rate. Default: false

--bbmerge_fast                  : Fastest possible preset. Default: false

--bbmerge_k                     : Kmer length.  31 (or less) is fastest and
                                  uses the least memory, but higher values
                                  may be more accurate. 60 tends to work well
                                  for 150bp reads. Default: 60

--bbmerge_prealloc              : Pre-allocate memory rather than dynamically
                                  growing. Faster and more memory-efficient
                                  for large datasets. A float fraction (0-1)
                                  may be specified, default 1. Default: true

--fastp_run                     : Run fastp tool. Default: true

--fastp_failed_out              : Specify whether to store reads that cannot
                                  pass the filters. Default: false

--fastp_merged_out              : Specify whether to store merged output or
                                  not. Default: false

--fastp_overlapped_out          : For each read pair, output the overlapped
                                  region if it has no mismatched base.
                                  Default: false

--fastp_6                       : Indicate that the input is using phred64
                                  scoring (it'll be converted to phred33, so
                                  the output will still be phred33). Default
                                  : false

--fastp_reads_to_process        : Specify how many reads/pairs are to be
                                  processed. Default value 0 means process
                                  all reads. Default: 0

--fastp_fix_mgi_id              : The MGI FASTQ ID format is not compatible
                                  with many BAM operation tools, enable this
                                  option to fix it. Default: false

--fastp_A                       : Disable adapter trimming. On by default.
                                  Default: false

--fastp_adapter_fasta           : Specify a FASTA file to trim both read1 and
                                  read2 (if PE) by all the sequences in this
                                  FASTA file. Default: false

--fastp_f                       : Trim how many bases in front of read1.
                                  Default: 0

--fastp_t                       : Trim how many bases at the end of read1.
                                  Default: 0

--fastp_b                       : Max length of read1 after trimming. Default
                                  : 0

--fastp_F                       : Trim how many bases in front of read2.
                                  Default: 0

--fastp_T                       : Trim how many bases at the end of read2.
                                  Default: 0

--fastp_B                       : Max length of read2 after trimming. Default
                                  : 0

--fastp_dedup                   : Enable deduplication to drop the duplicated
                                  reads/pairs. Default: true

--fastp_dup_calc_accuracy       : Accuracy level to calculate duplication (1~
                                  6), higher level uses more memory (1G, 2G,
                                  4G, 8G, 16G, 24G). Default 1 for no-dedup
                                  mode, and 3 for dedup mode. Default: 6

--fastp_poly_g_min_len          : The minimum length to detect polyG in the
                                  read tail. Default: 10

--fastp_G                       : Disable polyG tail trimming. Default: true

--fastp_x                       : Enable polyX trimming in 3' ends. Default:
                                  false

--fastp_poly_x_min_len          : The minimum length to detect polyX in the
                                  read tail. Default: 10

--fastp_cut_front               : Move a sliding window from front (5') to
                                  tail, drop the bases in the window if its
                                  mean quality < threshold, stop otherwise.
                                  Default: true

--fastp_cut_tail                : Move a sliding window from tail (3') to
                                  front, drop the bases in the window if its
                                  mean quality < threshold, stop otherwise.
                                  Default: false

--fastp_cut_right               : Move a sliding window from tail, drop the
                                  bases in the window and the right part if
                                  its mean quality < threshold, and then stop
                                  . Default: true

--fastp_W                       : Sliding window size shared by --
                                  fastp_cut_front, --fastp_cut_tail and --
                                  fastp_cut_right. Default: 20

--fastp_M                       : The mean quality requirement shared by --
                                  fastp_cut_front, --fastp_cut_tail and --
                                  fastp_cut_right. Default: 30

--fastp_q                       : The quality value below which a base should
                                  is not qualified. Default: 30

--fastp_u                       : What percent of bases are allowed to be
                                  unqualified. Default: 40

--fastp_n                       : How many N's can a read have. Default: 5

--fastp_e                       : If the full reads' average quality is below
                                  this value, then it is discarded. Default
                                  : 0

--fastp_l                       : Reads shorter than this length will be
                                  discarded. Default: 35

--fastp_max_len                 : Reads longer than this length will be
                                  discarded. Default: 0

--fastp_y                       : Enable low complexity filter. The
                                  complexity is defined as the percentage of
                                  bases that are different from its next base
                                  (base[i] != base[i+1]). Default: true

--fastp_Y                       : The threshold for low complexity filter (0~
                                  100). Ex: A value of 30 means 30%
                                  complexity is required. Default: 30

--fastp_U                       : Enable Unique Molecular Identifier (UMI)
                                  pre-processing. Default: false

--fastp_umi_loc                 : Specify the location of UMI, can be one of
                                  index1/index2/read1/read2/per_index/
                                  per_read. Default: false

--fastp_umi_len                 : If the UMI is in read1 or read2, its length
                                  should be provided. Default: false

--fastp_umi_prefix              : If specified, an underline will be used to
                                  connect prefix and UMI (i.e. prefix=UMI,
                                  UMI=AATTCG, final=UMI_AATTCG). Default:
                                  false

--fastp_umi_skip                : If the UMI is in read1 or read2, fastp can
                                  skip several bases following the UMI.
                                  Default: false

--fastp_p                       : Enable overrepresented sequence analysis.
                                  Default: true

--fastp_P                       : One in this many number of reads will be
                                  computed for overrepresentation analysis (1
                                  ~10000), smaller is slower. Default: 20

--fastp_use_custom_adapaters    : Use custom adapter FASTA with fastp on top
                                  of built-in adapter sequence auto-detection
                                  . Enabling this option will attempt to find
                                  and remove all possible Illumina adapter
                                  and primer sequences but will make the
                                  workflow run slow. Default: false

--mashscreen_run                : Run `mash screen` tool. Default: true

--mashscreen_w                  : Winner-takes-all strategy for identity
                                  estimates. After counting hashes for each
                                  query, hashes that appear in multiple
                                  queries will be removed from all except the
                                  one with the best identity (ties broken by
                                  larger query), and other identities will
                                  be reduced. This removes output redundancy
                                  , providing a rough compositional outline
                                  .  Default: false

--mashscreen_i                  : Minimum identity to report. Inclusive
                                  unless set to zero, in which case only
                                  identities greater than zero (i.e. with at
                                  least one shared hash) will be reported.
                                  Set to -1 to output everything. (-1-1).
                                  Default: false

--mashscreen_v                  : Maximum p-value to report (0-1). Default:
                                  false

--tuspy_run                     : Run the get_top_unique_mash_hits_genomes.py
                                  script. Default: true

--tuspy_s                       : Absolute UNIX path to metadata text file
                                  with the field separator, | and 5 fields:
                                  serotype|asm_lvl|asm_url|snp_cluster_idEx:
                                  serotype=Derby,antigen_formula=4:f,g:-|
                                  Scaffold|402440|ftp://...|PDS000096654.2.
                                  Mentioning this option will create a pickle
                                  file for the provided metadata and exits.
                                  Default: false

--tuspy_m                       : Absolute UNIX path to mash screen results
                                  file. Default: false

--tuspy_ps                      : Absolute UNIX Path to serialized metadata
                                  object in a pickle file. Default: /hpc/db/
                                  bettercallsal/latest/index_metadata/
                                  per_snp_cluster.ACC2SERO.pickle

--tuspy_gd                      : Absolute UNIX Path to directory containing
                                  gzipped genome FASTA files. Default: /hpc/
                                  db/bettercallsal/latest/scaffold_genomes

--tuspy_gds                     : Genome FASTA file suffix to search for in
                                  the genome directory. Default:
                                  _scaffolded_genomic.fna.gz

--tuspy_n                       : Return up to this many number of top N
                                  unique genome accession hits. Default: 10

--sourmashsketch_run            : Run `sourmash sketch dna` tool. Default:
                                  true

--sourmashsketch_mode           : Select which type of signatures to be
                                  created: dna, protein, fromfile or
                                  translate. Default: dna

--sourmashsketch_p              : Signature parameters to use. Default: abund
                                  ,scaled=1000,k=51,k=61,k=71

--sourmashsketch_file           : <path>  A text file containing a list of
                                  sequence files to load. Default: false

--sourmashsketch_f              : Recompute signatures even if the file
                                  exists. Default: false

--sourmashsketch_merge          : Merge all input files into one signature
                                  file with the specified name. Default:
                                  false

--sourmashsketch_singleton      : Compute a signature for each sequence
                                  record individually. Default: true

--sourmashsketch_name           : Name the signature generated from each file
                                  after the first record in the file.
                                  Default: false

--sourmashsketch_randomize      : Shuffle the list of input files randomly.
                                  Default: false

--sourmashgather_run            : Run `sourmash gather` tool. Default: true

--sourmashgather_n              : Number of results to report. By default,
                                  will terminate at --sourmashgather_thr_bp
                                  value. Default: false

--sourmashgather_thr_bp         : Reporting threshold (in bp) for estimated
                                  overlap with remaining query. Default:
                                  false

--sourmashgather_ignoreabn      : Do NOT use k-mer abundances if present.
                                  Default: false

--sourmashgather_prefetch       : Use prefetch before gather. Default: false

--sourmashgather_noprefetch     : Do not use prefetch before gather. Default
                                  : false

--sourmashgather_ani_ci         : Output confidence intervals for ANI
                                  estimates. Default: true

--sourmashgather_k              : The k-mer size to select. Default: 71

--sourmashgather_protein        : Choose a protein signature. Default: false

--sourmashgather_noprotein      : Do not choose a protein signature. Default
                                  : false

--sourmashgather_dayhoff        : Choose Dayhoff-encoded amino acid
                                  signatures. Default: false

--sourmashgather_nodayhoff      : Do not choose Dayhoff-encoded amino acid
                                  signatures. Default: false

--sourmashgather_hp             : Choose hydrophobic-polar-encoded amino acid
                                  signatures. Default: false

--sourmashgather_nohp           : Do not choose hydrophobic-polar-encoded
                                  amino acid signatures. Default: false

--sourmashgather_dna            : Choose DNA signature. Default: true

--sourmashgather_nodna          : Do not choose DNA signature. Default: false

--sourmashgather_scaled         : Scaled value should be between 100 and 1e6
                                  . Default: false

--sourmashgather_inc_pat        : Search only signatures that match this
                                  pattern in name, filename, or md5. Default
                                  : false

--sourmashgather_exc_pat        : Search only signatures that do not match
                                  this pattern in name, filename, or md5.
                                  Default: false

--sourmashsearch_run            : Run `sourmash search` tool. Default: false

--sourmashsearch_n              : Number of results to report. By default,
                                  will terminate at --sourmashsearch_thr
                                  value. Default: false

--sourmashsearch_thr            : Reporting threshold (similarity) to return
                                  results. Default: 0

--sourmashsearch_contain        : Score based on containment rather than
                                  similarity. Default: false

--sourmashsearch_maxcontain     : Score based on max containment rather than
                                  similarity. Default: false

--sourmashsearch_ignoreabn      : Do NOT use k-mer abundances if present.
                                  Default: true

--sourmashsearch_ani_ci         : Output confidence intervals for ANI
                                  estimates. Default: false

--sourmashsearch_k              : The k-mer size to select. Default: 71

--sourmashsearch_protein        : Choose a protein signature. Default: false

--sourmashsearch_noprotein      : Do not choose a protein signature. Default
                                  : false

--sourmashsearch_dayhoff        : Choose Dayhoff-encoded amino acid
                                  signatures. Default: false

--sourmashsearch_nodayhoff      : Do not choose Dayhoff-encoded amino acid
                                  signatures. Default: false

--sourmashsearch_hp             : Choose hydrophobic-polar-encoded amino acid
                                  signatures. Default: false

--sourmashsearch_nohp           : Do not choose hydrophobic-polar-encoded
                                  amino acid signatures. Default: false

--sourmashsearch_dna            : Choose DNA signature. Default: true

--sourmashsearch_nodna          : Do not choose DNA signature. Default: false

--sourmashsearch_scaled         : Scaled value should be between 100 and 1e6
                                  . Default: false

--sourmashsearch_inc_pat        : Search only signatures that match this
                                  pattern in name, filename, or md5. Default
                                  : false

--sourmashsearch_exc_pat        : Search only signatures that do not match
                                  this pattern in name, filename, or md5.
                                  Default: false

--sfhpy_run                     : Run the sourmash_filter_hits.py script.
                                  Default: true

--sfhpy_fcn                     : Column name by which filtering of rows
                                  should be applied. Default: f_match

--sfhpy_fcv                     : Remove genomes whose match with the query
                                  FASTQ is less than this much. Default: 0.1

--sfhpy_gt                      : Apply greather than or equal to condition
                                  on numeric values of --sfhpy_fcn column.
                                  Default: true

--sfhpy_lt                      : Apply less than or equal to condition on
                                  numeric values of --sfhpy_fcn column.
                                  Default: false

--kmaindex_run                  : Run kma index tool. Default: true

--kmaindex_t_db                 : Add to existing DB. Default: false

--kmaindex_k                    : k-mer size. Default: 31

--kmaindex_m                    : Minimizer size. Default: false

--kmaindex_hc                   : Homopolymer compression. Default: false

--kmaindex_ML                   : Minimum length of templates. Defaults to --
                                  kmaindex_k Default: false

--kmaindex_ME                   : Mega DB. Default: false

--kmaindex_Sparse               : Make Sparse DB. Default: false

--kmaindex_ht                   : Homology template. Default: false

--kmaindex_hq                   : Homology query. Default: false

--kmaindex_and                  : Both homology thresholds have to reach.
                                  Default: false

--kmaindex_nbp                  : No bias print. Default: false

--kmaalign_run                  : Run kma tool. Default: true

--kmaalign_int                  : Input file has interleaved reads.  Default
                                  : false

--kmaalign_ef                   : Output additional features. Default: false

--kmaalign_vcf                  : Output vcf file. 2 to apply FT. Default:
                                  false

--kmaalign_sam                  : Output SAM, 4/2096 for mapped/aligned.
                                  Default: false

--kmaalign_nc                   : No consensus file. Default: true

--kmaalign_na                   : No aln file. Default: true

--kmaalign_nf                   : No frag file. Default: true

--kmaalign_a                    : Output all template mappings. Default:
                                  false

--kmaalign_and                  : Use both -mrs and p-value on consensus.
                                  Default: false

--kmaalign_oa                   : Use neither -mrs or p-value on consensus.
                                  Default: false

--kmaalign_bc                   : Minimum support to call bases. Default:
                                  false

--kmaalign_bcNano               : Altered indel calling for ONT data. Default
                                  : false

--kmaalign_bcd                  : Minimum depth to call bases. Default: false

--kmaalign_bcg                  : Maintain insignificant gaps. Default: false

--kmaalign_ID                   : Minimum consensus ID. Default: false

--kmaalign_md                   : Minimum depth. Default: false

--kmaalign_dense                : Skip insertion in consensus. Default: false

--kmaalign_ref_fsa              : Use Ns on indels. Default: false

--kmaalign_Mt1                  : Map everything to one template. Default:
                                  false

--kmaalign_1t1                  : Map one query to one template. Default:
                                  false

--kmaalign_mrs                  : Minimum relative alignment score. Default:
                                  false

--kmaalign_mrc                  : Minimum query coverage. Default: 0.99

--kmaalign_mp                   : Minimum phred score of trailing and leading
                                  bases. Default: 30

--kmaalign_mq                   : Set the minimum mapping quality. Default:
                                  false

--kmaalign_eq                   : Minimum average quality score. Default: 30

--kmaalign_5p                   : Trim 5 prime by this many bases. Default:
                                  false

--kmaalign_3p                   : Trim 3 prime by this many bases Default:
                                  false

--kmaalign_apm                  : Sets both -pm and -fpm Default: false

--kmaalign_cge                  : Set CGE penalties and rewards Default:
                                  false

--salmonidx_run                 : Run `salmon index` tool. Default: true

--salmonidx_k                   : The size of k-mers that should be used for
                                  the  quasi index. Default: false

--salmonidx_gencode             : This flag will expect the input transcript
                                  FASTA to be in GENCODE format, and will
                                  split the transcript name at the first `|`
                                  character. These reduced names will be used
                                  in the output and when looking for these
                                  transcripts in a gene to transcript GTF.
                                  Default: false

--salmonidx_features            : This flag will expect the input reference
                                  to be in the tsv file format, and will
                                  split the feature name at the first `tab`
                                  character. These reduced names will be used
                                  in the output and when looking for the
                                  sequence of the features. GTF. Default:
                                  false

--salmonidx_keepDuplicates      : This flag will disable the default indexing
                                  behavior of discarding sequence-identical
                                  duplicate transcripts. If this flag is
                                  passed then duplicate transcripts that
                                  appear in the input will be retained and
                                  quantified separately. Default: false

--salmonidx_keepFixedFasta      : Retain the fixed fasta file (without short
                                  transcripts and duplicates, clipped, etc.)
                                  generated during indexing. Default: false

--salmonidx_filterSize          : The size of the Bloom filter that will be
                                  used by TwoPaCo during indexing. The filter
                                  will be of size 2^{filterSize}. A value of
                                  -1 means that the filter size will be
                                  automatically set based on the number of
                                  distinct k-mers in the input, as estimated
                                  by nthll. Default: false

--salmonidx_sparse              : Build the index using a sparse sampling of
                                  k-mer positions This will require less
                                  memory (especially during quantification),
                                  but will take longer to constructand can
                                  slow down mapping / alignment. Default:
                                  false

--salmonidx_n                   : Do not clip poly-A tails from the ends of
                                  target sequences. Default: false

--gsrpy_run                     : Run the gen_salmon_res_table.py script.
                                  Default: true

--gsrpy_url                     : Generate an additional column in final
                                  results table which links out to NCBI
                                  Pathogens Isolate Browser.  Default: true

Help options                    :

--help                          : Display this message.

```
