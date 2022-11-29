// Help text for seqkit rmdup within CPIPES.

def seqkitrmdupHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'seqkit_rmdup_run': [
            clihelp: 'Remove duplicate sequences using seqkit rmdup. Default: ' +
                (params.seqkit_rmdup_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'seqkit_rmdup_n': [
            clihelp: 'Match and remove duplicate sequences by full name instead of just ID. ' +
                "Default: ${params.seqkit_rmdup_n}",
            cliflag: '-n',
            clivalue: (params.seqkit_rmdup_n ? ' ' : '')
        ], 
        'seqkit_rmdup_s': [
            clihelp: 'Match and remove duplicate sequences by sequence content. ' +
                "Default: ${params.seqkit_rmdup_s}",
            cliflag: '-s',
            clivalue: (params.seqkit_rmdup_s ? ' ' : '')
        ],
        'seqkit_rmdup_d': [
            clihelp: 'Save the duplicated sequences to a file. ' +
                "Default: ${params.seqkit_rmdup_d}",
            cliflag: null,
            clivalue: null
        ],
        'seqkit_rmdup_D': [
            clihelp: 'Save the number and list of duplicated sequences to a file. ' +
                "Default: ${params.seqkit_rmdup_D}",
            cliflag: null,
            clivalue: null
        ],
        'seqkit_rmdup_i': [
            clihelp: 'Ignore case while using seqkit rmdup. ' +
                "Default: ${params.seqkit_rmdup_i}",
            cliflag: '-i',
            clivalue: (params.seqkit_rmdup_i ? ' ' : '')
        ],
        'seqkit_rmdup_P': [
            clihelp: "Only consider positive strand (i.e. 5') when comparing by sequence content. " +
                "Default: ${params.seqkit_rmdup_P}",
            cliflag: '-P',
            clivalue: (params.seqkit_rmdup_P ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}