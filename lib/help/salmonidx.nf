// Help text for salmon index within CPIPES.

def salmonidxHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'salmonidx_run': [
            clihelp: 'Run `salmon index` tool. Default: ' +
                (params.salmonidx_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'salmonidx_k': [
            clihelp: 'The size of k-mers that should be used for the ' +
                " quasi index. Default: ${params.salmonidx_k}",
            cliflag: '-k',
            clivalue: (params.salmonidx_k ?: '')
        ],
        'salmonidx_gencode': [
            clihelp: 'This flag will expect the input transcript FASTA ' +
                'to be in GENCODE format, and will split the transcript ' +
                'name at the first `|` character. These reduced names ' +
                'will be used in the output and when looking for these ' +
                'transcripts in a gene to transcript GTF.' +
                " Default: ${params.salmonidx_gencode}",
            cliflag: '--gencode',
            clivalue: (params.salmonidx_gencode ? ' ' : '')
        ],
        'salmonidx_features': [
            clihelp: 'This flag will expect the input reference to be in the ' +
                'tsv file format, and will split the feature name at the first ' +
                '`tab` character. These reduced names will be used in the output ' +
                'and when looking for the sequence of the features. GTF.' +
                " Default: ${params.salmonidx_features}",
            cliflag: '--features',
            clivalue: (params.salmonidx_features ? ' ' : '')
        ],
        'salmonidx_keepDuplicates': [
            clihelp: 'This flag will disable the default indexing behavior of ' +
                'discarding sequence-identical duplicate transcripts. If this ' +
                'flag is passed then duplicate transcripts that appear in the ' +
                'input will be retained and quantified separately.' +
                " Default: ${params.salmonidx_keepDuplicates}",
            cliflag: '--keepDuplicates',
            clivalue: (params.salmonidx_keepDuplicates ? ' ' : '')
        ],
        'salmonidx_keepFixedFasta': [
            clihelp: 'Retain the fixed fasta file (without short ' +
                'transcripts and duplicates, clipped, etc.) generated ' +
                "during indexing. Default: ${params.salmonidx_keepFixedFasta}",
            cliflag: '--keepFixedFasta',
            clivalue: (params.salmonidx_keepFixedFasta ?: '')
        ],
        'salmonidx_filterSize': [
            clihelp: 'The size of the Bloom filter that will be used ' +
                'by TwoPaCo during indexing. The filter will be of ' +
                'size 2^{filterSize}. A value of -1 means that the ' +
                'filter size will be automatically set based on the ' +
                'number of distinct k-mers in the input, as estimated by ' +
                "nthll. Default: ${params.salmonidx_filterSize}",
            cliflag: '--filterSize',
            clivalue: (params.salmonidx_filterSize ?: '')
        ],
        'salmonidx_sparse': [
            clihelp: 'Build the index using a sparse sampling of k-mer ' +
                'positions This will require less memory (especially ' +
                'during quantification), but will take longer to construct' +
                'and can slow down mapping / alignment.' +
                " Default: ${params.salmonidx_sparse}",
            cliflag: '--sparse',
            clivalue: (params.salmonidx_sparse ? ' ' : '')
        ],
        'salmonidx_n': [
            clihelp: 'Do not clip poly-A tails from the ends of target ' +
                "sequences. Default: ${params.salmonidx_n}",
            cliflag: '-n',
            clivalue: (params.salmonidx_n ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}