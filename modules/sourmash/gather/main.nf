process SOURMASH_GATHER {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}sourmash${params.fs}4.6.1" : null)
    conda (params.enable_conda ? "conda-forge::python bioconda::sourmash=4.6.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(signature), path(database)
    val save_unassigned
    val save_matches_sig
    val save_prefetch
    val save_prefetch_csv

    output:
    tuple val(meta), path("*.csv.gz")                   , emit: result       , optional: true
    tuple val(meta), path("*_scaffolded_genomic.fna.gz"), emit: genomes_fasta, optional: true
    tuple val(meta), path("*_unassigned.sig.zip")       , emit: unassigned   , optional: true
    tuple val(meta), path("*_matches.sig.zip")          , emit: matches      , optional: true
    tuple val(meta), path("*_prefetch.sig.zip")         , emit: prefetch     , optional: true
    tuple val(meta), path("*_prefetch.csv.gz")          , emit: prefetchcsv  , optional: true
    path "*FAILED.txt"                                  , emit: failed       , optional: true
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def unassigned  = save_unassigned   ? "--output-unassigned ${prefix}_unassigned.sig.zip" : ''
    def matches     = save_matches_sig  ? "--save-matches ${prefix}_matches.sig.zip"         : ''
    def prefetch    = save_prefetch     ? "--save-prefetch ${prefix}_prefetch.sig.zip"       : ''
    def prefetchcsv = save_prefetch_csv ? "--save-prefetch-csv ${prefix}_prefetch.csv.gz"    : ''
    def gd          = params.tuspy_gd   ? "-gd ${params.tuspy_gd}"                           : ''

    """
    sourmash gather \\
        $args \\
        --output ${prefix}.csv.gz \\
        ${unassigned} \\
        ${matches} \\
        ${prefetch} \\
        ${prefetchcsv} \\
        ${signature} \\
        ${database}

    sourmash_filter_hits.py \\
        $args2 \\
        -csv ${prefix}.csv.gz

    gen_otf_genome.py \\
        $gd \\
        -op ${prefix} \\
        -txt ${prefix}_template_hits.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
        python: \$( python --version | sed 's/Python //g' )
    END_VERSIONS
    """
}