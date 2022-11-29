def serotypefinderHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'serotypefinder_run': [
            clihelp: "Run SerotypeFinder tool. Default: ${params.serotypefinder_run}",
            cliflag: null,
            clivalue: null
        ],
        'serotypefinder_x': [
            clihelp: 'Generate extended output files. ' +
                "Default: ${params.serotypefinder_x}",
            cliflag: '-x',
            clivalue: (params.serotypefinder_x ? ' ' : '')
        ],
        'serotypefinder_db': [
            clihelp: 'Path to SerotypeFinder databases. ' +
                "Default: ${params.serotypefinder_db}",
            cliflag: '-p',
            clivalue: null
        ],
        'serotypefinder_min_threshold': [
            clihelp: 'Minimum percent identity (in float) required for calling a hit. ' +
                "Default: ${params.serotypefinder_min_threshold}",
            cliflag: '-t',
            clivalue: (params.serotypefinder_min_threshold ?: '')
        ],
        'serotypefinder_min_cov': [
            clihelp: 'Minumum percent coverage (in float) required for calling a hit. ' +
                "Default: ${params.serotypefinder_min_cov}",
            cliflag: '-l',
            clivalue: (params.serotypefinder_min_cov ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}