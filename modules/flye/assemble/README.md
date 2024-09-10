# NextFlow DSL2 Module

```bash
FLYE_ASSEMBLE
```

## Description

Run `flye` assembler tool on a list of read files in FASTQ format.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of FASTQ files of input type `path` (`reads`).

Ex:

```groovy
[ [id: 'sample1', single_end: true], '/data/sample1/f_merged.fq.gz' ]
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

#### `reads`

Type: `path`

NextFlow input type of `path` pointing to read files in FASTQ format that need to be *de novo* assembled.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'FLYE_ASSEMBLE' {
    ext.args = '--casava'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `flye` assembled contig file in FASTA format.

\
&nbsp;

#### `assembly`

Type: `path`

NextFlow output type of `path` pointing to the `flye` assembler results file per sample (`id:`) i.e., the final assembled contig file in FASTA format.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
