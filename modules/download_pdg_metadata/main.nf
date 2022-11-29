process DOWNLOAD_PDG_METADATA {
    tag "dl_pdg_metadata.py"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        val pdg_release

    output:
        path "**${params.fs}*.metadata.tsv"                     , emit: pdg_metadata
        path "**${params.fs}*.reference_target.cluster_list.tsv", emit: snp_cluster_metadata
        path "**${params.fs}*accs_all.txt"                      , emit: accs
        path 'versions.yml'                                     , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        args += (pdg_release ? " -rel ${pdg_release}" : '')
        """
        dl_pdg_metadata.py \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """

}