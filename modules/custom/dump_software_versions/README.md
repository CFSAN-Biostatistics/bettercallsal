# NextFlow DSL2 Module

```bash
DUMP_SOFTWARE_VERSIONS
```

## Description

Given an `YAML` format file, produce a final `.yml` file which has unique entries and a corresponding `.mqc.yml` file for use with `multiqc`.

\
&nbsp;

### `input:`

___

Type: `path`

Takes in a `path` (`versions`) type pointing to the file to be used to produce a final `.yml` file without any duplicate entries and a `.mqc.yml` file. Generally, this is passed by mixing `versions` from various run time channels and finally passed to this module to produce a final software versions list.

Ex:

```groovy
[ '/hpc/scratch/test/work/9b/e7bf7e28806419c1c9a571dacd1f67/versions.yml' ]
```

\
&nbsp;

### `output:`

___

#### `yml`

Type: `path`

NextFlow output type of `path` type pointing to an `YAML` file with software versions.

\
&nbsp;

#### `mqc_yml`

Type: `path`

NextFlow output type of `path` pointing to `.mqc.yml` file which can be used to produce a software versions' table with `multiqc`.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
