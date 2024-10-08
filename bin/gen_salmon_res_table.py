#!/usr/bin/env python3

# Kranti Konganti

import argparse
import glob
import inspect
import json
import logging
import os
import pickle
import pprint
import re
from collections import defaultdict

import yaml


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# Main
def main() -> None:
    """
    The succesful execution of this script requires access to bettercallsal formatted
    db flat files. On raven2, they are at /hpc/db/bettercallsall/PDGXXXXXXXXXX.XXXXX

    It takes the ACC2SERO.pickle file and *.reference_target.cluster_list.tsv file
    for that particular NCBI Pathogens release from the db directory mentioned with
    -db option and a root parent directory of the `salmon quant` results mentioned
    with -sal option and generates a final results table with number of reads
    mapped and a .json file to be used with MultiQC to generate a stacked bar plot.

    Using -url option optionally adds an extra column of NCBI Pathogens Isolates
    Browser, which directly links out to NCBI Pathogens Isolates SNP viewer tool.
    """
    # Set logging.
    logging.basicConfig(
        format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n\n",
        level=logging.DEBUG,
    )

    # Debug print.
    ppp = pprint.PrettyPrinter(width=55)
    prog_name = inspect.stack()[0].filename

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-sal",
        dest="salmon_res_dir",
        default=False,
        required=True,
        help="Absolute UNIX path to the parent directory that contains the\n"
        + "`salmon quant` results directory. For example, if path to\n"
        + "`quant.sf` is in /hpc/john_doe/test/salmon_res/quant.sf, then\n"
        + "use this command-line option as:\n"
        + "-sal /hpc/john_doe/test",
    )
    required.add_argument(
        "-snp",
        dest="rtc",
        default=False,
        required=True,
        help="Absolute UNIX Path to the PDG SNP reference target cluster\n"
        + "metadata file. On raven2, these are located at\n"
        + "/hpc/db/bettercallsal/PDGXXXXXXXXXX.XXXXX\n"
        + "Required if -sal is on.",
    )
    required.add_argument(
        "-pickle",
        dest="acc2sero",
        default=False,
        required=True,
        help="Absolute UNIX Path to the *ACC2SERO.pickle\n"
        + "metadata file. On raven2, these are located at\n"
        + "/hpc/db/bettercallsal/PDGXXXXXXXXXX.XXXXX\n"
        + "Required if -sal is on.",
    )
    parser.add_argument(
        "-op",
        dest="out_prefix",
        default="bettercallsal.tblsum",
        required=False,
        help="Set the output file(s) prefix for output(s) generated\n" + "by this program.",
    )
    parser.add_argument(
        "-url",
        dest="show_snp_clust_info",
        default=False,
        required=False,
        action="store_true",
        help="Show SNP cluster participation information of the final genome hit.\n"
        + "This may be useful to see a relative placement of your sample in\n"
        + "NCBI Isolates SNP Tree Viewer based on genome similarity but however\n"
        + "due to rapid nature of the updates at NCBI Pathogen Detection Project,\n"
        + "the placement may be in an outdated cluster.",
    )

    args = parser.parse_args()
    salmon_res_dir = args.salmon_res_dir
    out_prefix = args.out_prefix
    show_snp_clust_col = args.show_snp_clust_info
    rtc = args.rtc
    pickled_sero = args.acc2sero
    no_hit = "No genome hit"
    no_presence = "Salmonella presence not detected"
    bcs_sal_yn_prefix = "bettercallsal_salyn"
    sal_y = "Detected"
    sal_n = "Not detected"
    null_value = "NULL"
    assm_pat = re.compile(r"GC[AF]\_[0-9]+\.*[0-9]*")
    ncbi_pathogens_base_url = "https://www.ncbi.nlm.nih.gov/pathogens/"
    ncbi_pathogens_genome_base = "https://www.ncbi.nlm.nih.gov/datasets/genome/"

    sample2salmon, snp_clusters, multiqc_salmon_counts, seen_sero, sal_yn = (
        defaultdict(defaultdict),
        defaultdict(defaultdict),
        defaultdict(defaultdict),
        defaultdict(int),
        defaultdict(int),
    )

    cell_colors_yml = {
        bcs_sal_yn_prefix: {sal_y: "#c8e6c9 !important;", sal_n: "#ffcdd2 !important;"}
    }

    salmon_comb_res = os.path.join(os.getcwd(), out_prefix + ".txt")
    bcs_sal_yn = re.sub(out_prefix, bcs_sal_yn_prefix + ".tblsum", salmon_comb_res)
    cell_colors_yml_file = re.sub(
        out_prefix + ".txt", bcs_sal_yn_prefix + ".cellcolors.yml", salmon_comb_res
    )
    salmon_comb_res_mqc = os.path.join(os.getcwd(), str(out_prefix).split(".")[0] + "_mqc.json")
    salmon_res_files = glob.glob(os.path.join(salmon_res_dir, "*", "quant.sf"), recursive=True)
    salmon_res_file_failed = glob.glob(os.path.join(salmon_res_dir, "BCS_NO_CALLS.txt"))

    if rtc and (not os.path.exists(rtc) or not os.path.getsize(rtc) > 0):
        logging.error(
            "The reference target cluster metadata file,\n"
            + f"{os.path.basename(rtc)} does not exist or is empty!"
        )
        exit(1)

    if rtc and (not salmon_res_dir or not pickled_sero):
        logging.error("When -rtc is on, -sal and -ps are also required.")
        exit(1)

    if pickled_sero and (not os.path.exists(pickled_sero) or not os.path.getsize(pickled_sero)):
        logging.error(
            "The pickle file,\n" + f"{os.path.basename(pickled_sero)} does not exist or is empty!"
        )
        exit(1)

    if salmon_res_dir:
        if not os.path.isdir(salmon_res_dir):
            logging.error("UNIX path\n" + f"{salmon_res_dir}\n" + "does not exist!")
            exit(1)
        if len(salmon_res_files) <= 0:
            # logging.error(
            #     "Parent directory,\n"
            #     + f"{salmon_res_dir}"
            #     + "\ndoes not seem to have any directories that contain\n"
            #     + "the `quant.sf` file(s)."
            # )
            # exit(1)
            with open(salmon_comb_res, "w") as salmon_comb_res_fh:
                salmon_comb_res_fh.write(f"Sample\n{no_hit}s in any samples\n")
            salmon_comb_res_fh.close()

            with open(bcs_sal_yn, "w") as bcs_sal_yn_fh:
                bcs_sal_yn_fh.write(f"Sample\n{no_presence} in any samples\n")
            bcs_sal_yn_fh.close()

            exit(0)

    if rtc and os.path.exists(rtc) and os.path.getsize(rtc) > 0:

        # pdg_release = re.match(r"(^PDG\d+\.\d+)\..+", os.path.basename(rtc))[1] + "/"
        acc2sero = pickle.load(file=open(pickled_sero, "rb"))

        with open(rtc, "r") as rtc_fh:

            for line in rtc_fh:
                cols = line.strip().split("\t")

                if len(cols) < 4:
                    logging.error(
                        f"The file {os.path.basename(rtc)} seems to\n"
                        + "be malformed. It contains less than required 4 columns."
                    )
                    exit(1)
                elif cols[3] != null_value:
                    snp_clusters[cols[0]].setdefault("assembly_accs", []).append(cols[3])
                    snp_clusters[cols[3]].setdefault("snp_clust_id", []).append(cols[0])
                    snp_clusters[cols[3]].setdefault("pathdb_acc_id", []).append(cols[1])
                    if len(snp_clusters[cols[3]]["snp_clust_id"]) > 1:
                        logging.error(
                            f"There is a duplicate reference accession [{cols[3]}]"
                            + f"in the metadata file{os.path.basename(rtc)}!"
                        )
                        exit(1)

        rtc_fh.close()

        for salmon_res_file in salmon_res_files:
            sample_name = re.match(
                r"(^.+?)((\_salmon\_res)|(\.salmon))$",
                os.path.basename(os.path.dirname(salmon_res_file)),
            )[1]
            salmon_meta_json = os.path.join(
                os.path.dirname(salmon_res_file), "aux_info", "meta_info.json"
            )

            if not os.path.exists(salmon_meta_json) or not os.path.getsize(salmon_meta_json) > 0:
                logging.error(
                    "The file\n"
                    + f"{salmon_meta_json}\ndoes not exist or is empty!\n"
                    + "Did `salmon quant` fail?"
                )
                exit(1)

            if not os.path.exists(salmon_res_file) or not os.path.getsize(salmon_res_file):
                logging.error(
                    "The file\n"
                    + f"{salmon_res_file}\ndoes not exist or is empty!\n"
                    + "Did `salmon quant` fail?"
                )
                exit(1)

            with open(salmon_res_file, "r") as salmon_res_fh:
                for line in salmon_res_fh.readlines():
                    if re.match(r"^Name.+", line):
                        continue
                    cols = line.strip().split("\t")
                    ref_acc = "_".join(cols[0].split("_")[:2])

                    if ref_acc not in snp_clusters.keys():
                        snp_clusters[ref_acc]["snp_clust_id"] = ref_acc
                        snp_clusters[ref_acc]["pathdb_acc_id"] = ref_acc

                    (
                        sample2salmon[sample_name]
                        .setdefault(acc2sero[cols[0]], [])
                        .append(int(round(float(cols[4]), 2)))
                    )
                    (
                        sample2salmon[sample_name]
                        .setdefault("snp_clust_ids", {})
                        .setdefault("".join(snp_clusters[ref_acc]["snp_clust_id"]), [])
                        .append("".join(snp_clusters[ref_acc]["pathdb_acc_id"]))
                    )
                    seen_sero[acc2sero[cols[0]]] = 1

            salmon_meta_json_read = json.load(open(salmon_meta_json, "r"))
            (
                sample2salmon[sample_name]
                .setdefault("tot_reads", [])
                .append(salmon_meta_json_read["num_processed"])
            )

        with open(salmon_comb_res, "w") as salmon_comb_res_fh:

            # snp_clust_col_header = (
            #     "\tSNP Cluster(s) by Genome Hit\n" if show_snp_clust_col else "\n"
            # )
            snp_clust_col_header = (
                "\tNCBI Pathogens Isolate Browser\n" if show_snp_clust_col else "\n"
            )
            serotypes = sorted(seen_sero.keys())
            formatted_serotypes = [
                re.sub(r"\,antigen_formula=", " | ", s)
                for s in [re.sub(r"serotype=", "", s) for s in serotypes]
            ]
            salmon_comb_res_fh.write(
                "Sample\t" + "\t".join(formatted_serotypes) + snp_clust_col_header
            )
            # sample_snp_relation = (
            #     ncbi_pathogens_base_url
            #     + pdg_release
            #     + "".join(snp_clusters[ref_acc]["snp_clust_id"])
            #     + "?accessions="
            # )
            if len(salmon_res_file_failed) == 1:
                with (open("".join(salmon_res_file_failed), "r")) as no_calls_fh:
                    for line in no_calls_fh.readlines():
                        if line in ["\n", "\n\r", "\r"]:
                            continue
                        salmon_comb_res_fh.write(line.strip())
                        sal_yn[line.strip()] += 0
                        for serotype in serotypes:
                            salmon_comb_res_fh.write("\t-")
                        salmon_comb_res_fh.write(
                            "\t-\n"
                        ) if show_snp_clust_col else salmon_comb_res_fh.write("\n")
                no_calls_fh.close()

            for sample, counts in sorted(sample2salmon.items()):
                salmon_comb_res_fh.write(sample)
                snp_cluster_res_col = list()

                for snp_clust_id in sample2salmon[sample]["snp_clust_ids"].keys():
                    # print(snp_clust_id)
                    # print(",".join(sample2salmon[sample]["snp_clust_ids"][snp_clust_id]))
                    # ppp.pprint(sample2salmon[sample]["snp_clust_ids"])
                    # ppp.pprint(sample2salmon[sample]["snp_clust_ids"][snp_clust_id])
                    # final_url_text = ",".join(
                    #     sample2salmon[sample]["snp_clust_ids"][snp_clust_id]
                    # )
                    # final_url_text_to_show = snp_clust_id
                    # snp_cluster_res_col.append(
                    #     "".join(
                    #         [
                    #             f'<a href="',
                    #             sample_snp_relation,
                    #             ",".join(sample2salmon[sample]["snp_clust_ids"][snp_clust_id]),
                    #             f'" target="_blank">{snp_clust_id}</a>',
                    #         ]
                    #     )
                    # )
                    # ppp.pprint(sample2salmon[sample])
                    for pathdbacc in sample2salmon[sample]["snp_clust_ids"][snp_clust_id]:
                        # final_url_text_to_show = " ".join(
                        #     sample2salmon[sample]["snp_clust_ids"][snp_clust_id]
                        # )
                        sample_snp_relation = (
                            ncbi_pathogens_genome_base
                            if assm_pat.match(pathdbacc)
                            else ncbi_pathogens_base_url + "isolates/#"
                        )

                        snp_cluster_res_col.append(
                            "".join(
                                [
                                    f'<a href="',
                                    sample_snp_relation,
                                    pathdbacc,
                                    f'" target="_blank">{pathdbacc}</a>',
                                ]
                            )
                        )

                per_serotype_counts = 0
                for serotype in serotypes:

                    if serotype in sample2salmon[sample].keys():
                        # ppp.pprint(counts)
                        sample_perc_mapped = round(
                            sum(counts[serotype]) / sum(counts["tot_reads"]) * 100, 2
                        )
                        salmon_comb_res_fh.write(
                            f"\t{sum(counts[serotype])} ({sample_perc_mapped}%)"
                        )
                        multiqc_salmon_counts[sample].setdefault(
                            re.match(r"^serotype=(.+?)\,antigen_formula.*", serotype)[1],
                            sum(counts[serotype]),
                        )
                        per_serotype_counts += sum(counts[serotype])
                        sal_yn[sample] += 1
                    else:
                        salmon_comb_res_fh.write(f"\t-")
                        sal_yn[sample] += 0

                multiqc_salmon_counts[sample].setdefault(
                    no_hit, sum(counts["tot_reads"]) - per_serotype_counts
                )
                snp_clust_col_val = (
                    f'\t{" ".join(snp_cluster_res_col)}\n' if show_snp_clust_col else "\n"
                )
                # ppp.pprint(multiqc_salmon_counts)
                salmon_comb_res_fh.write(snp_clust_col_val)

            with open(bcs_sal_yn, "w") as bcs_sal_yn_fh:
                bcs_sal_yn_fh.write("Sample\tSalmonella Presence\tNo. of Serotypes\n")
                for sample in sal_yn.keys():
                    if sal_yn[sample] > 0:
                        bcs_sal_yn_fh.write(f"{sample}\tDetected\t{sal_yn[sample]}\n")
                    else:
                        bcs_sal_yn_fh.write(f"{sample}\tNot detected\t{sal_yn[sample]}\n")

            with open(cell_colors_yml_file, "w") as cell_colors_fh:
                yaml.dump(cell_colors_yml, cell_colors_fh, default_flow_style=False)

            salmon_plot_json(salmon_comb_res_mqc, multiqc_salmon_counts, no_hit)

        salmon_comb_res_fh.close()
        bcs_sal_yn_fh.close()
        cell_colors_fh.close()


