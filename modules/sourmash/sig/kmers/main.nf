process SOURMASH_SIG_KMERS {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}sourmash${params.fs}4.6.1" : null)
    conda (params.enable_conda ? "conda-forge::python bioconda::sourmash=4.6.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0' :
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"

    input:
        tuple val(meta), path(sig_or_seq), path(sequence)

    output:
        tuple val(meta), path("*.csv")  , emit: signatures, optional: true
        tuple val(meta), path("*.fasta"), emit: extracted_fasta, optional: true
        path "versions.yml"             , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        // required defaults for the tool to run, but can be overridden
        def args = task.ext.args ?: ''
        def is_seq = "${sig_or_seq.baseName.findAll(/(?i)\.(fa|fasta|fna)\.{0,1}(gz){0,1}$/).size()}"
        def save_kmers = (params.sourmashsigkmers_save_kmers ? "--save-kmers ${meta.id}.sm.kmers.csv" : '')
        def save_seqs = (params.sourmashsigkmers_save_seqs ? "--save-sequences ${meta.id}.sm.seq.fasta" : '')
        def sketch_mode = (params.sourmashsketch_mode ?: 'dna')
        def sketch_p = (params.sourmashsketch_p ?: "abund,scaled=1000,k=71")
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        db_sig="${sig_or_seq}"
        if [[ $is_seq -ge 1 ]]; then
            db_sig="${prefix}.db.sig"
            sourmash sketch \\
                $sketch_mode \\
                -p '$sketch_p' \\
                --output \$db_sig \\
                $sig_or_seq
        fi

        sourmash signature kmers \\
            $args \\
            $save_kmers \\
            $save_seqs \\
            --signatures \$db_sig \\
            --sequences $sequence 

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}