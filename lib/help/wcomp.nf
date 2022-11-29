// Help text for waterfall_per_computed_serotype.pl (wcomp) within CPIPES.

def wcompHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'wcomp_serocol': [
            clihelp: 'Column number (non 0-based index) of the PDG metadata file ' +
                'by which the serotypes are collected.' +
                " Default: ${params.wcomp_serocol}",
            cliflag: '--serocol',
            clivalue: (params.wcomp_serocol ?: '')
        ],
        'wcomp_complete_sero': [
            clihelp: 'Skip indexing serotypes when the serotype name in the column ' +
                'number 49 (non 0-based) of PDG metadata file consists a "-". For example, if ' +
                'an accession has a serotype= string as such in column ' +
                'number 49 (non 0-based): ' +
                '"serotype=- 13:z4,z23:-" ' +
                'then, the indexing of that accession is skipped.' +
                " Default: ${params.wcomp_complete_sero}",
            cliflag: '--complete_serotype_name',
            clivalue: (params.wcomp_complete_sero ? ' ' : '')
        ],
        'wcomp_not_null_serovar': [
            clihelp: 'Only index the computed_serotype column ' +
                'i.e. column number 49 (non 0-based), if the serovar column' +
                ' is not NULL. ' +
                " Default: ${params.wcomp_not_null_serovar}",
            cliflag: '--not_null_serotype_name',
            clivalue: (params.wcomp_not_null_serovar ?: '')
        ],
        'wcomp_i': [
            clihelp: 'Force include this serovar. Ignores ' +
                '--wcomp_complete_sero for only this serovar. ' +
                'Mention multiple serovars separated by a ! (Exclamation mark). ' +
                'Ex: --wcomp_complete_sero I 4,[5],12:i:-!Agona' +
                " Default: ${params.wcomp_i}",
            cliflag: '-i',
            clivalue: (params.wcomp_i ? params.wcomp_i.split(/\!/).join(' -i ').trim().replace(/^\-i\s+/, '') : '')
        ],
        'wcomp_num': [
            clihelp: 'Number of genome accessions to be collected per serotype.' +
                " Default: ${params.wcomp_num}",
            cliflag: '-num',
            clivalue: (params.wcomp_num ?: '')
        ],
        'wcomp_min_contig_size': [
            clihelp: 'Minimum contig size to consider a genome for indexing.' +
                " Default: ${params.wcomp_min_contig_size}",
            cliflag: '--min_contig_size',
            clivalue: (params.wcomp_min_contig_size ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}