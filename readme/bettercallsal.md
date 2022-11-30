# bettercallsal

`bettercallsal` is an automated workflow to assign Salmonella serotype based on [NCBI Pathogens Database](https://www.ncbi.nlm.nih.gov/pathogens). It uses `MASH` to reduce the search space for genome based alignment with `kma` followed by count generation using `salmon`. This workflow is especially useful in a case where a sample is of multi-serovar mixture.

\
&nbsp;

## Workflow Usage

```bash
cpipes --pipeline bettercallsal [options]
```

Example: Run the default `bettercallsal` pipeline in single-end mode.

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

Example: Run the `bettercallsal` pipeline in paired-end mode. In this mode, `bbmerge.sh` tool will be used to merge paired-end reads based on overlap.

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

## Example Data

After you make sure that you have all the [minimum requirements](../README.md#minimum-requirements) to run the workflow, you can try the `bettercallsal` pipeline on some simulated reads. The following input dataset contains simulated reads for `Montevideo` and `I 4,[5],12:i:-` in about roughly equal proportions.

- Download simulated reads: [S3](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/bettercallsal_sim_reads.tar.bz2) (~ 3 GB).
- Download pre-formatted database: [S3](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/PDG000000002.2491.tar.bz2) (~ 35 GB).
- After succesful run of the workflow, your **MultiQC** report should look something like [this](https://cfsan-pub-xfer.s3.amazonaws.com/Kranti.Konganti/bettercallsal/bettercallsal_sim_reads_mqc.html).

Now run the workflow by ignoring quality values since these are simulated base qualities:

```bash
cpipes \
    --pipeline bettercallsal \
    --input /path/to/bettercallsal_sim_reads \
    --output /path/to/bettercallsal_sim_reads_output \
    --bcs_root_dbdir /path/to/PDG000000002.2491
    --kmaalign_ignorequals \
    -profile stdkondagac \
    -resume
```

Please note that the run time profile `stdkondagac` will run jobs locally using `micromamba` for software provisioning. The first time you run the command, a new folder called `kondagac_cache` will be created and subsequent runs should use this `conda` cache.

\
&nbsp;

## Database

The successful run of the workflow requires certain database flat files specific for the workflow.

Please refer to `bettercallsal_db` [README](./bettercallsal_db.md) if you would like to run the workflow on the latest version of the **PDG** release.

\
&nbsp;

## `bettercallsal` Help

```text
[Kranti_Konganti@my-unix-box ]$ cpipes --pipeline bettercallsal --help
N E X T F L O W  ~  version 22.10.0
Launching `./bettercallsal/cpipes` [agitated_watson] DSL2 - revision: 93f5293f50
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

Version                         : 0.2.1


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

--bbmerge_run                   : Run BBMerge tool. Default: true

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
                                  Default: true

--kmaalign_oa                   : Use neither -mrs or p-value on consensus.
                                  Default: false

--kmaalign_bc                   : Minimum support to call bases. Default:
                                  false

--kmaalign_bcNano               : Altered indel calling for ONT data. Default
                                  : false

--kmaalign_bcd                  : Minimum depth to call bases. Default: false

--kmaalign_bcg                  : Maintain insignificant gaps. Default: false

--kmaalign_ID                   : Minimum consensus ID. Default: 10.0

--kmaalign_md                   : Minimum depth. Default: false

--kmaalign_dense                : Skip insertion in consensus. Default: false

--kmaalign_ref_fsa              : Use Ns on indels. Default: false

--kmaalign_Mt1                  : Map everything to one template. Default:
                                  false

--kmaalign_1t1                  : Map one query to one template. Default:
                                  false

--kmaalign_mrs                  : Minimum relative alignment score. Default:
                                  0.99

--kmaalign_mrc                  : Minimum query coverage. Default: 0.99

--kmaalign_mq                   : Minimum phred score of trailing and leading
                                  bases. Default: 30

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
