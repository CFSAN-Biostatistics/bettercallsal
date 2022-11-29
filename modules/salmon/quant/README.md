# NextFlow DSL2 Module

```bash
SALMON_QUANT
```

## Description

Run `salmon quant` in `reads` or `alignments` mode. The inputs can be either the alignment (Ex: `.bam`) files or read (Ex: `.fastq.gz`) files.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and either an alignment file or reads file and a `salmon index` or a transcript FASTA file per sample (`id:`).

Ex:

```groovy
[ 
    [ 
        id: 'FAL00870',
        strandedness: 'unstranded',
        single_end: true
    ],
    [
        '/hpc/scratch/test/FAL00870_R1.fastq.gz'
    ],
    [
        '/hpc/scratch/test/salmon_idx_for_FAL00870'
    ]
]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the input setup for `salmon quant`.

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

#### `reads_or_bam`

Type: `path`

NextFlow input type of `path` pointing to either an alignment file (Ex: `.bam`) or a reads file (Ex: `.fastq.gz`) on which `salmon quant` should be run.

\
&nbsp;

#### `index_or_tr_fasta`

Type: `path`

NextFlow input type of `path` pointing to either a folder containing `salmon index` files or a trasnscript FASTA file.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'SALMON_QUANT' {
    ext.args = '--vbPrior 0.02'
}
```

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and a folder containing `salmon quant` result files.

\
&nbsp;

#### `results`

Type: `path`

NextFlow output type of `path` pointing to the `salmon quant` result files per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
