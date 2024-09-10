process NANOPLOT {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}NanoPlot${params.fs}1.43.0" : null)
    conda (params.enable_conda ? "conda-forge::plotly bioconda::nanoplot=1.43.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoplot:1.42.0--pyhdfd78af_0' :
        'quay.io/biocontainers/nanoplot:1.42.0--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(ontfile)

    output:
        tuple val(meta), path("*.html"), emit: html
        tuple val(meta), path("*.png") , emit: png, optional: true
        tuple val(meta), path("*.txt") , emit: txt
        tuple val(meta), path("*.log") , emit: log
        path  "versions.yml"           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def input_file = ("$ontfile".endsWith(".fastq.gz") || "$ontfile".endsWith(".fq.gz")) ? "--fastq ${ontfile}" :
            ("$ontfile".endsWith(".txt")) ? "--summary ${ontfile}" : ''
        """
        NanoPlot \\
            $args \\
            -t $task.cpus \\
            $input_file

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            nanoplot: \$(echo \$(NanoPlot --version 2>&1) | sed 's/^.*NanoPlot //; s/ .*\$//')
        END_VERSIONS
        """
}