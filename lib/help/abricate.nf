// Help text for abricate within CPIPES.

def abricateHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'abricate_run': [
            clihelp: 'Run ABRicate tool. Default: ' +
                (params.abricate_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'abricate_minid': [
            clihelp: 'Minimum DNA %identity. ' +
                "Default: " + (params.abricate_minid ?: 80),
            cliflag: '--minid',
            clivalue: (params.abricate_minid ?: 80)
        ], 
        'abricate_mincov': [
            clihelp: 'Minimum DNA %coverage. ' +
                "Default: " + (params.abricate_mincov ?: 80),
            cliflag: '--mincov',
            clivalue: (params.abricate_mincov ?: 80)
        ],
        'abricate_datadir': [
            clihelp: 'ABRicate databases folder. ' +
                "Default: " + (params.abricate_datadir ?: 'undefined'),
            cliflag: '--datadir',
            clivalue: (params.abricate_datadir ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}