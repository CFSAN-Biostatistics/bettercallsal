# NextFlow DSL2 Module

```bash
CAT_FASTQ
```

## Description

Concatenates a list of FASTQ files. Produces 2 files per sample (`id:`) if `single_end` is `false` as mentioned in the metadata Groovy Map.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of FASTQ files of input type `path` (`reads`) to be concatenated.

Ex:

```groovy
[ [id: 'sample1', single_end: true], ['/data/sample1/f_L001.fq', '/data/sample1/f_L002.fq'] ]
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

NextFlow input type of `path` pointing to list of FASTQ files.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'CAT_FASTQ' {
    ext.args = '--genome_size 5.5m'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and list of concatenated FASTQ files (`catted_reads`).

\
&nbsp;

#### `catted_reads`

Type: `path`

NextFlow output type of `path` pointing to the concatenated FASTQ files per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
