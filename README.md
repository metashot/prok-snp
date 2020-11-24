# prok-snp

metashot/prok-snp is a workflow for the identification SNVs (of closely related
organisms) and phylogenetic tree inference from prokaryotic isolates.

- [MetaShot Home](https://metashot.github.io/)

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

1. Install Docker (or Singulariry) and Nextflow (see
   [Dependences](https://metashot.github.io/#dependencies));
1. Start running the analysis:

  ```bash
  nextflow run metashot/prok-snp \
    --reads '*_R{1,2}.fastq.gz' \
    --ref reference.fa \
    --outdir results
  ```

## Parameters
See the file [`nextflow.config`](nextflow.config) for the complete list of
parameters.

## Output
The files and directories listed below will be created in the `results`
directory after the pipeline has finished.

### Main outputs
- `core_aln.fa`: the core SNP alignment in FASTA format (`snippy-core` output);
- `full_aln.fa`: the whole genome SNP alignment in FASTA format (`snippy-core`
  output);
- `core.vcf`: multi-sample VCF file with genotype GT tags for all discovered
  (`snippy-core` output); alleles(`snippy-core` output);
- `tree.tree`: the best-scoring ML tree of a thorough ML analysis (`raxml`
  output);
- `tree_support.tree`: the best-scoring ML tree with the BS support values (from
  0 to 100, RAxML output when `--raxml_mode rbs`).

### Secondary outputs
- `raw_reads_stats`: base frequency, quality scores, gc content, average
  quality and length for each input sample;
- `snippy`: the snippy output for each input sample;
- `snippy_core`: the `snippy-core` output;
- `gubbins`: gubbins output (when `--skip_gubbins false`);
- `raxml`: RAxML output (when `--skip_raxml false`).

## Documentation

### RAxML
Since the input alignments are from SNP data, the ascertainment bias correction
is applied to the likelihood calculations<sup>[1](#footnote1)</sup> (RAxML
option `-m ASC_GTRCAT`) and the rate heterogeneity among sites model is disabled
(RAxML option `-­V`). Two modes are available:

- default mode: construct a maximum likelihood (ML) tree. This mode runs the
  default RAxML tree search algorithm<sup>[2](#footnote2)</sup> and perform
  multiple searches for the best tree (10 distinct randomized MP trees by
  default, see the parameter `--raxml_nsearch`). The following RAxML parameters
  will be used:

  ```bash
  -f d -m ASC_GTRCAT -V --asc-corr=lewis -N [RAXML_NSEARCH]
  ```
- rbs mode: assess the robustness of inference and construct a ML tree. This
  mode runs the rapid bootstrapping full analysis<sup>[3](#footnote3)</sup>. The
  bootstrap convergence criterion or the number of bootstrap searches can be
  specified with the parameter `--raxml_nboot`. The following parameters will be
  used:

  ```bash
  -f a -m ASC_GTRCAT -V --asc-corr=lewis -N [RAXML_NBOOT]
  ```

## System requirements
Please refer to [System
requirements](https://metashot.github.io/#system-requirements) for the complete
list of system requirements options.

---

<a name="footnote1">1</a>: Tamuri A., GoldmanAvoiding N. *Ascertainment bias in
      the maximum likelihood inference of phylogenies based on truncated data*.
      bioRxiv 186478, [Link](https://doi.org/10.1101/186478).

<a name="footnote2">2</a>: Stamatakis A., Blagojevic F., Nikolopoulos D.S. et
      al. *Exploring New Search Algorithms and Hardware for Phylogenetics: RAxML
      Meets the IBM* Cell. J VLSI Sign Process Syst Sign Im 48, 271–286 (2007).
      [Link](https://doi.org/10.1007/s11265-007-0067-4). 
      
<a name="footnote3">3</a>: Stamatakis A., Hoover P., Rougemont J. *A Rapid
      Bootstrap Algorithm for the RAxML Web Servers*. Systematic Biology, Volume
      57, Issue 5, October 2008, Pages 758–771,
      [Link](https://doi.org/10.1080/10635150802429642).

