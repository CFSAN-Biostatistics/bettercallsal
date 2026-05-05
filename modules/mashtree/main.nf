process MASHTREE {
    tag "$meta.id"
    label 'process_medium'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}mashtree${params.fs}1.4.3" : null)
    conda (params.enable_conda ? "bioconda::mashtree=1.4.3 conda-forge::perl conda-forge::coreutils" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mashtree:1.4.3--pl5321h031d066_0' :
        'quay.io/biocontainers/mashtree:1.4.3--pl5321h031d066_0' }"

    input:
        tuple val(meta), path(seqs)
        path reference

    output:
        tuple val(meta), path("*.dnd"), emit: tree
        tuple val(meta), path("*.tsv"), emit: matrix
        tuple val(meta), path("*.nwk"), emit: nwk, optional: true
        path "versions.yml"           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args      = task.ext.args ?: ''
        def prefix    = task.ext.prefix ?: "${meta.id}"
        def fofn      = (args.toString().matches(/.*file\-of\-files/) ? 'true' : 'false')
        """
        while IFS= read -r fa; do
            if [[ -n "\$fa" ]]; then
                if ! grep -F "\${fa}" $seqs && [ "$fofn" == "true" ]; then
                    echo "\$fa" >> $seqs
                fi
            fi
        done < "$reference"

        mashtree \\
            $args \\
            --tempdir "." \\
            --numcpus $task.cpus \\
            --outmatrix ${prefix}.tsv \\
            --outtree ${prefix}.dnd \\
            $seqs

        sed -ie 's/_scaffolded_genomic//g' ${prefix}.dnd
        sed -ie 's/.contigs//g' ${prefix}.dnd
        cp ${prefix}.dnd ${prefix}.nwk

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mashtree: \$( echo \$( mashtree --version 2>&1 ) | sed 's/^.*Mashtree //' )
        END_VERSIONS

        sedver=""
        grepver=""

        if [ "${workflow.containerEngine}" != "null" ]; then
            sedver=\$( sed --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
            grepver="\$sedver"
        else
            sedver=\$( echo \$(sed --version 2>&1) | sed 's/^.*(GNU sed) //; s/ Copyright.*\$//' )
            grepver=\$( echo \$(grep --version 2>&1) | sed 's/^.*(GNU grep) //; s/ Copyright.*\$//' )
        fi

        cat <<-END_VERSIONS >> versions.yml
            grep: \$grepver
            sed: \$sedver
        END_VERSIONS
    """
}