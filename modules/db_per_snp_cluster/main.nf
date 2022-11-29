process DB_PER_SNP_CLUSTER {
    tag "waterfall_per_snp_cluster.pl"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}perl${params.fs}5.30.0" : null)
    conda (params.enable_conda ? "conda-forge::perl bioconda::perl-bioperl=1.7.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl-bioperl:1.7.8--hdfd78af_1' :
        'quay.io/biocontainers/perl-bioperl:1.7.8--hdfd78af_1' }"

    input:
        path accs_tbl
        path pdg_metadata
        path snp_cluster_metadata

    output:
        path '*asm_chunk_snp.tbl'       , emit: asm_chunk_snp_tbl
        path '*asm_chunk_snp_counts.tbl', emit: asm_chunk_snp_counts
        path '*accs_snp.txt'            , emit: accs_snp
        path 'mash_snp_genome_list.txt' , emit: genome_paths
        path 'versions.yml'             , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.index ?: ''
        """
        waterfall_per_snp_cluster.pl \\
            -p $pdg_metadata \\
            -t $accs_tbl \\
            -snp $snp_cluster_metadata \\
            $args \\
            1> asm_chunk_snp.tbl 2> asm_chunk_snp_counts.tbl

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            perl: \$( perl -e 'print \$^V' | sed 's/v//g' )
            bioperl: \$(perl -MBio::Root::Version -e 'print \$Bio::Root::Version::VERSION')
        END_VERSIONS
        """
}