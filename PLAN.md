# Class: Methods & Workflow of a Bioinformatics Pipeline Analysis

## Context

The user (grad-level researcher, Bioinformatics mestrado track, working across clinical
variants and a phage/metagenomics pivot) wants to **build a class** teaching the methods and
workflow of bioinformatics pipeline analysis. Audience is grad / early-career researchers
(comfortable with biology, newer to NGS command-line analysis). The class must cover **all
domains** (generic NGS, variant calling, RNA-seq, phage/metagenomics) and ship in **all
formats** (lecture notes, slide outline, hands-on tutorial), in **English**.

The intended outcome: a self-contained, teachable course package the user can deliver to peers,
reuse for mestrado/teaching, and adapt. Because there is no codebase here, this plan is a
**content-authoring** plan: it defines the pedagogical structure, the files to create, and the
technical content each must contain.

### Core design decision
Teach **one universal pipeline skeleton** as the backbone, then show how each domain
*instantiates* it. This avoids teaching a full pipeline 4× and makes the shared logic explicit.

```
Experimental design → Raw data + QC → Preprocessing → Core processing (align ⟋ assemble)
   → Domain-specific downstream → Interpretation & reporting → Reproducibility (cross-cutting)
```

Each domain reuses the first stages and branches at "Core processing / downstream."

## Deliverables (files to create)

All under a new directory `~/bioinfo-pipeline-class/`:

```
bioinfo-pipeline-class/
├── README.md                      # Syllabus, learning objectives, prerequisites, how to use
├── notes/
│   ├── 00-foundations.md          # Pipeline concept, file formats, experimental design
│   ├── 01-qc-preprocessing.md     # FastQC/MultiQC, trimming (fastp/Trimmomatic/cutadapt)
│   ├── 02-core-processing.md      # Alignment (BWA/Bowtie2/minimap2) & assembly (SPAdes/MEGAHIT/Flye)
│   ├── 03-domain-variant-calling.md   # GATK best practices → VCF → annotation (VEP/SnpEff) → ACMG
│   ├── 03-domain-rnaseq.md            # STAR/HISAT2 or Salmon/kallisto → DESeq2/edgeR
│   ├── 03-domain-phage-metagenomics.md# Host removal → metaSPAdes → geNomad/VirSorter2/CheckV → Pharokka/Kraken2
│   ├── 04-interpretation-reporting.md # Visualization (IGV), stats, biological interpretation
│   └── 05-reproducibility.md          # Nextflow/nf-core, Snakemake, conda/mamba, containers, provenance
├── slides/
│   └── slide-outline.md           # Slide-by-slide deck outline w/ talking points + speaker notes
├── hands-on/
│   ├── tutorial.md                # Step-by-step runnable workshop (one shared dataset path)
│   ├── environment.yml            # conda env pinning the toolset used in the tutorial
│   └── commands.sh                # Copy-paste command reference mirroring tutorial steps
└── resources/
    └── references.md              # Curated papers, docs, datasets, glossary
```

## Content blueprint

### README.md (syllabus)
- Learning objectives (by end: read any pipeline as instances of one skeleton; run QC→align→call/quantify; pick a workflow manager; reason about reproducibility).
- Prerequisites: basic Unix shell, biology background, a conda install.
- Module map + suggested timing (e.g., 6 modules, ~3–4h lecture + 2h lab).
- "How to use": notes for self-study, slides for delivery, hands-on for lab.

### Module 0 — Foundations (`00-foundations.md`)
- What a pipeline is; why workflows; the universal skeleton diagram.
- Sequencing platforms: Illumina (short read) vs ONT/PacBio (long read) and how platform choice
  cascades through every later tool.
- Experimental design: replicates, controls, depth/coverage, batch effects.
- **File formats as the connective tissue**: FASTA, FASTQ (Phred quality encoding), SAM/BAM/CRAM,
  VCF, GFF/GTF, BED. One worked example showing the same read flowing FASTQ → BAM → VCF.

