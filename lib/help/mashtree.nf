// Help text for mashtree within CPIPES.

def mashtreeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'mashtree_run': [
            clihelp: 'Run mashtree tool. Default: ' +
                (params.mashtree_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'mashtree_fofn': [
            clihelp: 'Input is a file of file names. ' +
                "Default: ${params.mashtree_fofn}",
            cliflag: '--file-of-files',
            clivalue: (params.mashtree_fofn ? ' ' : '')
        ],
        'mashtree_trunclength': [
            clihelp: 'How many characters to keep in filename. ' +
                "Default: ${params.mashtree_trunclength}",
            cliflag: '--truncLength',
            clivalue: (params.mashtree_trunclength ?: '')
        ],
        'mashtree_mindepth': [
            clihelp: 'If mindepth is zero, then it will be chosen in a smart but slower method, ' +
                'to discard lower-abundance kmers. ' +
                "Default: ${params.mashtree_mindepth}",
            cliflag: '--mindepth',
            clivalue: (params.mashtree_mindepth ?: '')
        ],
        'mashtree_kmerlength': [
            clihelp: "The minimum k-mer length. " +
                "Default: ${params.mashtree_kmerlength}",
            cliflag: '--kmerlength',
            clivalue: (params.mashtree_kmerlength ?: '')
        ],
        'mashtree_sketchsize': [
            clihelp: "The minimum `mash` sketch size. " +
                "Default: ${params.mashtree_sketchsize}",
            cliflag: '--sketchsize',
            clivalue: (params.mashtree_sketchsize ?: '')
        ],
        'mashtree_seed': [
            clihelp: "Seed for `mash` sketch. " +
                "Default: ${params.mashtree_seed}",
            cliflag: '--seed',
            clivalue: (params.mashtree_seed ? ' ' : '')
        ],
        'mashtree_genomesize': [
            clihelp: 'Define genome size. ' +
                "Default: ${params.mashtree_genomesize}",
            cliflag: '--genomesize',
            clivalue: (params.mashtree_genomesize ?: '')
        ],
        'mashtree_sigfigs': [
            clihelp: "How many decimal places to use in mash distances. " +
                "Default: ${params.mashtree_sigfigs}",
            cliflag: '--sigfigs',
            clivalue: (params.mashtree_sigfigs ?: '')
        ],
        'mashtree_sortorder': [
            clihelp: 'For neighbor-joining, the sort order can make a difference. ' +
                'Options include: ABC (alphabetical), random, input-order. ' +
                "Default: ${params.mashtree_sortorder}",
            cliflag: '--sort-order',
            clivalue: (params.mashtree_sortorder ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}