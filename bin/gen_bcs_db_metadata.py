#!/usr/bin/env python3

# Kranti Konganti

import argparse
import csv
import inspect
import json
import logging
import os
import pickle
import pprint
import re
import sys


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(
    argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter
):
    pass


# Validate that the specified file exists and is not empty.
def validate_file(file_path: str, file_type: str) -> None:
    """Validate that a file exists and is not empty."""
    if not os.path.exists(file_path) or not os.path.getsize(file_path) > 0:
        logging.error(
            (
                f"{file_type} file {os.path.basename(file_path)} does not exist "
                "\nor is of size 0."
            )
        )
        sys.exit(1)


# Apply egex cleaning rules to field values.
def clean_field_value(value, cleaning_rules=None):
    """Apply multiple regex replacements to a field value."""
    if cleaning_rules is None:
        cleaning_rules = []

    result = value
    for rule in cleaning_rules:
        try:
            # Parse sed-style pattern: s/pattern/replacement/g
            # Extract pattern and replacement parts
            if rule.startswith("s/") and rule.endswith("/g"):
                # Extract everything between first and last slash
                pattern_part = rule[2:-2]
                replacement_start = pattern_part.find("/")
                pattern = pattern_part[:replacement_start]
                replacement = pattern_part[replacement_start + 1 :]
                result = re.sub(pattern, replacement, result)
            else:
                logging.warning(
                    f"Cleaning rule '{rule}' doesn't match sed format. Skipping."
                )
        except Exception as e:
            logging.error(f"Error applying cleaning rule '{rule}': {e}. Skipping.")
            sys.exit(1)

    return result


# Main
def main() -> None:
    """
    This script works only in the context of `bettercallsal` Nextflow workflow.
    It takes an UNIX path to pickle file with indexed `bettercallsal` database metadata and
    and a list of genome hits' accessions, one per line and generates metadata CSV file. If
    the list of accessions is empty, then,
        1.
        2. PDG SNP Cluster metadata file (Ex: `PDG000000002.3793.reference_target.cluster_list.tsv`)
        3. A list of possibly downloadable assembly accessions (one per line) from the metadata file.
    and then generates a pickled file with relevant metadata columns mentioned with the -cols option.
    """

    # Set logging.
    logging.basicConfig(
        format="\n"
        + "=" * 55
        + "\n%(asctime)s - %(levelname)s\n"
        + "=" * 55
        + "\n%(message)s\n\n",
        level=logging.DEBUG,
    )

    # Debug print.
    ppp = pprint.PrettyPrinter(width=55)
    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-pickle",
        dest="pfile",
        default=False,
        required=True,
        help="Absolute UNIX path to the indexed BCS DB Metadata\npickle file.",
    )
    required.add_argument(
        "-hits",
        dest="genome_hits",
        required=True,
        help=(
            "Absolute UNIX path to genome hits' file where each\nline is the"
            "genome accession (GCA|GCF).\n"
        ),
    )
    parser.add_argument(
        "--acc-pat",
        dest="acc_pat",
        default=re.compile(r"^GC[AF]\_\d+\.?\d*"),
        required=False,
        help="The pattern to be used to validate Genome accession.\n",
    )
    parser.add_argument(
        "--first-col-name",
        dest="fcol_name",
        default="ID",
        help="Name of the first column which will be the genome hit.",
    )
    parser.add_argument(
        "-out",
        dest="outfile",
        default=os.path.join(os.getcwd(), "BCS_UNIQ_METADATA.csv"),
        help="Set the output file.\n",
    )
    parser.add_argument(
        "--cleaning-rule",
        dest="cleaning_rules",
        action="append",
        default=[
            's/"//g',
            "s/\s*\|\s*/|/g",
            "s/serotype=//g",
            "s/,antigen_formula=/|/g",
        ],
        required=False,
        help=(
            "Add a regex pattern to clean field values.\nCan be specified multiple times. "
            "\nEach pattern is applied in order. "
            "\n\nExample: --cleaning-rule 's/^\"|\"$//g' "
            "\n--cleaning-rule 's/ +/ /g'.\n"
        ),
    )

    args = parser.parse_args()
    pfile = args.pfile
    acc_pat = args.acc_pat
    genome_hits = args.genome_hits
    out_file = args.outfile
    fcol_name = str(args.fcol_name)

    # Parse and validate cleaning rules
    cleaning_rules = []
    for i, rule_pattern in enumerate(args.cleaning_rules):
        rule_pattern = rule_pattern.strip()
        try:
            # Validate the regex pattern by compiling it
            re.compile(rule_pattern)
            cleaning_rules.append(rule_pattern)
        except re.error as e:
            logging.error(
                f"Invalid regex pattern at index {i}: {rule_pattern}. Error: {e}"
            )
            sys.exit(1)

    # Basic checks

    validate_file(pfile, "Pickle")
    validate_file(genome_hits, "Genome hits")

    logging.info("Loading bettercallsal indexed metadata into memory...")
    bcs_db_metadata = pickle.load(open(pfile, "rb"))
    bcs_db_metadata_header = list(bcs_db_metadata[next(iter(bcs_db_metadata))].keys())
    bcs_db_metadata_header.insert(0, fcol_name)
    total_accs = 0

    # Start writing the CSV metadata.
    with open(out_file, "w", newline="", encoding="utf-8") as csv_fh:
        csv_out = csv.DictWriter(
            csv_fh, fieldnames=[hv.upper() for hv in bcs_db_metadata_header]
        )
        csv_out.writeheader()

        # Start reading the accessions from the provided -hits.
        logging.info(f"Readling hits file {os.path.basename(genome_hits)}...")
        with open(genome_hits, "r") as genome_hits_fh:
            for line in genome_hits_fh:
                line = line.strip()

                if re.search(acc_pat, line) and line in bcs_db_metadata.keys():
                    csv_rem_row = {
                        k.upper(): clean_field_value(
                            "|".join(bcs_db_metadata[line][k]), cleaning_rules
                        )
                        for k in bcs_db_metadata[line].keys()
                    }
                    csv_row = {fcol_name: line} | csv_rem_row
                    csv_out.writerow(csv_row)
                    total_accs += 1
        genome_hits_fh.close()
    csv_fh.close()

    logging.info(f"Total metadata rows written: {total_accs}.")


if __name__ == "__main__":
    main()
