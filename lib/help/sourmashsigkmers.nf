// Help text for sourmash sigkmers within CPIPES.

def sourmashsigkmersHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sourmashsigkmers_run': [
            clihelp: 'Run `sourmash sigkmers` tool. Default: ' +
                (params.sourmashsigkmers_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sourmashsigkmers_k': [
            clihelp: 'The k-mer size to select. ' +
                "Default: ${params.sourmashsigkmers_k}",
            cliflag: '-k',
            clivalue: (params.sourmashsigkmers_k ?: '')
        ],
        'sourmashsigkmers_protein': [
            clihelp: 'Choose a protein signature. ' +
                "Default: ${params.sourmashsigkmers_protein}",
            cliflag: '--protein',
            clivalue: (params.sourmashsigkmers_protein ? ' ' : '')
        ],
        'sourmashsigkmers_noprotein': [
            clihelp: 'Do not choose a protein signature. ' +
                "Default: ${params.sourmashsigkmers_noprotein}",
            cliflag: '--no-protein',
            clivalue: (params.sourmashsigkmers_noprotein ? ' ' : '')
        ],
        'sourmashsigkmers_dayhoff': [
            clihelp: 'Choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsigkmers_dayhoff}",
            cliflag: '--dayhoff',
            clivalue: (params.sourmashsigkmers_dayhoff ? ' ' : '')
        ],
        'sourmashsigkmers_nodayhoff': [
            clihelp: 'Do not choose Dayhoff-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsigkmers_nodayhoff}",
            cliflag: '--no-dayhoff',
            clivalue: (params.sourmashsigkmers_nodayhoff ? ' ' : '')
        ],
        'sourmashsigkmers_hp': [
            clihelp: 'Choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsigkmers_hp}",
            cliflag: '--hp',
            clivalue: (params.sourmashsigkmers_hp ? ' ' : '')
        ],
        'sourmashsigkmers_nohp': [
            clihelp: 'Do not choose hydrophobic-polar-encoded amino acid signatures. ' +
                "Default: ${params.sourmashsigkmers_nohp}",
            cliflag: '--no-hp',
            clivalue: (params.sourmashsigkmers_nohp ? ' ' : '')
        ],
        'sourmashsigkmers_dna': [
            clihelp: 'Choose DNA signature. ' +
                "Default: ${params.sourmashsigkmers_dna}",
            cliflag: '--dna',
            clivalue: (params.sourmashsigkmers_dna ? ' ' : '')
        ],
        'sourmashsigkmers_nodna': [
            clihelp: 'Do not choose DNA signature. ' +
                "Default: ${params.sourmashsigkmers_nodna}",
            cliflag: '--no-dna',
            clivalue: (params.sourmashsigkmers_nodna ? ' ' : '')
        ],
        'sourmashsigkmers_save_kmers': [
            clihelp: 'Save k-mers and hash values to a CSV file. ' +
                "Default: ${params.sourmashsigkmers_save_kmers}",
            cliflag: null,
            clivalue: null
        ],
        'sourmashsigkmers_save_seqs': [
            clihelp: 'Save sequences with matching hash values to a FASTA file. ' +
                "Default: ${params.sourmashsigkmers_save_seqs}",
            cliflag: null,
            clivalue: null
        ],
        'sourmashsigkmers_translate': [
            clihelp: 'Translate DNA k-mers into amino acids (for protein, dayhoff, and hp sketches). ' +
                "Default: ${params.sourmashsigkmers_translate}",
            cliflag: '--translate',
            clivalue: (params.sourmashsigkmers_translate ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}