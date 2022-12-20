process BCS_RESULTS {
    tag "bettercallsal aggregate"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10 conda-forge::pyyaml" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.13--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.13--pyhdfd78af_0' }"

    input:
        path salmon_res_dirs

    output:
        path 'bettercallsal.tblsum.txt', emit: mqc_txt, optional: true
        path 'bettercallsal_mqc.json'  , emit: mqc_json, optional: true
        path 'bettercallsal_mqc.yml'   , emit: mqc_yml, optional: true
        path 'versions.yml'            , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        args += (params.tuspy_ps ? " -pickle ${params.tuspy_ps}" : '')
        args += (params.gsrpy_snp_clus_metadata ? " -snp ${params.gsrpy_snp_clus_metadata}" : '')
        """
        gen_salmon_res_table.py \\
            $args \\
            -sal "."

        create_mqc_data_table.py \\
            "bettercallsal" ${workflow.manifest.name}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}