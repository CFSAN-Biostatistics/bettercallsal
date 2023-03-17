process BBTOOLS_BBMERGE {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}bbtools${params.fs}38.94" : null)
    conda (params.enable_conda ? "conda-forge::pbzip2 bioconda::bbmap=38.95" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:38.95--he522d1c_0' :
        'quay.io/biocontainers/bbmap:38.95--he522d1c_0' }"

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("*.fastq.gz"), emit: fastq
        tuple val(meta), path("*.log")     , emit: log
        path "versions.yml"                , emit: versions

    when:
        !meta.single_end

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def in_files = "in1=${reads[0]} in2=${reads[1]}"
        def out_file  = "out=${prefix}.bbmerge.fastq.gz"
        def adapters_file = file (meta.adapters)
        def adapters = !("${adapters_file.simpleName}" ==~ 'dummy_file.*') && adapters_file.exits() ? "adapters=${meta.adapters}" : ''
        def args_formatted = args.replaceAll('=\s+', '=')
        """
        bbmerge.sh \\
            -Xmx${task.memory.toGiga()}G \\
            threads=$task.cpus \\
            $args_formatted \\
            $adapters \\
            $in_files \\
            $out_file &> ${prefix}.bbmerge.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bbmerge: \$( bbversion.sh )
        END_VERSIONS
        """
}
