// Define any required imports for this specific workflow
import java.nio.file.Paths
import java.util.zip.GZIPInputStream
import java.io.FileInputStream
import nextflow.file.FileHelper


// Include any necessary methods
include { \
    summaryOfParams; stopNow; fastqEntryPointHelp; sendMail; conciseHelp; \
    addPadding; wrapUpHelp     } from "${params.routines}"
include { bbmergeHelp          } from "${params.toolshelp}${params.fs}bbmerge"
include { fastpHelp            } from "${params.toolshelp}${params.fs}fastp"
include { mashscreenHelp       } from "${params.toolshelp}${params.fs}mashscreen"
include { tuspyHelp            } from "${params.toolshelp}${params.fs}tuspy"
include { sourmashsketchHelp   } from "${params.toolshelp}${params.fs}sourmashsketch"
include { sourmashgatherHelp   } from "${params.toolshelp}${params.fs}sourmashgather"
include { sourmashsearchHelp   } from "${params.toolshelp}${params.fs}sourmashsearch"
include { sfhpyHelp            } from "${params.toolshelp}${params.fs}sfhpy"
include { kmaindexHelp         } from "${params.toolshelp}${params.fs}kmaindex"
include { kmaalignHelp         } from "${params.toolshelp}${params.fs}kmaalign"
include { megahitHelp          } from "${params.toolshelp}${params.fs}megahit"
include { mlstHelp             } from "${params.toolshelp}${params.fs}mlst"
include { abricateHelp         } from "${params.toolshelp}${params.fs}abricate"
include { salmonidxHelp        } from "${params.toolshelp}${params.fs}salmonidx"
include { gsrpyHelp            } from "${params.toolshelp}${params.fs}gsrpy"

// Exit if help requested before any subworkflows
if (params.help) {
    log.info help()
    exit 0
}


// Include any necessary modules and subworkflows
include { PROCESS_FASTQ           } from "${params.subworkflows}${params.fs}process_fastq"
include { CAT_CAT                 } from "${params.modules}${params.fs}cat_cat${params.fs}main"
include { FASTQC                  } from "${params.modules}${params.fs}fastqc${params.fs}main"
include { BBTOOLS_BBMERGE         } from "${params.modules}${params.fs}bbtools${params.fs}bbmerge${params.fs}main"
include { FASTP                   } from "${params.modules}${params.fs}fastp${params.fs}main"
include { MASH_SCREEN             } from "${params.modules}${params.fs}mash${params.fs}screen${params.fs}main"
include { TOP_UNIQUE_SEROVARS     } from "${params.modules}${params.fs}top_unique_serovars${params.fs}main"
include { SOURMASH_SKETCH         } from "${params.modules}${params.fs}sourmash${params.fs}sketch${params.fs}main"
include { SOURMASH_GATHER         } from "${params.modules}${params.fs}sourmash${params.fs}gather${params.fs}main"
include { SOURMASH_SEARCH         } from "${params.modules}${params.fs}sourmash${params.fs}search${params.fs}main"
include { KMA_INDEX               } from "${params.modules}${params.fs}kma${params.fs}index${params.fs}main"
include { KMA_ALIGN               } from "${params.modules}${params.fs}kma${params.fs}align${params.fs}main"
include { OTF_GENOME              } from "${params.modules}${params.fs}otf_genome${params.fs}main"
include { MEGAHIT_ASSEMBLE        } from "${params.modules}${params.fs}megahit${params.fs}assemble${params.fs}main"
include { MLST                    } from "${params.modules}${params.fs}mlst${params.fs}main"
include { ABRICATE_RUN            } from "${params.modules}${params.fs}abricate${params.fs}run${params.fs}main"
include { ABRICATE_SUMMARY        } from "${params.modules}${params.fs}abricate${params.fs}summary${params.fs}main"
include { TABLE_SUMMARY           } from "${params.modules}${params.fs}cat${params.fs}tables${params.fs}main"
include { SALMON_INDEX            } from "${params.modules}${params.fs}salmon${params.fs}index${params.fs}main"
include { SALMON_QUANT            } from "${params.modules}${params.fs}salmon${params.fs}quant${params.fs}main"
include { SOURMASH_COMPARE        } from "${params.modules}${params.fs}custom${params.fs}sourmash${params.fs}compare${params.fs}main"
include { BCS_DISTANCE_MATRIX     } from "${params.modules}${params.fs}bcs_distance_matrix${params.fs}main"
include { BCS_RESULTS             } from "${params.modules}${params.fs}bcs_results${params.fs}main"
include { DUMP_SOFTWARE_VERSIONS  } from "${params.modules}${params.fs}custom${params.fs}dump_software_versions${params.fs}main"
include { MULTIQC                 } from "${params.modules}${params.fs}multiqc${params.fs}main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS AND ANY CHECKS FOR THE BETTERCALLSAL WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def reads_platform = 0
def salmon_idx_decoys = file ( "${params.salmonidx_decoys}" )
def abricate_dbs = [ 'ncbiamrplus', 'resfinder', 'megares', 'argannot' ]

