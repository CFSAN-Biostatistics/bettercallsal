#!/usr/bin/env python3

# Kranti Konganti

import os
import glob
import pickle
import argparse
import inspect
import logging
import re
import pprint
from collections import defaultdict

# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# Main
def main() -> None:
    """
    This script works only in the context of `bettercallsal` Nextflow workflow.
    It takes:
        1. A pickle file containing a dictionary object where genome accession
            is the key and the computed serotype is the value.
        2. A file with `mash screen` results run against the Salmonella SNP
            Cluster genomes' sketch.
        3. A directory containing genomes' FASTA in gzipped format where the
            FASTA file contains 2 lines: one FASTA header followed by
            genome Sequence.
    and then generates a concatenated FASTA file of top N unique `mash screen`
    genome hits as requested.
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
        help="This many number of serotype genomes' accessions are " + "\nreturned.",
    )
    parser.add_argument(
        "-op",
        dest="out_prefix",
        default="MASH_SCREEN",
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
    mash_genomes_gz = os.path.join(
        os.getcwd(), out_prefix + "_TOP_" + str(num_uniq_hits) + "_UNIQUE_HITS.fna.gz"
    )
    mash_uniq_hits_txt = os.path.join(
        os.getcwd(), re.sub(".fna.gz", ".txt", os.path.basename(mash_genomes_gz))
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
        with open(mash_genomes_gz, "wb") as msh_out_gz:
            for _, (ident, acc_list) in enumerate(sorted(mash_hits.items(), reverse=True)):
                for acc in acc_list:
                    if seen_uniq_hits >= num_uniq_hits:
                        break
                    if unpickled_acc2serotype[acc] not in seen_mash_sero.keys():
                        seen_mash_sero[unpickled_acc2serotype[acc]] = 1
                        seen_uniq_hits += 1
                        # print(acc.strip() + '\t' + ident + '\t' + unpickled_acc2serotype[acc], file=sys.stdout)
                        msh_out_txt.write(
                            f"{acc.strip()}\t{unpickled_acc2serotype[acc]}\t{ident}\n"
                        )
                        with open(
                            os.path.join(genomes_dir, acc + genomes_dir_suffix), "rb"
                        ) as msh_in_gz:
                            msh_out_gz.writelines(msh_in_gz.readlines())
                        msh_in_gz.close()
        msh_out_gz.close()
        msh_out_txt.close()
        logging.info(
            f"File {os.path.basename(mash_genomes_gz)}\n"
            + f"written in:\n{os.getcwd()}\nDone! Bye!"
        )
        exit(0)


if __name__ == "__main__":
    main()
