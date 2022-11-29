process MASH_SCREEN {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}mash${params.fs}2.3" : null)
    conda (params.enable_conda ? "conda-forge::capnproto bioconda::mash=2.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mash:2.3--he348c14_1':
        'quay.io/biocontainers/mash:2.3--he348c14_1' }"

    input:
        tuple val(meta), path(query)

    output:
        tuple val(meta), path("*.screened"), emit: screened
        path "versions.yml"                , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def sequence_sketch = (meta.sequence_sketch ?: '')
        """
        mash \\
            screen \\
            $args \\
            -p $task.cpus \\
            $sequence_sketch \\
            $query \\
            > ${prefix}.screened

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mash: \$( mash --version )
        END_VERSIONS
        """
}