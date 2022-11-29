// Help text for seqkit grep within CPIPES.

def seqkitgrepHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'seqkit_grep_n': [
            clihelp: 'Match by full name instead of just ID. ' +
                "Default: " + (params.seqkit_grep_n ?: 'undefined'),
            cliflag: '--seqkit_grep_n',
            clivalue: (params.seqkit_grep_n ? ' ' : '')
        ], 
        'seqkit_grep_s': [
            clihelp: 'Search subseq on seq, both positive and negative ' +
                'strand are searched, and mismatch allowed using flag --seqkit_grep_m. ' +
                "Default: " + (params.seqkit_grep_s ?: 'undefined'),
            cliflag: '--seqkit_grep_s',
            clivalue: (params.seqkit_grep_s ? ' ' : '')
        ],
        'seqkit_grep_c': [
            clihelp: 'Input is circular genome ' +
                "Default: " + (params.seqkit_grep_c ?: 'undefined'),
            cliflag: '--seqkit_grep_c',
            clivalue: (params.seqkit_grep_c ? ' ' : '')
        ],
        'seqkit_grep_C': [
            clihelp: 'Just print a count of matching records. With the ' +
                '--seqkit_grep_v flag, count non-matching records. ' +
                "Default: " + (params.seqkit_grep_v ?: 'undefined'),
            cliflag: '--seqkit_grep_v',
            clivalue: (params.seqkit_grep_v ? ' ' : '')
        ],
        'seqkit_grep_i': [
            clihelp: 'Ignore case while using seqkit grep. ' +
                "Default: " + (params.seqkit_grep_i ?: 'undefined'),
            cliflag: '--seqkit_grep_i',
            clivalue: (params.seqkit_grep_i ? ' ' : '')
        ],
        'seqkit_grep_v': [
            clihelp: 'Invert the match i.e. select non-matching records. ' +
                "Default: " + (params.seqkit_grep_v ?: 'undefined'),
            cliflag: '--seqkit_grep_v',
            clivalue: (params.seqkit_grep_v ? ' ' : '')
        ],
        'seqkit_grep_m': [
            clihelp: 'Maximum mismatches when matching by sequence. ' +
                "Default: " + (params.seqkit_grep_m ?: 'undefined'),
            cliflag: '--seqkit_grep_m',
            clivalue: (params.seqkit_grep_v ?: '')
        ],
        'seqkit_grep_r': [
            clihelp: 'Input patters are regular expressions. ' +
                "Default: " + (params.seqkit_grep_m ?: 'undefined'),
            cliflag: '--seqkit_grep_m',
            clivalue: (params.seqkit_grep_v ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}