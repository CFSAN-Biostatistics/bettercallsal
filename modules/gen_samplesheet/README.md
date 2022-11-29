# NextFlow DSL2 Module

```bash
GEN_SAMPLESHEET
```

## Description

Generates a sample sheet in CSV format that contains required fields to be used to construct a Groovy Map of metadata. It requires as input, an absolute UNIX path to a folder containing only FASTQ files. This module requires the `fastq_dir_to_samplesheet.py` script to be present in the `bin` folder from where the NextFlow script including this module will be executed.

\
&nbsp;

### `input:`

___

Type: `val`

Takes in the absolute UNIX path to a folder containing only FASTQ files (`inputdir`).

Ex:

```groovy
'/hpc/scratch/test/reads'
```

\
&nbsp;

### `output:`

___

Type: `path`

NextFlow output of type `path` pointing to auto-generated CSV sample sheet (`csv`).

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
