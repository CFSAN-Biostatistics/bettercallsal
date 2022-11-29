# NextFlow DSL2 Module

```bash
BBTOOLS_BBMERGE
```

## Description

Run `bbmerge.sh` from `BBTools` which will merge paired-end reads to produce single-end reads by overlap detection.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of reads of type `path` (`reads`) per sample (`id:`).

Ex:

```groovy
[ 
    [ 
        id: 'FAL00870',
        strandedness: 'unstranded',
        single_end: false
    ],
    [
        '/hpc/scratch/test/f1.R1.fq.gz',
        '/hpc/scratch/test/f1.R2.fq.gz'
    ]
]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTQ file.

Ex:

```groovy
[ 
    id: 'FAL00870',
    strandedness: 'unstranded',
    single_end: true
]
```

\
&nbsp;

#### `reads`

Type: `path`

NextFlow input type of `path` pointing to paired-end FASTQ files on which `bbmerge.sh` should be run.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'BBTOOLS_BBMERGE' {
    ext.args = 'minprog=0.5'
}
```

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and merged gzipped FASTQ file.

\
&nbsp;

#### `fastq`

Type: `path`

NextFlow output type of `path` pointing to the FASTQ format merged gzipped file per sample (`id:`).

\
&nbsp;

#### `log`

Type: `path`

NextFlow output type of `path` pointing to log file from `bbmerge.sh` run per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
