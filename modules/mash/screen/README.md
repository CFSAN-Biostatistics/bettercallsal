# NextFlow DSL2 Module

```bash
MASH_SCREEN
```

## Description

Run `mash screen` on the input FASTQ file.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of reads of type `path` (`query`) per sample (`id:`).

Ex:

```groovy
[ 
    [ 
        id: 'FAL00870'
    ],
    [
        '/hpc/scratch/test/f1.fq.gz'
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
    id: 'FAL00870'
]
```

\
&nbsp;

#### `query`

Type: `path`

NextFlow input type of `path` pointing to FASTQ file to be screened.

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `mash screen` result file ending with suffix `.screened`.

\
&nbsp;

#### `screened`

Type: `path`

NextFlow output type of `path` pointing to the result (`*.screened`) of the `mash screen` command per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
