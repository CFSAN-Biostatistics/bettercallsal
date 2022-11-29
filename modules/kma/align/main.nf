process KMA_ALIGN {
    tag "$meta.id"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}kma${params.fs}1.4.4" : null)
    conda (params.enable_conda ? "conda-forge::libgcc-ng bioconda::kma=1.4.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kma:1.4.3--h7132678_1':
        'quay.io/biocontainers/kma:1.4.3--h7132678_1' }"

    input:
        tuple val(meta), path(reads), path(index)

    output:
        path "${meta.id}_kma_res"
        tuple val(meta), path("${meta.id}_kma_res${params.fs}*.res")              , emit: res
        tuple val(meta), path("${meta.id}_kma_res${params.fs}*.mapstat")          , emit: mapstat, optional: true
        tuple val(meta), path("${meta.id}_kma_res${params.fs}*_template_hits.txt"), emit: hits, optional: true
        path "versions.yml"                                                       , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def reads_in = (meta.single_end ? "-i $reads" : "-ipe ${reads[0]} ${reads[1]}")
        def db = (meta.kma_t_db ?: "${index}")
        def db_basename = (db ? "${index.baseName}" : '')
        def get_hit_accs = (meta.get_kma_hit_accs ? 'true' : 'false')
        def res_dir = prefix + '_kma_res'
        reads_in = (params.kmaalign_int ? "-int $reads" : "-i $reads")
        """
        mkdir -p $res_dir || exit 1
        kma \\
            $args \\
            -t_db $db${params.fs}$db_basename \\
            -t $task.cpus \\
            -o $res_dir${params.fs}$prefix \\
            $reads_in

        if [ "$get_hit_accs" == "true" ]; then
            grep -v '^#' $res_dir${params.fs}${prefix}.res | \\
                cut -f1 > $res_dir${params.fs}${prefix}_template_hits.txt
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            kma: \$( kma -v | sed -e 's%KMA-%%' )
        END_VERSIONS

        mkdirver=""
        cutver=""
        grepver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            mkdirver=\$( mkdir --help 2>&1 | sed -e '1!d; s/ (.*\$//' |  cut -f1-2 -d' ' )
            cutver="\$mkdirver"
            grepver="\$mkdirver"
        else
            mkdirver=\$( mkdir --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
            cutver=\$( cut --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
            grepver=\$( echo \$(grep --version 2>&1) | sed 's/^.*(GNU grep) //; s/ Copyright.*\$//' )
        fi

        cat <<-END_VERSIONS >> versions.yml
            mkdir: \$mkdirver
            cut: \$cutver
            grep: \$grepver
        END_VERSIONS
        """
}