#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { deinterleave; reads_stats } from './modules/bbtools'
include { snippy; snippy_core } from './modules/snippy'
include { gubbins; raxml } from './modules/gubbins'
include { snp_sites } from './modules/snp_sites'

workflow {
    
    Channel
        .fromFilePairs( params.reads, size: (params.single_end || params.interleaved) ? 1 : 2 )
        .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}." }
        .set { reads_ch }

    ref_file = file(params.ref, type: 'file')
    targets_file = file(params.targets, type: 'file')

    deint_reads_ch = params.interleaved 
                   ? deinterleave(reads_ch).out.deint_reads
                   : reads_ch

    reads_stats(deint_reads_ch, "raw_reads_stats")
    snippy(deint_reads_ch, ref_file, targets_file)
    snippy_core(snippy.out.snps.map{ it -> it[1] }.collect(), ref_file)

    if ( !params.skip_gubbins ) {
        gubbins(snippy_core.out.clean_full_aln)
        snp_sites(gubbins.out.filt_core_aln)
        core_aln_ch = snp_sites.out.core_aln
    } else {
        core_aln_ch = snippy_core.out.core_aln
    }

    if ( !params.skip_raxml ) {
        raxml(core_aln_ch)
    }
}
