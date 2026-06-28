---
marp: true
theme: brand
paginate: true
size: 16:9
title: Methods & Workflow of a Bioinformatics Pipeline Analysis
author: Eduardo Ramos Alves
---

<!-- _class: lead -->
<!-- _paginate: false -->

<p class="eyebrow">BIOINFORMATICS · NGS PIPELINES</p>

# Methods & Workflow of a Bioinformatics Pipeline Analysis

## Reading any NGS pipeline as one skeleton with swappable parts

- Audience: grad / early-career researchers — biology-comfortable, NGS-newer
- Format: lecture (these slides) + notes handout + hands-on lab

<!-- Set expectations: by the end they read any NGS pipeline as one skeleton with swappable parts, and will have run both an alignment and an assembly pass themselves. -->

---

## Why this class exists

- Bioinformatics *looks* like 4 unrelated workflows — variants, RNA-seq, metagenomics, ...
- It's really **ONE skeleton** with different middle/back ends
- Learn the skeleton once → **instantiate forever**

<!-- Name the pain: students drown memorizing tool zoos. Reframe: tools are implementations of stages; stages are stable. This is the whole thesis of the course. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">THE BACKBONE</p>

## The universal pipeline skeleton

```
Design → QC → Preprocess → Core (ALIGN / ASSEMBLE) → Downstream → Interpret
                                                          ↳ Reproducibility wraps all
```

- Each junction is a **file format**
- Front half **shared**; back half **branches**

<!-- Walk left to right once. Emphasize the fork at "Core" and that reproducibility is the box around everything, not a final step. This diagram returns every module. -->

---

## Roadmap & how to use the materials

- **6 modules**; ~3–4 h lecture + 2 h lab
- Notes for self-study · slides for delivery · hands-on for the lab
- Three parallel domain modules (3a / 3b / 3c) — survey all or pick one

<!-- The lab deliberately makes them take both forks: align+call on E. coli, assemble+identify on a phage. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 0 · FOUNDATIONS</p>

## Foundations — stage: Design + formats

```
[DESIGN] → QC → Preprocess → Core → Downstream → Interpret → Reproducibility
```

- What a pipeline is; why we formalize it: **reproducibility, scale, reasoning**

<!-- "Pipeline = plumbing; junctions are file formats." Most pain is format-wrangling. -->

---

## Sequencing platforms

- **Short read** (Illumina) vs **long read** (ONT / PacBio HiFi)
- Trade-offs: read length · accuracy · throughput / cost

<!-- The platform is the FIRST fork — it cascades into aligner, assembler, error model. -->

---

## The platform cascade

- **ONT** → minimap2 (not BWA), Flye (not SPAdes), indel-heavy error profile
- **Illumina** → BWA / Bowtie2, SPAdes / MEGAHIT, accurate SNVs

> A Module-0 choice **silently rewrites** your Module-2/3 toolset.

<!-- Hammer the cascade: the platform is not a detail, it's the first fork in the road. -->

---

## Experimental design

- **Replicates** (biological ≫ technical), **controls**, depth / coverage
- **Batch effects**: randomize conditions across batches, record batch as metadata

<!-- Bioinformatics can't rescue a confounded design. The March/June batch story — a recurring cautionary tale; it returns in Module 4. -->

---

## File formats: the connective tissue

- FASTA · FASTQ · SAM/BAM/CRAM · VCF · GFF/GTF · BED
- Each format = **output of one stage, input of the next**

<!-- Don't memorize columns; learn which stage emits each. Detail on the next slides. -->

---

## FASTQ & Phred quality

- 4 lines / read; quality string = per-base **Phred** (Q = −10·log₁₀ P)
- Q20 = 1% error · Q30 = 0.1% · **Phred+33** ASCII encoding

<!-- This quality string is the entire reason QC (Module 1) exists. Quick ASCII demo: char − 33 = Q. -->

---

## BAM, VCF, GFF / BED in one breath

- **BAM** = aligned reads (POS, MAPQ, CIGAR)
- **VCF** = variants · **GFF/GTF** = features · **BED** = plain intervals
- BED is **0-based**; GFF/VCF **1-based** (off-by-one trap)

<!-- "BED counts from zero" — say it twice; it bites everyone once. -->

