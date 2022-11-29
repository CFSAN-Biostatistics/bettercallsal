// Help text for kma index within CPIPES.

def kmaindexHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'kmaindex_run': [
            clihelp: 'Run kma index tool. Default: ' +
                (params.kmaindex_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'kmaindex_t_db': [
            clihelp: 'Add to existing DB. ' +
                "Default: ${params.kmaindex_t_db}",
            cliflag: '-t_db',
            clivalue: (params.kmaindex_t_db ? ' ' : '')
        ], 
        'kmaindex_k': [
            clihelp: 'k-mer size. ' +
                "Default: ${params.kmaindex_k}",
            cliflag: '-k',
            clivalue: (params.kmaindex_k ?: '')
        ],
        'kmaindex_m': [
            clihelp: 'Minimizer size. ' +
                "Default: ${params.kmaindex_m}",
            cliflag: '-m',
            clivalue: (params.kmaindex_m ?: '')
        ],
        'kmaindex_hc': [
            clihelp: 'Homopolymer compression. ' +
                "Default: ${params.kmaindex_hc}",
            cliflag: '-hc',
            clivalue: (params.kmaindex_hc ? ' ' : '')
        ],
        'kmaindex_ML': [
            clihelp: 'Minimum length of templates. Defaults to --kmaindex_k ' +
                "Default: ${params.kmaindex_ML}",
            cliflag: '-ML',
            clivalue: (params.kmaindex_ML ?: '')
        ],
        'kmaindex_ME': [
            clihelp: 'Mega DB. ' +
                "Default: ${params.kmaindex_ME}",
            cliflag: '-ME',
            clivalue: (params.kmaindex_ME ? ' ' : '')
        ],
        'kmaindex_Sparse': [
            clihelp: 'Make Sparse DB. ' +
                "Default: ${params.kmaindex_Sparse}",
            cliflag: '-Sparse',
            clivalue: (params.kmaindex_Sparse ? ' ' : '')
        ],
        'kmaindex_ht': [
            clihelp: 'Homology template. ' +
                "Default: ${params.kmaindex_ht}",
            cliflag: '-ht',
            clivalue: (params.kmaindex_ht ?: '')
        ],
        'kmaindex_hq': [
            clihelp: 'Homology query. ' +
                "Default: ${params.kmaindex_hq}",
            cliflag: '-hq',
            clivalue: (params.kmaindex_hq ?: '')
        ],
        'kmaindex_and': [
            clihelp: 'Both homology thresholds have to reach. ' +
                "Default: ${params.kmaindex_and}",
            cliflag: '-and',
            clivalue: (params.kmaindex_and ? ' ' : '')
        ],
        'kmaindex_nbp': [
            clihelp: 'No bias print. ' +
                "Default: ${params.kmaindex_nbp}",
            cliflag: '-nbp',
            clivalue: (params.kmaindex_nbp ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}