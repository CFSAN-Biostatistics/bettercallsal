// Hold methods to print:
//      1. Colored logo.
//      2. Summary of parameters.
//      3. Single dashed line.
//      4. Double dashed line.
//

import groovy.json.JsonSlurper
import nextflow.config.ConfigParser
// import groovy.json.JsonOutput

// ASCII logo
def pipelineBanner() {

    def padding = (params.pad) ?: 30
    Map fgcolors = getANSIColors()

    def banner = [
        name: "${fgcolors.magenta}${workflow.manifest.name}${fgcolors.reset}",
        author: "${fgcolors.cyan}${workflow.manifest.author}${fgcolors.reset}",
        // workflow: "${fgcolors.magenta}${params.pipeline}${fgcolors.reset}",
        version:  "${fgcolors.green}${workflow.manifest.version}${fgcolors.reset}",
        center: "${fgcolors.green}${params.center}${fgcolors.reset}",
        pad: padding
    ]

    manifest = addPadding(banner)

    return """${fgcolors.white}${dashedLine(type: '=')}${fgcolors.magenta}
             (o)                  
  ___  _ __   _  _ __    ___  ___ 
 / __|| '_ \\ | || '_ \\  / _ \\/ __|
| (__ | |_) || || |_) ||  __/\\__ \\
 \\___|| .__/ |_|| .__/  \\___||___/
      | |       | |               
      |_|       |_|${fgcolors.reset}
${dashedLine()}
${fgcolors.blue}A collection of modular pipelines at CFSAN, FDA.${fgcolors.reset}
${dashedLine()}
${manifest}
${dashedLine(type: '=')}
""".stripIndent()
}

// Add padding to keys so that
// they indent nicely on the
// terminal
def addPadding(values) {

    def pad = (params.pad) ?: 30
    values.pad = pad

    def padding = values.pad.toInteger()
    def nocapitalize = values.nocapitalize
    def stopnow = values.stopNow
    def help = values.help

    values.removeAll { 
        k, v -> [
            'nocapitalize',
            'pad',
            'stopNow',
            'help'
        ].contains(k)
    }

    values.keySet().each { k ->
        v = values[k]
        s = params.linewidth - (pad + 5)
        if (v.toString().size() > s && !stopnow) {
            def sen = ''
            // v.toString().findAll(/.{1,${s}}\b(?:\W*|\s*)/).each {
            //     sen += ' '.multiply(padding + 2) + it + '\n'
            // }
            v.toString().eachMatch(/.{1,${s}}(?=.*)\b|\w+/) {
                sen += ' '.multiply(padding + 2) + it.trim() + '\n'
            }
            values[k] = (
                help ? sen.replaceAll(/^(\n|\s)*/, '') : sen.trim()
            )
        } else {
            values[k] = (help ? v + "\n" : v)
        }
        k = k.replaceAll(/\./, '_')
    }

    return values.findResults {
        k, v -> nocapitalize ?
            k.padRight(padding) + ': ' + v :
            k.capitalize().padRight(padding) + ': ' + v
    }.join("\n")
}

// Method for error messages
def stopNow(msg) {

    Map fgcolors = getANSIColors()
    Map errors = [:]

    if (msg == null) {
        msg = "Unknown error"
    }

    errors['stopNow'] = true
    errors["${params.cfsanpipename} - ${params.pipeline} - ERROR"] = """
${fgcolors.reset}${dashedLine()}
${fgcolors.red}${msg}${fgcolors.reset}
${dashedLine()}
""".stripIndent()
    // println dashedLine() // defaults to stdout
    // log.info addPadding(errors) // prints to stdout
    exit 1, "\n" + dashedLine() +
        "${fgcolors.red}\n" + addPadding(errors)
}

// Method to validate 4 required parameters
// if input for entry point is FASTQ files
def validateParamsForFASTQ() {
    switch (params) {
        case { params.metadata == null && params.input == null }:
            stopNow("Either metadata CSV file with 5 required columns\n" +
                "in order: sample, fq1, fq2, strandedness, single_end or \n" +
                "input directory of only FASTQ files (gzipped or unzipped) should be provided\n" +
                "using --metadata or --input options.\n" +
                "None of these two options were provided!")
            break
        case { params.metadata != null && params.input != null }:
            stopNow("Either metadata or input directory of FASTQ files\n" +
                "should be provided using --metadata or --input options.\n" +
                "Using both these options is not allowed!")
            break
        case { params.output == null }:
            stopNow("Please mention output directory to store all results " +
                "using --output option!")
            break
    }
    return 1
}

