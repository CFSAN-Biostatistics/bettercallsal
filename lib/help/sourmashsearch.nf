// Help text for sourmash search within CPIPES.

def sourmashsearchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sourmashsearch_run': [
            clihelp: 'Run `sourmash search` tool. Default: ' +
                (params.sourmashsearch_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sourmashsearch_n': [
            clihelp: 'Number of results to report. ' +
                'By default, will terminate at --sourmashsearch_thr value. ' +
                "Default: ${params.sourmashsearch_n}",
            cliflag: '-n',
            clivalue: (params.sourmashsearch_n ?: '')
        ],
        'sourmashsearch_thr': [
            clihelp: 'Reporting threshold (similarity) to return results. ' +
                "Default: ${params.sourmashsearch_thr}",
            cliflag: '--threshold',
            clivalue: (params.sourmashsearch_thr ?: '')
        ],
        'sourmashsearch_contain': [
            clihelp: 'Score based on containment rather than similarity. ' +
                "Default: ${params.sourmashsearch_contain}",
            cliflag: '--containment',
            clivalue: (params.sourmashsearch_contain ? ' ' : '')
        ],
        'sourmashsearch_maxcontain': [
            clihelp: 'Score based on max containment rather than similarity. ' +
                "Default: ${params.sourmashsearch_contain}",
            cliflag: '--max-containment',
            clivalue: (params.sourmashsearch_maxcontain ? ' ' : '')
        ],
        'sourmashsearch_ignoreabn': [
            clihelp: 'Do NOT use k-mer abundances if present. ' +
                "Default: ${params.sourmashsearch_ignoreabn}",
            cliflag: '--ignore-abundance',
            clivalue: (params.sourmashsearch_ignoreabn ? ' ' : '')
        ],
        'sourmashsearch_ani_ci': [
            clihelp: 'Output confidence intervals for ANI estimates. ' +
                "Default: ${params.sourmashsearch_ani_ci}",
            cliflag: '--estimate-ani-ci',
            clivalue: (params.sourmashsearch_ani_ci ? ' ' : '')
        ],
        'sourmashsearch_k': [
            clihelp: 'The k-mer size to select. ' +
                "Default: ${params.sourmashsearch_k}",
            cliflag: '-k',
            clivalue: (params.sourmashsearch_k ?: '')
        ],
        'sourmashsearch_protein': [
            clihelp: 'Choose a protein signature. ' +
                "Default: ${params.sourmashsearch_protein}",
            cliflag: '--protein',
            clivalue: (params.sourmashsearch_protein ? ' ' : '')
        ],
        'sourmashsearch_noprotein': [
            clihelp: 'Do not choose a protein signature. ' +
                "Default: ${params.sourmashsearch_noprotein}",
            cliflag: '--no-protein',
            clivalue: (params.sourmashsearch_noprotein ? ' ' : '')
        ],
        'sourmashsearch_dayhoff': [
            clihelp: 'Choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsearch_dayhoff}",
            cliflag: '--dayhoff',
            clivalue: (params.sourmashsearch_dayhoff ? ' ' : '')
        ],
        'sourmashsearch_nodayhoff': [
            clihelp: 'Do not choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsearch_nodayhoff}",
            cliflag: '--no-dayhoff',
            clivalue: (params.sourmashsearch_nodayhoff ? ' ' : '')
        ],
        'sourmashsearch_hp': [
            clihelp: 'Choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsearch_hp}",
            cliflag: '--hp',
            clivalue: (params.sourmashsearch_hp ? ' ' : '')
        ],
        'sourmashsearch_nohp': [
            clihelp: 'Do not choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsearch_nohp}",
            cliflag: '--no-hp',
            clivalue: (params.sourmashsearch_nohp ? ' ' : '')
        ],
        'sourmashsearch_dna': [
            clihelp: 'Choose DNA signature. ' +
                "Default: ${params.sourmashsearch_dna}",
            cliflag: '--dna',
            clivalue: (params.sourmashsearch_dna ? ' ' : '')
        ],
        'sourmashsearch_nodna': [
            clihelp: 'Do not choose DNA signature. ' +
                "Default: ${params.sourmashsearch_nodna}",
            cliflag: '--no-dna',
            clivalue: (params.sourmashsearch_nodna ? ' ' : '')
        ],
        'sourmashsearch_scaled': [
            clihelp: 'Scaled value should be between 100 and 1e6. ' +
                "Default: ${params.sourmashsearch_scaled}",
            cliflag: '--scaled',
            clivalue: (params.sourmashsearch_scaled ?: '')
        ],
        'sourmashsearch_inc_pat': [
            clihelp: 'Search only signatures that match this pattern in name, filename, or md5. ' +
                "Default: ${params.sourmashsearch_inc_pat}",
            cliflag: '--include-db-pattern',
            clivalue: (params.sourmashsearch_inc_pat ?: '')
        ],
        'sourmashsearch_exc_pat': [
            clihelp: 'Search only signatures that do not match this pattern in name, filename, or md5. ' +
                "Default: ${params.sourmashsearch_exc_pat}",
            cliflag: '--exclude-db-pattern',
            clivalue: (params.sourmashsearch_exc_pat ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}