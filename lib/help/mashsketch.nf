// Help text for mash sketch within CPIPES.

def mashsketchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'mashsketch_run': [
            clihelp: 'Run `mash screen` tool. Default: ' +
                (params.mashsketch_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'mashsketch_l': [
            clihelp: 'List input. Lines in each <input> specify paths to sequence files, ' +
                'one per line. ' +
                "Default: ${params.mashsketch_l}",
            cliflag: '-l',
            clivalue: (params.mashsketch_l ? ' ' : '')
        ],
        'mashsketch_I': [
            clihelp: '<path>  ID field for sketch of reads (instead of first sequence ID). ' +
                "Default: ${params.mashsketch_I}",
            cliflag: '-I',
            clivalue: (params.mashsketch_I ?: '')
        ],
        'mashsketch_C': [
            clihelp: '<path>  Comment for a sketch of reads (instead of first sequence comment). ' +
                "Default: ${params.mashsketch_C}",
            cliflag: '-C',
            clivalue: (params.mashsketch_C ?: '')
        ],
        'mashsketch_k': [
            clihelp: '<int>   K-mer size. Hashes will be based on strings of this many ' +
                'nucleotides. Canonical nucleotides are used by default (see ' +
                'Alphabet options below). (1-32) ' +
                "Default: ${params.mashsketch_k}",
            cliflag: '-k',
            clivalue: (params.mashsketch_k ?: '')
        ],
        'mashsketch_s': [
            clihelp: '<int>   Sketch size. Each sketch will have at most this many non-redundant ' +
                'min-hashes. ' +
                "Default: ${params.mashsketch_s}",
            cliflag: '-s',
            clivalue: (params.mashsketch_s ?: '')
        ],
        'mashsketch_i': [
            clihelp: 'Sketch individual sequences, rather than whole files, e.g. for ' +
                'multi-fastas of single-chromosome genomes or pair-wise gene ' +
                'comparisons. ' +
                "Default: ${params.mashsketch_i}",
            cliflag: '-i',
            clivalue: (params.mashsketch_i ? ' ' : '')
        ],
        'mashsketch_S': [
            clihelp: '<int>   Seed to provide to the hash function. (0-4294967296) [42] ' +
                "Default: ${params.mashsketch_S}",
            cliflag: '-S',
            clivalue: (params.mashsketch_S ?: '')
        ],

        'mashsketch_w': [
            clihelp: '<num>   Probability threshold for warning about low k-mer size. (0-1) ' +
                "Default: ${params.mashsketch_w}",
            cliflag: '-w',
            clivalue: (params.mashsketch_w ?: '')
        ],
        'mashsketch_r': [
            clihelp: 'Input is a read set. See Reads options below. Incompatible with ' +
                '--mashsketch_i. ' +
                "Default: ${params.mashsketch_r}",
            cliflag: '-r',
            clivalue: (params.mashsketch_r ? ' ' : '')
        ],
        'mashsketch_b': [
            clihelp: '<size>  Use a Bloom filter of this size (raw bytes or with K/M/G/T) to ' +
                'filter out unique k-mers. This is useful if exact filtering with ' +
                '--mashsketch_m uses too much memory. However, some unique k-mers may pass ' +
                'erroneously, and copies cannot be counted beyond 2. Implies --mashsketch_r. ' +
                "Default: ${params.mashsketch_b}",
            cliflag: '-b',
            clivalue: (params.mashsketch_b ?: '')
        ],
        'mashsketch_m': [
            clihelp: '<int>   Minimum copies of each k-mer required to pass noise filter for ' +
                'reads. Implies --mashsketch_r. ' +
                "Default: ${params.mashsketch_r}",
            cliflag: '-m',
            clivalue: (params.mashsketch_m ?: '')
        ],
        'mashsketch_c': [
            clihelp: '<num>   Target coverage. Sketching will conclude if this coverage is ' +
                'reached before the end of the input file (estimated by average ' +
                'k-mer multiplicity). Implies --mashsketch_r. ' +
                "Default: ${params.mashsketch_c}",
            cliflag: '-c',
            clivalue: (params.mashsketch_c ?: '')
        ],
        'mashsketch_g': [
            clihelp: '<size>  Genome size (raw bases or with K/M/G/T). If specified, will be used ' +
                'for p-value calculation instead of an estimated size from k-mer ' +
                'content. Implies --mashsketch_r. ' +
                "Default: ${params.mashsketch_g}",
            cliflag: '-g',
            clivalue: (params.mashsketch_g ?: '')
        ],
        'mashsketch_n': [
            clihelp: 'Preserve strand (by default, strand is ignored by using canonical ' +
                'DNA k-mers, which are alphabetical minima of forward-reverse ' +
                'pairs). Implied if an alphabet is specified with --mashsketch_a ' +
                'or --mashsketch_z. ' +
                "Default: ${params.mashsketch_n}",
            cliflag: '-n',
            clivalue: (params.mashsketch_n ? ' ' : '')
        ],
        'mashsketch_a': [
            clihelp: 'Use amino acid alphabet (A-Z, except BJOUXZ). Implies ' +
                '--mashsketch_n --mashsketch_k 9. ' +
                "Default: ${params.mashsketch_a}",
            cliflag: '-a',
            clivalue: (params.mashsketch_a ? ' ' : '')
        ],
        'mashsketch_z': [
            clihelp: '<text>  Alphabet to base hashes on (case ignored by default; ' +
                'see --mashsketch_Z). K-mers with other characters will be ' +
                'ignored. Implies --mashsketch_n. ' +
                "Default: ${params.mashsketch_z}",
            cliflag: '-z',
            clivalue: (params.mashsketch_z ?: '')
        ],
        'mashsketch_Z': [
            clihelp: 'Preserve case in k-mers and alphabet (case is ignored by default). ' +
                'Sequence letters whose case is not in the current alphabet will be ' +
                'skipped when sketching. ' +
                "Default: ${params.mashsketch_Z}",
            cliflag: '-Z',
            clivalue: (params.mashsketch_Z ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}