# NextFlow DSL2 Module

```bash
SAMPLESHEET_CHECK
```

## Description

Checks the validity of the sample sheet in CSV format to make sure there are required mandatory fields. This module generally succeeds `GEN_SAMPLESHEET` module as part of the `cpipes` pipelines to make sure that all fields of the columns are properly formatted to be used as Groovy Map for `meta` which is of input type `val`. This module requires the `check_samplesheet.py` script to be present in the `bin` folder from where the NextFlow script including this module will be executed

\
&nbsp;

### `input:`

___

Type: `path`

Takes in the absolute UNIX path to the sample sheet in CSV format (`samplesheet`).

Ex:

```groovy
'/hpc/scratch/test/reads/output/gen_samplesheet/autogen_samplesheet.csv'
```

\
&nbsp;

### `output:`

___

Type: `path`

NextFlow output of type `path` pointing to properly formatted CSV sample sheet (`csv`).

\
&nbsp;

#### `csv`

Type: `path`

NextFlow output type of `path` pointing to auto-generated CSV sample sheet for all FASTQ files present in the folder given by NextFlow input type of `val` (`inputdir`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
