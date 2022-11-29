# NextFlow DSL2 Module

```bash
TABLE_SUMMARY
```

## Description

Concatenates a list of tables (CSV or TAB delimited) in `.txt` or `.csv` format. The table files to be concatenated **must** have a header as the header from one of the table files will be used as the header for the concatenated result table file.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of `val` table key (`table_sum_on`) and a list of table files of input type `path` (`tables`) to be concatenated. For this module to work, a `bin` directory with the script `create_mqc_data_table.py` should be present where the NextFlow script using this DSL2 module will be run. This `python` script will convert the aggregated table to `.yml` format to be used with `multiqc`.

Ex:

```groovy
[ ['ectyper'], ['/data/sample1/f1_ectyper.txt', '/data/sample2/f2_ectyper.txt'] ]
```

\
&nbsp;

#### `table_sum_on`

Type: `val`

A single key defining what tables are being concatenated. For example, if all the `ectyper` results are being concatenated for all samples, then this can be `ectyper`.

Ex:

```groovy
[ ['ectyper'], ['/data/sample1/f1_ectyper.txt', '/data/sample2/f2_ectyper.txt'] ]
```

\
&nbsp;

#### `tables`

Type: `path`

NextFlow input type of `path` pointing to a list of tables (files) to be concatenated.

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of table key (`table_sum_on` from `input:`) and list of concatenated table files (`tblsummed`).

\
&nbsp;

#### `tblsummed`

Type: `path`

NextFlow output type of `path` pointing to the concatenated table files per table key (Ex: `ectyper`).

\
&nbsp;

#### `mqc_yml`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing table contents in `YAML` format which can be used to inject this table as part of the `multiqc` report.

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
