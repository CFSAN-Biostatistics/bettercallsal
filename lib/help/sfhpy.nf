// Help text for sourmash_filter_hits.py (sfhpy) within CPIPES.
def sfhpyHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sfhpy_run': [
            clihelp: 'Run the sourmash_filter_hits.py ' +
                'script. Default: ' +
                (params.sfhpy_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sfhpy_fcv': [
            clihelp: 'Remove genomes whose match with the query FASTQ is less than ' +
                'this much. ' +
                "Default: ${params.sfhpy_fcv}",
            cliflag: '-fcv',
            clivalue: (params.sfhpy_fcv ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}