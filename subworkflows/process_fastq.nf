// Include any necessary methods and modules
include { stopNow; validateParamsForFASTQ } from "${params.routines}"
include { GEN_SAMPLESHEET                 } from "${params.modules}${params.fs}gen_samplesheet${params.fs}main"
include { SAMPLESHEET_CHECK               } from "${params.modules}${params.fs}samplesheet_check${params.fs}main"
include { CAT_FASTQ                       } from "${params.modules}${params.fs}cat${params.fs}fastq${params.fs}main"
include { SEQKIT_SEQ                      } from "${params.modules}${params.fs}seqkit${params.fs}seq${params.fs}main"

// Validate 4 required workflow parameters if
// FASTQ files are the input for the
// entry point.
validateParamsForFASTQ()

// Start the subworkflow
workflow PROCESS_FASTQ {
    main:
        versions = Channel.empty()
        input_ch = Channel.empty()
        reads = Channel.empty()

        def input = file( (params.input ?: params.metadata) )

        if (params.input) {
            def fastq_files = []

            if (params.fq_suffix == null) {
            stopNow("We need to know what suffix the FASTQ files ends with inside the\n" +
                "directory. Please use the --fq_suffix option to indicate the file\n" +
                "suffix by which the files are to be collected to run the pipeline on.")
            }

            if (params.fq_strandedness == null) {
                stopNow("We need to know if the FASTQ files inside the directory\n" +
                    "are sequenced using stranded or non-stranded sequencing. This is generally\n" +
                    "required if the sequencing experiment is RNA-SEQ. For almost all of the other\n" +
                    "cases, you can probably use the --fq_strandedness unstranded option to indicate\n" +
                    "that the reads are unstranded.")
            }

            if (params.fq_filename_delim == null || params.fq_filename_delim_idx == null) {
                stopNow("We need to know the delimiter of the filename of the FASTQ files.\n" +
                    "By default the filename delimiter is _ (underscore). This delimiter character\n" +
                    "is used to split and assign a group name. The group name can be controlled by\n" +
                    "using the --fq_filename_delim_idx option (1-based). For example, if the FASTQ\n" +
                    "filename is WT_REP1_001.fastq, then to create a group WT, use the following\n" +
                    "options: --fq_filename_delim _ --fq_filename_delim_idx 1")
            }

            if (!input.exists()) {
                stopNow("The input directory,\n${params.input}\ndoes not exist!")
            }

            input.eachFileRecurse {
                it.name.endsWith("${params.fq_suffix}") ? fastq_files << it : fastq_files << null
            }

            if (fastq_files.findAll{ it != null }.size() == 0) {
                stopNow("The input directory,\n${params.input}\nis empty! or does not " +
                    "have FASTQ files ending with the suffix: ${params.fq_suffix}")
            }
            
            GEN_SAMPLESHEET( Channel.fromPath(params.input, type: 'dir') )
            GEN_SAMPLESHEET.out.csv.set{ input_ch }
            versions.mix( GEN_SAMPLESHEET.out.versions )
                .set { versions }
        } else if (params.metadata) {
            if (!input.exists()) {
                stopNow("The metadata CSV file,\n${params.metadata}\ndoes not exist!")
            }

            if (input.size() <= 0) {
                stopNow("The metadata CSV file,\n${params.metadata}\nis empty!")
            }

            Channel.fromPath(params.metadata, type: 'file')
                .set { input_ch }
        }

        SAMPLESHEET_CHECK( input_ch )
            .csv
            .splitCsv( header: true, sep: ',')
            .map { create_fastq_channel(it) }
            .groupTuple(by: [0])
            .branch {
                meta, fastq ->
                    single   : fastq.size() == 1
                        return [ meta, fastq.flatten() ]
                    multiple : fastq.size() > 1
                        return [ meta, fastq.flatten() ]
            }
            .set { reads }

        CAT_FASTQ( reads.multiple )
            .catted_reads
            .mix( reads.single )
            .set { processed_reads }

        if (params.fq_filter_by_len.toInteger() > 0) {
            SEQKIT_SEQ( processed_reads )
                .fastx
                .set { processed_reads }

            versions.mix( SEQKIT_SEQ.out.versions.first().ifEmpty(null) )
                .set { versions }
        }

        versions.mix(
            SAMPLESHEET_CHECK.out.versions,
            CAT_FASTQ.out.versions.first().ifEmpty(null)
        )
        .set { versions }

    emit:
        processed_reads
        versions
}

// Function to get list of [ meta, [ fq1, fq2 ] ]
def create_fastq_channel(LinkedHashMap row) {

    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = row.single_end.toBoolean()
    meta.strandedness = row.strandedness
    meta.id = meta.id.split(params.fq_filename_delim)[0..params.fq_filename_delim_idx.toInteger() - 1]
        .join(params.fq_filename_delim)
    meta.id = (meta.id =~ /\./ ? meta.id.take(meta.id.indexOf('.')) : meta.id)

    def array = []

    if (!file(row.fq1).exists()) {
        stopNow("Please check input metadata CSV. The following Read 1 FASTQ file does not exist!" +
            "\n${row.fq1}")
    }
    if (meta.single_end) {
        array = [ meta, [ file(row.fq1) ] ]
    } else {
        if (!file(row.fq2).exists()) {
            stopNow("Please check input metadata CSV. The following Read 2 FASTQ file does not exist!" +
                "\n${row.fq2}")
        }
        array = [ meta, [ file(row.fq1), file(row.fq2) ] ]
    }
    return array
}