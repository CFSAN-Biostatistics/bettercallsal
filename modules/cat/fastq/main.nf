process CAT_FASTQ {
    tag "$meta.id"
    label 'process_micro'

    conda (params.enable_conda ? "conda-forge::sed=4.7 conda-forge::gzip" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://containers.biocontainers.pro/s3/SingImgsRepo/biocontainers/v1.2.0_cv1/biocontainers_v1.2.0_cv1.img' :
        'biocontainers/biocontainers:v1.2.0_cv1' }"

    input:
        tuple val(meta), path(reads, stageAs: "input*/*")

    output:
        tuple val(meta), path("*.merged.fastq.gz"), emit: catted_reads
        path "versions.yml"                       , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def readList = reads.collect{ it.toString() }
        def is_in_gz = readList[0].endsWith('.gz')
        def gz_or_ungz = (is_in_gz ? '' : ' | gzip')
        def pigz_or_ungz = (is_in_gz ? '' : " | pigz -p ${task.cpus}")
        if (meta.single_end) {
            if (readList.size > 1) {
                """
                zcmd="gzip"
                zver=""

                if type pigz > /dev/null 2>&1; then
                    cat ${readList.join(' ')} ${pigz_or_ungz} > ${prefix}.merged.fastq.gz
                    zcmd="pigz"
                    zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed -e '1!d' | sed "s/\$zcmd //" )
                else
                    cat ${readList.join(' ')} ${gz_or_ungz} > ${prefix}.merged.fastq.gz
                    zcmd="gzip"

                    if [ "${workflow.containerEngine}" != "null" ]; then
                        zver=\$( echo \$( \$zcmd --help 2>&1 ) | sed -e '1!d; s/ (.*\$//' )
                    else
                        zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed "s/^.*(\$zcmd) //; s/\$zcmd //; s/ Copyright.*\$//" )
                    fi
                fi

                cat <<-END_VERSIONS > versions.yml
                "${task.process}":
                    cat: \$( echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//' )
                    \$zcmd: \$zver
                END_VERSIONS
                """
            }
        } else {
            if (readList.size > 2) {
                def read1 = []
                def read2 = []
                readList.eachWithIndex{ v, ix -> ( ix & 1 ? read2 : read1 ) << v }
                """
                zcmd="gzip"
                zver=""

                if type pigz > /dev/null 2>&1; then
                    cat ${read1.join(' ')} ${pigz_or_ungz} > ${prefix}_1.merged.fastq.gz
                    cat ${read2.join(' ')} ${pigz_or_ungz} > ${prefix}_2.merged.fastq.gz
                    zcmd="pigz"
                    zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed -e '1!d' | sed "s/\$zcmd //" )
                else
                    cat ${read1.join(' ')} ${gz_or_ungz} > ${prefix}_1.merged.fastq.gz
                    cat ${read2.join(' ')} ${gz_or_ungz} > ${prefix}_2.merged.fastq.gz
                    zcmd="gzip"

                    if [ "${workflow.containerEngine}" != "null" ]; then
                        zver=\$( echo \$( \$zcmd --help 2>&1 ) | sed -e '1!d; s/ (.*\$//' )
                    else
                        zver=\$( echo \$( \$zcmd --version 2>&1 ) | sed "s/^.*(\$zcmd) //; s/\$zcmd //; s/ Copyright.*\$//" )
                    fi
                fi

                cat <<-END_VERSIONS > versions.yml
                "${task.process}":
                    cat: \$( echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//' )
                    \$zcmd: \$zver
                END_VERSIONS
                """
            }
        }
}