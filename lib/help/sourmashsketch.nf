// Help text for sourmash sketch dna within CPIPES.

def sourmashsketchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'sourmashsketch_run': [
            clihelp: 'Run `sourmash sketch dna` tool. Default: ' +
                (params.sourmashsketch_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'sourmashsketch_mode': [
            clihelp: "Select which type of signatures to be created: dna, protein, fromfile or translate. "
                + "Default: ${params.sourmashsketch_mode}",
            cliflag: "${params.sourmashsketch_mode}",
            clivalue: ' '
        ],
        'sourmashsketch_p': [
            clihelp: 'Signature parameters to use. ' +
                "Default: ${params.sourmashsketch_p}",
            cliflag: '-p',
            clivalue: (params.sourmashsketch_p ?: '')
        ],
        'sourmashsketch_file': [
            clihelp: '<path>  A text file containing a list of sequence files to load. ' +
                "Default: ${params.sourmashsketch_file}",
            cliflag: '--from-file',
            clivalue: (params.sourmashsketch_file ?: '')
        ],
        'sourmashsketch_f': [
            clihelp: 'Recompute signatures even if the file exists. ' +
                "Default: ${params.sourmashsketch_f}",
            cliflag: '-f',
            clivalue: (params.sourmashsketch_f ? ' ' : '')
        ],
        'sourmashsketch_merge': [
            clihelp: 'Merge all input files into one signature file with the specified name. ' +
                "Default: ${params.sourmashsketch_merge}",
            cliflag: '--merge',
            clivalue: (params.sourmashsketch_merge ? ' ' : '')
        ],
        'sourmashsketch_singleton': [
            clihelp: 'Compute a signature for each sequence record individually. ' +
                "Default: ${params.sourmashsketch_singleton}",
            cliflag: '--singleton',
            clivalue: (params.sourmashsketch_singleton ? ' ' : '')
        ],
        'sourmashsketch_name': [
            clihelp: 'Name the signature generated from each file after the first record in the file. ' +
                "Default: ${params.sourmashsketch_name}",
            cliflag: '--name-from-first',
            clivalue: (params.sourmashsketch_name ? ' ' : '')
        ],
        'sourmashsketch_randomize': [
            clihelp: 'Shuffle the list of input files randomly. ' +
                "Default: ${params.sourmashsketch_randomize}",
            cliflag: '--randomize',
            clivalue: (params.sourmashsketch_randomize ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}