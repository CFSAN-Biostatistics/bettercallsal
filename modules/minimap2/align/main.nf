process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ?
        "${params.swmodulepath}${params.fs}minimap2${params.fs}2.22:${params.swmodulepath}${params.fs}samtools${params.fs}1.13" : null)
    conda (params.enable_conda ? "bioconda::minimap2=2.24 bioconda::samtools=1.18 conda-forge::perl" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:365b17b986c1a60c1b82c6066a9345f38317b763-0' :
        'quay.io/biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:365b17b986c1a60c1b82c6066a9345f38317b763-0' }"

    input:
        tuple val(meta), path(reads)
        tuple val(meta2), path(reference)
        val bam_format
        val align_bam_sorted
        val cigar_paf_format
        val cigar_bam

    output:
        tuple val(meta), path("*.paf"), emit: paf, optional: true
        tuple val(meta), path("*.bam"), emit: bam, optional: true
        tuple val(meta), path("*.bai"), emit: bai, optional: true
        path "versions.yml"           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def bam_sort = align_bam_sorted ? "samtools sort | samtools view -@${task.cpus} -b -h -o ${prefix}.bam; samtools index -@${task.cpus} ${prefix}.bam" : "samtools view -@${task.cpus} -b -h -o ${prefix}.bam"
        def bam_output = bam_format ? "-a | ${bam_sort}" : "-o ${prefix}.paf"
        def cigar_paf = cigar_paf_format && !bam_format ? "-c" : ''
        def set_cigar_bam = cigar_bam && bam_format ? "-L" : ''
        """
        minimap2 \\
            $args \\
            -t $task.cpus \\
            "${reference ?: reads}" \\
            "$reads" \\
            $cigar_paf \\
            $set_cigar_bam \\
            $bam_output

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            minimap2: \$(minimap2 --version 2>&1)
            samtools: \$(samtools version | head -n1 | sed -e 's/samtools //' 2>&1)
        END_VERSIONS
    """
}