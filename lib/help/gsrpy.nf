// Help text for gen_salmon_res_table.py (gsrpy) within CPIPES.

def gsrpyHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'gsrpy_run': [
            clihelp: 'Run the gen_salmon_res_table.py script. Default: ' +
                (params.gsrpy_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'gsrpy_url': [
            clihelp: 'Generate an additional column in final results table ' +
                'which links out to NCBI Pathogens Isolate Browser. ' +
                " Default: ${params.gsrpy_url}",
            cliflag: '-url',
            clivalue: (params.gsrpy_url ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}