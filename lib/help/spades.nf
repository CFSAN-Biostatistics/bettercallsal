// Help text for spades within CPIPES.

def spadesHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'spades_run': [
            clihelp: 'Run SPAdes assembler. Default: ' +
                (params.spades_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'spades_isolate': [
            clihelp: 'This flag is highly recommended for high-coverage isolate and ' +
                "multi-cell data. Default: ${params.spades_isolate}",
            cliflag: '--isolate',
            clivalue: (params.spades_isolate ? ' ' : '')
        ], 
        'spades_sc': [
            clihelp: 'This flag is required for MDA (single-cell) data. ' +
                "Default: ${params.spades_sc}",
            cliflag: '--sc',
            clivalue: (params.spades_sc ? ' ' : '')
        ],
        'spades_meta': [
            clihelp: 'This flag is required for metagenomic data. ' +
                "Default: ${params.spades_meta}",
            cliflag: '--meta',
            clivalue: (params.spades_meta ? ' ' : '')
        ],
        'spades_bio': [
            clihelp: 'This flag is required for biosytheticSPAdes mode. ' +
                "Default: ${params.spades_bio}",
            cliflag: '--bio',
            clivalue: (params.spades_bio ? ' ' : '')
        ],
        'spades_corona': [
            clihelp: 'This flag is required for coronaSPAdes mode. ' +
                "Default: ${params.spades_corona}",
            cliflag: '--corona',
            clivalue: (params.spades_corona ? ' ' : '')
        ],
        'spades_rna': [
            clihelp: 'This flag is required for RNA-Seq data. ' +
                "Default: ${params.spades_rna}",
            cliflag: '--rna',
            clivalue: (params.spades_rna ? ' ' : '')
        ],
        'spades_plasmid': [
            clihelp: 'Runs plasmidSPAdes pipeline for plasmid detection. ' +
                "Default: ${params.spades_plasmid}",
            cliflag: '--plasmid',
            clivalue: (params.spades_plasmid ? ' ' : '')
        ],
        'spades_metaviral': [
            clihelp: 'Runs metaviralSPAdes pipeline for virus detection. ' +
                "Default: ${params.spades_metaviral}",
            cliflag: '--metaviral',
            clivalue: (params.spades_metaviral ? ' ' : '')
        ],
        'spades_metaplasmid': [
            clihelp: 'Runs metaplasmidSPAdes pipeline for plasmid detection in ' +
                "metagenomics datasets. Default: ${params.spades_metaplasmid}",
            cliflag: '--metaplasmid',
            clivalue: (params.spades_metaplasmid ? ' ' : '')
        ],
        'spades_rnaviral': [
            clihelp: 'This flag enables virus assembly module from RNA-Seq data. ' +
                "Default: ${params.spades_rnaviral}",
            cliflag: '--rnaviral',
            clivalue: (params.spades_rnaviral ? ' ' : '')
        ],
        'spades_iontorrent': [
            clihelp: 'This flag is required for IonTorrent data. ' +
                "Default: ${params.spades_iontorrent}",
            cliflag: '--iontorrent',
            clivalue: (params.spades_iontorrent ? ' ' : '')
        ],
        'spades_only_assembler': [
            clihelp: 'Runs only the SPAdes assembler module (without read error correction). ' +
                "Default: ${params.spades_only_assembler}",
            cliflag: '--only-assembler',
            clivalue: (params.spades_only_assembler ? ' ' : '')
        ],
        'spades_careful': [
            clihelp: 'Tries to reduce the number of mismatches and short indels in the assembly. ' +
                "Default: ${params.spades_careful}",
            cliflag: '--careful',
            clivalue: (params.spades_careful ? ' ' : '')
        ],
        'spades_cov_cutoff': [
            clihelp: 'Coverage cutoff value (a positive float number). ' +
                "Default: ${params.spades_cov_cutoff}",
            cliflag: '--cov-cutoff',
            clivalue: (params.spades_cov_cutoff ?: '')
        ],
        'spades_k': [
            clihelp: 'List of k-mer sizes (must be odd and less than 128). ' +
                "Default: ${params.spades_k}",
            cliflag: '-k',
            clivalue: (params.spades_k ?: '')
        ],
        'spades_hmm': [
            clihelp: 'Directory with custom hmms that replace the default ones (very rare). ' +
                "Default: ${params.spades_hmm}",
            cliflag: '--custom-hmms',
            clivalue: (params.spades_hmm ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}