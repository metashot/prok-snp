nextflow.enable.dsl=2


process gubbins {
    publishDir "${params.outdir}/gubbins/" , mode: 'copy'

    input:
    path(full_aln)

    output:
    path "gubbins.*"
    path "gubbins.filtered_polymorphic_sites.fasta", emit: filt_core_aln

    script:
    """
    run_gubbins.py \
        -p gubbins \
        -t ${params.gubbins_tree_builder} \
        -i ${params.gubbins_iterations} \
        --threads ${task.cpus} \
        ${full_aln} > gubbins.log
    """
}


process raxml {
    publishDir "${params.outdir}/raxml" , mode: 'copy'
    publishDir "${params.outdir}" , mode: 'copy' ,
        saveAs: { filename -> 
            if (filename == "RAxML_bestTree.run") "tree.tree"
            else if (filename == "RAxML_bipartitions.run") "tree_support.tree"
        }

    input:
    path(core_aln)

    output:
    path "*.run"

    script:
    if (params.raxml_mode == 'default')
        """
        raxmlHPC-PTHREADS-SSE3 \
            -f d \
            -m ASC_GTRCAT \
            -V \
            --asc-corr=lewis \
            -p 42 \
            -T ${task.cpus} \
            -n run \
            -N ${params.raxml_nsearch} \
            -s ${core_aln}
        """
        
    else if ( params.raxml_mode == 'rbs' )
        """
        raxmlHPC-PTHREADS-SSE3 \
            -f a \
            -x 43 \
            -N ${params.raxml_nboot} \
            -m ASC_GTRCAT \
            -V \
            --asc-corr=lewis \
            -p 42 \
            -s ${core_aln} \
            -n run \
            -T ${task.cpus}
        """
    else
        error "Invalid RAxML mode: ${params.raxml_mode}"
}
