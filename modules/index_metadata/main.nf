process INDEX_METADATA {
    tag "get_top_unique_mash_hit_genomes.py"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        tuple val(type), path(sero_tbl)

    output:
        path '*.ACC2SERO.pickle', emit: acc2sero
        path 'versions.yml'     , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = (
            type.find(/_comp/) \
            ? type.replaceAll(/\_comp/, 'per_comp_serotype') \
            : type.replaceAll(/\_snp/, 'per_snp_cluster')
        )
        """
        get_top_unique_mash_hit_genomes.py \\
            -s $sero_tbl -op $prefix

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}