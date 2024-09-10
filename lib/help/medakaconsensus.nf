// Help text for medaka `consensus` within CPIPES.

def medakaconsensusHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'medakaconsensus_run': [
            clihelp: 'Run medaka `consensus` tool. Default: ' +
                (params.medakaconsensus_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'medakaconsensus_batch_size': [
            clihelp: 'Inference batch size. ' +
                "Default: ${params.medakaconsensus_batch_size}",
            cliflag: '--batch_size',
            clivalue: (params.medakaconsensus_batch_size ?: '')
        ], 
        'medakaconsensus_chunk_len': [
            clihelp: 'Chunk length of samples. ' +
                "Default: ${params.medakaconsensus_chunk_len}",
            cliflag: '--chunk_len',
            clivalue: (params.medakaconsensus_chunk_len ?: '')
        ],
        'medakaconsensus_chunk_ovlp': [
            clihelp: 'Overlap of chunks. ' +
                "Default: ${params.medakaconsensus_chunk_ovlp}",
            cliflag: '--chunk_ovlp',
            clivalue: (params.medakaconsensus_chunk_ovlp ?: '')
        ],
        'medakaconsensus_regions': [
            clihelp: 'Genomic regions to analyze, or a bed file. ' +
                "Default: ${params.medakaconsensus_regions}",
            cliflag: '--regions',
            clivalue: (params.medakaconsensus_regions ?: '')
        ],
        'medakaconsensus_model': [
            clihelp: 'Model to use. Can be a medaka model name or a basecaller model name ' +
                "suffixed with ':consensus' or ':variant'. " +
                "Ex: 'dna_r10.4.1_e8.2_400bps_hac@v4.1.0:variant'. " +
                "Default: ${params.medakaconsensus_model}",
            cliflag: '--model',
            clivalue: (params.medakaconsensus_model ?: '')
        ],
        'medakaconsensus_auto_model': [
            clihelp: 'Automatically choose model according to input. Use one of ' +
                "'consensus' or 'variant'. Default: ${params.medakaconsensus_auto_model}",
            cliflag: '--auto_model',
            clivalue: (params.medakaconsensus_auto_model ?: '')
        ],
        'medakaconsensus_bam_chunk': [
            clihelp: 'Size of reference chunks each worker parses from bam. ' +
                "Default: ${params.medakaconsensus_bam_chunk}",
            cliflag: '--bam_chunk',
            clivalue: (params.medakaconsensus_bam_chunk ?: '')
        ],
        'medakaconsensus_chk_out': [
            clihelp: 'Verify integrity of output file after inference. ' +
                "Default: ${params.medakaconsensus_chk_out}",
            cliflag: '--check_output',
            clivalue: (params.medakaconsensus_chk_out ? ' ' : '')
        ],
        'medakaconsensus_save_feats': [
            clihelp: 'Save features with consensus probabilities. ' +
                "Default: ${params.medakaconsensus_save_feats}",
            cliflag: '--save_features',
            clivalue: (params.medakaconsensus_save_feats ? ' ' : '')
        ],
        'medakaconsensus_read_grp': [
            clihelp: "Read group to select. Default: ${params.medakaconsensus_read_grp}",
            cliflag: '--RG',
            clivalue: (params.medakaconsensus_read_grp ?: '')
        ],
        'medakaconsensus_tag_name': [
            clihelp: "Two-letter tag name. Default: ${params.medakaconsensus_tag_name}",
            cliflag: '--tag_name',
            clivalue: (params.medakaconsensus_tag_name ?: '')
        ],
        'medakaconsensus_tag_val': [
            clihelp: "Value of tag. Default: ${params.medakaconsensus_tag_val}",
            cliflag: '--tag_val',
            clivalue: (params.medakaconsensus_tag_val ?: '')
        ],
        'medakaconsensus_tag_keep': [
            clihelp: 'Keep alignments when tag is missing. '
            + "Default: ${params.medakaconsensus_tag_keep}",
            cliflag: '--tag_keep_missing',
            clivalue: (params.medakaconsensus_tag_keep ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}