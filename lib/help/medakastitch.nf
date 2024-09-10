// Help text for medaka `stitch` within CPIPES.

def medakastitchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'medakastitch_min_depth': [
            clihelp: 'Sites with depth lower than this will not be polished. ' +
                "Default: ${params.medakastitch_min_depth}",
            cliflag: '--min_depth',
            clivalue: (params.medakastitch_min_depth ?: '')
        ], 
        'medakastitch_no_fillgaps': [
            clihelp: "Don't fill gaps in consensus sequence with draft sequence. " +
                "Default: ${params.medakastitch_no_fillgaps}",
            cliflag: '--no-fillgaps',
            clivalue: (params.medakastitch_no_fillgaps ? ' ' : '')
        ],
        'medakastitch_fill_char': [
            clihelp: 'Use a designated character to fill gaps. ' +
                "Default: ${params.medakastitch_fill_char}",
            cliflag: '--fill_char',
            clivalue: (params.medakastitch_fill_char ?: '')
        ],
        'medakastitch_regions': [
            clihelp: 'Genomic regions to analyze, or a bed file. ' +
                "Default: ${params.medakastitch_regions}",
            cliflag: '--regions',
            clivalue: (params.medakastitch_regions ?: '')
        ],
        'medakastitch_quals': [
            clihelp: 'Output with per-base quality scores (fastq). ' +
                "Default: ${params.medakastitch_quals}",
            cliflag: '--qualities',
            clivalue: (params.medakastitch_quals ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}