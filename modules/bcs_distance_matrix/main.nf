process BCS_DISTANCE_MATRIX {
    tag "Samples vs Genomes"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10 conda-forge::pyyaml" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.13--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.13--pyhdfd78af_0' }"

    input:
        path matrix
        path labels

    output:
        path 'bcs_sourmash_matrix.tblsum.txt', emit: mqc_txt, optional: true
        path 'bcs_sourmash_matrix_mqc.json'  , emit: mqc_json, optional: true
        path 'bcs_sourmash_matrix_mqc.yml'   , emit: mqc_yml, optional: true
        path 'versions.yml'                  , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''

        """
        sourmash_sim_matrix.py \\
            -pickle ${params.tuspy_ps} \\
            -csv $matrix \\
            -labels $labels

        if [ -e "bcs_sourmash_matrix.tblsum.txt" ] && [ -s "bcs_sourmash_matrix.tblsum.txt" ]; then
            create_mqc_data_table.py \\
                "bcs_sourmash_matrix" \\
                ${workflow.manifest.name}
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}