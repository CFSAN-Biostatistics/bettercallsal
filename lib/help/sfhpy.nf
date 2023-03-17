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
        'sfhpy_fcn': [
            clihelp: 'Column name by which filtering of rows should be applied. ' +
                "Default: ${params.sfhpy_fcn}",
            cliflag: '-fcn',
            clivalue: (params.sfhpy_fcn ?: '')
        ],
        'sfhpy_fcv': [
            clihelp: 'Remove genomes whose match with the query FASTQ is less than ' +
                'this much. ' +
                "Default: ${params.sfhpy_fcv}",
            cliflag: '-fcv',
            clivalue: (params.sfhpy_fcv ?: '')
        ],
        'sfhpy_gt': [
            clihelp: 'Apply greather than or equal to condition on numeric values of ' +
                '--sfhpy_fcn column. ' +
                "Default: ${params.sfhpy_gt}",
            cliflag: '-gt',
            clivalue: (params.sfhpy_gt ? ' ' : '')
        ],
        'sfhpy_lt': [
            clihelp: 'Apply less than or equal to condition on numeric values of ' +
                '--sfhpy_fcn column. ' +
                "Default: ${params.sfhpy_lt}",
            cliflag: '-gt',
            clivalue: (params.sfhpy_lt ? ' ' : '')
        ],
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}