### Module 1 — QC & preprocessing (`01-qc-preprocessing.md`)
- FastQC metrics (per-base quality, adapter content, GC, duplication) + MultiQC aggregation.
- Trimming/filtering: `fastp` (primary), Trimmomatic, cutadapt; when each applies.
- Decision rules: when to trim, how aggressive, paired-end considerations.

### Module 2 — Core processing (`02-core-processing.md`) — the branch point
- **Alignment** (reference-based): BWA-MEM, Bowtie2, minimap2 (long reads); reference selection;
  SAM/BAM, sorting/indexing with samtools.
- **De novo assembly**: SPAdes/metaSPAdes, MEGAHIT, Flye (long read); contigs, N50, assembly QC.
- Explicit framing: "variant calling & RNA-seq usually align; metagenomics/phage usually assemble."

### Module 3 — Domain instantiations (three parallel notes)
- **Variant calling**: GATK best-practices arc (mark duplicates → BQSR → HaplotypeCaller),
  alt callers (bcftools, DeepVariant), VCF anatomy, annotation (VEP, SnpEff, ANNOVAR), and
  **clinical interpretation (ACMG/ClinVar)** — ties to the user's VariantScribe work.
- **RNA-seq**: spliced alignment (STAR/HISAT2) vs pseudo-alignment (Salmon/kallisto);
  quantification; normalization; differential expression with DESeq2/edgeR; multiple testing.
- **Phage / metagenomics**: host-read removal → metaSPAdes/MEGAHIT assembly → viral
  identification (geNomad, VirSorter2, CheckV completeness/contamination) → taxonomy (Kraken2/
  Bracken) → phage annotation (Pharokka/Prokka). Aligned with the user's research pivot.

### Module 4 — Interpretation & reporting (`04-interpretation-reporting.md`)
- Visualization (IGV for alignments/variants, volcano/MA plots for RNA-seq, genome maps for phage).
- Statistics & biological interpretation; avoiding common over-interpretation pitfalls.
- What a good results report contains.

### Module 5 — Reproducibility (`05-reproducibility.md`) — cross-cutting
- Workflow managers: Nextflow + nf-core (highlight `nf-core/sarek`, `nf-core/rnaseq`,
  `nf-core/mag` as production instances of Modules 3), and Snakemake.
- Environment management: conda/mamba, Docker/Singularity/Apptainer.
- Provenance: version pinning, parameter logging, seeds, version control.

### Slides (`slides/slide-outline.md`)
- ~40–50 slides mirroring Modules 0–5, each slide = title + 3–5 bullets + speaker-note paragraph.
- Recurring "skeleton" diagram slide that highlights the current stage in each module.

### Hands-on (`hands-on/`)
- One small public dataset (e.g., a subsampled bacterial/phage genome or E. coli reads) so the lab
  runs on a laptop. `tutorial.md` walks QC → trim → (align + call) and (assemble + identify),
  giving students one reference-based and one assembly-based pass.
- `environment.yml` pins: fastqc, multiqc, fastp, bwa, samtools, bcftools, spades, and a viral-ID
  tool; `commands.sh` is the copy-paste mirror.
- Note: tutorial commands will be written and sanity-checked for syntax; full execution on real
  data is the student's lab step (and can be verified locally if desired).

## Notes on reuse / existing assets
- Pull ACMG/ClinVar framing and any glossary from the user's **VariantScribe** project notes if
  available, to keep terminology consistent.
- Phage/metagenomics module should align with the user's existing virome/metagenomics direction
  (see memory: pivot to bacteriophages) and can later cross-link into the Obsidian vault.

## Verification
1. **Structure check**: confirm all files in the tree above exist and README links resolve.
2. **Content QC**: each module note has objectives, body, a worked command block, and a
   "checkpoint" question; the three domain notes all map back to the skeleton diagram.
3. **Tutorial dry-run (optional, local)**: create the conda env from `environment.yml` and run the
   first QC + trim steps on the sample data to confirm commands are syntactically correct and the
   toolchain resolves. (Read-only/no-network constraints permitting.)
4. **Deliverability check**: slide outline length and module timing fit the stated session budget.

## Open question deferred to execution
- Exact sample dataset for the hands-on lab (bacterial vs phage genome) — will pick a small,
  freely downloadable one and document the source; easy to swap.
