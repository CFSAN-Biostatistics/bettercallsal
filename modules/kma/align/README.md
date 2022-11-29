# NextFlow DSL2 Module

```bash
KMA_ALIGN
```

## Description

Run `kma` alinger on input FASTQ files with a pre-formatted `kma` index.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of reads of type `path` (`reads`) and a correspondonding `kma` pre-formatted index folder per sample (`id:`).

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
    ],
    '/path/to/kma/index/folder'
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

#### `index`

Type: `path`

NextFlow input type of `path` pointing to folder containing `kma` index files.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'KMA_ALIGN' {
    ext.args = '-mint2'
}
```

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `kma` result files.

\
&nbsp;

#### `res`

Type: `path`

NextFlow output type of `path` pointing to the `.res` file from `kma` per sample (`id:`).

\
&nbsp;

#### `mapstat`

Type: `path`

NextFlow output type of `path` pointing to the `.map` file from `kma` per sample (`id:`). Optional: `true`

\
&nbsp;

#### `hits`

Type: `path`

NextFlow output type of `path` pointing to a `*_template_hits.txt` file containing only hit IDs. Optional: `true`

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
