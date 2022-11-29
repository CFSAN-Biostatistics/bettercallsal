// Help text for waterfall_per_snp_cluster.pl (wsnp) within CPIPES.

def wsnpHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'wsnp_serocol': [
            clihelp: 'Column number (non 0-based index) of the PDG metadata file ' +
                'by which the serotypes are collected.' +
                " Default: ${params.wsnp_serocol}",
            cliflag: '--serocol',
            clivalue: (params.wsnp_serocol ?: '')
        ],
        'wsnp_complete_sero': [
            clihelp: 'Skip indexing serotypes when the serotype name in the column ' +
                'number 49 (non 0-based) of PDG metadata file consists a "-". For example, if ' +
                'an accession has a serotype= string as such in column ' +
                'number 49 (non 0-based): ' +
                '"serotype=- 13:z4,z23:-" ' +
                'then, the indexing of that accession is skipped.' +
                " Default: ${params.wsnp_complete_sero}",
            cliflag: '--complete_serotype_name',
            clivalue: (params.wsnp_complete_sero ? ' ' : '')
        ],
        'wsnp_not_null_serovar': [
            clihelp: 'Only index the computed_serotype column ' +
                'i.e. column number 49 (non 0-based), if the serovar column' +
                ' is not NULL. ' +
                " Default: ${params.wsnp_not_null_serovar}",
            cliflag: '--not_null_serotype_name',
            clivalue: (params.wsnp_not_null_serovar ?: '')
        ],
        'wsnp_i': [
            clihelp: 'Force include this serovar. Ignores ' +
                '--wsnp_complete_sero for only this serovar. ' +
                'Mention multiple serovars separated by a ! (Exclamation mark). ' +
                'Ex: --wsnp_complete_sero I 4,[5],12:i:-!Agona' +
                " Default: ${params.wsnp_i}",
            cliflag: '-i',
            clivalue: (params.wsnp_i ? params.wsnp_i.split(/\!/).join(' -i ').trim().replace(/^\-i\s+/, '') : '')
        ],
        'wsnp_num': [
            clihelp: 'Number of genome accessions to collect per SNP cluster.' +
                " Default: ${params.wsnp_num}",
            cliflag: '-num',
            clivalue: (params.wsnp_num ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}