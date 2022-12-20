process SOURMASH_COMPARE {
    tag "Samples vs Genomes"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}sourmash${params.fs}4.6.1" : null)
    conda (params.enable_conda ? "conda-forge::python bioconda::sourmash=4.6.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"

    input:
    path queries
    path accessions

    output:
    path "bcs_sourmash_cont_mat.csv"            , emit: matrix, optional: true
    path "bcs_sourmash_cont_mat.data.labels.txt", emit: labels, optional: true
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sketch_args = (params.sourmashsketch_mode ?: '')
    sketch_args += (params.sourmashsketch_singleton ? ' --singleton ' : '')
    sketch_args += (params.sourmashsketch_p ? " -p ${params.sourmashsketch_p} " : '')
    """

    gen_otf_genome.py \\
        -gd "${params.tuspy_gd}" \\
        -gds "${params.tuspy_gds}" \\
        -txt $accessions

    if [ ! -e "CATTED_GENOMES_FAILED.txt" ]; then

        sourmash sketch \\
            $sketch_args \\
            --output OTF.db.sig \\
            CATTED_GENOMES_scaffolded_genomic.fna.gz

        sourmash compare \\
            --${params.sourmashsketch_mode} \\
            -k ${params.sourmashgather_k} \\
            --csv bcs_sourmash_cont_mat.csv \\
            --output bcs_sourmash_cont_mat.data \\
            ${queries.collect().join(' ')} \\
            OTF.db.sig
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
        python: \$( python --version | sed 's/Python //g' )
        bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
    END_VERSIONS
    """
}