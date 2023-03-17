# bettercallsal_db

`bettercallsal_db` is an end-to-end automated workflow to generate and consolidate the required DB flat files based on [NCBI Pathogens Database for Salmonella](https://ftp.ncbi.nlm.nih.gov/pathogen/Results/Salmonella/). It first downloads the metadata based on the provided release identifier (Ex: `latest_snps` or `PDG000000002.2537`) and then creates a `mash sketch` based on the filtering strategy. It generates two types of sketches, one that prioritizes genome collection based on SNP clustering (`per_snp_cluster`) and the other just collects up to N number of genome accessions for each `computed_serotype` column from the metadata file (`per_computed_serotype`).

The `bettercallsal_db` workflow should finish within an hour with stable internet connection.

\
&nbsp;

## Workflow Usage

```bash
cpipes --pipeline bettercallsal_db [options]
```

\
&nbsp;

Example: Run the `bettercallsal_db` pipeline and store output at `/data/Kranti_Konganti/bettercallsal_db`.

```bash
cpipes
      --pipeline bettercallsal_db \
      --pdg_release PDG000000002.2537 \
      --output /data/Kranti_Konganti/bettercallsal_db
```

\
&nbsp;

Now you can run the `bettercallsal` workflow with the created database by mentioning the root path to the database with `--bcs_root_dbdir` option.

```bash
cpipes
      --pipeline bettercallsal \
      --input /path/to/illumina/fastq/dir \
      --output /path/to/output \
      --bcs_root_dbdir /data/Kranti_Konganti/bettercallsal_db
```

\
&nbsp;

## Note

Please note that the last step of the `bettercallsal_db` workflow named `SCAFFOLD_GENOMES` will spawn multiple processes and is not cached by **Nextflow**. This is an intentional setup for this specific stage of the workflow to speed up database creation and as such it is recommended that you run this workflow in a grid computing or similar cloud computing setting.

\
&nbsp;

## `bettercallsal_db` CLI Help

```text
[Kranti_Konganti@my-unix-box ]$ cpipes --pipeline bettercallsal_db --help
N E X T F L O W  ~  version 22.10.0
Launching `./bettercallsal/cpipes` [hopeful_franklin] DSL2 - revision: 93f5293f50
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

Workflow                        : bettercallsal_db

Author                          : Kranti Konganti

Version                         : 0.4.0


Required                        :

--output                        : Absolute path to directory where all the
                                  pipeline outputs should be stored. Ex: --
                                  output /path/to/output

Other options                   :

--wcomp_serocol                 : Column number (non 0-based index) of the
                                  PDG metadata file by which the serotypes
                                  are collected. Default: false

--wcomp_complete_sero           : Skip indexing serotypes when the serotype
                                  name in the column number 49 (non 0-based)
                                  of PDG metadata file consists a "-". For
                                  example, if an accession has a serotype=
                                  string as such in column number 49 (non 0-
                                  based): "serotype=- 13:z4,z23:-" then, the
                                  indexing of that accession is skipped.
                                  Default: false

--wcomp_not_null_serovar        : Only index the computed_serotype column i.e
                                  . column number 49 (non 0-based), if the
                                  serovar column is not NULL.  Default: false

--wcomp_i                       : Force include this serovar. Ignores --
                                  wcomp_complete_sero for only this serovar.
                                  Mention multiple serovars separated by a
                                  ! (Exclamation mark). Ex: --
                                  wcomp_complete_sero I 4,[5],12:i:-!Agona
                                  Default: false

--wcomp_num                     : Number of genome accessions to be collected
                                  per serotype. Default: false

--wcomp_min_contig_size         : Minimum contig size to consider a genome
                                  for indexing. Default: false

--wsnp_serocol                  : Column number (non 0-based index) of the
                                  PDG metadata file by which the serotypes
                                  are collected. Default: false

--wsnp_complete_sero            : Skip indexing serotypes when the serotype
                                  name in the column number 49 (non 0-based)
                                  of PDG metadata file consists a "-". For
                                  example, if an accession has a serotype=
                                  string as such in column number 49 (non 0-
                                  based): "serotype=- 13:z4,z23:-" then, the
                                  indexing of that accession is skipped.
                                  Default: true

--wsnp_not_null_serovar         : Only index the computed_serotype column i.e
                                  . column number 49 (non 0-based), if the
                                  serovar column is not NULL.  Default: false

--wsnp_i                        : Force include this serovar. Ignores --
                                  wsnp_complete_sero for only this serovar.
                                  Mention multiple serovars separated by a
                                  ! (Exclamation mark). Ex: --
                                  wsnp_complete_sero I 4,[5],12:i:-!Agona
                                  Default: 'I 4,[5],12:i

--wsnp_num                      : Number of genome accessions to collect per
                                  SNP cluster. Default: false

--mashsketch_run                : Run `mash screen` tool. Default: true

--mashsketch_l                  : List input. Lines in each <input> specify
                                  paths to sequence files, one per line.
                                  Default: true

--mashsketch_I                  : <path>  ID field for sketch of reads (
                                  instead of first sequence ID). Default:
                                  false

--mashsketch_C                  : <path>  Comment for a sketch of reads (
                                  instead of first sequence comment). Default
                                  : false

--mashsketch_k                  : <int>   K-mer size. Hashes will be based on
                                  strings of this many nucleotides.
                                  Canonical nucleotides are used by default (
                                  see Alphabet options below). (1-32) Default
                                  : 21

--mashsketch_s                  : <int>   Sketch size. Each sketch will have
                                  at most this many non-redundant min-hashes
                                  . Default: 1000

--mashsketch_i                  : Sketch individual sequences, rather than
                                  whole files, e.g. for multi-fastas of
                                  single-chromosome genomes or pair-wise gene
                                  comparisons. Default: false

--mashsketch_S                  : <int>   Seed to provide to the hash
                                  function. (0-4294967296) [42] Default:
                                  false

--mashsketch_w                  : <num>   Probability threshold for warning
                                  about low k-mer size. (0-1) Default: false

--mashsketch_r                  : Input is a read set. See Reads options
                                  below. Incompatible with --mashsketch_i.
                                  Default: false

--mashsketch_b                  : <size>  Use a Bloom filter of this size (
                                  raw bytes or with K/M/G/T) to filter out
                                  unique k-mers. This is useful if exact
                                  filtering with --mashsketch_m uses too much
                                  memory. However, some unique k-mers may
                                  pass erroneously, and copies cannot be
                                  counted beyond 2. Implies --mashsketch_r.
                                  Default: false

--mashsketch_m                  : <int>   Minimum copies of each k-mer
                                  required to pass noise filter for reads.
                                  Implies --mashsketch_r. Default: false

--mashsketch_c                  : <num>   Target coverage. Sketching will
                                  conclude if this coverage is reached before
                                  the end of the input file (estimated by
                                  average k-mer multiplicity). Implies --
                                  mashsketch_r. Default: false

--mashsketch_g                  : <size>  Genome size (raw bases or with K/M/
                                  G/T). If specified, will be used for p-
                                  value calculation instead of an estimated
                                  size from k-mer content. Implies --
                                  mashsketch_r. Default: false

--mashsketch_n                  : Preserve strand (by default, strand is
                                  ignored by using canonical DNA k-mers,
                                  which are alphabetical minima of forward-
                                  reverse pairs). Implied if an alphabet is
                                  specified with --mashsketch_a or --
                                  mashsketch_z. Default: false

--mashsketch_a                  : Use amino acid alphabet (A-Z, except BJOUXZ
                                  ). Implies --mashsketch_n --mashsketch_k 9
                                  . Default: false

--mashsketch_z                  : <text>  Alphabet to base hashes on (case
                                  ignored by default; see --mashsketch_Z). K-
                                  mers with other characters will be ignored
                                  . Implies --mashsketch_n. Default: false

--mashsketch_Z                  : Preserve case in k-mers and alphabet (case
                                  is ignored by default). Sequence letters
                                  whose case is not in the current alphabet
                                  will be skipped when sketching. Default:
                                  false

Help options                    :

--help                          : Display this message.

```
