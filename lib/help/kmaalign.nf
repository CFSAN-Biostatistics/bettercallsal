// Help text for kma align within CPIPES.

def kmaalignHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'kmaalign_run': [
            clihelp: 'Run kma tool. Default: ' +
                (params.kmaalign_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'kmaalign_int': [
            clihelp: 'Input file has interleaved reads. ' +
                " Default: ${params.kmaalign_int}",
            cliflag: '-int',
            clivalue: (params.kmaalign_int ? ' ' : '')
        ], 
        'kmaalign_ef': [
            clihelp: 'Output additional features. ' +
                "Default: ${params.kmaalign_ef}",
            cliflag: '-ef',
            clivalue: (params.kmaalign_ef ? ' ' : '')
        ], 
        'kmaalign_vcf': [
            clihelp: 'Output vcf file. 2 to apply FT. ' +
                "Default: ${params.kmaalign_vcf}",
            cliflag: '-vcf',
            clivalue: (params.kmaalign_vcf ? ' ' : '')
        ],
        'kmaalign_sam': [
            clihelp: 'Output SAM, 4/2096 for mapped/aligned. ' +
                "Default: ${params.kmaalign_sam}",
            cliflag: '-sam',
            clivalue: (params.kmaalign_sam ? ' ' : '')
        ],
        'kmaalign_nc': [
            clihelp: 'No consensus file. ' +
                "Default: ${params.kmaalign_nc}",
            cliflag: '-nc',
            clivalue: (params.kmaalign_nc ? ' ' : '')
        ],
        'kmaalign_na': [
            clihelp: 'No aln file. ' +
                "Default: ${params.kmaalign_na}",
            cliflag: '-na',
            clivalue: (params.kmaalign_na ? ' ' : '')
        ],
        'kmaalign_nf': [
            clihelp: 'No frag file. ' +
                "Default: ${params.kmaalign_nf}",
            cliflag: '-nf',
            clivalue: (params.kmaalign_nf ? ' ' : '')
        ],
        'kmaalign_a': [
            clihelp: 'Output all template mappings. ' +
                "Default: ${params.kmaalign_a}",
            cliflag: '-a',
            clivalue: (params.kmaalign_a ? ' ' : '')
        ],
        'kmaalign_and': [
            clihelp: 'Use both -mrs and p-value on consensus. ' +
                "Default: ${params.kmaalign_and}",
            cliflag: '-and',
            clivalue: (params.kmaalign_and ? ' ' : '')
        ],
        'kmaalign_oa': [
            clihelp: 'Use neither -mrs or p-value on consensus. ' +
                "Default: ${params.kmaalign_oa}",
            cliflag: '-oa',
            clivalue: (params.kmaalign_oa ? ' ' : '')
        ],
        'kmaalign_bc': [
            clihelp: 'Minimum support to call bases. ' +
                "Default: ${params.kmaalign_bc}",
            cliflag: '-bc',
            clivalue: (params.kmaalign_bc ?: '')
        ],
        'kmaalign_bcNano': [
            clihelp: 'Altered indel calling for ONT data. ' +
                "Default: ${params.kmaalign_bcNano}",
            cliflag: '-bcNano',
            clivalue: (params.kmaalign_bcNano ? ' ' : '')
        ],
        'kmaalign_bcd': [
            clihelp: 'Minimum depth to call bases. ' +
                "Default: ${params.kmaalign_bcd}",
            cliflag: '-bcd',
            clivalue: (params.kmaalign_bcd ?: '')
        ],
        'kmaalign_bcg': [
            clihelp: 'Maintain insignificant gaps. ' +
                "Default: ${params.kmaalign_bcg}",
            cliflag: '-bcg',
            clivalue: (params.kmaalign_bcg ? ' ' : '')
        ],
        'kmaalign_ID': [
            clihelp: 'Minimum consensus ID. ' +
                "Default: ${params.kmaalign_ID}",
            cliflag: '-ID',
            clivalue: (params.kmaalign_ID ?: '')
        ],
        'kmaalign_md': [
            clihelp: 'Minimum depth. ' +
                "Default: ${params.kmaalign_md}",
            cliflag: '-md',
            clivalue: (params.kmaalign_md ?: '')
        ],
        'kmaalign_dense': [
            clihelp: 'Skip insertion in consensus. ' +
                "Default: ${params.kmaalign_dense}",
            cliflag: '-dense',
            clivalue: (params.kmaalign_dense ? ' ' : '')
        ],
        'kmaalign_ref_fsa': [
            clihelp: 'Use Ns on indels. ' +
                "Default: ${params.kmaalign_ref_fsa}",
            cliflag: '-ref_fsa',
            clivalue: (params.kmaalign_ref_fsa ? ' ' : '')
        ],
        'kmaalign_Mt1': [
            clihelp: 'Map everything to one template. ' +
                "Default: ${params.kmaalign_Mt1}",
            cliflag: '-Mt1',
            clivalue: (params.kmaalign_Mt1 ? ' ' : '')
        ],
        'kmaalign_1t1': [
            clihelp: 'Map one query to one template. ' +
                "Default: ${params.kmaalign_1t1}",
            cliflag: '-1t1',
            clivalue: (params.kmaalign_1t1 ? ' ' : '')
        ],
        'kmaalign_mrs': [
            clihelp: 'Minimum relative alignment score. ' +
                "Default: ${params.kmaalign_mrs}",
            cliflag: '-mrs',
            clivalue: (params.kmaalign_mrs ?: '')
        ],
        'kmaalign_mrc': [
            clihelp: 'Minimum query coverage. ' +
                "Default: ${params.kmaalign_mrc}",
            cliflag: '-mrc',
            clivalue: (params.kmaalign_mrc ?: '')
        ],
        'kmaalign_mq': [
            clihelp: 'Minimum phred score of trailing and leading bases. ' +
                "Default: ${params.kmaalign_mq}",
            cliflag: '-mq',
            clivalue: (params.kmaalign_mq ?: '')
        ],
        'kmaalign_eq': [
            clihelp: 'Minimum average quality score. ' +
                "Default: ${params.kmaalign_eq}",
            cliflag: '-eq',
            clivalue: (params.kmaalign_eq ?: '')
        ],
        'kmaalign_5p': [
            clihelp: 'Trim 5 prime by this many bases. ' +
                "Default: ${params.kmaalign_5p}",
            cliflag: '-5p',
            clivalue: (params.kmaalign_5p ?: '')
        ],
        'kmaalign_3p': [
            clihelp: 'Trim 3 prime by this many bases ' +
                "Default: ${params.kmaalign_3p}",
            cliflag: '-3p',
            clivalue: (params.kmaalign_3p ?: '')
        ],
        'kmaalign_apm': [
            clihelp: 'Sets both -pm and -fpm ' +
                "Default: ${params.kmaalign_apm}",
            cliflag: '-apm',
            clivalue: (params.kmaalign_apm ?: '')
        ],
        'kmaalign_cge': [
            clihelp: 'Set CGE penalties and rewards ' +
                "Default: ${params.kmaalign_cge}",
            cliflag: '-cge',
            clivalue: (params.kmaalign_cge ? ' ' : '')
        ],

    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}