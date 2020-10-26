nextflow.enable.dsl=2


// Params:
//   - outdir
process snp_sites {
    publishDir "${params.outdir}/gubbins/" , mode: 'copy'

    input:
    path(aln)

    output:
    path "gubbins.filtered_polymorphic_sites_clean.fasta", emit: core_aln

    script:
    """
    snp-sites \
        -c -m \
        -o gubbins.filtered_polymorphic_sites_clean.fasta \
        ${aln}
    """
}
