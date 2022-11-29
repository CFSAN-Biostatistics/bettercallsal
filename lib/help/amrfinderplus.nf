def amrfinderplusHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'amrfinderplus_run': [
            clihelp: "Run AMRFinderPlus tool. Default: ${params.amrfinderplus_run}",
            cliflag: null,
            clivalue: null
        ],
        'amrfinderplus_db': [
            clihelp: 'Path to AMRFinderPlus database. Please note that ' +
                ' the databases should be ready and formatted with blast for use. ' +
                'Please read more at: ' +
                'https://github.com/ncbi/amr/wiki/AMRFinderPlus-database ' +
                "Default: ${params.amrfinderplus_db}",
            cliflag: '--database',
            clivalue: (params.amrfinderplus_db ?: '')
        ],
        'amrfinderplus_genes': [
            clihelp: 'Add the plus genes to the report',
            cliflag: '--plus',
            clivalue: (params.amrfinderplus_genes ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}