// Help text for megahit within CPIPES.

def megahitHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'megahit_run': [
            clihelp: 'Run MEGAHIT assembler. Default: ' +
                (params.megahit_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'megahit_min_count': [
            clihelp: '<int>. Minimum multiplicity for filtering (k_min+1)-mers. ' +
                "Default: ${params.megahit_min_count}",
            cliflag: '--min-count',
            clivalue: (params.megahit_min_count ?: '')
        ], 
        'megahit_k_list': [
            clihelp: 'Comma-separated list of kmer size. All values must be odd, in ' + 
                "the range 15-255, increment should be <= 28. Ex: '21,29,39,59,79,99,119,141'. " +
                "Default: ${params.megahit_k_list}",
            cliflag: '--k-list',
            clivalue: (params.megahit_k_list ?: '')
        ],
        'megahit_no_mercy': [
            clihelp: 'Do not add mercy k-mers. ' +
                "Default: ${params.megahit_no_mercy}",
            cliflag: '--no-mercy',
            clivalue: (params.megahit_no_mercy ? ' ' : '')
        ],
        'megahit_bubble_level': [
            clihelp: '<int>. Intensity of bubble merging (0-2), 0 to disable. ' +
                "Default: ${params.megahit_bubble_level}",
            cliflag: '--bubble-level',
            clivalue: (params.megahit_bubble_level ?: '')
        ],
        'megahit_merge_level': [
            clihelp: '<l,s>. Merge complex bubbles of length <= l*kmer_size and ' +
                "similarity >= s. Default: ${params.megahit_merge_level}",
            cliflag: '--merge-level',
            clivalue: (params.megahit_merge_level ?: '')
        ],
        'megahit_prune_level': [
            clihelp: '<int>. Strength of low depth pruning (0-3). ' +
                "Default: ${params.megahit_prune_level}",
            cliflag: '--prune-level',
            clivalue: (params.megahit_prune_level ?: '')
        ],
        'megahit_prune_depth': [
            clihelp: '<int>. Remove unitigs with avg k-mer depth less than this value. ' +
                "Default: ${params.megahit_prune_depth}",
            cliflag: '--prune-depth',
            clivalue: (params.megahit_prune_depth ?: '')
        ],
        'megahit_low_local_ratio': [
            clihelp: '<float>. Ratio threshold to define low local coverage contigs. ' +
                "Default: ${params.megahit_low_local_ratio}",
            cliflag: '--low-local-ratio',
            clivalue: (params.megahit_low_local_ratio ?: '')
        ],
        'megahit_max_tip_len': [
            clihelp: '<int>. remove tips less than this value [<int> * k]. ' +
                "Default: ${params.megahit_max_tip_len}",
            cliflag: '--max-tip-len',
            clivalue: (params.megahit_max_tip_len ?: '')
        ],
        'megahit_no_local': [
            clihelp: 'Disable local assembly. ' +
                "Default: ${params.megahit_no_local}",
            cliflag: '--no-local',
            clivalue: (params.megahit_no_local ? ' ' : '')
        ],
        'megahit_kmin_1pass': [
            clihelp: 'Use 1pass mode to build SdBG of k_min. ' +
                "Default: ${params.megahit_kmin_1pass}",
            cliflag: '--kmin-1pass',
            clivalue: (params.megahit_kmin_1pass ? ' ' : '')
        ],
        'megahit_preset': [
            clihelp: '<str>. Override a group of parameters. Valid values are '+
                "meta-sensitive which enforces '--min-count 1 --k-list 21,29,39,49,...,129,141', " +
                'meta-large (large & complex metagenomes, like soil) which enforces ' +
                "'--k-min 27 --k-max 127 --k-step 10'. " +
                "Default: ${params.megahit_preset}",
            cliflag: '--preset',
            clivalue: (params.megahit_preset ?: '')
        ],
        'megahit_mem_flag': [
            clihelp: '<int>. SdBG builder memory mode. 0: minimum; 1: moderate; 2: use all memory specified. ' +
                "Default: ${params.megahit_mem_flag}",
            cliflag: '--mem-flag',
            clivalue: (params.megahit_mem_flag ?: '')
        ],
        'megahit_min_contig_len': [
            clihelp: '<int>.  Minimum length of contigs to output. ' +
                "Default: ${params.megahit_min_contig_len}",
            cliflag: '--use-gpu',
            clivalue: (params.megahit_min_contig_len ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}