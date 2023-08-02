process ABRICATE_RUN {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}abricate${params.fs}1.0.1" : null)
    conda (params.enable_conda ? "conda-forge::perl bioconda::abricate=1.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'quay.io/biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    tuple val(meta), path(assembly)
    val abdbs

    output:
    path "${meta.id}${params.fs}*"
    tuple val(meta), path("${meta.id}${params.fs}*.ab.txt"), emit: abricated
    path "versions.yml"                                    , emit: versions

    when:
    (task.ext.when == null || task.ext.when) && assembly.size() > 0

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def dbs = abdbs.collect().join('\\n')
    """
    newprefix="${prefix}${params.fs}${prefix}"

    if [ ! -d "$prefix" ]; then
        mkdir "$prefix" || exit 1
    fi

    echo -e "$dbs" | while read -r db; do
        abricate \\
            $assembly \\
            $args \\
            --db \$db \\
            --threads $task.cpus 1> "\${newprefix}.\${db}.ab.txt"
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
        bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
    END_VERSIONS
    """
}