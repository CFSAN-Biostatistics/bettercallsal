process UPLOAD_MICROREACT {
    tag "microreact_post.py"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10 conda-forge::requests" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/requests:2.26.0' :
        'quay.io/biocontainers/requests:2.26.0' }"

    input:
        path tree
        path metadata

    output:
        path "*.txt"       , emit: url
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        microreact_post.py \\
            $args \\
            -atp "${params.microreact_api_key}" \\
            -name "${params.microreact_tree_name}" \\
            -dir "."

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """

}