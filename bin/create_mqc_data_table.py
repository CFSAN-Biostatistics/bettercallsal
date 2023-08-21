#!/usr/bin/env python

import os
import sys
from textwrap import dedent

import yaml


def main():
    """
    Takes a tab-delimited text file with a mandatory header
    column and generates an HTML table.
    """

    args = sys.argv
    if len(args) < 2 or len(args) >= 4:
        print(
            f"\nAt least one argument specifying the *.tblsum file is required.\n"
            + "No more than 2 command-line arguments should be passed.\n"
        )
        exit(1)

    table_sum_on = str(args[1]).lower() + ".tblsum.txt"
    cell_colors = f"{table_sum_on}.cellcolors.yml"

    if len(args) == 3:
        description = str(args[2])
    else:
        description = "The results table shown here is a collection from all samples."

    if os.path.exists(cell_colors) and os.path.getsize(cell_colors) > 0:
        with open(cell_colors, "r") as cc_yml:
            cell_colors = yaml.safe_load(cc_yml)
    else:
        cell_colors = dict()

    if not (os.path.exists(table_sum_on) and os.path.getsize(table_sum_on) > 0):
        exit(0)

    with open(table_sum_on, "r") as tbl:
        header = tbl.readline()
        header_cols = header.strip().split("\t")

        html = [
            dedent(
                f"""<script type="text/javascript">
                    $(document).ready(function () {{
                        $('#cpipes-process-custom-res-{table_sum_on}').DataTable({{
                            scrollX: true,
                            fixedColumns: true, dom: 'Bfrtip',
                            buttons: [
                                'copy',
                                {{
                                    extend: 'print',
                                    title: 'CPIPES: MultiQC Report: {table_sum_on}'
                                }},
                                {{
                                    extend: 'excel',
                                    filename: '{table_sum_on}_results',
                                }},
                                {{
                                    extend: 'csv',
                                    filename: '{table_sum_on}_results',
                                }}
                            ]
                        }});
                    }});
                </script>
                <div class="table-responsive">
                <style>
                #cpipes-process-custom-res tr:nth-child(even) {{
                    background-color: #f2f2f2;
                }}
                </style>
                <table class="table" style="width:100%" id="cpipes-process-custom-res-{table_sum_on}">
                <thead>
                <tr>"""
            )
        ]

        for header_col in header_cols:
            html.append(
                dedent(
                    f"""
                        <th> {header_col} </th>"""
                )
            )

        html.append(
            dedent(
                """
                </tr>
                </thead>
                <tbody>"""
            )
        )

        for row in tbl:
            html.append("<tr>\n")
            data_cols = row.strip().split("\t")
            if len(header_cols) != len(data_cols):
                print(
                    f"\nWARN: Number of header columns ({len(header_cols)}) and data "
                    + f"columns ({len(data_cols)}) are not equal!\nWill append empty columns!\n"
                )
                if len(header_cols) > len(data_cols):
                    data_cols += (len(header_cols) - len(data_cols)) * " "
                    print(len(data_cols))
                else:
                    header_cols += (len(data_cols) - len(header_cols)) * " "

            html.append(
                dedent(
                    f"""
                        <td><samp>{data_cols[0]}</samp></td>
                    """
                )
            )

            for data_col in data_cols[1:]:
                data_col_w_color = f"""<td>{data_col}</td>
                """
                if (
                    table_sum_on in cell_colors.keys()
                    and data_col in cell_colors[table_sum_on].keys()
                ):
                    data_col_w_color = f"""<td style="background-color: {cell_colors[table_sum_on][data_col]}">{data_col}</td>
                    """
                html.append(dedent(data_col_w_color))
            html.append("</tr>\n")
        html.append("</tbody>\n")
        html.append("</table>\n")
        html.append("</div>\n")

        mqc_yaml = {
            "id": f"{table_sum_on.upper()}_collated_table",
            "section_name": f"{table_sum_on.upper()}",
            "section_href": f"https://github.com/CFSAN-Biostatistics/bettercallsal",
            "plot_type": "html",
            "description": f"{description}",
            "data": ("").join(html),
        }

        with open(f"{table_sum_on.lower()}_mqc.yml", "w") as html_mqc:
            yaml.dump(mqc_yaml, html_mqc, default_flow_style=False)


if __name__ == "__main__":
    main()
