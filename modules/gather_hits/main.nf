process GATHER_HITS {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}pigz${params.fs}2.7" : null)
    conda (params.enable_conda ? "conda-forge::pigz=2.6" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pigz:2.3.4' :
        'quay.io/biocontainers/pigz:2.3.4' }"

    input:
        tuple val(meta), path(genomes_fasta)

    output:
        tuple val(meta), path("*_template_hits.txt"), emit: sm_template_hits
        path "versions.yml"                         , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def args2 = task.ext.args2 ?: ''

        // Use input file ending as default
        prefix   = task.ext.prefix ?: "${meta.id}"
        command  = genomes_fasta.toString().endsWith('.gz') ? 'zcat' : 'cat'
        """
        $command \\
            $args \\
            $genomes_fasta | \\
            grep -F '>' | grep -E -o 'GC[AF]\\_[0-9]+\\.*[0-9]*' > ${prefix}.sm_template_hits.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            pigz: \$( pigz --version 2>&1 | sed 's/pigz //g' )
        END_VERSIONS
        
        mkdirver=""
        catver=""
        zver=""
        grepver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            mkdirver=\$( mkdir --help 2>&1 | sed -e '1!d; s/ (.*\$//' |  cut -f1-2 -d' ' )
            catver=\$( cat --help 2>&1 | sed -e '1!d; s/ (.*\$//' |  cut -f1-2 -d' ' )
            zver=\$( zcat --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
            grepver="\$mkdirver"
        else
            catver=\$( cat --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
            zver=\$( zcat --version 2>&1 | sed '1!d; s/^.*(gzip) //' )
            grepver=\$( echo \$(grep --version 2>&1) | sed 's/^.*(GNU grep) //; s/ Copyright.*\$//' )
        fi

        cat <<-END_VERSIONS >> versions.yml
            cat: \$catver
            zcat: \$zver
            grep: \$grepver
        END_VERSIONS
        """
}