reads_platform += (params.input ? 1 : 0)

if (reads_platform < 1 || reads_platform == 0) {
    stopNow("Please mention at least one absolute path to input folder which contains\n" +
            "FASTQ files sequenced using the --input option.\n" +
        "Ex: --input (Illumina or Generic short reads in FASTQ format)")
}

checkMetadataExists(params.mash_sketch, 'MASH sketch')
checkMetadataExists(params.tuspy_ps, 'ACC2SERO pickle')
checkMetadataExists(params.gsrpy_snp_clus_metadata, 'PDG reference target cluster metadata')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN THE BETTERCALLSAL WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BETTERCALLSAL {
    main:
        log.info summaryOfParams()

        PROCESS_FASTQ()

        PROCESS_FASTQ
            .out
            .versions
            .set { software_versions }

        PROCESS_FASTQ
            .out
            .processed_reads
            .set { ch_processed_reads }

        if (params.bbmerge_run && !params.fq_single_end) {
            ch_processed_reads
                .map { meta, fastq ->
                    meta.adapters = (params.bbmerge_adapters ?: params.dummyfile)
                    [ meta, fastq ]
                }
                .set { ch_processed_reads }
            
            BBTOOLS_BBMERGE( ch_processed_reads )

            BBTOOLS_BBMERGE
                .out
                .fastq
                .map { meta, fastq -> [ meta, [ fastq ] ] }
                .set { ch_processed_reads }

            software_versions
                .mix ( BBTOOLS_BBMERGE.out.versions )
                .set { software_versions }
        }

        if (params.fastp_run) {
            FASTP ( ch_processed_reads )

            FASTP
                .out
                .passed_reads
                .set { ch_processed_reads }

            FASTP
                .out
                .json
                .map { meta, json -> [ json ] }
                .collect()
                .set { ch_multiqc }

            software_versions
                .mix ( FASTP.out.versions )
                .set { software_versions }
        } else {
            FASTQC ( ch_processed_reads )

            FASTQC
                .out
                .zip
                .map { meta, zip -> [ zip ] }
                .collect()
                .set { ch_multiqc }

            software_versions
                .mix ( FASTQC.out.versions )
                .set { software_versions }
        }

        if (params.bcs_concat_pe && !params.fq_single_end && !params.bbmerge_run) {
            CAT_CAT ( ch_processed_reads )

            CAT_CAT
                .out
                .concatenated_reads
                .set { ch_processed_reads }

            software_versions
                .mix ( CAT_CAT.out.versions )
                .set { software_versions }
        }

        ch_processed_reads
            .map { meta, fastq ->
                meta.sequence_sketch = params.mash_sketch
                meta.get_kma_hit_accs = true
                meta.single_end = true
                meta.salmon_decoys = params.dummyfile
                meta.salmon_lib_type = (params.salmonalign_libtype ?: false)
                [ meta, fastq ]
            }
            .filter { meta, fastq ->
                fq_file = ( fastq.getClass().toString() =~ /ArrayList/ ? fastq : [ fastq ] )
                fq_gzip = new GZIPInputStream( new FileInputStream( fq_file[0].toString() ) )
                fq_gzip.read() != -1
            }
            .set { ch_processed_reads }

        MASH_SCREEN ( ch_processed_reads )

        TOP_UNIQUE_SEROVARS ( MASH_SCREEN.out.screened )
        
        TOP_UNIQUE_SEROVARS.out.genomes_fasta
            .set { ch_genomes_fasta }

        TOP_UNIQUE_SEROVARS.out.failed
            .set { ch_bcs_calls_failed }

        if (params.sourmashgather_run || params.sourmashsearch_run) {
            SOURMASH_SKETCH (
                ch_processed_reads
                    .join ( ch_genomes_fasta )
            )

            if (params.sourmashgather_run) {
                SOURMASH_GATHER (
                    SOURMASH_SKETCH.out.signatures,
                    [], [], [], []
                )

                SOURMASH_GATHER
                    .out
                    .genomes_fasta
                    .set { ch_genomes_fasta }

                ch_bcs_calls_failed
                    .concat ( SOURMASH_GATHER.out.failed )
                    .set { ch_bcs_calls_failed }

                software_versions
                    .mix ( SOURMASH_GATHER.out.versions.ifEmpty(null) )
                    .set { software_versions }
            }

            if (params.sourmashsearch_run) {
                SOURMASH_SEARCH (
                    SOURMASH_SKETCH.out.signatures,
                    []
                )

                SOURMASH_SEARCH
                    .out
                    .genomes_fasta
                    .set { ch_genomes_fasta }

                ch_bcs_calls_failed
                    .concat ( SOURMASH_SEARCH.out.failed )
                    .set { ch_bcs_calls_failed }

                software_versions
                    .mix ( SOURMASH_SEARCH.out.versions.ifEmpty(null) )
                    .set { software_versions }
            }
        }

        KMA_INDEX ( ch_genomes_fasta )

        KMA_ALIGN ( 
            ch_processed_reads
                .join ( KMA_INDEX.out.idx )
        )

        OTF_GENOME (
            KMA_ALIGN.out.hits
                .join ( KMA_ALIGN.out.frags )
        )

        OTF_GENOME.out.failed
            .concat ( ch_bcs_calls_failed )
            .collectFile( name: 'BCS_NO_CALLS.txt' )
            .set { ch_bcs_no_calls }

        SALMON_INDEX ( OTF_GENOME.out.genomes_fasta )

        SALMON_QUANT (
            ch_processed_reads
                .join ( SALMON_INDEX.out.idx )
        )

        SALMON_QUANT
            .out
            .results
            .groupTuple(by: [0])
            .map { it -> tuple ( it[1].flatten() ) }
            .mix ( ch_bcs_no_calls )
            .collect()
            .set { ch_salmon_res_dirs }

        if (params.sourmashsketch_run) {
            SOURMASH_SKETCH
                .out
                .signatures
                .groupTuple(by: [0])
                .map { meta, qsigs, dsigs -> [ qsigs ] }
                .collect()
                .flatten()
                .collect()
                .set { ch_query_sigs }

            KMA_ALIGN
                .out
                .hits
                .map { meta, hits -> [ hits ] }
                .collect()
                .flatten()
                .collectFile(name: 'accessions.txt')
                .set { ch_otf_genomes }

            if (params.megahit_run) {

                MEGAHIT_ASSEMBLE ( OTF_GENOME.out.reads_extracted )

                MEGAHIT_ASSEMBLE
                    .out
                    .assembly
                    .set { ch_asm_filtered_contigs }

                MLST ( ch_asm_filtered_contigs )

                MLST.out.tsv
                    .map { meta, tsv -> [ 'mlst', tsv] }
                    .groupTuple(by: [0])
                    .map { it -> tuple ( it[0], it[1].flatten() ) }
                    .set { ch_mqc_custom_tbl }

                ABRICATE_RUN ( 
                    ch_asm_filtered_contigs, 
                    abricate_dbs
                )

                ABRICATE_RUN
                    .out
                    .abricated
                    .map { meta, abres -> [ abricate_dbs, abres ] }
                    .groupTuple(by: [0])
                    .map { it -> tuple ( it[0], it[1].flatten() ) }
                    .set { ch_abricated }

                ABRICATE_SUMMARY ( ch_abricated )

                ch_mqc_custom_tbl
                    .concat (
                        ABRICATE_SUMMARY.out.ncbiamrplus.map { it -> tuple ( it[0], it[1] )},
                        ABRICATE_SUMMARY.out.resfinder.map { it -> tuple ( it[0], it[1] )},
                        ABRICATE_SUMMARY.out.megares.map { it -> tuple ( it[0], it[1] )},
                        ABRICATE_SUMMARY.out.argannot.map { it -> tuple ( it[0], it[1] )},
                    )
                    .groupTuple(by: [0])
                    .map { it -> [ it[0], it[1].flatten() ]}
                    .set { ch_mqc_custom_tbl }

                TABLE_SUMMARY ( ch_mqc_custom_tbl )

                ch_multiqc
                    .concat ( TABLE_SUMMARY.out.mqc_yml )
                    .set { ch_multiqc }

                software_versions
                    .mix (
                        MEGAHIT_ASSEMBLE.out.versions.ifEmpty(null),
                        MLST.out.versions.ifEmpty(null),
                        ABRICATE_RUN.out.versions.ifEmpty(null),
                        ABRICATE_SUMMARY.out.versions.ifEmpty(null),
                        TABLE_SUMMARY.out.versions.ifEmpty(null)
                    )
                    .set { software_versions }
            }

            SOURMASH_COMPARE ( ch_query_sigs, ch_otf_genomes )

            BCS_DISTANCE_MATRIX (
                SOURMASH_COMPARE.out.matrix,
                SOURMASH_COMPARE.out.labels
            )

            ch_multiqc
                .concat ( BCS_DISTANCE_MATRIX.out.mqc_yml )
                .set { ch_multiqc }

            software_versions
                .mix (
                    SOURMASH_SKETCH.out.versions.ifEmpty(null),
                    SOURMASH_COMPARE.out.versions.ifEmpty(null),
                    BCS_DISTANCE_MATRIX.out.versions.ifEmpty(null),
                )
                .set { software_versions }
        }

        BCS_RESULTS ( ch_salmon_res_dirs )

        DUMP_SOFTWARE_VERSIONS (
            software_versions
                .mix (
                    MASH_SCREEN.out.versions,
                    TOP_UNIQUE_SEROVARS.out.versions,
                    KMA_INDEX.out.versions,
                    KMA_ALIGN.out.versions,
                    OTF_GENOME.out.versions.ifEmpty(null),
                    SALMON_INDEX.out.versions,
                    SALMON_QUANT.out.versions,
                    BCS_RESULTS.out.versions
                )
                .unique()
                .collectFile(name: 'collected_versions.yml')
        )

        DUMP_SOFTWARE_VERSIONS
            .out
            .mqc_yml
            .concat (
                ch_multiqc,
                BCS_RESULTS.out.mqc_yml,
                BCS_RESULTS.out.mqc_json
            )
            .collect()
            .set { ch_multiqc }

        MULTIQC ( ch_multiqc )
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
    METHOD TO CHECK METADATA EXISTENCE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def checkMetadataExists(file_path, msg) {
    file_path_obj = file( file_path )

    if (!file_path_obj.exists() || file_path_obj.size() == 0) {
        stopNow("Please check if your ${msg} file\n" +
            "[ ${file_path} ]\nexists and is not of size 0.")
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP TEXT METHODS FOR BETTERCALLSAL WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def help() {

    Map helptext = [:]
    Map bcsConcatHelp = [:]
    Map fastpAdapterHelp = [:]
    Map nH = [:]
    def uHelp = (params.help.getClass().toString() =~ /String/ ? params.help.tokenize(',').join(' ') : '')

    Map defaultHelp = [
        '--help bbmerge'          : 'Show bbmerge.sh CLI options',
        '--help fastp'            : 'Show fastp CLI options',
        '--help mash'             : 'Show mash `screen` CLI options',
        '--help tuspy'            : 'Show get_top_unique_mash_hit_genomes.py CLI options',
        '--help sourmashsketch'   : 'Show sourmash `sketch` CLI options',
        '--help sourmashgather'   : 'Show sourmash `gather` CLI options',
        '--help sourmashsearch'   : 'Show sourmash `search` CLI options',
        '--help sfhpy'            : 'Show sourmash_filter_hits.py CLI options',
        '--help kmaindex'         : 'Show kma `index` CLI options',
        '--help kmaalign'         : 'Show kma CLI options',
        '--help megahit'          : 'Show megahit CLI options',
        '--help mlst'             : 'Show mlst CLI options',
        '--help abricate'         : 'Show abricate CLI options',
        '--help salmon'           : 'Show salmon `index` CLI options',
        '--help gsrpy'            : 'Show gen_salmon_res_table.py CLI options\n'
    ]

    bcsConcatHelp['--bcs_concat_pe'] = "Concatenate paired-end files. " +
        "Default: ${params.bcs_concat_pe}"

    fastpAdapterHelp['--fastp_use_custom_adapaters'] = "Use custom adapter FASTA with fastp on top of " +
        "built-in adapter sequence auto-detection. Enabling this option will attempt to find and remove " +
        "all possible Illumina adapter and primer sequences but will make the workflow run slow. " +
        "Default: ${params.fastp_use_custom_adapters}"

    if (params.help.getClass().toString() =~ /Boolean/ || uHelp.size() == 0) {
        println conciseHelp('fastp,mash')
        helptext.putAll(defaultHelp)
    } else {
        params.help.tokenize(',').each { h ->
            if (defaultHelp.keySet().findAll{ it =~ /(?i)\b${h}\b/ }.size() == 0) {
                println conciseHelp('fastp,mash')
                stopNow("Tool [ ${h} ] is not a part of ${params.pipeline} pipeline.")
            }
        }

        helptext.putAll(
            fastqEntryPointHelp() +
            bcsConcatHelp +
            (uHelp =~ /(?i)\bbbmerge/ ? bbmergeHelp(params).text : nH) +
            (uHelp =~ /(?i)\bfastp/ ? fastpHelp(params).text + fastpAdapterHelp : nH) +
            (uHelp =~ /(?i)\bmash/ ? mashscreenHelp(params).text : nH) +
            (uHelp =~ /(?i)\btuspy/ ? tuspyHelp(params).text : nH) +
            (uHelp =~ /(?i)\bsourmashsketch/ ? sourmashsketchHelp(params).text : nH) +
            (uHelp =~ /(?i)\bsourmashgather/ ? sourmashgatherHelp(params).text : nH) +
            (uHelp =~ /(?i)\bsourmashsearch/ ? sourmashsearchHelp(params).text : nH) +
            (uHelp =~ /(?i)\bsfhpy/ ? sfhpyHelp(params).text : nH) +
            (uHelp =~ /(?i)\bkmaindex/ ? kmaindexHelp(params).text : nH) +
            (uHelp =~ /(?i)\bkmaalign/ ? kmaalignHelp(params).text : nH) +
            (uHelp =~ /(?i)\bmegahit/ ? megahitHelp(params).text : nH) +
            (uHelp =~ /(?i)\bmlst/ ? mlstHelp(params).text : nH) +
            (uHelp =~ /(?i)\babricate/ ? abricateHelp(params).text : nH) +
            (uHelp =~ /(?i)\bsalmon/ ? salmonidxHelp(params).text : nH) +
            (uHelp =~ /(?i)\bgsrpy/ ? gsrpyHelp(params).text : nH) +
            wrapUpHelp()
        )
    }

    return addPadding(helptext)
}