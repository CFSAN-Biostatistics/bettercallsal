#!/usr/bin/env python

import yaml
import platform
import subprocess
from textwrap import dedent


def _make_versions_html(versions):
    html = [
        dedent(
            """\\
            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/jszip-2.5.0/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/fc-4.1.0/r-2.3.0/sc-2.0.6/sb-1.3.3/sp-2.0.1/datatables.min.css"/>
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js"></script>
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js"></script>
            <script type="text/javascript" src="https://cdn.datatables.net/v/dt/jszip-2.5.0/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/fc-4.1.0/r-2.3.0/sc-2.0.6/sb-1.3.3/sp-2.0.1/datatables.min.js"></script>
            <style>
            #cpipes-software-versions tbody:nth-child(even) {
                background-color: #f2f2f2;
            }
            </style>
            <table class="table" style="width:100%" id="cpipes-software-versions">
                <thead>
                    <tr>
                        <th> Process Name </th>
                        <th> Software </th>
                        <th> Version  </th>
                    </tr>
                </thead>
            """
        )
    ]
    for process, tmp_versions in sorted(versions.items()):
        html.append("<tbody>")
        for i, (tool, version) in enumerate(sorted(tmp_versions.items())):
            html.append(
                dedent(
                    f"""\\
                    <tr>
                        <td><samp>{process if (i == 0) else ''}</samp></td>
                        <td><samp>{tool}</samp></td>
                        <td><samp>{version}</samp></td>
                    </tr>
                    """
                )
            )
        html.append("</tbody>")
    html.append("</table>")
    return "\\n".join(html)


versions_this_module = {}
versions_this_module["${task.process}"] = {
    "python": platform.python_version(),
    "yaml": yaml.__version__,
}

with open("$versions") as f:
    versions_by_process = yaml.load(f, Loader=yaml.BaseLoader)
    versions_by_process.update(versions_this_module)

# aggregate versions by the module name (derived from fully-qualified process name)
versions_by_module = {}
for process, process_versions in versions_by_process.items():
    module = process.split(":")[-1]
    try:
        assert versions_by_module[module] == process_versions, (
            "We assume that software versions are the same between all modules. "
            "If you see this error-message it means you discovered an edge-case "
            "and should open an issue in nf-core/tools. "
        )
    except KeyError:
        versions_by_module[module] = process_versions

versions_by_module["CPIPES"] = {
    "Nextflow": "$workflow.nextflow.version",
    "$workflow.manifest.name": "$workflow.manifest.version",
    "${params.pipeline}": "${params.workflow_version}",
}

versions_mqc = {
    "id": "software_versions",
    "section_name": "${workflow.manifest.name} Software Versions",
    "section_href": "https://github.com/CFSAN-Biostatistics/bettercallsal",
    "plot_type": "html",
    "description": "Collected at run time from the software output (STDOUT/STDERR).",
    "data": _make_versions_html(versions_by_module),
}

with open("software_versions.yml", "w") as f:
    yaml.dump(versions_by_module, f, default_flow_style=False)

# print('sed -i -e "' + "s%'%%g" + '" *.yml')
subprocess.run('sed -i -e "' + "s%'%%g" + '" software_versions.yml', shell=True)

with open("software_versions_mqc.yml", "w") as f:
    yaml.dump(versions_mqc, f, default_flow_style=False)

with open("versions.yml", "w") as f:
    yaml.dump(versions_this_module, f, default_flow_style=False)
