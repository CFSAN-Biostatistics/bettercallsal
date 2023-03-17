process KMA_INDEX {
    tag "$meta.id"
    label 'process_nano'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}kma${params.fs}1.4.4" : null)
    conda (params.enable_conda ? "conda-forge::libgcc-ng bioconda::kma=1.4.3 conda-forge::coreutils" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kma:1.4.3--h7132678_1':
        'quay.io/biocontainers/kma:1.4.3--h7132678_1' }"

    input:
        tuple val(meta), path(fasta)

    output:
        tuple val(meta), path("${meta.id}_kma_idx"), emit: idx
        path "versions.yml"                        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}_kma_idx"
        def add_to_db = (meta.kmaindex_t_db ? "-t_db ${meta.kmaindex_t_db}" : '')
        """
        mkdir -p $prefix && cd $prefix || exit 1
        kma \\
            index \\
            $args \\
            $add_to_db \\
            -i ../$fasta \\
            -o $prefix
        cd .. || exit 1

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            kma: \$( kma -v | sed -e 's%KMA-%%' )
        END_VERSIONS

        mkdirver=""
        cutver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            mkdirver=\$( mkdir --help 2>&1 | sed -e '1!d; s/ (.*\$//' |  cut -f1-2 -d' ' )
            cutver="\$mkdirver"
        else
            mkdirver=\$( mkdir --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
            cutver=\$( cut --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
        fi

        cat <<-END_VERSIONS >> versions.yml
            mkdir: \$mkdirver
            cut: \$cutver
            cd: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}