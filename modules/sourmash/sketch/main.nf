process SOURMASH_SKETCH {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}sourmash${params.fs}4.6.1" : null)
    conda (params.enable_conda ? "conda-forge::python bioconda::sourmash=4.6.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(sequence), path(database)

    output:
    tuple val(meta), path("*.query.sig"), path("*.db.sig"), emit: signatures
    path "versions.yml"                                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = task.ext.args ?: ''
    def args_query 
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    sourmash sketch \\
        ${args.toString().replace('--singleton', '')} \\
        --output "${prefix}.query.pre" \\
        $sequence

    sourmash signature rename \\
        --${args.toString().replaceAll(/\s+\-p.*/, '')} \\
        -o "${prefix}.query.sig" \\
        "${prefix}.query.pre" \\
        ${prefix} 

    sourmash sketch \\
        $args \\
        --output "${prefix}.db.sig" \\
        $database

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}