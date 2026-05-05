process TREE_METADATA {
    tag "$tuspy.id"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.10.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.4' :
        'quay.io/biocontainers/python:3.10.4' }"
    
    input:
        tuple val(tuspy), path(uniq_genome_hits)

    output:
        tuple val(tuspy), path("*METADATA.csv"), emit: metadata
        tuple val(tuspy), path("*.fofn")       , emit: fofn
        path "versions.yml"                    , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args        = task.ext.args ?: ''
        def gds_defined = (tuspy.gds ?: "false")
        def gd_defined  = (tuspy.gd ?: "false")
        def pdg_dir     = (tuspy.pdg_dir ?: "false")
        """
        meta_pickle="BCS_IDXD_METAD"
        meta_pickle_ws="\${meta_pickle}.pickle"
        out_file="BCS_UNIQ_METADATA.csv"
        genomes_fofn="BCS_GENOMES.fofn"
        touch \$out_file

        if [[ "$pdg_dir" != "false" && -s "$uniq_genome_hits" ]]; then
            index_pdg_metadata.py -pdg_dir $pdg_dir -op "\$meta_pickle"

            if [[ -e "\$meta_pickle_ws" && -f "\$meta_pickle_ws" && -s "\$meta_pickle_ws" ]]; then
                gen_bcs_db_metadata.py -pickle "\$meta_pickle_ws" -hits $uniq_genome_hits -out \$out_file
                rm \$meta_pickle_ws || exit 1

                if [[ "$gds_defined" != "false" && "$gd_defined" != "false" ]]; then
                    while read -r acc; do
                        echo -e "$gd_defined/\${acc}$gds_defined" >> \$genomes_fofn
                    done < "$uniq_genome_hits"
                fi
            else
                echo "Unable to parse \$meta_pickle_ws" > \$out_file
            fi
        else
            echo "No genome hits in any samples" > \$out_file
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
        END_VERSIONS
        """
}