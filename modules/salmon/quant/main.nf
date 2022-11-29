process SALMON_QUANT {
    tag "$meta.id"
    label "process_medium"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}salmon${params.fs}1.9.0" : null)
    conda (params.enable_conda ? 'conda-forge::libgcc-ng bioconda::salmon=1.9.0' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/salmon:1.9.0--h7e5ed60_1' :
        'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1' }"
    input:
        tuple val(meta), path(reads_or_bam), path(index_or_tr_fasta)

    output:
        tuple val(meta), path("${meta.id}_salmon_res"), emit: results
        path  "versions.yml"                          , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args   ?: ''
        def prefix   = task.ext.prefix ?: "${meta.id}_salmon_res"
        def reference   = "--index $index_or_tr_fasta"
        def lib_type = (meta.salmon_lib_type ?: '')
        def alignment_mode = (meta.salmon_alignment_mode ?: '')
        def gtf = (meta.salmon_gtf ? "--geneMap ${meta.salmon_gtf}" : '')
        def input_reads =(meta.single_end ? "-r $reads_or_bam" : "-1 ${reads_or_bam[0]} -2 ${reads_or_bam[1]}")

        // Use path(reads_or_bam) to point to BAM and path(index_or_tr_fasta) to point to transcript fasta
        // if using salmon DSL2 module in alignment-based mode.
        // By default, this module will be run in selective-alignment-based mode of salmon.
        if (alignment_mode) {
            reference   = "-t $index_or_tr_fasta"
            input_reads = "-a $reads_or_bam"
        }

        def strandedness_opts = [
            'A', 'U', 'SF', 'SR',
            'IS', 'IU' , 'ISF', 'ISR',
            'OS', 'OU' , 'OSF', 'OSR',
            'MS', 'MU' , 'MSF', 'MSR'
        ]

        def strandedness =  'A'

        if (lib_type) {
            if (strandedness_opts.contains(lib_type)) {
                strandedness = lib_type
            } else {
                log.info "[Salmon Quant] Invalid library type specified '--libType=${lib_type}', defaulting to auto-detection with '--libType=A'."
            }
        } else {
            strandedness = meta.single_end ? 'U' : 'IU'
            if (meta.strandedness == 'forward') {
                strandedness = meta.single_end ? 'SF' : 'ISF'
            } else if (meta.strandedness == 'reverse') {
                strandedness = meta.single_end ? 'SR' : 'ISR'
            }
        }
        """
        salmon quant \\
            --threads $task.cpus \\
            --libType=$strandedness \\
            $gtf \\
            $args \\
            -o $prefix \\
            $reference \\
            $input_reads

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
        END_VERSIONS
        """
}