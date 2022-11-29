// Help text for centrifuge within CPIPES.

def centrifugeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'centrifuge_x': [
            clihelp: "Absolute path to centrifuge database. Default: ${params.centrifuge_x}",
            cliflag: '-x',
            clivalue: null
        ],
        'centrifuge_save_unaligned': [
            clihelp: 'Save SINGLE-END reads that did not align. For PAIRED-END' +
                " reads, save read pairs that did not align concordantly. Default: ${params.centrifuge_save_unaligned}",
            cliflag: null, // Handled in modules logic.
            clivalue: null
        ],
        'centrifuge_save_aligned': [
            clihelp: 'Save SINGLE-END reads that aligned. For PAIRED-END' +
                " reads, save read pairs that aligned concordantly. Default: ${params.centrifuge_save_aligned}",
            cliflag: null, // Handled in modules logic.
            clivalue: null
        ],
        'centrifuge_out_fmt_sam': [
            clihelp: "Centrifuge output should be in SAM. Default: ${params.centrifuge_save_aligned}",
            cliflag: null, // Handled in modules logic.
            clivalue: null
        ],
        'centrifuge_extract_bug': [
            clihelp: "Extract this bug from centrifuge results." +
                " Default: ${params.centrifuge_extract_bug}",
            cliflag: null, // Handled in modules logic.
            clivalue: null,
        ],
        'centrifuge_ignore_quals': [
            clihelp: 'Treat all quality values as 30 on Phred scale. ' +
                "Default: ${params.centrifuge_ignore_quals}",
            cliflag: '--ignore-quals',
            clivalue: (params.centrifuge_ignore_quals ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}