---

## Worked example: one read, FASTQ → BAM → VCF

```
FASTQ   quality letter (low-Q 3' tail)
  ↓  align
BAM     CIGAR mismatch + soft-clip, MAPQ 60
  ↓  call
VCF     0/1 genotype, DP=31, PASS
```

- Same observation, three formats — the **read never changes**

<!-- The whole pipeline in one slide. Return to this image whenever someone is lost. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 1 · QC & PREPROCESSING</p>

## QC & Preprocessing

```
Design → [QC] → [PREPROCESS] → Core → Downstream → Interpret → Reproducibility
```

- Garbage in → garbage out; **cheapest place to catch disaster**

<!-- Raw FASTQ is NOT trustworthy raw material — adapters, low-qual tails, contaminants. -->

---

## FastQC: the metrics that matter

- Per-base quality · adapter content · overrepresented seqs · duplication · GC
- Pass / Warn / Fail = a **prompt, not a verdict**

<!-- "Read FastQC like a doctor reads a chart" — interpret in the context of the library type. -->

---

## MultiQC: aggregate & spot the outlier

- **One report**, all samples, every step
- The **outlier view** is the payoff

<!-- Highest value / lowest effort tool in the course. Run it after every batch step. -->

---

## Trimming tools

| Tool | Role |
|------|------|
| **fastp** | **default** — all-in-one: adapters, quality, length + report |
| **Trimmomatic** | explicit / legacy, fine control |
| **cutadapt** | adapter / primer specialist |

<!-- fastp = one fast pass + its own report. Show the table; default to fastp. -->

---

## Decision rules

- **Always** remove adapters; quality-trim **only** decayed 3' tails
- **Don't over-trim** (hurts mappability); don't hard-trim the 5' wobble
- Paired-end: **keep mates in sync** — use a pair-aware tool

<!-- By goal — variants: light trim; assembly: more; pseudo-align RNA: often adapters only. -->

---

## Module 1 checkpoint

- A **duplication FAIL** on a deep RNA-seq library — panic?

> **No.** High duplication is *expected* in deep RNA-seq. Interpret QC in context.

<!-- Use as a discussion beat; let them answer before revealing. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 2 · CORE PROCESSING</p>

## Core processing — THE BRANCH POINT

```
Design → QC → Preprocess → [ ALIGN / ASSEMBLE ] → Downstream → Interpret
```

- Everything before = **shared**; everything after = **diverges here**

<!-- The single most important conceptual slide. Slow down. -->

---

## The fork: do you already have a map?

- **Align**: "how does my sample differ from a known genome?" → **BAM**
- **Assemble**: "what is the sequence I just got?" → **FASTA**
- Jigsaw *with* the box picture (align) vs *without* it (assemble)

<!-- The decision rule = does a trustworthy reference exist? -->

---

## Aligners

- **BWA-MEM** (DNA / variants) · **Bowtie2** (general / ChIP) · **minimap2** (long reads)
- Right reference, **indexed**, documented

<!-- Spliced RNA aligners (STAR/HISAT2) are a special case → Module 3b. -->

---

## Reads → usable BAM (samtools)

```bash
bwa mem -t4 ref.fa R1.fq.gz R2.fq.gz | samtools sort -o s.bam -
samtools index s.bam ; samtools flagstat s.bam
```

- Low **% mapped** = wrong ref / contamination / adapters

<!-- samtools is the swiss-army knife. flagstat is your first reality check. -->

---

## De novo assembly

- **SPAdes** (isolate/meta) · **MEGAHIT** (big metagenomes) · **Flye** (long read)
- de Bruijn graphs (short) vs overlap (long)

<!-- No reference → reconstruct by overlap. Compute / memory heavy. -->

---

## Judging an assembly: N50 & friends

- **contig count** · **N50** (contiguity) · total length · completeness (BUSCO / CheckV)

> **N50 rewards length, not correctness** — always pair it with completeness.

<!-- The "higher N50 but 71% complete" trap (returns in the checkpoint). -->

---

## Mapping domains to branches

| Domain | Branch |
|--------|--------|
| Variant calling | **ALIGN** |
| RNA-seq | **ALIGN** / pseudo-align |
| Phage / metagenomics | **ASSEMBLE** |

