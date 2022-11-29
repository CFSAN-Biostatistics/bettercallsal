# NextFlow DSL2 Module

```bash
FASTQC
```

## Description

Run `fastqc` tool on reads in FASTQ format. Produces a HTML report file and a `.zip` file containing plots and data used to produce the plots.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of reads of type `path` (`reads`) per sample (`id:`).

Ex:

```groovy
[ 
    [ id: 'FAL00870',
       strandedness: 'unstranded',
       single_end: true,
       centrifuge_x: '/hpc/db/centrifuge/2022-04-12/ab'
    ],
    '/hpc/scratch/test/FAL000870/f1.merged.fq.gz'
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

NextFlow input type of `path` pointing to FASTQ files on which `fastqc` classification should be run.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'FASTQC' {
    ext.args = '--nano'
}
```

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and list of `fastqc` result files.

\
&nbsp;

#### `html`

Type: `path`

NextFlow output type of `path` pointing to the `fastqc` report file in HTML format per sample (`id:`).

\
&nbsp;

#### `zip`

Type: `path`

NextFlow output type of `path` pointing to the zipped `fastqc` results per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
