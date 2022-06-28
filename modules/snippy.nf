nextflow.enable.dsl=2


// Params:
//   - outdir
//   - single_end
//   - targets
//   - report
process snippy {
    tag "${id}"

    publishDir "${params.outdir}/snippy" , mode: 'copy'

    input:
    tuple val(id), path(input)
    path (ref)
    path (targets)
    
    output:
    tuple val(id), path("${id}"), emit: snps

    script:
    param_input = params.single_end ? " --se \"$input\"" : "--pe1 \"${input[0]}\" --pe2 \"${input[1]}\""
    param_targets = params.targets != 'none' ? "--targets $targets" : ''
    param_report = params.report ? '--report' : ''
    """
    snippy \
        --cpus ${task.cpus} \
        --outdir ${id} \
        --ref ${ref} \
        $param_input \
        $param_targets \
        $param_report \
        --force
    """
}


// Params:
//   - outdir
process snippy_core {
    publishDir "${params.outdir}/snippy_core" , mode: 'copy'
    publishDir "${params.outdir}" , mode: 'copy' ,
        saveAs: { filename -> 
            if (filename == "core.aln") "core_aln.fa"
            else if (filename == "core.vcf") "core.vcf"
            else if (filename == "clean.full.aln") "full_aln.fa"
        }
    
    input:
    path (snps)
    path (ref)

    output:
    path "core.*"
    path "core.aln", emit: core_aln
    path "clean.full.aln", emit: clean_full_aln

    script:
    """
    snippy-core \
        --ref ${ref} \
        ${snps}

    snippy-clean_full_aln \
        core.full.aln > clean.full.aln
    """
}