<!-- The line to memorize: variants & RNA-seq usually align; metagenomics/phage usually assemble. The lab makes them do both. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 3a · VARIANT CALLING</p>

## Variant calling — ALIGN branch

```
... → Core (ALIGN) → [VARIANT CALLING] → Interpret
```

- BAM → where & how does the sample differ → **does it matter?**

<!-- This branch consumes the aligned BAM. Germline vs somatic. -->

---

## GATK Best Practices arc

```
BAM → MarkDuplicates → BQSR → HaplotypeCaller → joint genotyping → filter → VCF
```

- Each step kills a **specific** false-call source

<!-- Dedup + BQSR make the evidence honest; HaplotypeCaller makes calls; filtering keeps the defensible ones. -->

---

## Alternative callers

- **bcftools** — light / bacterial (used in the lab)
- **DeepVariant** — deep-learning, strong on long reads
- **Mutect2** — somatic (tumor / normal)

<!-- Right tool for scale. GATK's full arc is overkill on a phage / E. coli genome. -->

---

## VCF anatomy

```
CHROM POS ID REF ALT QUAL FILTER INFO   FORMAT  sample
chr7  ...  . G   A   312  PASS   DP=54  GT:AD:DP 0/1:27,27:54
```

- **GT**: 0/0 hom-ref · 0/1 het · 1/1 hom-alt — DP / AD / GQ are trust signals

<!-- Read one row aloud as a sentence. -->

---

## Annotation: coordinate → consequence

- **VEP** / **SnpEff** / **ANNOVAR**
- Gene · consequence · **gnomAD frequency** · in-silico scores (CADD, SIFT, SpliceAI)

<!-- Raw VCF says where, not what it does. Annotation feeds interpretation. -->

---

## Clinical interpretation: ACMG/AMP + ClinVar

- 5 tiers: **Pathogenic → VUS → Benign**; criteria PVS1 / PS / PM2 / PP3 / BA1...
- **ClinVar** = prior interpretations; **VUS** is the honest common verdict

> A statistical call ≠ a diagnosis. Be conservative; state uncertainty.

<!-- Ties to VariantScribe — keep ACMG/ClinVar terminology aligned with that project. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 3b · RNA-SEQ</p>

## RNA-seq — ALIGN / pseudo-align

```
... → Core (ALIGN / pseudo-align) → [QUANTIFY] → Diff. expression → Interpret
```

- Measure how much each gene is expressed; the twist: **introns removed → reads span junctions**

<!-- Why DNA aligners don't suffice for mRNA. -->

---

## Two routes to counts

- **A** — spliced alignment (STAR / HISAT2) + featureCounts / HTSeq
- **B** — pseudo-alignment (Salmon / kallisto) + tximport — the fast default

<!-- Want counts for DE? Salmon. Need alignments (isoforms / RNA variants)? STAR. -->

---

## The count matrix

```
        ctrl_1 ctrl_2 treat_1 treat_2
GENE_A    412    388     820     795
GENE_B      2      0       3       1
```

- genes × samples — **filter low-count genes** before testing

<!-- The convergence point: both routes end here; it's the DE input. -->

---

## Normalization: raw counts lie

- Library size · gene length · **composition**
- CPM / TPM (within-sample) vs DESeq2 size factors / edgeR TMM (across-sample DE)

> **Don't feed TPM to DESeq2** — it wants raw counts.

<!-- The most common RNA-seq mistake. Say the "raw counts" rule explicitly. -->

---

## Differential expression (DESeq2 / edgeR)

- **Negative binomial**; size factors → dispersion → GLM → test
- Output: **log2FC** + **padj**; `lfcShrink` for stable effect sizes

<!-- n ≥ 3 replicates floor; more replicates beat more depth. -->

---

## Multiple testing & the volcano

- ~20k genes → ~1000 false "hits" at p<0.05 → use **BH FDR (padj)**
- Combine padj threshold **with** effect size; volcano / MA plots

> Significant ≠ meaningful (padj 1e-30, log2FC 0.08).

<!-- The big idea. Don't rank by p-value alone. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 3c · PHAGE / METAGENOMICS</p>

