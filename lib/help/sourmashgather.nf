// Help text for sourmash gather within CPIPES.

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
            cliflag: '--threshold-bp',
            clivalue: (params.sourmashgather_thr_bp ?: '')
        ],
        'sourmashgather_ignoreabn': [
            clihelp: 'Do NOT use k-mer abundances if present. ' +
                "Default: ${params.sourmashgather_ignoreabn}",
            cliflag: '--ignore-abundance',
            clivalue: (params.sourmashgather_ignoreabn ? ' ' : '')
        ],
        'sourmashgather_prefetch': [
            clihelp: 'Use prefetch before gather. ' +
                "Default: ${params.sourmashgather_prefetch}",
            cliflag: '--prefetch',
            clivalue: (params.sourmashgather_prefetch ? ' ' : '')
        ],
        'sourmashgather_noprefetch': [
            clihelp: 'Do not use prefetch before gather. ' +
                "Default: ${params.sourmashgather_noprefetch}",
            cliflag: '--no-prefetch',
            clivalue: (params.sourmashgather_noprefetch ? ' ' : '')
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
        'sourmashgather_protein': [
            clihelp: 'Choose a protein signature. ' +
                "Default: ${params.sourmashgather_protein}",
            cliflag: '--protein',
            clivalue: (params.sourmashgather_protein ? ' ' : '')
        ],
        'sourmashgather_noprotein': [
            clihelp: 'Do not choose a protein signature. ' +
                "Default: ${params.sourmashgather_noprotein}",
            cliflag: '--no-protein',
            clivalue: (params.sourmashgather_noprotein ? ' ' : '')
        ],
        'sourmashgather_dayhoff': [
            clihelp: 'Choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashgather_dayhoff}",
            cliflag: '--dayhoff',
            clivalue: (params.sourmashgather_dayhoff ? ' ' : '')
        ],
        'sourmashgather_nodayhoff': [
            clihelp: 'Do not choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashgather_nodayhoff}",
            cliflag: '--no-dayhoff',
            clivalue: (params.sourmashgather_nodayhoff ? ' ' : '')
        ],
        'sourmashgather_hp': [
            clihelp: 'Choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashgather_hp}",
            cliflag: '--hp',
            clivalue: (params.sourmashgather_hp ? ' ' : '')
        ],
        'sourmashgather_nohp': [
            clihelp: 'Do not choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashgather_nohp}",
            cliflag: '--no-hp',
            clivalue: (params.sourmashgather_nohp ? ' ' : '')
        ],
        'sourmashgather_dna': [
            clihelp: 'Choose DNA signature. ' +
                "Default: ${params.sourmashgather_dna}",
            cliflag: '--dna',
            clivalue: (params.sourmashgather_dna ? ' ' : '')
        ],
        'sourmashgather_nodna': [
            clihelp: 'Do not choose DNA signature. ' +
                "Default: ${params.sourmashgather_nodna}",
            cliflag: '--no-dna',
            clivalue: (params.sourmashgather_nodna ? ' ' : '')
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