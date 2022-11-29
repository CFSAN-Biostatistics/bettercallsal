# NextFlow DSL2 Module

```bash
MASH_SKETCH
```

## Description

Run `mash sketch` on the input FASTQ or FASTA files, gzipped or unzipped.

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

NextFlow input type of `path` pointing to either FASTQ or FASTA files to be sketched.

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and `mash sketch` files ending with suffix `.msh`.

\
&nbsp;

#### `sketch`

Type: `path`

NextFlow output type of `path` pointing to the sketch (`*.msh`) file per sample (`id:`).

\
&nbsp;

#### `stats`

Type: `path`

NextFlow output type of `path` pointing to the log of the `mash sketch` command per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
