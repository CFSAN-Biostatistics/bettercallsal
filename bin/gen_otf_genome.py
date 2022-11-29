#!/usr/bin/env python3

# Kranti Konganti

import os
import argparse
import inspect
import logging
import re
import pprint
import glob

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
        1. A text file containing accessions or FASTA IDs, one per line and
            then,
        2. Searches for a genome FASTA file in gzipped format in specified
            search path, where the prefix of the filename is the accession or
            FASTA ID from 1. and then,
    creates a new concatenated gzipped genome FASTA file with all the genomes
    in the text file from 1.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-txt",
        dest="accs_txt",
        default=False,
        required=True,
        help="Absolute UNIX path to .txt file containing accessions\n" + "FASTA IDs, one per line.",
    )
    required.add_argument(
        "-gd",
        dest="genomes_dir",
        default=False,
        required=True,
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
        "-op",
        dest="out_prefix",
        default="CATTED_GENOMES",
        help="Set the output file prefix for .fna.gz and .txt\n" + "files.",
    )
    parser.add_argument(
        "-txts",
        dest="accs_suffix",
        default="_template_hits.txt",
        required=False,
        help="The suffix of the file supplied with -txt option. It is assumed that the\n"
        + "sample name is present in the file supplied with -txt option and the suffix\n"
        + "will be stripped and stored in a file that logs samples which have no hits.",
    )

    args = parser.parse_args()
    accs_txt = args.accs_txt
    genomes_dir = args.genomes_dir
    genomes_dir_suffix = args.genomes_dir_suffix
    out_prefix = args.out_prefix
    accs_suffix = args.accs_suffix
    cat_genomes_gz = os.path.join(os.getcwd(), out_prefix + "_" + genomes_dir_suffix)
    cat_genomes_gz = re.sub("__", "_", str(cat_genomes_gz))

    if accs_txt and os.path.exists(cat_genomes_gz) and os.path.getsize(cat_genomes_gz) > 0:
        logging.error(
            "A concatenated genome FASTA file,\n"
            + f"{os.path.basename(cat_genomes_gz)} already exists in:\n"
            + f"{os.getcwd()}\n"
            + "Please remove or move it as we will not "
            + "overwrite it."
        )
        exit(1)

    if accs_txt and (not os.path.exists(accs_txt) or not os.path.getsize(accs_txt) > 0):
        logging.error("File,\n" + f"{accs_txt}\ndoes not exist " + "or is empty!")
        failed_sample_name = os.path.basename(accs_txt).rstrip(accs_suffix)
        with open(
            os.path.join(os.getcwd(), "_".join([out_prefix, "FAILED.txt"])), "w"
        ) as failed_sample_fh:
            failed_sample_fh.write(f"{failed_sample_name}\n")
        failed_sample_fh.close()
        exit(0)

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

        # ppp.pprint(mash_hits)
        empty_lines = 0
        empty_lines_msg = ""
        with open(cat_genomes_gz, "wb") as genomes_out_gz:
            with open(accs_txt, "r") as accs_txt_fh:
                for line in accs_txt_fh:
                    if line in ["\n", "\n\r"]:
                        empty_lines += 1
                        continue

                    genome_file = os.path.join(genomes_dir, line.strip() + genomes_dir_suffix)

                    if not os.path.exists(genome_file) or os.path.getsize(genome_file) <= 0:
                        logging.error(
                            f"Genome file {os.path.basename(genome_file)} does not\n"
                            + "exits or is empty!"
                        )
                        exit(1)
                    else:
                        with open(genome_file, "rb") as genome_file_h:
                            genomes_out_gz.writelines(genome_file_h.readlines())
                        genome_file_h.close()
            accs_txt_fh.close()
        genomes_out_gz.close()

        if empty_lines > 0:
            empty_lines_msg = f"Skipped {empty_lines} empty line(s).\n"

        logging.info(
            empty_lines_msg
            + f"File {os.path.basename(cat_genomes_gz)}\n"
            + f"written in:\n{os.getcwd()}\nDone! Bye!"
        )
        exit(0)


if __name__ == "__main__":
    main()
