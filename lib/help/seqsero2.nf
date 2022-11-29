def seqsero2Help(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'seqsero2_run': [
            clihelp: "Run SeqSero2 tool. Default: ${params.seqsero2_run}",
            cliflag: null,
            clivalue: null
        ],
        'seqsero2_t': [
            clihelp: "'1' for interleaved paired-end reads, '2' for " +
                "separated paired-end reads, '3' for single reads, '4' for " +
                "genome assembly, '5' for nanopore reads (fasta/fastq). " +
                "Default: ${params.seqsero2_t}",
            cliflag: '-t',
            clivalue: (params.seqsero2_t ?: '')
        ],
        'seqsero2_m': [
            clihelp: "Which workflow to apply, 'a'(raw reads allele " +
                "micro-assembly), 'k'(raw reads and genome assembly k-mer). " +
                "Default: ${params.seqsero2_m}",
            cliflag: '-m',
            clivalue: (params.seqsero2_m ?: '')
        ],
        'seqsero2_c': [
            clihelp: 'SeqSero2 will only output serotype prediction without the directory ' +
                'containing log files. ' +
                "Default: ${params.seqsero2_c}",
            cliflag: '-c',
            clivalue: (params.seqsero2_c ? ' ' : '')
        ],
        'seqsero2_s': [
            clihelp: 'SeqSero2 will not output header in SeqSero_result.tsv. ' +
                "Default: ${params.seqsero2_s}",
            cliflag: '-l',
            clivalue: (params.seqsero2_s ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}