process FASTP {
    tag "$meta.id"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}fastp${params.fs}0.23.2" : null)
    conda (params.enable_conda ? "bioconda::fastp=0.23.2 conda-forge::isa-l" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.2--h79da9fb_0' :
        'quay.io/biocontainers/fastp:0.23.2--h79da9fb_0' }"

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path('*.fastp.fastq.gz') , emit: passed_reads, optional: true
        tuple val(meta), path('*.fail.fastq.gz')  , emit: failed_reads, optional: true
        tuple val(meta), path('*.merged.fastq.gz'), emit: merged_reads, optional: true
        tuple val(meta), path('*.json')           , emit: json
        tuple val(meta), path('*.html')           , emit: html
        tuple val(meta), path('*.log')            , emit: log
        path "versions.yml"                       , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def fail_fastq = params.fastp_failed_out && meta.single_end ? "--failed_out ${prefix}.fail.fastq.gz" : params.fastp_failed_out && !meta.single_end ? "--unpaired1 ${prefix}_1.fail.fastq.gz --unpaired2 ${prefix}_2.fail.fastq.gz" : ''
        // Added soft-links to original fastqs for consistent naming in MultiQC
        // Use single ended for interleaved. Add --interleaved_in in config.
        if ( task.ext.args?.contains('--interleaved_in') ) {
            """
            [ ! -f  ${prefix}.fastq.gz ] && ln -sf $reads ${prefix}.fastq.gz

            fastp \\
                --stdout \\
                --in1 ${prefix}.fastq.gz \\
                --thread $task.cpus \\
                --json ${prefix}.fastp.json \\
                --html ${prefix}.fastp.html \\
                $fail_fastq \\
                $args \\
                2> ${prefix}.fastp.log \\
            | gzip -c > ${prefix}.fastp.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
            END_VERSIONS
            """
        } else if (meta.single_end) {
            """
            [ ! -f  ${prefix}.fastq.gz ] && ln -sf $reads ${prefix}.fastq.gz

            fastp \\
                --in1 ${prefix}.fastq.gz \\
                --out1  ${prefix}.fastp.fastq.gz \\
                --thread $task.cpus \\
                --json ${prefix}.fastp.json \\
                --html ${prefix}.fastp.html \\
                $fail_fastq \\
                $args \\
                2> ${prefix}.fastp.log

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
            END_VERSIONS
            """
        } else {
            def merge_fastq = params.fastp_merged_out ? "-m --merged_out ${prefix}.merged.fastq.gz" : ''
            """
            [ ! -f  ${prefix}_1.fastq.gz ] && ln -sf ${reads[0]} ${prefix}_1.fastq.gz
            [ ! -f  ${prefix}_2.fastq.gz ] && ln -sf ${reads[1]} ${prefix}_2.fastq.gz
            fastp \\
                --in1 ${prefix}_1.fastq.gz \\
                --in2 ${prefix}_2.fastq.gz \\
                --out1 ${prefix}_1.fastp.fastq.gz \\
                --out2 ${prefix}_2.fastp.fastq.gz \\
                --json ${prefix}.fastp.json \\
                --html ${prefix}.fastp.html \\
                $fail_fastq \\
                $merge_fastq \\
                --thread $task.cpus \\
                --detect_adapter_for_pe \\
                $args \\
                2> ${prefix}.fastp.log

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
            END_VERSIONS
            """
    }
}