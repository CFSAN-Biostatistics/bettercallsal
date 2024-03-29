def mlstHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'mlst_run': [
            clihelp: "Run MLST tool. Default: ${params.mlst_run}",
            cliflag: null,
            clivalue: null
        ],
        'mlst_legacy': [
            clihelp: "Use old legacy output with allele header row (requires --mlst_scheme). " +
                "Default: ${params.mlst_legacy}",
            cliflag: '--legacy',
            clivalue: (params.mlst_legacy ? ' ' : '')
        ],
        'mlst_scheme': [
            clihelp: "Don't autodetect, force this scheme on all inputs. " +
                "Default: ${params.mlst_scheme}",
            cliflag: '--scheme',
            clivalue: (params.mlst_scheme ?: null)
        ],
        'mlst_minid': [
            clihelp: "DNA %identity of full allelle to consider 'similar' [~]. " +
                "Default: ${params.mlst_minid}",
            cliflag: '--minid',
            clivalue: (params.mlst_minid ?: 95)
        ],
        'mlst_mincov': [
            clihelp: 'DNA %cov to report partial allele at all [?].' +
                "Default: ${params.mlst_mincov}",
            cliflag: '--mincov',
            clivalue: (params.mlst_mincov ?: 10)
        ],
        'mlst_minscore': [
            clihelp: 'Minumum score out of 100 to match a scheme.' +
                "Default: ${params.mlst_minscore}",
            cliflag: '--minscore',
            clivalue: (params.mlst_minscore ?: 50)
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}