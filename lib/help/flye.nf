// Help text for flye within CPIPES.

def flyeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'flye_pacbio_raw': [
            clihelp: 'Input FASTQ reads are PacBio regular CLR reads (<20% error) ' +
                "Default: ${params.flye_pacbio_raw}",
            cliflag: '--pacbio-raw',
            clivalue: (params.flye_pacbio_raw ? ' ' : '')
        ], 
        'flye_pacbio_corr': [
            clihelp: 'Input FASTQ reads are PacBio reads that were corrected ' +
                "with other methods (<3% error). Default: ${params.flye_pacbio_corr}",
            cliflag: '--pacbio-corr',
            clivalue: (params.flye_pacbio_corr ? ' ' : '')
        ],
        'flye_pacbio_hifi': [
            clihelp: 'Input FASTQ reads are PacBio HiFi reads (<1% error). ' +
                "Default: ${params.flye_pacbio_hifi}",
            cliflag: '--pacbio-hifi',
            clivalue: (params.flye_pacbio_hifi ? ' ' : '')
        ],
        'flye_nano_raw': [
            clihelp: 'Input FASTQ reads are ONT regular reads, pre-Guppy5 (<20% error). ' +
                "Default: ${params.flye_nano_raw}",
            cliflag: '--nano-raw',
            clivalue: (params.flye_nano_raw ? ' ' : '')
        ],
        'flye_nano_corr': [
            clihelp: 'Input FASTQ reads are ONT reads that were corrected with other ' +
                "methods (<3% error). Default: ${params.flye_nano_corr}",
            cliflag: '--nano-corr',
            clivalue: (params.flye_nano_corr ? ' ' : '')
        ],
        'flye_nano_hq': [
            clihelp: 'Input FASTQ reads are ONT high-quality reads: ' +
                "Guppy5+ SUP or Q20 (<5% error). Default: ${params.flye_nano_hq}",
            cliflag: '--nano-hq',
            clivalue: (params.flye_nano_hq ? ' ' : '')
        ],
        'flye_genome_size': [
            clihelp: 'Estimated genome size (for example, 5m or 2.6g). ' +
                "Default: ${params.flye_genome_size}",
            cliflag: '--genome-size',
            clivalue: (params.flye_genome_size ?: '')
        ],
        'flye_polish_iter': [
            clihelp: 'Number of genome polishing iterations. ' +
                "Default: ${params.flye_polish_iter}",
            cliflag: '--iterations',
            clivalue: (params.flye_polish_iter ?: '')
        ],
        'flye_meta': [
            clihelp: "Do a metagenome assembly (unenven coverage mode). Default: ${params.flye_meta}",
            cliflag: '--meta',
            clivalue: (params.flye_meta ? ' ' : '')
        ],
        'flye_min_overlap': [
            clihelp: "Minimum overlap between reads. Default: ${params.flye_min_overlap}",
            cliflag: '--min-overlap',
            clivalue: (params.flye_min_overlap ?: '')
        ],
        'flye_scaffold': [
            clihelp: "Enable scaffolding using assembly graph. Default: ${params.flye_scaffold}",
            cliflag: '--scaffold',
            clivalue: (params.flye_scaffold ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}