// Method to print summary of parameters 
// before running
def summaryOfParams() {

    def pipeline_specific_config = new ConfigParser().setIgnoreIncludes(true).parse(
        file("${params.workflowsconf}${params.fs}${params.pipeline}.config").text
    )
    Map fgcolors = getANSIColors()
    Map globalparams = [:]
    Map localparams = params.subMap(
        pipeline_specific_config.params.keySet().toList() + params.logtheseparams
    )

    if (localparams !instanceof Map) {
        stopNow("Need a Map of paramters. We got: " + localparams.getClass())
    }

    if (localparams.size() != 0) {
        localparams['nocapitalize'] = true
        globalparams['nocapitalize'] = true
        globalparams['nextflow_version'] = "${nextflow.version}"
        globalparams['nextflow_build'] = "${nextflow.build}"
        globalparams['nextflow_timestamp'] = "${nextflow.timestamp}"
        globalparams['workflow_projectDir'] = "${workflow.projectDir}"
        globalparams['workflow_launchDir'] = "${workflow.launchDir}"
        globalparams['workflow_workDir'] = "${workflow.workDir}"
        globalparams['workflow_container'] = "${workflow.container}"
        globalparams['workflow_containerEngine'] = "${workflow.containerEngine}"
        globalparams['workflow_runName'] = "${workflow.runName}"
        globalparams['workflow_sessionId'] = "${workflow.sessionId}"
        globalparams['workflow_profile'] = "${workflow.profile}"
        globalparams['workflow_start'] = "${workflow.start}"
        globalparams['workflow_commandLine'] = "${workflow.commandLine}"
        return """${dashedLine()}
Summary of the current workflow (${fgcolors.magenta}${params.pipeline}${fgcolors.reset}) parameters
${dashedLine()}
${addPadding(localparams)}
${dashedLine()}
${fgcolors.cyan}N E X T F L O W${fgcolors.reset} - ${fgcolors.magenta}${params.cfsanpipename}${fgcolors.reset} - Runtime metadata
${dashedLine()}
${addPadding(globalparams)}
${dashedLine()}""".stripIndent()
    }
    return 1
}

// Method to display
// Return dashed line either '-'
// type or '=' type
def dashedLine(Map defaults = [:]) {

    Map fgcolors = getANSIColors()
    def line = [color: 'white', type: '-']

    if (!defaults.isEmpty()) {
        line.putAll(defaults)
    }

    return fgcolors."${line.color}" + 
        "${line.type}".multiply(params.linewidth) +
        fgcolors.reset
}

// Return slurped keys parsed from JSON
def slurpJson(file) {
    def slurped = null
    def jsonInst = new JsonSlurper()

    try {
        slurped = jsonInst.parse(new File ("${file}"))
    }
    catch (Exception e) {
        log.error 'Please check your JSON schema. Invalid JSON file: ' + file
    }

    // Declare globals for the nanofactory
    // workflow.
    return [keys: slurped.keySet().toList(), cparams: slurped]
}

// Default help text in a map if the entry point
// to a pipeline is FASTQ files.
def fastqEntryPointHelp() {

    Map helptext = [:]
    Map fgcolors = getANSIColors()

    helptext['Workflow'] =  "${fgcolors.magenta}${params.pipeline}${fgcolors.reset}"
    helptext['Author'] =  "${fgcolors.cyan}${params.workflow_built_by}${fgcolors.reset}"
    helptext['Version'] = "${fgcolors.green}${params.workflow_version}${fgcolors.reset}\n"
    helptext['Usage'] = "cpipes --pipeline ${params.pipeline} [options]\n"
    helptext['Required'] = ""
    helptext['--input'] = "Absolute path to directory containing FASTQ files. " +
        "The directory should contain only FASTQ files as all the " +
        "files within the mentioned directory will be read. " +
        "Ex: --input /path/to/fastq_pass"
    helptext['--output'] = "Absolute path to directory where all the pipeline " +
        "outputs should be stored. Ex: --output /path/to/output"
    helptext['Other options'] = ""
    helptext['--metadata'] = "Absolute path to metadata CSV file containing five " +
        "mandatory columns: sample,fq1,fq2,strandedness,single_end. The fq1 and fq2 " +
        "columns contain absolute paths to the FASTQ files. This option can be used in place " +
        "of --input option. This is rare. Ex: --metadata samplesheet.csv"
    helptext['--fq_suffix'] = "The suffix of FASTQ files (Unpaired reads or R1 reads or Long reads) if " +
        "an input directory is mentioned via --input option. Default: ${params.fq_suffix}"
    helptext['--fq2_suffix'] = "The suffix of FASTQ files (Paired-end reads or R2 reads) if an input directory is mentioned via " +
        "--input option. Default: ${params.fq2_suffix}"
    helptext['--fq_filter_by_len'] = "Remove FASTQ reads that are less than this many bases. " +
        "Default: ${params.fq_filter_by_len}"
    helptext['--fq_strandedness'] = "The strandedness of the sequencing run. This is mostly needed " +
        "if your sequencing run is RNA-SEQ. For most of the other runs, it is probably safe to use " +
        "unstranded for the option. Default: ${params.fq_strandedness}"
    helptext['--fq_single_end'] = "SINGLE-END information will be auto-detected but this option forces " +
        "PAIRED-END FASTQ files to be treated as SINGLE-END so only read 1 information is included in " +
        "auto-generated samplesheet. Default: ${params.fq_single_end}"
    helptext['--fq_filename_delim'] = "Delimiter by which the file name is split to obtain sample name. " +
        "Default: ${params.fq_filename_delim}"
    helptext['--fq_filename_delim_idx'] = "After splitting FASTQ file name by using the --fq_filename_delim option," +
        " all elements before this index (1-based) will be joined to create final sample name." + 
        " Default: ${params.fq_filename_delim_idx}"

    return helptext
}

