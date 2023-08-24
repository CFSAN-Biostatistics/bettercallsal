process FILTER_PDG_METADATA {
    tag "NCBI datasets"
    label "process_micro"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}perl${params.fs}5.30.0" : null)
    conda (params.enable_conda ? "conda-forge::perl conda-forge::coreutils bioconda::perl-bioperl=1.7.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl-bioperl:1.7.8--hdfd78af_1' :
        'quay.io/biocontainers/perl-bioperl:1.7.8--hdfd78af_1' }"

    input:
        path accs_chunk

    output:
        path '*accs_chunk_tbl.tsv', emit: accs_chunk_tbl
        path 'versions.yml'       , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.index ?: ''
        """
        datasets summary genome accession \\
            --as-json-lines \\
            --report sequence \\
            --inputfile $accs_chunk | \\
            dataformat tsv genome-seq \\
            --fields accession \\
            --elide-header | sort -u > "${prefix}_accs_chunk_tbl.filt"

        datasets summary genome accession \\
            --inputfile "${prefix}_accs_chunk_tbl.filt" \\
            --assembly-version latest \\
            --as-json-lines | \\
            dataformat tsv genome \\
            --fields accession,assminfo-level,assmstats-scaffold-n50,assmstats-contig-n50 \\
            --elide-header \\
            > "${prefix}_accs_chunk_tbl.tsv"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            datasets: \$( datasets --version | sed 's/datasets version: //g' )
            dataformat: \$( dataformat version )
        END_VERSIONS

        sortver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            sortver=\$( sort --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
        else
            sortver=\$( sort --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
        fi

        cat <<-END_VERSIONS >> versions.yml
            sort: \$sortver
        END_VERSIONS
        """
}