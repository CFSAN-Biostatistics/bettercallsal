# NextFlow DSL2 Module

```bash
ABRICATE_SUMMARY
```

## Description

Run `abricate` tool's `summary` sub-command on a list of `abricate`'s result table files per database.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of `abricate` database names of type `val` (`abdbs`) and a list of `abricate` result table files for all databases of type `path` (`abfiles`).

Ex:

```groovy
[ 
    [ 'megares', 'argannot', 'resfinder', 'ncbi' ], 
    [ '/data/sample1/f.ncbi.ab.txt',
      '/data/sample1/f.megares.ab.txt',
      '/data/sample1/f.resfinder.ab.txt',
      '/data/sample1/f.argannot.ab.txt',
      '/data/sample1/f2.ncbi.ab.txt',
      '/data/sample1/f2.megares.ab.txt',
      '/data/sample1/f2.resfinder.ab.txt',
      '/data/sample1/f2.argannot.ab.txt'
    ]
]
```

\
&nbsp;

#### `abdbs`

Type: `val`

A Groovy List containing the **mandatory** list of at least the following 4 `abricate` database names on which `abricate` was run.

Ex:

```groovy
[ 'resfinder', 'megares', 'ncbi', 'argannot' ]
```

\
&nbsp;

#### `abfiles`

Type: `path`

NextFlow input type of `path` pointing to `abricate` result files for each of the database.

\
&nbsp;

### `output:`

___

#### `ncbi`

Type: `tuple`
\
Optional: `true`

Outputs a tuple of `abricate` database key (`abricate_ncbi`) and summary result file from `abricate summary` command of type `path` (`ncbi`). This database includes only core AMR genes. This tuple is emitted optionally only where there are output files with suffix `.ncbi.absum.txt`

\
&nbsp;

#### `ncbiamrplus`

Type: `tuple`
\
Optional: `true`

Outputs a tuple of `abricate` database key (`abricate_ncbiamrplus`) and summary result file from `abricate summary` command of type `path` (`ncbiamrplus`). This database includes both core AMR genes and plus AMR genes. This tuple is emitted optionally only where there are output files with suffix `.ncbiamrplus.absum.txt`

\
&nbsp;

#### `resfinder`

Type: `tuple`
\
Optional: `true`

Outputs a tuple of `abricate` database key (`abricate_resfinder`) and summary result file from `abricate summary` command of type `path` (`resfinder`). This tuple is emitted optionally only where there are output files with suffix `.resfinder.absum.txt`

\
&nbsp;

#### `megares`

Type: `tuple`
\
Optional: `true`

Outputs a tuple of `abricate` database key (`abricate_megares`) and summary result file from `abricate summary` command of type `path` (`megares`). This tuple is emitted optionally only where there are output files with suffix `.megares.absum.txt`

\
&nbsp;

#### `argannot`

Type: `tuple`
\
Optional: `true`

Outputs a tuple of `abricate` database key (`abricate_argannot`) and summary result file from `abricate summary` command of type `path` (`argannot`). This tuple is emitted optionally only where there are output files with suffix `.argannot.absum.txt`

\
&nbsp;

#### `ecoli_vf`

Type: `tuple`
\
Optional: `true`

Outputs an **optional** tuple of `abricate` database key (`abricate_ecoli_vf`) and summary result file from `abricate summary` command of type `path` (`ecoli_vf`). This tuple is emitted only when there are output files with suffix `.ecoli_vf.absum.txt` within the `work` folder.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
