process MULTIQC {
    label 'process_low'
    tag 'MultiQC'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}multiqc${params.fs}1.12" : null)
    conda (params.enable_conda ? 'bioconda::multiqc=1.12 conda-forge::spectra conda-forge::lzstring' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.12--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.12--pyhdfd78af_0' }"

    input:
    path multiqc_files

    output:
    path "*multiqc*"
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , emit: plots, optional: true
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    cp ${params.projectconf}${params.fs}multiqc${params.fs}${params.pipeline}_mqc.yml cpipes_mqc_config.yml
    sed -i -e 's/Workflow_Name_Placeholder/${params.pipeline}/g; s/Workflow_Version_Placeholder/${params.workflow_version}/g' cpipes_mqc_config.yml
    sed -i -e 's/CPIPES_Version_Placeholder/${workflow.manifest.version}/g; s%Workflow_Output_Placeholder%${params.output}%g' cpipes_mqc_config.yml
    sed -i -e 's%Workflow_Input_Placeholder%${params.input}%g' cpipes_mqc_config.yml

    multiqc --interactive -c cpipes_mqc_config.yml -f $args .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS

    sedver=""

    if [ "${workflow.containerEngine}" != "null" ]; then
        sedver=\$( sed --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
    else
        sedver=\$( echo \$(sed --version 2>&1) | sed 's/^.*(GNU sed) //; s/ Copyright.*\$//' )
    fi

    cat <<-END_VERSIONS >> versions.yml
        sed: \$sedver
    END_VERSIONS
    """
}