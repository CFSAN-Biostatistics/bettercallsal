process ABRICATE_SUMMARY {
    tag "${abdbs.join(',')}"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}abricate${params.fs}1.0.1" : null)
    conda (params.enable_conda ? "conda-forge::perl bioconda::abricate=1.0.1 conda-forge::coreutils" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'quay.io/biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    tuple val(abdbs), path(abfiles)

    output:
    tuple val('abricate_ncbi'), path("*.ncbi.absum.txt")              , emit: ncbi, optional: true
    tuple val('abricate_ncbiamrplus'), path("*.ncbiamrplus.absum.txt"), emit: ncbiamrplus, optional: true
    tuple val('abricate_resfinder'), path("*resfinder.absum.txt")     , emit: resfinder, optional: true
    tuple val('abricate_megares'), path("*.megares.absum.txt")        , emit: megares, optional: true
    tuple val('abricate_argannot'), path("*.argannot.absum.txt")      , emit: argannot, optional: true
    tuple val('abricate_ecoli_vf'), path("*.ecoli_vf.absum.txt")      , emit: ecoli_vf, optional: true
    path "versions.yml"                                               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def onthese = abdbs.collect{ db ->
        abfiles.findAll { files ->
            files =~ /\.${db}/
        }.join(' ')
    }.join('\\n')
    """
    filenum="1"

    echo -e "$onthese" | while read -r files; do
        db=\$( echo -e "\${files}" | grep -E -o '\\w+\\.ab\\.txt' | sort -u | sed -e 's/.ab.txt//' )

        if [ -z "\$db" ]; then
            db="\$filenum"
        fi

        abricate \\
            $args \\
            --summary \${files} \\
            1> "abricate.\${db}.absum.txt"

        sed -i -e "s/.\${db}.ab.txt//" "abricate.\${db}.absum.txt"
        sed -i -e 's/.assembly_filtered_contigs.fasta//' "abricate.\${db}.absum.txt"

        filenum=\$((filenum+1))
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
        bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
    END_VERSIONS

    sedver=""
    sortver=""
    grepver=""

    if [ "${workflow.containerEngine}" != "null" ]; then
        sortver=\$( sort --help 2>&1 | sed -e '1!d; s/ (.*\$//' )
        sedver="\$sortver"
        grepver="\$sortver"
    else
        sortver=\$( sort --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
        sedver=\$( echo \$(sed --version 2>&1) | sed 's/^.*(GNU sed) //; s/ Copyright.*\$//' )
        grepver=\$( echo \$(grep --version 2>&1) | sed 's/^.*(GNU grep) //; s/ Copyright.*\$//' )
    fi

    cat <<-END_VERSIONS >> versions.yml
        sort: \$sortver
        grep: \$grepver
        sed: \$sedver
    END_VERSIONS
    """
}