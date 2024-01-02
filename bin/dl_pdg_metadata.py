#!/usr/bin/env python3

# Kranti Konganti

import argparse
import inspect
import logging
import os
import re
import shutil
import ssl
import tempfile
from html.parser import HTMLParser
from urllib.request import urlopen

# Set logging.f
logging.basicConfig(
    format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n",
    level=logging.DEBUG,
)

# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# HTMLParser override class to get PDG release and latest Cluster .tsv file
class NCBIPathogensHTMLParser(HTMLParser):
    def __init__(self, *, convert_charrefs: bool = ...) -> None:
        super().__init__(convert_charrefs=convert_charrefs)
        self.reset()
        self.href_data = list()

    def handle_data(self, data):
        self.href_data.append(data)


def dl_pdg(**kwargs) -> None:
    """
    Method to save the PDG metadata file and
    return the latest PDG release.
    """
    db_path, url, regex, suffix, overwrite, release = [kwargs[k] for k in kwargs.keys()]

    contxt = ssl.create_default_context()
    contxt.check_hostname = False
    contxt.verify_mode = ssl.CERT_NONE

    if (db_path or url) == None:
        logging.error("Please provide absolute UNIX path\n" + "to store the result DB flat files.")
        exit(1)

    if re.match(r"^PDG\d+\.\d+$", release):
        url = re.sub("latest_snps", release.strip(), url)

    html_parser = NCBIPathogensHTMLParser()
    logging.info(f"Finding latest NCBI PDG release at:\n{url}")

    with urlopen(url, context=contxt) as response:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_html_file:
            shutil.copyfileobj(response, tmp_html_file)

    with open(tmp_html_file.name, "r") as html:
        html_parser.feed("".join(html.readlines()))

    pdg_filename = re.search(regex, "".join(html_parser.href_data)).group(0)
    pdg_release = pdg_filename.rstrip(suffix)
    pdg_metadata_url = "/".join([url, pdg_filename])
    pdg_release = pdg_filename.rstrip(suffix)
    dest_dir = os.path.join(db_path, pdg_release)

    logging.info(f"Found NCBI PDG file:\n{pdg_metadata_url}")

    if (
        not overwrite
        and re.match(r".+?\.metadata\.tsv$", pdg_filename)
        and os.path.exists(dest_dir)
    ):
        logging.error(f"DB path\n{dest_dir}\nalready exists. Please use -f to overwrite.")
        exit(1)
    elif overwrite and not re.match(r".+?\.reference_target\.cluster_list\.tsv$", pdg_filename):
        shutil.rmtree(dest_dir, ignore_errors=True) if os.path.exists(dest_dir) else None
        os.makedirs(dest_dir)
    elif (
        not overwrite
        and re.match(r".+?\.metadata\.tsv$", pdg_filename)
        and not os.path.exists(dest_dir)
    ):
        os.makedirs(dest_dir)

    tsv_at = os.path.join(dest_dir, pdg_filename)
    logging.info(f"Saving to:\n{tsv_at}")

    with urlopen(pdg_metadata_url, context=contxt) as response:
        with open(tsv_at, "w") as tsv:
            tsv.writelines(response.read().decode("utf-8"))

    html.close()
    tmp_html_file.close()
    os.unlink(tmp_html_file.name)
    tsv.close()
    response.close()

    return tsv_at, dest_dir


def main() -> None:
    """
    This script is part of the `bettercallsal_db` Nextflow workflow and is only
    tested on POSIX sytems.
    It:
        1. Downloads the latest NCBI Pathogens Release metadata file, which
            looks like PDGXXXXXXXXXX.2504.metadata.csv and also the SNP cluster
            information file which looks like PDGXXXXXXXXXX.2504.reference_target.cluster_list.tsv
        2. Generates a new metadata file with only required information such as
            computed_serotype, isolates GenBank or RefSeq downloadable genome FASTA
            URL.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    # required = parser.add_argument_group("required arguments")

    parser.add_argument(
        "-db",
        dest="db_path",
        default=os.getcwd(),
        required=False,
        help="Absolute UNIX path to a path where all results files are\nstored.",
    )
    parser.add_argument(
        "-f",
        dest="overwrite_db",
        default=False,
        required=False,
        action="store_true",
        help="Force overwrite a PDG release directory at DB path\nmentioned with -db.",
    )
    parser.add_argument(
        "-org",
        dest="organism",
        default="Salmonella",
        required=False,
        help="The organism to create the DB flat files\nfor.",
    )
    parser.add_argument(
        "-rel",
        dest="release",
        default=False,
        required=False,
        help="If you get a 404 error, try mentioning the actual release identifier.\n"
        + "Ex: For Salmonella, you can get the release identifier by going to:\n"
        + "    https://ftp.ncbi.nlm.nih.gov/pathogen/Results/Salmonella\n"
        + "Ex: If you want metadata beloginging to release PDG000000002.2507, then you\n"
        + "    would use this command-line option as:\n    -rel PDG000000002.2507",
    )

    args = parser.parse_args()
    db_path = args.db_path
    org = args.organism
    overwrite = args.overwrite_db
    release = args.release
    ncbi_pathogens_loc = "/".join(
        ["https://ftp.ncbi.nlm.nih.gov/pathogen/Results", org, "latest_snps"]
    )

    if not db_path:
        db_path = os.getcwd()

    # Save metadata
    file, dest_dir = dl_pdg(
        db_path=db_path,
        url="/".join([ncbi_pathogens_loc, "Metadata"]),
        regex=re.compile(r"PDG\d+\.\d+\.metadata\.tsv"),
        suffix=".metadata.tsv",
        overwrite=overwrite,
        release=release,
    )

    # Save cluster to target mapping
    dl_pdg(
        db_path=db_path,
        url="/".join([ncbi_pathogens_loc, "Clusters"]),
        regex=re.compile(r"PDG\d+\.\d+\.reference_target\.cluster_list\.tsv"),
        suffix="reference_target\.cluster_list\.tsv",
        overwrite=overwrite,
        release=release,
    )

    # Create accs.txt for dataformat to fetch required ACC fields
    accs_file = os.path.join(dest_dir, "accs_all.txt")
    with open(file, "r") as pdg_metadata_fh:
        with open(accs_file, "w") as accs_fh:
            for line in pdg_metadata_fh.readlines():
                if re.match(r"^#", line) or line in ["\n", "\n\r", "\r"]:
                    continue
                cols = line.strip().split("\t")
                asm_acc = cols[9]
                accs_fh.write(f"{asm_acc}\n") if (asm_acc != "NULL") else None
        accs_fh.close()
    pdg_metadata_fh.close()

    logging.info("Finished writing accessions for dataformat tool.")


if __name__ == "__main__":
    main()
