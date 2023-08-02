# NextFlow DSL2 Module

```bash
ABRICATE_RUN
```

## Description

Run `abricate` tool on a list of assembled contigs in FASTA format given a list of database names. Produces a single output table in ASCII text format per database.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of assemled contig FASTA files of input type `path` (`assembly`).

Ex:

```groovy
[ [id: 'sample1', single_end: true], '/data/sample1/f_assembly.fa' ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTQ file.

Ex:

```groovy
[ id: 'FAL00870', strandedness: 'unstranded', single_end: true ]
```

\
&nbsp;

#### `assembly`

Type: `path`

NextFlow input type of `path` pointing to assembled contig file in FASTA format.

\
&nbsp;

#### `abdbs`

Type: `val`

Nextflow input type of `val` containing a list of at least one of the following database names on which `abricate` should be run.

Ex:

```groovy
[ 'resfinder', 'megares', 'ncbi', 'ncbiamrplus', 'argannot' , 'ecoli_vf' ]
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and list of `abricate` result files (`abricated`).

\
&nbsp;

#### `abricated`

Type: `path`

NextFlow output type of `path` pointing to the `abricate` results table file per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
