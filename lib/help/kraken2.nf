// Help text for kraken2 within CPIPES.

def kraken2Help(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'kraken2_db': [
            clihelp: "Absolute path to kraken database. Default: ${params.kraken2_db}",
            cliflag: '--db',
            clivalue: null
        ],
        'kraken2_confidence': [
            clihelp: 'Confidence score threshold which must be ' +
                "between 0 and 1. Default: ${params.kraken2_confidence}",
            cliflag: '--confidence',
            clivalue: (params.kraken2_confidence ?: '')
        ],
        'kraken2_quick': [
            clihelp: "Quick operation (use first hit or hits). Default: ${params.kraken2_quick}",
            cliflag: '--quick',
            clivalue: (params.kraken2_quick ? ' ' : '')
        ],
        'kraken2_use_mpa_style': [
            clihelp: "Report output like Kraken 1's " +
                "kraken-mpa-report. Default: ${params.kraken2_use_mpa_style}",
            cliflag: '--use-mpa-style',
            clivalue: (params.kraken2_use_mpa_style ? ' ' : '')
        ],
        'kraken2_minimum_base_quality': [
            clihelp: 'Minimum base quality used in classification ' +
                " which is only effective with FASTQ input. Default: ${params.kraken2_minimum_base_quality}",
            cliflag: '--minimum-base-quality',
            clivalue: (params.kraken2_minimum_base_quality ?: '')
        ],
        'kraken2_report_zero_counts': [
            clihelp: 'Report counts for ALL taxa, even if counts are zero. ' +
                "Default: ${params.kraken2_report_zero_counts}",
            cliflag: '--report-zero-counts',
            clivalue: (params.kraken2_report_zero_counts ? ' ' : '')
        ],
        'kraken2_report_minmizer_data': [
            clihelp: 'Report minimizer and distinct minimizer count' +
                ' information in addition to normal Kraken report. ' +
                "Default: ${params.kraken2_report_minimizer_data}",
            cliflag: '--report-minimizer-data',
            clivalue: (params.kraken2_report_minimizer_data ? ' ' : '')
        ],
        'kraken2_use_names': [
            clihelp: 'Print scientific names instead of just taxids. ' +
                "Default: ${params.kraken2_use_names}",
            cliflag: '--use-names',
            clivalue: (params.kraken2_use_names ? ' ' : '')
        ],
        'kraken2_extract_bug': [
            clihelp: 'Extract the reads or contigs beloging to this bug. ' +
                "Default: ${params.kraken2_extract_bug}",
            cliflag: null,
            clivalue: null
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}