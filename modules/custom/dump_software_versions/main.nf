process DUMP_SOFTWARE_VERSIONS {
    tag "${params.pipeline} software versions"
    label 'process_pico'

    // Requires `pyyaml` which does not have a dedicated container but is in the MultiQC container
    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.9 conda-forge::pyyaml" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-ca258a039fcd88610bc4e297b13703e8be53f5ca:d638c4f85566099ea0c74bc8fddc6f531fe56753-0' :
        'quay.io/biocontainers/mulled-v2-ca258a039fcd88610bc4e297b13703e8be53f5ca:d638c4f85566099ea0c74bc8fddc6f531fe56753-0' }"

    input:
    path versions

    output:
    path "software_versions.yml"    , emit: yml
    path "software_versions_mqc.yml", emit: mqc_yml
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    template 'dumpsoftwareversions.py'
}