process TABLE_SUMMARY {
    tag "$table_sum_on"
    label 'process_low'

    // Requires `pyyaml` which does not have a dedicated container but is in the MultiQC container
    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.9 conda-forge::pyyaml conda-forge::coreutils" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.11--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.11--pyhdfd78af_0' }"

    input:
    tuple val(table_sum_on), path(tables)

    output:
    tuple val(table_sum_on), path("*.tblsum.txt"), emit: tblsummed
    path "*_mqc.yml"                             , emit: mqc_yml
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when || tables

    script:
    def args = task.ext.args ?: ''
    def onthese = tables.collect().join('\\n')
    """
    filenum="1"
    header=""

    echo -e "$onthese" | while read -r file; do
        
        if [ "\${filenum}" == "1" ]; then
            header=\$( head -n1 "\${file}" )
            echo -e "\${header}" > ${table_sum_on}.tblsum.txt
        fi

        tail -n+2 "\${file}" >> ${table_sum_on}.tblsum.txt

        filenum=\$((filenum+1))
    done

    create_mqc_data_table.py $table_sum_on ${workflow.manifest.name}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        python: \$( python --version | sed 's/Python //g' )
    END_VERSIONS

    headver=\$( head --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
    tailver=\$( tail --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )

    cat <<-END_VERSIONS >> versions.yml
        head: \$headver
        tail: \$tailver
    END_VERSIONS
    """
}