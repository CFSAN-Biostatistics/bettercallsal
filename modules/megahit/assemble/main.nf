process MEGAHIT_ASSEMBLE {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}megahit${params.fs}1.2.9" : null)
    conda (params.enable_conda ? "conda-forge::python bioconda::megahit=1.2.9" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/megahit:1.2.9--h2e03b76_1' :
        'quay.io/biocontainers/megahit:1.2.9--h2e03b76_1' }"

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("${meta.id}${params.fs}${meta.id}.contigs.fa"), emit: assembly, optional: true
        path "versions.yml"                                                 , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def maxmem = task.memory ? "--memory ${task.memory.toBytes()}" : ""
        if (meta.single_end) {
            """
            megahit \\
                -r ${reads} \\
                -t $task.cpus \\
                $maxmem \\
                $args \\
                --out-dir $prefix \\
                --out-prefix $prefix

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                megahit: \$(echo \$(megahit -v 2>&1) | sed 's/MEGAHIT v//')
            END_VERSIONS
            """
        } else {
            """
            megahit \\
                -1 ${reads[0]} \\
                -2 ${reads[1]} \\
                -t $task.cpus \\
                $maxmem \\
                $args \\
                --out-dir $prefix \\
                --out-prefix $prefix

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                megahit: \$(echo \$(megahit -v 2>&1) | sed 's/MEGAHIT v//')
            END_VERSIONS
            """
    }
}
