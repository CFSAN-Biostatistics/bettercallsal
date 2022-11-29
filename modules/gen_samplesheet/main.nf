process GEN_SAMPLESHEET {
    tag "${inputdir.simpleName}"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
        val inputdir

    output:
        path '*.csv'       , emit: csv
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    // This script (fastq_dir_to_samplesheet.py) is distributed
    // as part of the pipeline nf-core/rnaseq/bin/. MIT License.
    script:
        def this_script_args = (params.fq_single_end ? ' -se' : '')
        this_script_args += (params.fq_suffix ? " -r1 '${params.fq_suffix}'" : '')
        this_script_args += (params.fq2_suffix ? " -r2 '${params.fq2_suffix}'" : '')

        """
        fastq_dir_to_samplesheet.py -sn \\
            -st '${params.fq_strandedness}' \\
            -sd '${params.fq_filename_delim}' \\
            -si ${params.fq_filename_delim_idx} \\
            ${this_script_args} \\
            ${inputdir} autogen_samplesheet.csv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}