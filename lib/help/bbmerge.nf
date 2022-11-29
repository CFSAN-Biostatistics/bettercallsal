// Help text for bbmerge within CPIPES.

def bbmergeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'bbmerge_run': [
            clihelp: 'Run BBMerge tool. Default: ' +
                (params.bbmerge_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'bbmerge_reads': [
            clihelp: 'Quit after this many read pairs (-1 means all) ' +
                "Default: ${params.bbmerge_reads}",
            cliflag: 'reads=',
            clivalue: (params.bbmerge_reads ?: '')
        ],
        'bbmerge_adapters': [
            clihelp: 'Absolute UNIX path pointing to the adapters file in ' +
                "FASTA format. Default: ${params.bbmerge_adapters}",
            cliflag: 'adapters=',
            clivalue: (params.bbmerge_adapters ?: '')
        ],
        'bbmerge_ziplevel': [
            clihelp: 'Set to 1 (lowest) through 9 (max) to change compression ' +
                "level; lower compression is faster. Default: ${params.bbmerge_ziplevel}",
            cliflag: 'ziplevel=',
            clivalue: (params.bbmerge_ziplevel ?: '')
        ],
        'bbmerge_ordered': [
            clihelp: 'Output reads in the same order as input. ' +
                "Default: ${params.bbmerge_ordered}",
            cliflag: 'ordered=',
            clivalue: (params.bbmerge_ordered ?: '')
        ],
        'bbmerge_qtrim': [
            clihelp: 'Trim read ends to remove bases with quality below --bbmerge_minq. ' +
                'Trims BEFORE merging. Values: t (trim both ends), ' + 
                'f (neither end), r (right end only), l (left end only). ' +
                "Default: ${params.bbmerge_qtrim}",
            cliflag: 'qtrim=',
            clivalue: (params.bbmerge_qtrim ?: '')
        ],
        'bbmerge_qtrim2': [
            clihelp: 'May be specified instead of --bbmerge_qtrim to perform trimming ' +
                'only if merging is unsuccesful. then retry merging. ' +
                "Default: ${params.bbmerge_qtrim2}",
            cliflag: 'qtrim2=',
            clivalue: (params.bbmerge_qtrim2 ?: '')
        ],
        'bbmerge_trimq': [
            clihelp: 'Trim quality threshold. This may be comma-delimited list (ascending) ' +
                "to try multiple values. Default: ${params.bbmerge_trimq}",
            cliflag: 'trimq=',
            clivalue: (params.bbmerge_trimq ?: '')
        ],
        'bbmerge_minlength': [
            clihelp: '(ml) Reads shorter than this after trimming, but before ' +
                'merging, will be discarded. Pairs will be discarded only' +
                "if both are shorter. Default: ${params.bbmerge_minlength}",
            cliflag: 'minlength=',
            clivalue: (params.bbmerge_minlength ?: '')
        ],
        'bbmerge_tbo': [
            clihelp: '(trimbyoverlap). Trim overlapping reads to remove right ' +
                "most (3') non-overlaping portion instead of joining " +
                "Default: ${params.bbmerge_tbo}",
            cliflag: 'tbo=',
            clivalue: (params.bbmerge_tbo ?: '')
        ],
        'bbmerge_minavgquality': [
            clihelp: '(maq). Reads with average quality below this after trimming will ' +
                "not be attempted to merge. Default: ${params.bbmerge_minavgquality}",
            cliflag: 'minavgquality=',
            clivalue: (params.bbmerge_minavgquality ?: '')
        ],
        'bbmerge_trimpolya': [
            clihelp: 'Trim trailing poly-A tail from adapter output. Only affects ' +
                'outadapter.  This also trims poly-A followed by poly-G, which ' +
                "occurs on NextSeq. Default: ${params.bbmerge_trimpolya}",
            cliflag: 'trimpolya=',
            clivalue: (params.bbmerge_trimpolya ?: '')
        ],
        'bbmerge_pfilter': [
            clihelp: 'Ban improbable overlaps. Higher is more strict. 0 will ' +
                'disable the filter; 1 will allow only perfect overlaps. ' +
                "Default: ${params.bbmerge_pfilter}",
            cliflag: 'pfilter=',
            clivalue: (params.bbmerge_pfilter ?: '')
        ],
        'bbmerge_ouq': [
            clihelp: 'Calculate best overlap using quality values. ' +
                "Default: ${params.bbmerge_ouq}",
            cliflag: 'ouq',
            clivalue: (params.bbmerge_ouq ?: '')
        ],
        'bbmerge_owq': [
            clihelp: 'Calculate best overlap without using quality values. ' +
                "Default: ${params.bbmerge_owq}",
            cliflag: 'owq=',
            clivalue: (params.bbmerge_owq ?: '')
        ],
        'bbmerge_strict': [
            clihelp: 'Decrease false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_strict}",
            cliflag: 'strict=',
            clivalue: (params.bbmerge_strict ?: '')
        ],
        'bbmerge_verystrict': [
            clihelp: 'Greatly decrease false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_verystrict}",
            cliflag: 'verystrict=',
            clivalue: (params.bbmerge_verystrict ?: '')
        ],
        'bbmerge_ultrastrict': [
            clihelp: 'Decrease false positive rate and merging rate even more. ' +
                "Default: ${params.bbmerge_ultrastrict}",
            cliflag: 'ultrastrict=',
            clivalue: (params.bbmerge_ultrastrict ?: '')
        ],
        'bbmerge_maxstrict': [
            clihelp: 'Maxiamally decrease false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_maxstrict}",
            cliflag: 'maxstrict=',
            clivalue: (params.bbmerge_maxstrict ?: '')
        ],
        'bbmerge_loose': [
            clihelp: 'Increase false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_loose}",
            cliflag: 'loose=',
            clivalue: (params.bbmerge_loose ?: '')
        ],
        'bbmerge_veryloose': [
            clihelp: 'Greatly increase false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_veryloose}",
            cliflag: 'veryloose=',
            clivalue: (params.bbmerge_veryloose ?: '')
        ],
        'bbmerge_ultraloose': [
            clihelp: 'Increase false positive rate and merging rate even more. ' +
                "Default: ${params.bbmerge_ultraloose}",
            cliflag: 'ultraloose=',
            clivalue: (params.bbmerge_ultraloose ?: '')
        ],
        'bbmerge_maxloose': [
            clihelp: 'Maximally increase false positive rate and merging rate. ' +
                "Default: ${params.bbmerge_maxloose}",
            cliflag: 'maxloose=',
            clivalue: (params.bbmerge_maxloose ?: '')
        ],
        'bbmerge_fast': [
            clihelp: 'Fastest possible preset. ' +
                "Default: ${params.bbmerge_fast}",
            cliflag: 'fast=',
            clivalue: (params.bbmerge_fast ?: '')
        ],
        'bbmerge_k': [
            clihelp: 'Kmer length.  31 (or less) is fastest and uses the least ' +
                'memory, but higher values may be more accurate. ' +
                '60 tends to work well for 150bp reads. ' +
                "Default: ${params.bbmerge_k}",
            cliflag: 'k=',
            clivalue: (params.bbmerge_k ?: '')
        ],
        'bbmerge_prealloc': [
            clihelp: 'Pre-allocate memory rather than dynamically growing. ' +
                'Faster and more memory-efficient for large datasets. ' +
                'A float fraction (0-1) may be specified, default 1. ' +
                "Default: ${params.bbmerge_prealloc}",
            cliflag: 'prealloc=',
            clivalue: (params.bbmerge_prealloc ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}