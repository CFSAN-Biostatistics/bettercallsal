// Help text for mash screen within CPIPES.

def mashscreenHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'mashscreen_run': [
            clihelp: 'Run `mash screen` tool. Default: ' +
                (params.mashscreen_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'mashscreen_w': [
            clihelp: 'Winner-takes-all strategy for identity estimates. After counting ' +
                'hashes for each query, hashes that appear in multiple queries will ' +
                'be removed from all except the one with the best identity (ties ' +
                'broken by larger query), and other identities will be reduced. This ' +
                'removes output redundancy, providing a rough compositional outline. ' +
                " Default: ${params.mashscreen_w}",
            cliflag: '-w',
            clivalue: (params.mashscreen_w ? ' ' : '')
        ], 
        'mashscreen_i': [
            clihelp: 'Minimum identity to report. Inclusive unless set to zero, in which ' +
                'case only identities greater than zero (i.e. with at least one ' +
                'shared hash) will be reported. Set to -1 to output everything. ' +
                "(-1-1). Default: ${params.mashscreen_i}",
            cliflag: '-i',
            clivalue: (params.mashscreen_i ?: '')
        ],
        'mashscreen_v': [
            clihelp: 'Maximum p-value to report (0-1). ' +
                "Default: ${params.mashscreen_v}",
            cliflag: '-v',
            clivalue: (params.mashscreen_v ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}