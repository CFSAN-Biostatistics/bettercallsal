#!/usr/bin/env python3

# Kranti Konganti

import argparse
import inspect
import logging
import os
import pickle
import pprint
import re
from collections import defaultdict


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(
    argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter
):
    pass


# Main
def main() -> None:
    """
    This script works only in the context of `bettercallsal` Nextflow workflow.
    It takes an UNIX path to directory containing the following files:
        1. PDG metadata file (Ex: `PDG000000002.3793.metadata.tsv`)
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
        "-pdg_dir",
        dest="pdg_dir",
        default=False,
        required=True,
        help="Absolute UNIX path to directory containing the following files.\nEx:"
        + "\n1. PDG000000002.3793.metadata.tsv"
        + "\n2. PDG000000002.3793.reference_target.cluster_list.tsv"
        + "\n3. A file of assembly accessions, one per line parsed out from"
        + "\n   the metadata file.",
    )
    parser.add_argument(
        "-mlst",
        dest="mlst_results",
        required=False,
        help="Absolute UNIX path to MLST results file\nIf MLST results exists for a accession, they"
        + "\nwill be included in the index.",
    )
    parser.add_argument(
        "-pdg_meta_pat",
        dest="pdg_meta_pat",
        default="PDG\d+\.\d+\.metadata\.tsv",
        required=False,
        help="The pattern to be used to search for PDG metadata\nfile.",
    )
    parser.add_argument(
        "-pdg_snp_meta_pat",
        dest="pdg_snp_meta_pat",
        default="PDG\d+\.\d+\.reference\_target\.cluster\_list\.tsv",
        required=False,
        help="The pattern to be used to search for PDG SNP Cluster metadata\nfile.",
    )
    parser.add_argument(
        "-pdg_accs_filename_pat",
        dest="pdg_accs_fn_pat",
        default="accs_all.txt",
        required=False,
        help="The filename to look for where all the parsed GC[AF] accessions are stored,\n"
        + "one per line.",
    )
    parser.add_argument(
        "-cols",
        dest="metadata_cols",
        default="epi_type,collected_by,collection_date,host,"
        + "\nhost_disease,isolation_source,outbreak,sample_name,scientific_name,serovar,"
        + "\nsource_type,strain,computed_types,target_acc",
        required=False,
        help="The data in these metadata columns will be indexed for each\nisolate.",
    )
    parser.add_argument(
        "-fs",
        dest="force_write_pick",
        action="store_true",
        required=False,
        help="By default, when -s flag is on, the pickle file named *.IDXD_PDG_METAD.pickle"
        + "\nis written to CWD. If the file exists, the program will not overwrite"
        + "\nand exit. Use -fs option to overwrite.",
    )
    parser.add_argument(
        "-op",
        dest="out_prefix",
        default="IDXD_PDG_METAD",
        help="Set the output file prefix for indexed PDG metadata.",
    )
    parser.add_argument(
        "-pfs",
        dest="pdg_meta_fs",
        default="\t",
        help="Change the field separator of the PDG metadata file.",
    )

    args = parser.parse_args()
    pdg_dir = os.path.abspath(args.pdg_dir)
    mcols = args.metadata_cols
    f_write_pick = args.force_write_pick
    out_prefix = args.out_prefix
    pdg_meta_fs = args.pdg_meta_fs
    mlst_res = args.mlst_results
    acc_pat = re.compile(r"^GC[AF]\_\d+\.?\d*")
    mcols_pat = re.compile(r"[\w+\,]")
    pdg_meta_pat = re.compile(f"{args.pdg_meta_pat}")
    pdg_snp_meta_pat = re.compile(f"{args.pdg_snp_meta_pat}")
    pdg_accs_fn_pat = re.compile(f"{args.pdg_accs_fn_pat}")
    target_acc_col = 41
    acc_col = 9
    num_accs_check = list()
    mlst_sts = dict()
    acceptable_num_mlst_cols = 10
    mlst_st_col = 2
    mlst_acc_col = 0

    # Basic checks

    if os.path.exists(pdg_dir) and os.path.isdir(pdg_dir):
        pdg_meta_file = [f for f in os.listdir(pdg_dir) if pdg_meta_pat.match(f)]
        pdg_snp_meta_file = [
            f for f in os.listdir(pdg_dir) if pdg_snp_meta_pat.match(f)
        ]
        pdg_acc_all = [f for f in os.listdir(pdg_dir) if pdg_accs_fn_pat.match(f)]
        req_files = [len(pdg_meta_file), len(pdg_snp_meta_file), len(pdg_acc_all)]
        if any(x > 1 for x in req_files):
            logging.error(
                f"Directory {os.path.basename(pdg_dir)} contains"
                + "\ncontains mulitple files matching the search pattern."
            )
            exit(1)
        elif any(x == 0 for x in req_files):
            logging.error(
                f"Directory {os.path.basename(pdg_dir)} does not contain"
                + "\nany files matching the following file patterns:"
                + f"\n{pdg_meta_pat.pattern}"
                + f"\n{pdg_snp_meta_pat.pattern}"
                + f"\n{pdg_accs_fn_pat.pattern}"
            )
            exit(1)
        pdg_meta_file = os.path.join(pdg_dir, "".join(pdg_meta_file))
        pdg_snp_meta_file = os.path.join(pdg_dir, "".join(pdg_snp_meta_file))
        pdg_acc_all = os.path.join(pdg_dir, "".join(pdg_acc_all))
    else:
        logging.error(f"Directory path {pdg_dir} does not exist.")
        exit(1)

    if mlst_res and not (os.path.exists(mlst_res) or os.path.getsize(mlst_res) > 0):
        logging.error(
            f"Requested to index MLST results. but the file {os.path.basename(mlst_res)}"
            + "does not exist or the file is empty."
        )
        exit(1)
    elif mlst_res:
        with open(mlst_res, "r") as mlst_res_fh:
            header = mlst_res_fh.readline()
            mlst_res_has_10_cols = False

            for line in mlst_res_fh:
                cols = line.strip().split("\t")
                acc = acc_pat.findall(cols[mlst_acc_col])
                if len(acc) > 1:
                    logging.error(
                        f"Found more than 1 accession in column:\ncols[mlst_acc_col]\n"
                    )
                    exit(1)
                else:
                    acc = "".join(acc)
                if len(cols) == acceptable_num_mlst_cols and re.match(
                    r"\d+|\-", cols[mlst_st_col]
                ):
                    mlst_res_has_10_cols = True
                    if re.match(r"\-", cols[mlst_st_col]):
                        mlst_sts[acc] = "NULL"
                    else:
                        mlst_sts[acc] = cols[mlst_st_col]

            if not mlst_res_has_10_cols:
                logging.error(
                    "Requested to incorporate MLST ST's but file"
                    + f"\n{os.path.basename(mlst_res)}"
                    + "\ndoes not have 10 columns in all rows."
                )
                exit(1)

        mlst_res_fh.close()

    with open(pdg_acc_all, "r") as pdg_acc_all_fh:
        for a in pdg_acc_all_fh.readlines():
            num_accs_check.append(a.strip())

    if not mcols_pat.match(mcols):
        logging.error(
            f"Supplied columns' names should only be"
            + "\nalphanumeric (including _) separated by a comma."
        )
        exit(1)
    else:
        mcols = re.sub("\n", "", mcols).split(",")

    if (
        pdg_snp_meta_file
        and os.path.exists(pdg_snp_meta_file)
        and os.path.getsize(pdg_snp_meta_file) > 0
    ):
        acc2snp = defaultdict()
        acc2meta = defaultdict(defaultdict)
        init_pickled_sero = os.path.join(os.getcwd(), out_prefix + ".pickle")

        if (
            os.path.exists(init_pickled_sero)
            and os.path.getsize(init_pickled_sero)
            and not f_write_pick
        ):
            logging.error(
                f"File {os.path.basename(init_pickled_sero)} already exists in\n{os.getcwd()}\n"
                + "Use -fs to force overwrite it."
            )
            exit(1)

        with open(pdg_snp_meta_file, "r") as snp_meta:
            header = snp_meta.readline()
            skipped_acc2snp = set()
            for line in snp_meta:
                cols = line.strip().split(pdg_meta_fs)
                if not 4 <= len(cols) < 5:
                    logging.error(
                        f"The metadata file {pdg_snp_meta_file} is malformed.\n"
                        + f"Expected 4 columns. Got {len(cols)} columns.\n"
                    )
                    exit(1)

                if re.match("NULL", cols[3]):
                    skipped_acc2snp.add(
                        f"Isolate {cols[1]} has no genome accession: {cols[3]}"
                    )
                elif not acc_pat.match(cols[3]):
                    logging.error(
                        f"Did not find accession in either field number 4\n"
                        + "or field number 10 of column 4."
                        + f"\nLine: {line}"
                    )
                    exit(1)
                elif not re.match("NULL", cols[3]):
                    acc2snp[cols[3]] = cols[0]

            if len(skipped_acc2snp) > 0:
                logging.info(
                    f"While indexing\n{os.path.basename(pdg_snp_meta_file)},"
                    + "\nthese isolates were skipped:\n\n"
                    + "\n".join(skipped_acc2snp)
                )

        with open(pdg_meta_file, "r") as pdg_meta:
            header = pdg_meta.readline().strip().split(pdg_meta_fs)
            user_req_cols = [
                mcol_i for mcol_i, mcol in enumerate(header) if mcol in mcols
            ]
            cols_not_found = [mcol for mcol in mcols if mcol not in header]
            null_wgs_accs = set()
            if len(cols_not_found) > 0:
                logging.error(
                    f"The following columns do not exist in the"
                    + f"\nmetadata file [ {os.path.basename(pdg_meta_file)} ]:\n"
                    + "".join(cols_not_found)
                )
                exit(1)

            for line in pdg_meta.readlines():
                cols = line.strip().split(pdg_meta_fs)
                pdg_assm_acc = cols[acc_col]
                if not acc_pat.match(pdg_assm_acc):
                    null_wgs_accs.add(
                        f"Isolate {cols[target_acc_col]} has no genome accession: {pdg_assm_acc}"
                    )
                    continue

                if pdg_assm_acc in mlst_sts.keys():
                    acc2meta[pdg_assm_acc].setdefault("mlst_sequence_type", []).append(
                        str(mlst_sts[pdg_assm_acc])
                    )

                for col in user_req_cols:
                    acc2meta[pdg_assm_acc].setdefault(header[col], []).append(
                        str(cols[col])
                    )

            if len(null_wgs_accs) > 0:
                logging.info(
                    f"While indexing\n{os.path.basename(pdg_meta_file)},"
                    + "\nthese isolates were skipped:\n\n"
                    + "\n".join(null_wgs_accs)
                )

        with open(init_pickled_sero, "wb") as write_pickled_sero:
            pickle.dump(file=write_pickled_sero, obj=acc2meta)

        if len(num_accs_check) != len(acc2meta.keys()):
            logging.error(
                "Failed the accession count check."
                + f"\nExpected {len(num_accs_check)} accessions but got {len(acc2meta.keys())}."
            )
            exit(1)
        else:
            logging.info(
                f"Number of valid accessions: {len(num_accs_check)}"
                + f"\nNumber of accessions indexed: {len(acc2meta.keys())}"
                + f"\nNumber of accessions participating in any of the SNP Clusters: {len(acc2snp.keys())}"
                + f"\n\nCreated the pickle file for\n{os.path.basename(pdg_meta_file)}."
                + "\nThis was the only requested function."
            )

        snp_meta.close()
        write_pickled_sero.close()
        exit(0)
    elif pdg_meta_file and not (
        os.path.exists(pdg_meta_file) and os.path.getsize(pdg_meta_file) > 0
    ):
        logging.error(
            "Requested to create pickle from metadata, but\n"
            + f"the file, {os.path.basename(pdg_meta_file)} is empty or\ndoes not exist!"
        )
        exit(1)

    pdg_acc_all_fh.close()
    snp_meta.close()
    pdg_meta.close()
    write_pickled_sero.close()


if __name__ == "__main__":
    main()
