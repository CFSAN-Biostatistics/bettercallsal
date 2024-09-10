// Help text for NanoPlot within CPIPES.

def nanoplotHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'nanoplot_run': [
            clihelp: 'Run NanoPlot tool on ONT reads. Default: ' +
                (params.nanoplot_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'nanoplot_store': [
            clihelp: 'Store the extracted data in a pickle file for future plotting. ' +
                "Default: ${params.nanoplot_store}",
            cliflag: '--store',
            clivalue: (params.nanoplot_store ? ' ' : '')
        ],
        'nanoplot_raw': [
            clihelp: 'Store the extracted data in tab separated file. ' +
                "Default: ${params.nanoplot_raw}",
            cliflag: '--raw',
            clivalue: (params.nanoplot_raw ? ' ' : '')
        ],
        'nanoplot_huge': [
            clihelp: 'Input data is one very large file. ' +
                "Default: ${params.nanoplot_huge}",
            cliflag: '--huge',
            clivalue: (params.nanoplot_huge ? ' ' : '')
        ],
        'nanoplot_no_static': [
            clihelp: 'Do not make static (png) plots. ' +
                "Default: ${params.nanoplot_no_static}",
            cliflag: '--no_static',
            clivalue: (params.nanoplot_no_static ? ' ' : '')
        ],
        'nanoplot_tsv_stats': [
            clihelp: 'Output the stats file as a properly formatted TSV. ' +
                "Default: ${params.nanoplot_tsv_stats}",
            cliflag: '--tsv_stats',
            clivalue: (params.nanoplot_tsv_stats ? ' ' : '')
        ],
        'nanoplot_only_report': [
            clihelp: 'Output only the report. ' +
                "Default: ${params.nanoplot_only_report}",
            cliflag: '--only-report',
            clivalue: (params.nanoplot_only_report ? ' ' : '')
        ],
        'nanoplot_minlength': [
            clihelp: "Hide reads shorter than length specified. " +
                "Default: ${params.nanoplot_minlength}",
            cliflag: '--minlength',
            clivalue: (params.nanoplot_minlength ?: '')
        ],
        'nanoplot_maxlength': [
            clihelp: 'Hide reads longer than length specified. ' +
                "Default: ${params.nanoplot_maxlength}",
            cliflag: '--maxlength',
            clivalue: (params.nanoplot_maxlength ?: '')
        ],
        'nanoplot_downsample': [
            clihelp: 'Reduce dataset to N reads by random sampling. ' +
                "Default: ${params.nanoplot_downsample}",
            cliflag: '--downsample',
            clivalue: (params.nanoplot_downsample ?: '')
        ],
        'nanoplot_drop_outliers': [
            clihelp: 'Drop outlier reads with extreme long length. ' +
                "Default: ${params.nanoplot_drop_outliers}",
            cliflag: '--drop_outliers',
            clivalue: (params.nanoplot_drop_outliers ? ' ' : '')
        ],
        'nanoplot_loglength': [
            clihelp: 'Additionally show logarithmic scaling of lengths in plots. ' +
                "Default: ${params.nanoplot_loglength}",
            cliflag: '--loglength',
            clivalue: (params.nanoplot_loglength ?: '')
        ],
        'nanoplot_perc_qual': [
            clihelp: 'Weight given to the window quality score. ' +
                "Default: ${params.nanoplot_perc_qual}",
            cliflag: '--percentqual',
            clivalue: (params.nanoplot_perc_qual ? ' ' : '')
        ],
        'nanoplot_alength': [
            clihelp: 'Use aligned read lengths rather than sequenced length (bam mode). ' +
                "Default: ${params.nanoplot_alength}",
            cliflag: '--alength',
            clivalue: (params.nanoplot_alength ? ' ' : '')
        ],
        'nanoplot_minqual': [
            clihelp: 'Drop reads with an average quality lower than specified. ' +
                "Default: ${params.nanoplot_minqual}",
            cliflag: '--minqual',
            clivalue: (params.nanoplot_minqual ?: '')
        ],
        'nanoplot_runtime_until': [
            clihelp: 'Only tke the N first hours of a run. ' +
                "Default: ${params.nanoplot_runtime_until}",
            cliflag: '--runtime_until',
            clivalue: (params.nanoplot_runtime_until ?: '')
        ],
        'nanoplot_readtype': [
            clihelp: 'Which read type to extract information about from summary. ' +
                'Options are 1D, 2D, 1D2. ' +
                "Default: ${params.nanoplot_readtype}",
            cliflag: '--readtype',
            clivalue: (params.nanoplot_readtype ?: '')
        ],
        'nanoplot_barcoded': [
            clihelp: 'Split the summary file by barcode. ' +
                "Default: ${params.nanoplot_barcoded}",
            cliflag: '--barcoded',
            clivalue: (params.nanoplot_barcoded ? ' ' : '')
        ],
        'nanoplot_no_supp': [
            clihelp: 'Remove supplementary alignments. ' +
                "Default: ${params.nanoplot_no_supp}",
            cliflag: '--no_supplementary',
            clivalue: (params.nanoplot_no_supp ? ' ' : '')
        ],
        'nanoplot_c': [
            clihelp: 'Specify a valid matplotlib color for the plots. ' +
                "Default: ${params.nanoplot_c}",
            cliflag: '-c',
            clivalue: (params.nanoplot_c ?: '')
        ],
        'nanoplot_cm': [
            clihelp: 'Specify a valid matplotlib colormap for the heatmap. ' +
                "Default: ${params.nanoplot_cm}",
            cliflag: '-cm',
            clivalue: (params.nanoplot_cm ?: '')
        ],
        'nanoplot_format': [
            clihelp: 'Specify the output format of the plots, which are in addition to the html files. ' +
                "Default: ${params.nanoplot_format}",
            cliflag: '-f',
            clivalue: (params.nanoplot_format ?: '')
        ],
        'nanoplot_plots': [
            clihelp: 'Specify which bivariate plots have to be made [ kde, hex, dot ]. ' +
                "Default: ${params.nanoplot_plots}",
            cliflag: '--plots',
            clivalue: (params.nanoplot_plots ?: '')
        ],
        'nanoplot_noN50': [
            clihelp: 'Hide the N50 mark in the read length histogram. ' +
                "Default: ${params.nanoplot_noN50}",
            cliflag: '--no-N50',
            clivalue: (params.nanoplot_noN50 ?: '')
        ],
        'nanoplot_N50': [
            clihelp: 'Show the N50 mark in the read length histogram. ' +
                "Default: ${params.nanoplot_N50}",
            cliflag: '--N50',
            clivalue: (params.nanoplot_N50 ?: '')
        ],
        'nanoplot_dpi': [
            clihelp: 'Set the DPI for saving images. ' +
                "Default: ${params.nanoplot_dpi}",
            cliflag: '--dpi',
            clivalue: (params.nanoplot_dpi ?: '')
        ],
        'nanoplot_hide_stats': [
            clihelp: 'Do not add Pearson R stats in some bivariate plots. ' +
                "Default: ${params.nanoplot_hide_stats}",
            cliflag: '--hide_stats',
            clivalue: (params.nanoplot_hide_stats ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}