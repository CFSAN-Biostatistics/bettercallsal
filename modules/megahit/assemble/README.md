# NextFlow DSL2 Module

```bash
MEGAHIT_ASSEMBLE
```

## Description

Run `megahit` assembler tool on a list of read files in FASTQ format.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of FASTQ files (short reads) of input type `path` (`reads`).

Ex:

```groovy
[ [id: 'sample1', single_end: true], '/data/sample1/f_merged.fq.gz' ]
[ [id: 'sample1', single_end: false], ['/data/sample1/f1_merged.fq.gz', '/data/sample2/f2_merged.fq.gz'] ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTQ file.

Ex:

```groovy
[ id: 'KB01', strandedness: 'unstranded', single_end: true ]
```

\
&nbsp;

#### `reads`

Type: `path`

NextFlow input type of `path` pointing to short read files in FASTQ format that need to be *de novo* assembled.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'MEGAHIT_ASSEMBLE' {
    ext.args = '--keep-tmp-files'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `megahit` assembled contigs file in FASTA format.

\
&nbsp;

#### `assembly`

Type: `path`

NextFlow output type of `path` pointing to the `megahit` assembler results file (`final.contigs.fa`) per sample (`id:`) i.e., the final assembled contigs file in FASTA format.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
