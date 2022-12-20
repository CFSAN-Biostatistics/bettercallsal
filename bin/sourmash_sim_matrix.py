#!/usr/bin/env python3

# Kranti Konganti

import os
import argparse
import inspect
import logging
import re
import pickle
import pprint
import json
from collections import defaultdict

# Set logging.
logging.basicConfig(
    format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n\n",
    level=logging.DEBUG,
)

# Debug print.
ppp = pprint.PrettyPrinter(width=50, indent=4)

# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main() -> None:
    """
    This script works only in the context of `bettercallsal` Nextflow workflow.
    It takes:
        1. A CSV file containing a similarity matrix or dissimilarity matrix where
            the header row contains the names.
        3. It takes indexed NCBI Pathogen metadata in pickle format and converts
            accessions to serotype names in the final distance matrix output.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-csv",
        dest="mat",
        default=False,
        required=True,
        help="Absolute UNIX path to .csv file containing similarity\n"
        + "or dissimilarity matrix from `sourmash compare`.",
    )
    required.add_argument(
        "-pickle",
        dest="acc2sero",
        default=False,
        required=True,
        help="Absolute UNIX Path to the *ACC2SERO.pickle\n"
        + "metadata file. On raven2, these are located at\n"
        + "/hpc/db/bettercallsal/PDGXXXXXXXXXX.XXXXX/",
    )
    required.add_argument(
        "-labels",
        dest="labels",
        default=False,
        required=True,
        help="Absolute UNIX Path to the *.labels.txt\n"
        + "file from `sourmash compare`. The accessions\n"
        + "will be renanamed to serotype names.",
    )

    args = parser.parse_args()
    csv = args.mat
    labels = args.labels
    pickled_sero = args.acc2sero
    row_names = list()
    distance_mat = defaultdict(defaultdict)
    out_csv = os.path.join(os.getcwd(), "bcs_sourmash_matrix.tblsum.txt")
    out_json = os.path.join(os.getcwd(), "bcs_sourmash_matrix_mqc.json")

    # Prepare dictionary to be dumped as JSON.
    distance_mat["id"] = "BETTERCALLSAL_CONTAINMENT_INDEX"
    distance_mat["section_name"] = "Containment index"
    distance_mat["description"] = (
        "This section shows the containment index between a sample and the genomes"
        + "by running <code>sourmash gather</code> "
        + "using <code>--containment</code> option."
    )
    distance_mat["plot_type"] = "heatmap"
    distance_mat["pconfig"]["id"] = "bettercallsal_containment_index_heatmap"
    distance_mat["pconfig"]["title"] = "Sourmash: containment index"
    distance_mat["pconfig"]["xTitle"] = "Samples"
    distance_mat["pconfig"]["yTitle"] = "Isolates (Genome assemblies)"
    distance_mat["pconfig"]["ycats_samples"] = "False"
    distance_mat["pconfig"]["xcats_samples"] = "False"
    distance_mat["pconfig"]["square"] = "False"
    distance_mat["pconfig"]["min"] = "0.0"
    distance_mat["pconfig"]["max"] = "1.0"
    distance_mat["data"]["data"] = list()

    if pickled_sero and (not os.path.exists(pickled_sero) or not os.path.getsize(pickled_sero)):
        logging.error(
            "The pickle file,\n" + f"{os.path.basename(pickled_sero)} does not exist or is empty!"
        )
        exit(1)
    else:
        acc2sero = pickle.load(file=open(pickled_sero, "rb"))

    if csv and (not os.path.exists(csv) or not os.path.getsize(csv) > 0):
        logging.error("File,\n" + f"{csv}\ndoes not exist " + "or is empty!")
        exit(0)

    if labels and (not os.path.exists(labels) or not os.path.getsize(labels) > 0):
        logging.error("File,\n" + f"{labels}\ndoes not exist " + "or is empty!")
        exit(0)

    # with open(out_labels, "w") as out_labels_fh:
    with open(labels, "r") as labels_fh:
        for line in labels_fh:
            line = line.strip()
            if line not in acc2sero.keys():
                row_names.append(line)

    labels_fh.close()

    with open(out_csv, "w") as csv_out_fh:
        with open(csv, "r") as csv_in_fh:
            header = csv_in_fh.readline().strip().split(",")
            acc_cols = [idx for idx, col in enumerate(header) if col in acc2sero.keys()]
            sample_cols = [idx for idx, col in enumerate(header) if col not in acc2sero.keys()]

            col_names = [
                re.sub(r"serotype=|\,antigen_formula=.*?\|", "", s)
                for s in [acc2sero[col] + f"| | {col}" for col in header if col in acc2sero.keys()]
            ]

            distance_mat["xcats"] = col_names
            csv_out_fh.write("\t".join(["Sample"] + col_names) + "\n")
            line_num = 0

            for line in csv_in_fh:
                if line_num not in sample_cols:
                    continue
                else:

                    heatmap_rows = [
                        str(round(float(line.strip().split(",")[col]), 5)) for col in acc_cols
                    ]
                    # distance_mat["data"]["hmdata"].append(heatmap_rows)
                    # distance_mat["data"][row_names[line_num]] = heatmap_rows
                    distance_mat["data"]["data"].append(heatmap_rows)
                    # distance_mat["data"][row_names[line_num]] = dict(
                    #     [(col_names[idx], val) for idx, val in enumerate(heatmap_rows)]
                    # )
                    csv_out_fh.write("\t".join([row_names[line_num]] + heatmap_rows) + "\n")
                    line_num += 1
        csv_in_fh.close()
    csv_out_fh.close()

    distance_mat["ycats"] = row_names
    json.dump(distance_mat, open(out_json, "w"))


if __name__ == "__main__":
    main()
