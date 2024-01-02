#!/usr/bin/env python3

# Kranti Konganti

import argparse
import glob
import inspect
import logging
import os
import pickle
import pprint
import re
import subprocess
from collections import defaultdict


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# Main
def main() -> None:
    """
    This script works only in the context of a Nextflow workflow.
    It takes:
        1. A pickle file containing a dictionary object where genome accession
            is the key and the computed serotype is the value.
                        OR
        1. It takes a pickle file containing a nested dictionary, where genome accession
            is the key and the metadata is a dictionary associated with that key.
        2. A file with `mash screen` results.
        3. A directory containing genomes' FASTA in gzipped format where the
            FASTA file contains 2 lines: one FASTA header followed by
            genome Sequence.
    and then generates a concatenated FASTA file of top N unique `mash screen`
    genome hits as requested.

    In addition:
        1. User can skip `mash screen` hits that originate from the supplied
            bio project accessions.
            For -skip option to work, ncbi-datasets should be available in $PATH.
    """

    # Set logging.
    logging.basicConfig(
        format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n\n",
        level=logging.DEBUG,
    )

    # Debug print.
    ppp = pprint.PrettyPrinter(width=55)
    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    parser.add_argument(
        "-s",
        dest="sero_snp_metadata",
        default=False,
        required=False,
        help="Absolute UNIX path to metadata text file with the field separator, | "
        + "\nand 5 fields: serotype|asm_lvl|asm_url|snp_cluster_id"
        + "\nEx: serotype=Derby,antigen_formula=4:f,g:-|Scaffold|402440|ftp://...\n|PDS000096654.2\n"
        + "Mentioning this option will create a pickle file for the\nprovided metadata and exits.",
    )
    parser.add_argument(
        "-fs",
        dest="force_write_pick",
        action="store_true",
        required=False,
        help="By default, when -s flag is on, the pickle file named *.ACC2SERO.pickle\n"
        + "is written to CWD. If the file exists, the program will not overwrite\n"
        + "and exit. Use -fs option to overwrite.",
    )
    parser.add_argument(
        "-m",
        dest="mash_screen_res",
        default=False,
        required=False,
        help="Absolute UNIX path to `mash screen` results file.",
    )
    parser.add_argument(
        "-ms",
        dest="mash_screen_res_suffix",
        default=".screened",
        required=False,
        help="Suffix of the `mash screen` result file.",
    )
    parser.add_argument(
        "-ps",
        dest="pickled_sero",
        default=False,
        required=False,
        help="Absolute UNIX Path to serialized metadata object in a pickle file.\n"
        + "You can create the pickle file of the metadata using -s option.\n"
        + "Required if -m is on.",
    )
    parser.add_argument(
        "-gd",
        dest="genomes_dir",
        default=False,
        required=False,
        help="Absolute UNIX path to a directory containing\n"
        + "gzipped genome FASTA files.\n"
        + "Required if -m is on.",
    )
    parser.add_argument(
        "-gds",
        dest="genomes_dir_suffix",
        default="_scaffolded_genomic.fna.gz",
        required=False,
        help="Genome FASTA file suffix to search for\nin the directory mentioned using\n-gd.",
    )
    parser.add_argument(
        "-n",
        dest="num_uniq_hits",
        default=10,
        required=False,
        help="This many number of serotype genomes' accessions are returned.",
    )
    parser.add_argument(
        "-skip",
        dest="skip_accs",
        default=str(""),
        required=False,
        help="Skip all hits which belong to the following bioproject accession(s).\n"
        + "A comma separated list of more than one bioproject.",
    )
    parser.add_argument(
        "-op",
        dest="out_prefix",
        default="MASH_SCREEN",
        required=False,
        help="Set the output file prefix for .fna.gz and .txt files.",
    )
    # required = parser.add_argument_group('required arguments')

    args = parser.parse_args()
    num_uniq_hits = int(args.num_uniq_hits)
    mash_screen_res = args.mash_screen_res
    mash_screen_res_suffix = args.mash_screen_res_suffix
    pickle_sero = args.sero_snp_metadata
    pickled_sero = args.pickled_sero
    f_write_pick = args.force_write_pick
    genomes_dir = args.genomes_dir
    genomes_dir_suffix = args.genomes_dir_suffix
    out_prefix = args.out_prefix
    skip_accs = args.skip_accs
    skip_accs_list = list()
    skip_check = re.compile(r"PRJNA\d+(?:\,PRJNA\d+){0,1}")
    req_metadata = {
        "mlst_sequence_type": "ST",
        "epi_type": "ET",
        "host": "HO",
        "host_disease": "HD",
        "isolation_source": "IS",
        "outbreak": "OU",
        "source_type": "SOT",
        "strain": "GS",
    }
    target_acc_key = "target_acc"
    ncbi_path_heading = "NCBI Pathogen Isolates Browser"
    ncbi_path_uri = "https://www.ncbi.nlm.nih.gov/pathogens/isolates/#"
    mash_genomes_gz = os.path.join(
        os.getcwd(), out_prefix + "_TOP_" + str(num_uniq_hits) + "_UNIQUE_HITS.fna.gz"
    )
    mash_uniq_hits_txt = os.path.join(
        os.getcwd(), re.sub(".fna.gz", ".txt", os.path.basename(mash_genomes_gz))
    )
    mash_uniq_accs_txt = os.path.join(
        os.getcwd(), re.sub(".fna.gz", "_ACCS.txt", os.path.basename(mash_genomes_gz))
    )
    mash_popup_info_txt = os.path.join(
        os.getcwd(), re.sub(".fna.gz", "_POPUP.txt", os.path.basename(mash_genomes_gz))
    )

    if mash_screen_res and os.path.exists(mash_genomes_gz):
        logging.error(
            "A concatenated genome FASTA file,\n"
            + f"{os.path.basename(mash_genomes_gz)} already exists in:\n"
            + f"{os.getcwd()}\n"
            + "Please remove or move it as we will not "
            + "overwrite it."
        )
        exit(1)

    if os.path.exists(mash_uniq_hits_txt) and os.path.getsize(mash_uniq_hits_txt) > 0:
        os.remove(mash_uniq_hits_txt)

    if mash_screen_res and (not genomes_dir or not pickled_sero):
        logging.error("When -m is on, -ps and -gd are also required.")
        exit(1)

    if skip_accs and not skip_check.match(skip_accs):
        logging.error(
            "Supplied bio project accessions are not valid!\n"
            + "Valid options:\n\t-skip PRJNA766315\n\t-skip PRJNA766315,PRJNA675435"
        )
        exit(1)
    elif skip_check.match(skip_accs):
        datasets_cmd = "datasets summary genome accession --as-json-lines --report ids_only".split()
        datasets_cmd.append(skip_accs)
        dataformat_cmd = "dataformat tsv genome --fields accession --elide-header".split()
        try:
            accs_query = subprocess.run(datasets_cmd, capture_output=True, check=True)
            try:
                skip_accs_list = (
                    subprocess.check_output(dataformat_cmd, input=accs_query.stdout)
                    .decode("utf-8")
                    .split("\n")
                )
            except subprocess.CalledProcessError as e:
                logging.error(f"Query failed\n\t{dataformat_cmd.join(' ')}\nError:\n\t{e}")
                exit(1)
        except subprocess.CalledProcessError as e:
            logging.error(f"Query failed\n\t{datasets_cmd.join(' ')}\nError:\n\t{e}")
            exit(1)

        if len(skip_accs_list) > 0:
            filter_these_hits = list(filter(bool, skip_accs_list))
        else:
            filter_these_hits = list()

    if genomes_dir:
        if not os.path.isdir(genomes_dir):
            logging.error("UNIX path\n" + f"{genomes_dir}\n" + "does not exist!")
            exit(1)
        if len(glob.glob(os.path.join(genomes_dir, "*" + genomes_dir_suffix))) <= 0:
            logging.error(
                "Genomes directory"
                + f"{genomes_dir}"
                + "\ndoes not seem to have any\n"
                + f"files ending with suffix: {genomes_dir_suffix}"
            )
            exit(1)

    if pickle_sero and os.path.exists(pickle_sero) and os.path.getsize(pickle_sero) > 0:
        acc2serotype = defaultdict()
        init_pickled_sero = os.path.join(os.getcwd(), out_prefix + ".ACC2SERO.pickle")

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

        with open(pickle_sero, "r") as sero_snp_meta:
            for line in sero_snp_meta:
                cols = line.strip().split("|")
                url_cols = cols[3].split("/")

                if not 4 <= len(cols) <= 5:
                    logging.error(
                        f"The metadata file {pickle_sero} is malformed.\n"
                        + f"Expected 4-5 columns. Got {len(cols)} columns.\n"
                    )
                    exit(1)

                if not len(url_cols) > 5:
                    acc = url_cols[3]
                else:
                    acc = url_cols[9]

                if not re.match(r"^GC[AF]\_\d+\.\d+$", acc):
                    logging.error(
                        f"Did not find accession in either field number 4\n"
                        + "or field number 10 of column 4."
                    )
                    exit(1)

                acc2serotype[acc] = cols[0]

        with open(init_pickled_sero, "wb") as write_pickled_sero:
            pickle.dump(file=write_pickled_sero, obj=acc2serotype)

        logging.info(
            f"Created the pickle file for\n{os.path.basename(pickle_sero)}.\n"
            + "This was the only requested function."
        )
        sero_snp_meta.close()
        write_pickled_sero.close()
        exit(0)
    elif pickle_sero and not (os.path.exists(pickle_sero) and os.path.getsize(pickle_sero) > 0):
        logging.error(
            "Requested to create pickle from metadata, but\n"
            + f"the file, {os.path.basename(pickle_sero)} is empty or\ndoes not exist!"
        )
        exit(1)

    if mash_screen_res and os.path.exists(mash_screen_res):
        if os.path.getsize(mash_screen_res) > 0:
            seen_uniq_hits = 0
            unpickled_acc2serotype = pickle.load(file=open(pickled_sero, "rb"))

            with open(mash_screen_res, "r") as msh_res:
                mash_hits = defaultdict()
                seen_mash_sero = defaultdict()

                for line in msh_res:
                    cols = line.strip().split("\t")

                    if len(cols) < 5:
                        logging.error(
                            f"The file {os.path.basename(mash_screen_res)} seems to\n"
                            + "be malformed. It contains less than required 5-6 columns."
                        )
                        exit(1)

                    mash_hit_acc = re.sub(
                        genomes_dir_suffix,
                        "",
                        str((re.search(r"GC[AF].*?" + genomes_dir_suffix, cols[4])).group()),
                    )

                    if mash_hit_acc:
                        mash_hits.setdefault(cols[0], []).append(mash_hit_acc)
                    else:
                        logging.error(
                            "Did not find an assembly accession in column\n"
                            + f"number 5. Found {cols[4]} instead. Cannot proceed!"
                        )
                        exit(1)
            msh_res.close()
        elif os.path.getsize(mash_screen_res) == 0:
            failed_sample_name = os.path.basename(mash_screen_res).rstrip(mash_screen_res_suffix)
            with open(
                os.path.join(os.getcwd(), "_".join([out_prefix, "FAILED.txt"])), "w"
            ) as failed_sample_fh:
                failed_sample_fh.write(f"{failed_sample_name}\n")
                failed_sample_fh.close()
            exit(0)

        # ppp.pprint(mash_hits)
        msh_out_txt = open(mash_uniq_hits_txt, "w")
        wrote_header_pop = False
        wrote_header_acc = False

        with open(mash_genomes_gz, "wb") as msh_out_gz:
            for _, (ident, acc_list) in enumerate(sorted(mash_hits.items(), reverse=True)):
                for acc in acc_list:
                    if len(filter_these_hits) > 0 and acc in filter_these_hits:
                        continue
                    if seen_uniq_hits >= num_uniq_hits:
                        break
                    if isinstance(unpickled_acc2serotype[acc], dict):
                        if target_acc_key in unpickled_acc2serotype[acc].keys():
                            if not wrote_header_pop:
                                mash_out_pop_txt = open(mash_popup_info_txt, "w")
                                mash_out_pop_txt.write("POPUP_INFO\nSEPARATOR COMMA\nDATA\n")
                                wrote_header_pop = True

                            pdt = "".join(unpickled_acc2serotype[acc][target_acc_key])

                            popup_line = ",".join(
                                [
                                    acc,
                                    ncbi_path_heading,
                                    f'<a target="_blank" href="{ncbi_path_uri + pdt}">{pdt}</a>',
                                ]
                            )
                            mash_out_pop_txt.write(popup_line + "\n")

                        if all(
                            k in unpickled_acc2serotype[acc].keys() for k in req_metadata.keys()
                        ):
                            if not wrote_header_acc:
                                msh_out_accs_txt = open(mash_uniq_accs_txt, "w")
                                msh_out_txt.write("METADATA\nSEPARATOR COMMA\nFIELD_LABELS,")
                                msh_out_txt.write(
                                    f"{','.join([str(key).upper() for key in req_metadata.keys()])}\nDATA\n"
                                )
                                wrote_header_acc = True

                            metadata_line = ",".join(
                                [
                                    re.sub(
                                        ",",
                                        "",
                                        "|".join(unpickled_acc2serotype[acc][m]),
                                    )
                                    for m in req_metadata.keys()
                                ],
                            )

                        msh_out_txt.write(f"{acc.strip()},{metadata_line}\n")
                        msh_out_accs_txt.write(
                            f"{os.path.join(genomes_dir, acc + genomes_dir_suffix)}\n"
                        )
                        seen_mash_sero[acc] = 1
                        seen_uniq_hits += 1
                    elif not isinstance(unpickled_acc2serotype[acc], dict):
                        if unpickled_acc2serotype[acc] not in seen_mash_sero.keys():
                            seen_mash_sero[unpickled_acc2serotype[acc]] = 1
                            seen_uniq_hits += 1
                            # print(acc.strip() + '\t' + ident + '\t' + unpickled_acc2serotype[acc], file=sys.stdout)
                            msh_out_txt.write(
                                f"{acc.strip()}\t{unpickled_acc2serotype[acc]}\t{ident}\n"
                            )
                            with open(
                                os.path.join(genomes_dir, acc + genomes_dir_suffix),
                                "rb",
                            ) as msh_in_gz:
                                msh_out_gz.writelines(msh_in_gz.readlines())
                            msh_in_gz.close()
        msh_out_gz.close()
        msh_out_txt.close()

        if "msh_out_accs_txt" in locals().keys() and not msh_out_accs_txt.closed:
            msh_out_accs_txt.close()
        if "mash_out_pop_txt" in locals().keys() and not mash_out_pop_txt.closed:
            mash_out_pop_txt.close()

        logging.info(
            f"File {os.path.basename(mash_genomes_gz)}\n"
            + f"written in:\n{os.getcwd()}\nDone! Bye!"
        )
        exit(0)


if __name__ == "__main__":
    main()
