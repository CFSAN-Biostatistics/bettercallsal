process SALMON_INDEX {
    tag "$meta.id"
    label "process_micro"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}salmon${params.fs}1.10.0" : null)
    conda (params.enable_conda ? 'conda-forge::libgcc-ng bioconda::salmon=1.10.1' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/salmon:1.10.1--h7e5ed60_1' :
        'quay.io/biocontainers/salmon:1.10.1--h7e5ed60_1' }"

    input:
        tuple val(meta), path(genome_fasta)

    output:
        tuple val(meta), path("${meta.id}_salmon_idx"), emit: idx
        path "versions.yml"                           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}_salmon_idx"
        def decoys_file = file( meta.salmon_decoys )
        def decoys = !("${decoys_file.simpleName}" ==~ 'dummy_file.*') && decoys_file.exits() ? "--decoys ${meta.salmon_decoys}" : ''
        """
        salmon \\
            index \\
            $decoys \\
            --threads $task.cpus \\
            $args \\
            --index $prefix \\
            --transcripts $genome_fasta

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
        END_VERSIONS
        """
}