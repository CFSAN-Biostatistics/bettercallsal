# NextFlow DSL2 Module

```bash
SALMON_INDEX
```

## Description

Run `salmon index` command on input FASTA file.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a FASTA file of type `path` (`genome_fasta`) per sample (`id:`).

Ex:

```groovy
[ 
    [ 
        id: 'FAL00870'
    ],
    [
        '/hpc/scratch/test/FAL00870_contigs.fasta',
    ]
]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the genome FASTA file.

Ex:

```groovy
[ 
    id: 'FAL00870'
]
```

\
&nbsp;

#### `genome_fasta`

Type: `path`

NextFlow input type of `path` pointing to the FASTA file (gzipped or unzipped) on which `salmon index` should be run.

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and a folder containing `salmon index` result files.

\
&nbsp;

#### `idx`

Type: `path`

NextFlow output type of `path` pointing to the `salmon index` result files per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
