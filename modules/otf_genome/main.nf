process OTF_GENOME {
    tag "$meta.id"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"

    input:
        tuple val(meta), path(kma_hits), path(kma_fragz)

    output:
        tuple val(meta), path('*_scaffolded_genomic.fna.gz'), emit: genomes_fasta, optional: true
        tuple val(meta), path('*_aln_reads.fna.gz')         , emit: reads_extracted, optional: true
        path '*FAILED.txt'                                  , emit: failed, optional: true
        path 'versions.yml'                                 , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        args += (kma_hits ? " -txt ${kma_hits}" : '')
        args += (params.tuspy_gd ? " -gd ${params.tuspy_gd}" : '')
        args += (prefix ? " -op ${prefix}" : '')

        """
        gen_otf_genome.py \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}