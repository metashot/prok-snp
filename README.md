# metashot/prok-snp

## Introduction
metashot/prok-snp is a workflow for the identification SNVs (of closely related
organisms) and phylogenetic tree inference from prokaryotic isolates.

## Main features

- Input: single-end, paired-end (also interleaved) Illumina sequences (gzip
  compressed FASTA/FASTQ also supported);
- Variant calling and core genome alignment using
  [snippy](https://github.com/tseemann/snippy);
- Recombination prediction and filtering using 
  [Gubbins](https://doi.org/10.1093/nar/gku1196), optional;
- Phylogenetic tree inference using 
  [RAxML](https://10.1093/bioinformatics/btu033), optional.

## Quick start
1. Install [Nextflow](https://www.nextflow.io/) and [Docker](https://www.docker.com/);
1. Start running the analysis:

  ```bash
  nextflow run metashot/prok-snp
    --reads '*_R{1,2}.fastq.gz' \
    --ref reference.fa \
    --outdir results
  ```

See the file [`nextflow.config`](nextflow.config) for the complete list of
parameters.

## Output
Several files and directories will be created in the `results` folder.

### Main outputs
- `core_aln.fa`: the core SNP alignment in FASTA format (`snippy-core` output);
- `full_aln.fa`: the whole genome SNP alignment in FASTA format (`snippy-core`
  output);
- `core.vcf`: multi-sample VCF file with genotype GT tags for all discovered
  (`snippy-core` output); alleles(`snippy-core` output);
- `tree.tree`: the best-scoring ML tree of a thorough ML analysis (`raxml` output);
- `tree_support.tree`: the best-scoring ML tree with the BS support values (from
  0 to 100, RAxML output when `--raxml_mode rbs`).

### Secondary outputs
- `raw_reads_stats`: base frequency, quality scores, gc content, average
  quality and length for each input sample;
- `snippy`: the snippy output for each input sample;
- `snippy_core`: the `snippy-core` output;
- `gubbins`: gubbins output (when `--skip_gubbins false`);
- `raxml`: RAxML output (when `--skip_raxml false`).

## RAxML
Since the input alignments are from SNP data, the ascertainment bias correction
is applied to the likelihood calculations (https://doi.org/10.1101/186478, RAxML
option `-m ASC_GTRCAT`) and the rate heterogeneity among sites model is disabled
(RAxML option `-­V`). Two modes are available:

- **default mode**: construct a maximum likelihood (ML) tree. This mode runs the
  default RAxML tree search algorithm
  (https://doi.org/10.1007/s11265-007-0067-4) and perform multiple searches for
  the best tree (10 distinct randomized MP trees by default, see the parameter
  `--raxml_nsearch`). The following RAxML parameters will be used:

  ```bash
  -f d -m ASC_GTRCAT -V --asc-corr=lewis -N [RAXML_NSEARCH]
  ```
- **rbs mode**: assess the robustness of inference and construct a ML tree. This
  mode runs the rapid bootstrapping full analysis
  (https://doi.org/10.1080/10635150802429642). The bootstrap convergence
  criterion or the number of bootstrap searches can be specified with the
  parameter `--raxml_nboot`. The following parameters will be used:

  ```bash
  -f a -m ASC_GTRCAT -V --asc-corr=lewis -N [RAXML_NBOOT]
  ```
 
## System requirements
Each step in the pipeline has a default set of requirements for number of CPUs,
memory and time. For some of the steps in the pipeline, if the job exits with an
error it will automatically resubmit with higher requests (see
[`process.config`](process.config)).

You can customize the compute resources that the pipeline requests by either:
- setting the global parameters `--max_cpus`, `--max_memory` and
  `--max_time`, or
- creating a [custom config
  file](https://www.nextflow.io/docs/latest/config.html#configuration-file)
  (`-c` or `-C` parameters), or
- modifying the [`process.config`](process.config) file.

## Reproducibility
We recommend to specify a pipeline version when running the pipeline on your
data with the `-r` parameter:

```bash
  nextflow run metashot/kraken2 -r 1.0.0
    ...
```

Moreover, this workflow uses the docker images available at
https://hub.docker.com/u/metashot/ for reproducibility. You can check the
version of the software used in the workflow by opening the file
[`process.config`](process.config). For example `container =
metashot/kraken2:2.0.9-beta-6` means that the version of kraken2 is the
`2.0.9-beta` (the last number, 6, is the metashot release of this container).

## Singularity
If you want to use [Singularity](https://singularity.lbl.gov/) instead of Docker,
comment the Docker lines in [`nextflow.config`](nextflow.config) and add the following:

```nextflow
singularity.enabled = true
singularity.autoMounts = true
```

## Credits
This workflow is maintained by Davide Albanese and Claudio Donati at the [FEM's
Unit of Computational
Biology](https://www.fmach.it/eng/CRI/general-info/organisation/Chief-scientific-office/Computational-biology).
