// Help text for get_top_unique_mash_hit_genomes.py (tuspy) within CPIPES.

def tuspyHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'tuspy_run': [
            clihelp: 'Run the get_top_unique_mash_hits_genomes.py ' +
                'script. Default: ' +
                (params.tuspy_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'tuspy_s': [
            clihelp: 'Absolute UNIX path to metadata text file with the ' +
                'field separator, | and ' +
                '5 fields: serotype|asm_lvl|asm_url|snp_cluster_id' +
                'Ex: serotype=Derby,antigen_formula=4:f,g:-|Scaffold|402440|ftp://...' +
                '|PDS000096654.2. Mentioning this option will create a pickle file for the ' +
                'provided metadata and exits.' +
                " Default: ${params.tuspy_s}",
            cliflag: '-s',
            clivalue: (params.tuspy_s ?: '')
        ],
        'tuspy_m': [
            clihelp: 'Absolute UNIX path to mash screen results file.' +
                " Default: ${params.tuspy_m}",
            cliflag: '-m',
            clivalue: (params.tuspy_m ?: '')
        ],
        'tuspy_ps': [
            clihelp: 'Absolute UNIX Path to serialized metadata object ' +
                'in a pickle file.' +
                " Default: ${params.tuspy_ps}",
            cliflag: '-ps',
            clivalue: (params.tuspy_ps ?: '')
        ],
        'tuspy_gd': [
            clihelp: 'Absolute UNIX Path to directory containing ' +
                'gzipped genome FASTA files.' +
                " Default: ${params.tuspy_gd}",
            cliflag: '-gd',
            clivalue: (params.tuspy_gd ?: '')
        ],
        'tuspy_gds': [
            clihelp: 'Genome FASTA file suffix to search for in the ' +
                'genome directory.' +
                " Default: ${params.tuspy_gds}",
            cliflag: '-gds',
            clivalue: (params.tuspy_gds ?: '')
        ],
        'tuspy_n': [
            clihelp: 'Return up to this many number of top N unique ' +
                'genome accession hits.' +
                " Default: ${params.tuspy_n}",
            cliflag: '-n',
            clivalue: (params.tuspy_n ?: '')
        ],
        'tuspy_skip': [
            clihelp: 'Skip all hits which belong to the following bioproject ' +
                'accession(s). A comma separated list of more than one bioproject. ' +
                " Default: ${params.tuspy_skip}",
            cliflag: '-skip',
            clivalue: (params.tuspy_skip ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}