def salmon_plot_json(file: None, sample_salmon_counts: None, no_hit: None) -> None:
    """
    This method will take a dictionary of salmon counts per sample
    and will dump a JSON that will be used by MultiQC.
    """

    if file is None or sample_salmon_counts is None:
        logging.error(
            "Neither an output file to dump the JSON for MultiQC or the"
            + "dictionary holding the salmon counts was not passed."
        )

    # Credit: http://phrogz.net/tmp/24colors.html
    # Will cycle through 20 distinct colors.
    distinct_color_palette = [
        "#FF0000",
        "#FFFF00",
        "#00EAFF",
        "#AA00FF",
        "#FF7F00",
        "#BFFF00",
        "#0095FF",
        "#FF00AA",
        "#FFD400",
        "#6AFF00",
        "#0040FF",
        "#EDB9B9",
        "#B9D7ED",
        "#E7E9B9",
        "#DCB9ED",
        "#B9EDE0",
        "#8F2323",
        "#23628F",
        "#8F6A23",
        "#6B238F",
        "#4F8F23",
    ]

    # Credit: https://mokole.com/palette.html
    # Will use this palette if we run out ouf
    # 20 serotypes. More than 50 serotypes
    # per run is probably rare but if not,
    # will cycle through about 45.
    distinct_color_palette2 = [
        "#2F4F4F",  # darkslategray
        "#556B2F",  # darkolivegreen
        "#A0522D",  # sienna
        "#2E8B57",  # seagreen
        "#006400",  # darkgreen
        "#8B0000",  # darkred
        "#808000",  # olive
        "#BC8F8F",  # rosybrown
        "#663399",  # rebeccapurple
        "#B8860B",  # darkgoldenrod
        "#4682B4",  # steelblue
        "#000080",  # navy
        "#D2691E",  # chocolate
        "#9ACD32",  # yellowgreen
        "#20B2AA",  # lightseagreen
        "#CD5C5C",  # indianred
        "#8FBC8F",  # darkseagreen
        "#800080",  # purple
        "#B03060",  # maroon3
        "#FF8C00",  # darkorange
        "#FFD700",  # gold
        "#FFFF00",  # yellow
        "#DEB887",  # burlywood
        "#00FF00",  # lime
        "#BA55D3",  # mediumorchid
        "#00FA9A",  # mediumspringgreen
        "#4169E1",  # royalblue
        "#E9967A",  # darksalmon
        "#DC143C",  # crimson
        "#00FFFF",  # aqua
        "#F4A460",  # sandybrown
        "#9370DB",  # mediumpurple
        "#0000FF",  # blue
        "#ADFF2F",  # greenyellow
        "#FF6347",  # tomato
        "#D8BFD8",  # thistle
        "#FF00FF",  # fuchsia
        "#DB7093",  # palevioletred
        "#F0E68C",  # khaki
        "#6495ED",  # cornflower
        "#DDA0DD",  # plum
        "#EE82EE",  # violet
        "#7FFFD4",  # aquamarine
        "#FAFAD2",  # lightgoldenrod
        "#FF69B4",  # hotpink
        "#FFB6C1",  # lightpink
    ]

    no_hit_color = "#434348"
    col_count = 0
    serotypes = set()
    salmon_counts = defaultdict(defaultdict)
    salmon_counts["id"] = "BETTERCALLSAL_SALMON_COUNTS"
    salmon_counts["section_name"] = "Salmon read counts"
    salmon_counts["description"] = (
        "This section shows the read counts from running <code>salmon</code> "
        + "in <code>--meta</code> mode using SE, merged PE or concatenated PE reads against "
        + "an on-the-fly <code>salmon</code> index generated from the genome hits "
        + "of <code>kma</code>."
    )
    salmon_counts["plot_type"] = "bargraph"
    salmon_counts["pconfig"]["id"] = "bettercallsal_salmon_counts_plot"
    salmon_counts["pconfig"]["title"] = "Salmon: Read counts"
    salmon_counts["pconfig"]["ylab"] = "Number of reads"
    salmon_counts["pconfig"]["xDecimals"] = "false"
    salmon_counts["pconfig"]["cpswitch_counts_label"] = "Number of reads (Counts)"
    salmon_counts["pconfig"]["cpswitch_percent_label"] = "Number of reads (Percentages)"

    for sample in sorted(sample_salmon_counts.keys()):
        serotypes.update(list(sample_salmon_counts[sample].keys()))
        salmon_counts["data"][sample] = sample_salmon_counts[sample]

    if len(serotypes) > len(distinct_color_palette):
        distinct_color_palette = distinct_color_palette2

    for serotype in sorted(serotypes):
        if serotype == no_hit:
            continue
        if col_count == len(distinct_color_palette) - 1:
            col_count = 0

        col_count += 1
        salmon_counts["categories"][serotype] = {"color": distinct_color_palette[col_count]}

    salmon_counts["categories"][no_hit] = {"color": no_hit_color}
    json.dump(salmon_counts, open(file, "w"))


if __name__ == "__main__":
    main()
