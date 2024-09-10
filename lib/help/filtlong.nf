// Help text for filtlong within CPIPES.

def filtlongHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'filtlong_run': [
            clihelp: 'Run filtlong read trimming tool. Default: ' +
                (params.filtlong_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'filtlong_keep_perc': [
            clihelp: 'Keep only this percentage of best reads. ' +
                "Default: ${params.filtlong_keep_perc}",
            cliflag: '--keep_percent',
            clivalue: (params.filtlong_keep_perc ?: '')
        ],
        'filtlong_target_bases': [
            clihelp: 'Keep only the best bases up to this many total bases. ' +
                "Default: ${params.filtlong_target_bases}",
            cliflag: '--target_bases',
            clivalue: (params.filtlong_target_bases ?: '')
        ],
        'filtlong_min_length': [
            clihelp: 'Minimum length threshold. ' +
                "Default: ${params.filtlong_min_length}",
            cliflag: '--min_length',
            clivalue: (params.filtlong_min_length ?: '')
        ],
        'filtlong_max_length': [
            clihelp: 'Maximum length threshold. ' +
                "Default: ${params.filtlong_max_length}",
            cliflag: '--max_length',
            clivalue: (params.filtlong_max_length ?: '')
        ],
        'filtlong_min_mean_q': [
            clihelp: 'Minimum mean quality threshold. ' +
                "Default: ${params.filtlong_min_mean_q}",
            cliflag: '--min_mean_q',
            clivalue: (params.filtlong_min_mean_q ?: '')
        ],
        'filtlong_min_window_q': [
            clihelp: 'Minimum window quality threshold. ' +
                "Default: ${params.filtlong_min_window_q}",
            cliflag: '--min_window_q',
            clivalue: (params.filtlong_min_window_q ?: '')
        ],
        'filtlong_a': [
            clihelp: "External reference assembly in FASTA format. " +
                "Default: ${params.filtlong_a}",
            cliflag: '-a',
            clivalue: (params.filtlong_a ?: '')
        ],
        'filtlong_1': [
            clihelp: 'External reference Illumina reads in FASTQ format (R1). ' +
                "Default: ${params.filtlong_1}",
            cliflag: '-1',
            clivalue: (params.filtlong_1 ?: '')
        ],
        'filtlong_2': [
            clihelp: 'External reference Illumina reads in FASTQ format (R2). ' +
                "Default: ${params.filtlong_2}",
            cliflag: '--2',
            clivalue: (params.filtlong_2 ?: '')
        ],
        'filtlong_len_weight': [
            clihelp: 'Weight given to the length score. ' +
                "Default: ${params.filtlong_len_weight}",
            cliflag: '--length_weight',
            clivalue: (params.filtlong_len_weight ?: '')
        ],
        'filtlong_mean_q_weight': [
            clihelp: 'Weight given to the mean quality score. ' +
                "Default: ${params.filtlong_mean_q_weight}",
            cliflag: '--mean_q_weight',
            clivalue: (params.filtlong_mean_q_weight ?: '')
        ],
        'filtlong_window_q_weight': [
            clihelp: 'Weight given to the window quality score. ' +
                "Default: ${params.filtlong_window_q_weight}",
            cliflag: '--window_q_weight',
            clivalue: (params.filtlong_window_q_weight ?: '')
        ],
        'filtlong_trim': [
            clihelp: 'Trim non k-mer matching bases from start/end of the reads. ' +
                "Default: ${params.filtlong_trim}",
            cliflag: '--trim',
            clivalue: (params.filtlong_trim ? ' ' : '')
        ],
        'filtlong_split': [
            clihelp: 'Split reads at this many (or more) consecutive non k-mer matching bases. ' +
                "Default: ${params.filtlong_split}",
            cliflag: '--split',
            clivalue: (params.filtlong_split ? ' ' : '')
        ],
        'filtlong_window_size': [
            clihelp: 'Size of sliding window used when measuring window quality. ' +
                "Default: ${params.filtlong_window_size}",
            cliflag: '--window_size',
            clivalue: (params.filtlong_window_size ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}