## Phage / metagenomics — ASSEMBLE branch

```
... → Core (ASSEMBLE) → [VIRAL ID] → Taxonomy → Annotation → Interpret
```

- Novel, uncultured genomes; **no single reference** · lean: virome / phage

<!-- Why assemble not align — alignment only sees the known. -->

---

## Host removal → assembly

- Strip host / PhiX reads (keep non-host)
- **metaSPAdes** / **MEGAHIT** / **Flye --meta**

<!-- A phage prep is mostly host DNA; also a privacy step for human samples. -->

---

## Viral identification

- **geNomad** / **VirSorter2** score contigs for viral signal; find proviruses

<!-- The output of assembly is an undifferentiated contig pile; this separates the viral wheat. -->

---

## CheckV: how good is each viral genome?

- **Completeness** + **contamination** + provirus trimming
- Viral analog of BUSCO / QUAST — completeness ≠ contiguity

> 18% contamination ≈ host DNA flanking an integrated **prophage**.

<!-- Report phages with their CheckV quality tier. -->

---

## Taxonomy: Kraken2 + Bracken

- **Kraken2** classifies reads; **Bracken** re-estimates abundance
- Database caveat: **novel phages = unclassified** (that's the interesting bit)

<!-- Exactly why assembly + CheckV matters — characterize the unknown. -->

---

## Phage annotation: Pharokka

- **PHANOTATE** gene calling + **PHROGs** DB; phage-tuned; genome map
- Prokka / Bakta = general bacterial (more "hypothetical protein")

<!-- Phage genes sparse in generic DBs → use the phage-specialized tool. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 4 · INTERPRETATION</p>

## Interpretation & reporting

```
... → Downstream → [INTERPRETATION & REPORTING] → Reproducibility
```

- Numbers → **defensible biological claims**; visualize **before** you believe

<!-- Pipeline exiting 0 means it ran, not that it's right. -->

---

## Visualization & stats per domain

- **IGV** (variants — strand / end / homopolymer artifacts)
- **Volcano / MA / PCA** (RNA-seq) · **genome maps / Krona** (phage)
- Effect size + significance; multiple testing everywhere; differential ≠ functional

<!-- The IGV strand-bias story and the PCA-clusters-by-date (= batch effect) story. -->

---

## What a good report contains

- Question / design · **methods WITH versions** · QC summary
- Results **with uncertainty** · bounded interpretation · reproducibility pointers

> "BWA-MEM" ≠ reproducible; "BWA-MEM 0.7.17, GRCh38, default params" is.

<!-- A report a reviewer can't reproduce from the methods is scientifically incomplete. -->

---

<!-- _class: skeleton -->

<p class="eyebrow">MODULE 5 · REPRODUCIBILITY</p>

## Reproducibility wraps everything

```
[ Design → QC → Preprocess → Core → Downstream → Interpret ]
                  ↳ all of it inside REPRODUCIBILITY
```

- Why a workflow manager: **resume · parallelism · portability · reproducibility**

<!-- Not a final step — the box around the whole skeleton. -->

---

## Workflow managers & environments

- **Nextflow + nf-core**: sarek=3a · rnaseq=3b · mag=3c | **Snakemake** (Pythonic, file rules)
- **conda / mamba** (pin versions!) + **containers** (Docker / Singularity / Apptainer)

> Everything you did by hand, **nf-core runs for you** — now you can trust / configure / debug it.

<!-- THE punchline. They understand each stage now, so the pipelines aren't black boxes. -->

---

## Provenance & close

- Version pinning · parameter logging · **seeds** · git for code · data in SRA / ENA / Zenodo

> The reproducibility test: could you (or someone) regenerate these exact results in 2 years?

<!-- Recap the skeleton one last time; point them to the hands-on lab. Close. -->

---

<!-- _class: lead -->
<!-- _paginate: false -->

<p class="eyebrow">ONE SKELETON · MANY INSTANCES</p>

# Thank you

## Now: the hands-on lab — align + call on *E. coli*, assemble + identify on a phage

- Notes: `notes/00–05` · Lab: `hands-on/tutorial.md` · Refs: `resources/references.md`

<!-- Hand off to the lab. Create the env first: mamba env create -f hands-on/environment.yml. -->
