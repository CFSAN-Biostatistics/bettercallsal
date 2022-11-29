process SCAFFOLD_GENOMES {
    tag "fasta_join.pl"
    label "process_nano"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}perl${params.fs}5.30.0" : null)
    conda (params.enable_conda ? "conda-forge::perl bioconda::perl-bioperl=1.7.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl-bioperl:1.7.8--hdfd78af_1' :
        'quay.io/biocontainers/perl-bioperl:1.7.8--hdfd78af_1' }"

    input:
        path acc_chunk_file

    output:
        val "${params.output}${params.fs}scaffold_genomes", emit: genomes_dir
        path '*_scaffolded_genomic.fna.gz'                , emit: scaffolded
        path 'versions.yml'                               , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        datasets download genome accession \\
            --dehydrated \\
            --inputfile $acc_chunk_file

        unzip ncbi_dataset.zip

        datasets rehydrate \\
            --gzip \\
            --directory "."

        fasta_join.pl -in ncbi_dataset

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            datasets: \$( datasets --version | sed 's/datasets version: //g' )
            perl: \$( perl -e 'print \$^V' | sed 's/v//g' )
            bioperl: \$(perl -MBio::Root::Version -e 'print \$Bio::Root::Version::VERSION')
        END_VERSIONS

        zcmd=""
        zver=""

        if type pigz > /dev/null 2>&1; then
            zcmd="pigz"
            zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed -e '1!d' | sed "s/\$zcmd //" )
        elif type gzip > /dev/null 2>&1; then
            zcmd="gzip"
        
            if [ "${workflow.containerEngine}" != "null" ]; then
                zver=\$( echo \$( \$zcmd --help 2>&1 ) | sed -e '1!d; s/ (.*\$//' )
            else
                zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed "s/^.*(\$zcmd) //; s/\$zcmd //; s/ Copyright.*\$//" )
            fi
        fi

        cat <<-END_VERSIONS >> versions.yml
            \$zcmd: \$zver
        END_VERSIONS
        """
}