nextflow.enable.dsl=2


process deinterleave {      
        tag "${id}"

        input:
        tuple val(id), path(reads)

        output:
        tuple val(id), path("read_*.fastq.gz"), emit: deint_reads

        script:
        task_memory_GB = task.memory.toGiga()
        
        """
        reformat.sh \
            -Xmx${task_memory_GB}g \
            in=$reads \
            out1=read_1.fastq.gz \
            out2=read_2.fastq.gz \
            t=1
        """
}


// Params:
//     - params.outdir
process reads_stats {   
    tag "${id}"

    publishDir "${params.outdir}/${reads_stats_outdir}/${id}" , mode: 'copy'

    input:
    tuple val(id), path(reads)
    val (reads_stats_outdir)

    output:
    path "*hist.txt"

    script:
    task_memory_GB = task.memory.toGiga()
    input = params.single_end ? "in=\"$reads\"" : "in1=\"${reads[0]}\" in2=\"${reads[1]}\""
    """
    bbduk.sh \
        -Xmx${task_memory_GB}g \
        $input \
        bhist=bhist.txt \
        qhist=qhist.txt \
        gchist=gchist.txt \
        aqhist=aqhist.txt \
        lhist=lhist.txt \
        gcbins=auto
    """
}