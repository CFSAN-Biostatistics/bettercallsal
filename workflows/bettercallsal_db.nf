// Define any required imports for this specific workflow
import java.nio.file.Paths
import nextflow.file.FileHelper


// Include any necessary methods
include { \
    fastqEntryPointHelp; summaryOfParams; stopNow; sendMail; \
    addPadding; wrapUpHelp    } from "${params.routines}"
include { wcompHelp           } from "${params.toolshelp}${params.fs}wcomp"
include { wsnpHelp            } from "${params.toolshelp}${params.fs}wsnp"
include { mashsketchHelp      } from "${params.toolshelp}${params.fs}mashsketch"


// Exit if help requested before any subworkflows
if (params.help) {
    log.info help()
    exit 0
}


// Include any necessary modules and subworkflows
include { DOWNLOAD_PDG_METADATA    } from "${params.modules}${params.fs}download_pdg_metadata${params.fs}main"
include { FILTER_PDG_METADATA      } from "${params.modules}${params.fs}filter_pdg_metadata${params.fs}main"
include { DB_PER_COMPUTED_SEROTYPE } from "${params.modules}${params.fs}db_per_computed_serotype${params.fs}main"
include { DB_PER_SNP_CLUSTER       } from "${params.modules}${params.fs}db_per_snp_cluster${params.fs}main"
include { INDEX_METADATA           } from "${params.modules}${params.fs}index_metadata${params.fs}main"
include { SCAFFOLD_GENOMES         } from "${params.modules}${params.fs}scaffold_genomes${params.fs}main"
include { MASH_SKETCH              } from "${params.modules}${params.fs}mash${params.fs}sketch${params.fs}main"
include { DUMP_SOFTWARE_VERSIONS   } from "${params.modules}${params.fs}custom${params.fs}dump_software_versions${params.fs}main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS AND ANY CHECKS FOR THE BETTERCALLSAL_DB WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (!params.output) {
    stopNow("Please mention the absolute UNIX path to store the DB flat files\n" +
            "using the --output option.\n" +
        "Ex: --output /path/to/bettercallsal/db_files")
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN THE BETTERCALLSAL_DB WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BETTERCALLSAL_DB {
    main:
        log.info summaryOfParams()

        DOWNLOAD_PDG_METADATA ( params.pdg_release ?: null )

        DOWNLOAD_PDG_METADATA
            .out
            .versions
            .set { software_versions }

        FILTER_PDG_METADATA (
            DOWNLOAD_PDG_METADATA.out.accs
                .splitText(by: params.genomes_chunk.toInteger() * 10, file: true)
        )

        DB_PER_COMPUTED_SEROTYPE (
            FILTER_PDG_METADATA.out.accs_chunk_tbl
                .collectFile(name: 'per_comp_db_accs.txt'),
            DOWNLOAD_PDG_METADATA.out.pdg_metadata
        )

        DB_PER_SNP_CLUSTER (
            FILTER_PDG_METADATA.out.accs_chunk_tbl
                .collectFile(name: 'per_snp_db_accs.txt'),
            DOWNLOAD_PDG_METADATA.out.pdg_metadata,
            DOWNLOAD_PDG_METADATA.out.snp_cluster_metadata
        )

        DB_PER_COMPUTED_SEROTYPE.out.genome_paths
            .map { query ->
                kv = [:]
                kv['id'] = 'comp'
                [ kv, query ]
            }
            .concat(
                DB_PER_SNP_CLUSTER.out.genome_paths
                    .map { query ->
                        kv = [:]
                        kv['id'] = 'snp'
                        [ kv, query ]
                    }
            )
            .groupTuple(by: [0])
            .set { ch_mash_these_genomes }

        DB_PER_SNP_CLUSTER
            .out
            .asm_chunk_snp_tbl
            .concat( DB_PER_COMPUTED_SEROTYPE.out.asm_chunk_comp_tbl )
            .map { acc -> [ acc.name.find(/\_comp|\_snp/), acc ] }
            .set { ch_index_metadata }

        INDEX_METADATA ( ch_index_metadata )

        DB_PER_COMPUTED_SEROTYPE.out.accs_comp
            .concat( DB_PER_SNP_CLUSTER.out.accs_snp )
            .splitText()
            .collect()
            .flatten()
            .unique()
            .collectFile(name: 'accs_to_download.txt')
            .splitText(by: params.genomes_chunk, file: true)
            .set { ch_accs_to_download }
        
        SCAFFOLD_GENOMES ( ch_accs_to_download )

        SCAFFOLD_GENOMES
            .out
            .genomes_dir
            .toSortedList()
            .flatten()
            .unique()
            .set { ch_genomes_dir }

        MASH_SKETCH ( 
            ch_mash_these_genomes.combine( ch_genomes_dir )
        )

        DUMP_SOFTWARE_VERSIONS (
            software_versions
                .mix (
                    DOWNLOAD_PDG_METADATA.out.versions,
                    FILTER_PDG_METADATA.out.versions,
                    DB_PER_COMPUTED_SEROTYPE.out.versions,
                    DB_PER_SNP_CLUSTER.out.versions,
                    INDEX_METADATA.out.versions,
                    SCAFFOLD_GENOMES.out.versions,
                    MASH_SKETCH.out.versions,
                )
                .unique()
                .collectFile(name: 'collected_versions.yml')
        )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ON COMPLETE, SHOW GORY DETAILS OF ALL PARAMS WHICH WILL BE HELPFUL TO DEBUG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (workflow.success) {
        sendMail()
    }
}

workflow.onError {
    sendMail()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP TEXT METHODS FOR BETTERCALLSAL_DB WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def help() {

    Map helptext = [:]

    helptext.putAll (
        fastqEntryPointHelp().findAll {
            it.key =~ /Required|output|Other|Workflow|Author|Version/
        } +
        wcompHelp(params).text +
        wsnpHelp(params).text +
        mashsketchHelp(params).text + 
        wrapUpHelp()
    )

    return addPadding(helptext)
}
