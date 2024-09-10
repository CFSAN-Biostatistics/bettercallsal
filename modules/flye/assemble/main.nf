process FLYE_ASSEMBLE {
    tag "$meta.id"
    label 'process_medium'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}flye${params.fs}2.9.4" : null)
    conda (params.enable_conda ? "conda-forge::libgcc-ng bioconda::flye=2.9.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/flye:2.9.4--py310h2b6aa90_0' :
        'quay.io/biocontainers/flye:2.9.4--py310h2b6aa90_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    path "${meta.id}${params.fs}*"
    tuple val(meta), path("${meta.id}${params.fs}assembly.fasta"), emit: assembly, optional: true
    path "versions.yml"                                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    reads_platform=\$( echo "$args" | grep -E -o '(--nano|--pacbio)-(raw|corr|hq|hifi)' )
    flye \\
        \$(echo "$args" | sed -e "s/\$reads_platform//") \\
        -t $task.cpus \\
        --out-dir "${meta.id}" \\
        \$reads_platform \\
        $reads

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flye: \$( flye --version )
    END_VERSIONS

    grepver=""

    if [ "${workflow.containerEngine}" != "null" ]; then
        grepver=\$( grep --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
    else
        grepver=\$( echo \$( grep --version 2>&1 ) | sed 's/^.*(GNU grep) //; s/ Copyright.*\$//' )
    fi

    cat <<-END_VERSIONS >> versions.yml
        grep: \$grepver
    END_VERSIONS
    """
}