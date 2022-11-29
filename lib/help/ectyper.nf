def ectyperHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'ectyper_run': [
            clihelp: "Run ectyper tool. Default: ${params.ectyper_run}",
            cliflag: null,
            clivalue: null
        ],
        'ectyper_perc_opid': [
            clihelp: 'Percent identity required for an O antigen allele match. ' +
                "Default: ${params.ectyper_perc_opid}",
            cliflag: '-opid',
            clivalue: (params.ectyper_perc_opid ?: 90)
        ],
        'ectyper_perc_hpid': [
            clihelp: 'Percent identity required for a H antigen allele match. ' +
                "Default: ${params.ectyper_perc_hpid}",
            cliflag: '-hpid',
            clivalue: (params.ectyper_perc_hpid ?: 95)
        ],
        'ectyper_perc_opcov': [
            clihelp: 'Minumum percent coverage required for an O antigen allele match. ' +
                "Default: ${params.ectyper_perc_opcov}",
            cliflag: '-opcov',
            clivalue: (params.ectyper_perc_opcov ?: 95)
        ],
        'ectyper_perc_hpcov': [
            clihelp: 'Minumum percent coverage required for a H antigen allele match. ' +
                "Default: ${params.ectyper_perc_hpcov}",
            cliflag: '-hpcov',
            clivalue: (params.ectyper_perc_hpcov ?: 50)
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}