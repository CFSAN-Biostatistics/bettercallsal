process TOP_UNIQUE_SEROVARS {
    tag "$meta.id"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        tuple val(meta), path(mash_screen_res)

    output:
        tuple val(meta), path('*_UNIQUE_HITS.txt')   , emit: tsv, optional: true
        tuple val(meta), path('*_UNIQUE_HITS.fna.gz'), emit: genomes_fasta, optional: true
        path'*FAILED.txt'                            , emit: failed, optional: true
        path 'versions.yml'                          , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        args += (mash_screen_res ? " -m ${mash_screen_res}" : '')
        args += (prefix ? " -op ${prefix}" : '')
        """
        get_top_unique_mash_hit_genomes.py \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """

}