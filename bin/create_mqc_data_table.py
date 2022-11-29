#!/usr/bin/env python

import sys
import yaml
from textwrap import dedent


def main():
    """
    Takes a tab-delimited text file with a mandatory header
    column and generates an HTML table.
    """

    args = sys.argv
    if len(args) < 2 or len(args) > 3:
        print(f"\nTwo CL arguments are required!\n")
        exit(1)

    table_sum_on = args[1].lower()
    workflow_name = args[2].lower()

    with open(f"{table_sum_on}.tblsum.txt", "r") as tbl:
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
                html.append(
                    dedent(
                        f"""<td>{data_col}</td>
                        """
                    )
                )
            html.append("</tr>\n")
        html.append("</tbody>\n")
        html.append("</table>\n")
        html.append("</div>\n")

        mqc_yaml = {
            "id": f"{table_sum_on.upper()}_collated_table",
            "section_name": f"{table_sum_on.upper()}",
            "section_href": f"https://github.com/CFSAN-Biostatistics/bettercallsal",
            "plot_type": "html",
            "description": "The results table shown here is a collection from all samples.",
            "data": ("").join(html),
        }

        with open(f"{table_sum_on.lower()}_mqc.yml", "w") as html_mqc:
            yaml.dump(mqc_yaml, html_mqc, default_flow_style=False)


if __name__ == "__main__":
    main()
