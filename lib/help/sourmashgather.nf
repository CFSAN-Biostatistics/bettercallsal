// Help text for sourmash gather within CPIPES.mashsketch

def sourmashgatherHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sourmashgather_run': [
            clihelp: 'Run `sourmash gather` tool. Default: ' +
                (params.sourmashgather_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sourmashgather_n': [
            clihelp: 'Number of results to report. ' +
                'By default, will terminate at --sourmashgather_thr_bp value. ' +
                "Default: ${params.sourmashgather_n}",
            cliflag: '-n',
            clivalue: (params.sourmashgather_n ?: '')
        ],
        'sourmashgather_thr_bp': [
            clihelp: 'Reporting threshold (in bp) for estimated overlap with remaining query. ' +
                "Default: ${params.sourmashgather_thr_bp}",
            cliflag: '--threshold_bp',
            clivalue: (params.sourmashgather_thr_bp ?: '')
        ],
        'sourmashgather_ani_ci': [
            clihelp: 'Output confidence intervals for ANI estimates. ' +
                "Default: ${params.sourmashgather_ani_ci}",
            cliflag: '--estimate-ani-ci',
            clivalue: (params.sourmashgather_ani_ci ? ' ' : '')
        ],
        'sourmashgather_k': [
            clihelp: 'The k-mer size to select. ' +
                "Default: ${params.sourmashgather_k}",
            cliflag: '-k',
            clivalue: (params.sourmashgather_k ?: '')
        ],
        'sourmashgather_dna': [
            clihelp: 'Choose DNA signature. ' +
                "Default: ${params.sourmashgather_dna}",
            cliflag: '--dna',
            clivalue: (params.sourmashgather_dna ? ' ' : '')
        ],
        'sourmashgather_rna': [
            clihelp: 'Choose RNA signature. ' +
                "Default: ${params.sourmashgather_rna}",
            cliflag: '--rna',
            clivalue: (params.sourmashgather_rna ? ' ' : '')
        ],
        'sourmashgather_nuc': [
            clihelp: 'Choose Nucleotide signature. ' +
                "Default: ${params.sourmashgather_nuc}",
            cliflag: '--nucleotide',
            clivalue: (params.sourmashgather_nuc ? ' ' : '')
        ],
        'sourmashgather_scaled': [
            clihelp: 'Scaled value should be between 100 and 1e6. ' +
                "Default: ${params.sourmashgather_scaled}",
            cliflag: '--scaled',
            clivalue: (params.sourmashgather_scaled ?: '')
        ],
        'sourmashgather_inc_pat': [
            clihelp: 'Search only signatures that match this pattern in name, filename, or md5. ' +
                "Default: ${params.sourmashgather_inc_pat}",
            cliflag: '--include-db-pattern',
            clivalue: (params.sourmashgather_inc_pat ?: '')
        ],
        'sourmashgather_exc_pat': [
            clihelp: 'Search only signatures that do not match this pattern in name, filename, or md5. ' +
                "Default: ${params.sourmashgather_exc_pat}",
            cliflag: '--exclude-db-pattern',
            clivalue: (params.sourmashgather_exc_pat ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}