# NextFlow DSL2 Module

```bash
KMA_INDEX
```

## Description

Run `kma index` alinger on input FASTA files.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a FASTA file of type `path` (`fasta`) per sample (`id:`).

Ex:

```groovy
[ 
    [ 
        id: 'FAL00870',
    ],
    '/path/to/FAL00870_contigs.fasta'
]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTA file.

Ex:

```groovy
[ 
    id: 'FAL00870'
]
```

\
&nbsp;

#### `fasta`

Type: `path`

NextFlow input type of `path` pointing to the FASTA file on which the `kma index` command should be run.

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and a folder containing `kma index` files.

\
&nbsp;

#### `idx`

Type: `path`

NextFlow output type of `path` pointing to the folder containing `kma index` files per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
