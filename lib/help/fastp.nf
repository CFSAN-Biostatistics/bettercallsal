// Help text for fastp within CPIPES.

def fastpHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'fastp_run': [
            clihelp: 'Run fastp tool. Default: ' +
                (params.fastp_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'fastp_failed_out': [
            clihelp: 'Specify whether to store reads that cannot pass the filters. ' +
                "Default: ${params.fastp_failed_out}",
            cliflag: null,
            clivalue: null
        ],
        'fastp_merged_out': [
            clihelp: 'Specify whether to store merged output or not. ' +
                "Default: ${params.fastp_merged_out}",
            cliflag: null,
            clivalue: null
        ],
        'fastp_overlapped_out': [
            clihelp: 'For each read pair, output the overlapped region if it has no mismatched base. ' +
                "Default: ${params.fastp_overlapped_out}",
            cliflag: '--overlapped_out',
            clivalue: (params.fastp_overlapped_out ?: '')
        ],
        'fastp_6': [
            clihelp: "Indicate that the input is using phred64 scoring (it'll be converted to phred33, " +
                'so the output will still be phred33). ' +
                "Default: ${params.fastp_6}",
            cliflag: '-6',
            clivalue: (params.fastp_6 ? ' ' : '')
        ],
        'fastp_reads_to_process': [
            clihelp: 'Specify how many reads/pairs are to be processed. Default value 0 means ' +
                'process all reads. ' +
                "Default: ${params.fastp_reads_to_process}",
            cliflag: '--reads_to_process',
            clivalue: (params.fastp_reads_to_process ?: '')
        ],
        'fastp_fix_mgi_id': [
            clihelp: 'The MGI FASTQ ID format is not compatible with many BAM operation tools, ' +
                'enable this option to fix it. ' +
                "Default: ${params.fastp_fix_mgi_id}",
            cliflag: '--fix_mgi_id',
            clivalue: (params.fastp_fix_mgi_id ? ' ' : '')
        ],
        'fastp_A': [
            clihelp: 'Disable adapter trimming. On by default. ' +
                "Default: ${params.fastp_A}",
            cliflag: '-A',
            clivalue: (params.fastp_A ? ' ' : '')
        ],
        'fastp_adapter_fasta': [
            clihelp: 'Specify a FASTA file to trim both read1 and read2 (if PE) by all the sequences ' +
                'in this FASTA file. ' +
                "Default: ${params.fastp_adapter_fasta}",
            cliflag: '--adapter_fasta',
            clivalue: (params.fastp_adapter_fasta ?: '')
        ],
        'fastp_f': [
            clihelp: 'Trim how many bases in front of read1. ' +
                "Default: ${params.fastp_f}",
            cliflag: '-f',
            clivalue: (params.fastp_f ?: '')
        ],
        'fastp_t': [
            clihelp: 'Trim how many bases at the end of read1. ' +
                "Default: ${params.fastp_t}",
            cliflag: '-t',
            clivalue: (params.fastp_t ?: '')
        ],
        'fastp_b': [
            clihelp: 'Max length of read1 after trimming. ' +
                "Default: ${params.fastp_b}",
            cliflag: '-b',
            clivalue: (params.fastp_b ?: '')
        ],
        'fastp_F': [
            clihelp: 'Trim how many bases in front of read2. ' +
                "Default: ${params.fastp_F}",
            cliflag: '-F',
            clivalue: (params.fastp_F ?: '')
        ],
        'fastp_T': [
            clihelp: 'Trim how many bases at the end of read2. ' +
                "Default: ${params.fastp_T}",
            cliflag: '-T',
            clivalue: (params.fastp_T ?: '')
        ],
        'fastp_B': [
            clihelp: 'Max length of read2 after trimming. ' +
                "Default: ${params.fastp_B}",
            cliflag: '-B',
            clivalue: (params.fastp_B ?: '')
        ],
        'fastp_dedup': [
            clihelp: 'Enable deduplication to drop the duplicated reads/pairs. ' +
                "Default: ${params.fastp_dedup}",
            cliflag: '--dedup',
            clivalue: (params.fastp_dedup ? ' ' : '')
        ],
        'fastp_dup_calc_accuracy': [
            clihelp: 'Accuracy level to calculate duplication (1~6), higher level uses more memory ' +
                '(1G, 2G, 4G, 8G, 16G, 24G). Default 1 for no-dedup mode, and 3 for dedup mode. ' +
                "Default: ${params.fastp_dup_calc_accuracy}",
            cliflag: '--dup_calc_accuracy',
            clivalue: (params.fastp_dup_calc_accuracy ?: '')
        ],
        'fastp_poly_g_min_len': [
            clihelp: 'The minimum length to detect polyG in the read tail. ' +
                "Default: ${params.fastp_poly_g_min_len}",
            cliflag: '--poly_g_min_len',
            clivalue: (params.fastp_poly_g_min_len ?: '')
        ],
        'fastp_G': [
            clihelp: 'Disable polyG tail trimming. ' +
                "Default: ${params.fastp_G}",
            cliflag: '-G',
            clivalue: (params.fastp_G ? ' ' : '')
        ],
        'fastp_x': [
            clihelp: "Enable polyX trimming in 3' ends. " +
                "Default: ${params.fastp_x}",
            cliflag: 'x=',
            clivalue: (params.fastp_x ? ' ' : '')
        ],
        'fastp_poly_x_min_len': [
            clihelp: 'The minimum length to detect polyX in the read tail. ' +
                "Default: ${params.fastp_poly_x_min_len}",
            cliflag: '--poly_x_min_len',
            clivalue: (params.fastp_poly_x_min_len ?: '')
        ],
        'fastp_cut_front': [
            clihelp: "Move a sliding window from front (5') to tail, drop the bases in the window " +
                'if its mean quality < threshold, stop otherwise. ' +
                "Default: ${params.fastp_cut_front}",
            cliflag: '--cut_front',
            clivalue: (params.fastp_cut_front ? ' ' : '')
        ],
        'fastp_cut_tail': [
            clihelp: "Move a sliding window from tail (3') to front, drop the bases in the window " +
                'if its mean quality < threshold, stop otherwise. ' +
                "Default: ${params.fastp_cut_tail}",
            cliflag: '--cut_tail',
            clivalue: (params.fastp_cut_tail ? ' ' : '')
        ],
        'fastp_cut_right': [
            clihelp: "Move a sliding window from tail, drop the bases in the window and the right part " +
                'if its mean quality < threshold, and then stop. ' +
                "Default: ${params.fastp_cut_right}",
            cliflag: '--cut_right',
            clivalue: (params.fastp_cut_right ? ' ' : '')
        ],
        'fastp_W': [
            clihelp: "Sliding window size shared by --fastp_cut_front, --fastp_cut_tail and " +
                '--fastp_cut_right. ' +
                "Default: ${params.fastp_W}",
            cliflag: '--cut_window_size',
            clivalue: (params.fastp_W ?: '')
        ],
        'fastp_M': [
            clihelp: "The mean quality requirement shared by --fastp_cut_front, --fastp_cut_tail and " +
                '--fastp_cut_right. ' +
                "Default: ${params.fastp_M}",
            cliflag: '--cut_mean_quality',
            clivalue: (params.fastp_M ?: '')
        ],
        'fastp_q': [
            clihelp: 'The quality value below which a base should is not qualified. ' +
                "Default: ${params.fastp_q}",
            cliflag: '-q',
            clivalue: (params.fastp_q ?: '')
        ],
        'fastp_u': [
            clihelp: 'What percent of bases are allowed to be unqualified. ' +
                "Default: ${params.fastp_u}",
            cliflag: '-u',
            clivalue: (params.fastp_u ?: '')
        ],
        'fastp_n': [
            clihelp: "How many N's can a read have. " +
                "Default: ${params.fastp_n}",
            cliflag: '-n',
            clivalue: (params.fastp_n ?: '')
        ],
        'fastp_e': [
            clihelp: "If the full reads' average quality is below this value, then it is discarded. " +
                "Default: ${params.fastp_e}",
            cliflag: '-e',
            clivalue: (params.fastp_e ?: '')
        ],
        'fastp_l': [
            clihelp: 'Reads shorter than this length will be discarded. ' +
                "Default: ${params.fastp_l}",
            cliflag: '-l',
            clivalue: (params.fastp_l ?: '')
        ],
        'fastp_max_len': [
            clihelp: 'Reads longer than this length will be discarded. ' +
                "Default: ${params.fastp_max_len}",
            cliflag: '--length_limit',
            clivalue: (params.fastp_max_len ?: '')
        ],
        'fastp_y': [
            clihelp: 'Enable low complexity filter. The complexity is defined as the percentage ' +
                'of bases that are different from its next base (base[i] != base[i+1]). ' +
                "Default: ${params.fastp_y}",
            cliflag: '-y',
            clivalue: (params.fastp_y ? ' ' : '')
        ],
        'fastp_Y': [
            clihelp: 'The threshold for low complexity filter (0~100). Ex: A value of 30 means ' +
                '30% complexity is required. ' +
                "Default: ${params.fastp_Y}",
            cliflag: '-Y',
            clivalue: (params.fastp_Y ?: '')
        ],
        'fastp_U': [
            clihelp: 'Enable Unique Molecular Identifier (UMI) pre-processing. ' +
                "Default: ${params.fastp_U}",
            cliflag: '-U',
            clivalue: (params.fastp_U ? ' ' : '')
        ],
        'fastp_umi_loc': [
            clihelp: 'Specify the location of UMI, can be one of ' + 
                'index1/index2/read1/read2/per_index/per_read. ' +
                "Default: ${params.fastp_umi_loc}",
            cliflag: '--umi_loc',
            clivalue: (params.fastp_umi_loc ?: '')
        ],
        'fastp_umi_len': [
            clihelp: 'If the UMI is in read1 or read2, its length should be provided. ' + 
                "Default: ${params.fastp_umi_len}",
            cliflag: '--umi_len',
            clivalue: (params.fastp_umi_len ?: '')
        ],
        'fastp_umi_prefix': [
            clihelp: 'If specified, an underline will be used to connect prefix and UMI ' +
                '(i.e. prefix=UMI, UMI=AATTCG, final=UMI_AATTCG). ' + 
                "Default: ${params.fastp_umi_prefix}",
            cliflag: '--umi_prefix',
            clivalue: (params.fastp_umi_prefix ?: '')
        ],
        'fastp_umi_skip': [
            clihelp: 'If the UMI is in read1 or read2, fastp can skip several bases following the UMI. ' +
                "Default: ${params.fastp_umi_skip}",
            cliflag: '--umi_skip',
            clivalue: (params.fastp_umi_skip ?: '')
        ],
        'fastp_p': [
            clihelp: 'Enable overrepresented sequence analysis. ' +
                "Default: ${params.fastp_p}",
            cliflag: '-p',
            clivalue: (params.fastp_p ? ' ' : '')
        ],
        'fastp_P': [
            clihelp: 'One in this many number of reads will be computed for overrepresentation analysis ' +
                '(1~10000), smaller is slower. ' +
                "Default: ${params.fastp_P}",
            cliflag: '-P',
            clivalue: (params.fastp_P ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}