// Wrap help text with the following options
def wrapUpHelp() {

    return [
        'Help options' : "",
        '--help': "Display this message.\n",
        'help': true,
        'nocapitalize': true
    ]
}

// Method to send email on workflow complete.
def sendMail() {

    if (params.user_email == null) {
        return 1
    }

    def pad = (params.pad) ?: 30
    def contact_emails = [
        stakeholder: (params.workflow_blueprint_by ?: 'Not defined'),
        author: (params.workflow_built_by ?: 'Not defined')
    ]
    def msg = """
${pipelineBanner()}
${summaryOfParams()}
${params.cfsanpipename} - ${params.pipeline}
${dashedLine()}
Please check the following directory for N E X T F L O W
reports. You can view the HTML files directly by double clicking
them on your workstation.
${dashedLine()}
${params.tracereportsdir}
${dashedLine()}
Please send any bug reports to CFSAN Dev Team or the author or
the stakeholder of the current pipeline.
${dashedLine()}
Error messages (if any)
${dashedLine()}
${workflow.errorMessage}
${workflow.errorReport}
${dashedLine()}
Contact emails
${dashedLine()}
${addPadding(contact_emails)}
${dashedLine()}
Thank you for using ${params.cfsanpipename} - ${params.pipeline}!
${dashedLine()}
""".stripIndent()

    def mail_cmd = [
        'sendmail',
        '-f', 'noreply@gmail.com',
        '-F', 'noreply',
        '-t', "${params.user_email}"
    ]

    def email_subject = "${params.cfsanpipename} - ${params.pipeline}"
    Map fgcolors = getANSIColors()

    if (workflow.success) {
        email_subject += ' completed successfully!'
    }
    else if (!workflow.success) {
        email_subject += ' has failed!'
    }

    try {
        ['env', 'bash'].execute() << """${mail_cmd.join(' ')}
Subject: ${email_subject}
Mime-Version: 1.0
Content-Type: text/html
<pre>
${msg.replaceAll(/\x1b\[[0-9;]*m/, '')}
</pre>
""".stripIndent()
    } catch (all) {
        def warning_msg = "${fgcolors.yellow}${params.cfsanpipename} - ${params.pipeline} - WARNING"
            .padRight(pad) + ':'
        log.info """
${dashedLine()}
${warning_msg}
${dashedLine()}
Could not send mail with the sendmail command!
${dashedLine()}
""".stripIndent()
    }
    return 1
}

// Set ANSI colors for any and all
// STDOUT or STDERR
def getANSIColors() {

    Map fgcolors = [:]

    fgcolors['reset']   = "\033[0m"
    fgcolors['black']   = "\033[0;30m"
    fgcolors['red']     = "\033[0;31m"
    fgcolors['green']   = "\033[0;32m"
    fgcolors['yellow']  = "\033[0;33m"
    fgcolors['blue']    = "\033[0;34m"
    fgcolors['magenta'] = "\033[0;35m"
    fgcolors['cyan']    = "\033[0;36m"
    fgcolors['white']   = "\033[0;37m"

    return fgcolors
}
