# Methods & Workflow of a Bioinformatics Pipeline Analysis

A self-contained, teachable short course on how NGS (next-generation sequencing) pipelines
actually work — from raw reads to interpreted biology — for grad and early-career researchers who
are comfortable with biology but newer to command-line analysis.

> **Big idea of the course:** there is *one* universal pipeline skeleton. Variant calling,
> RNA-seq, and phage/metagenomics are not four unrelated workflows — they are the *same* skeleton
> with a different "core processing" step and a different downstream branch. Learn the skeleton
> once; instantiate it forever.

```
Experimental design → Raw data + QC → Preprocessing → Core processing (align ⟋ assemble)
   → Domain-specific downstream → Interpretation & reporting → Reproducibility (cross-cutting)
```

---

## Learning objectives

By the end of this course a student can:

1. **Read any pipeline as an instance of the universal skeleton** — name each stage, the file
   format that connects it to the next, and why.
2. **Run the shared front half** — QC a FASTQ set, decide on and perform trimming, and either
   align to a reference or assemble de novo.
3. **Instantiate at least one domain end-to-end** — call & annotate variants, *or* quantify &
   test differential expression, *or* assemble & identify phages/viruses from a metagenome.
4. **Interpret responsibly** — visualize results, apply the right statistics, and avoid common
   over-interpretation traps.
5. **Choose and justify a reproducibility strategy** — a workflow manager (Nextflow/nf-core or
   Snakemake), environment management (conda/containers), and provenance practices.

## Prerequisites

- **Biology**: comfortable with genes, genomes, transcription, mutation/variant concepts.
- **Unix shell**: can `cd`, `ls`, pipe (`|`), redirect (`>`), and run a command with flags. A
  20-minute refresher is enough; we are not assuming scripting fluency.
- **Software**: a working `conda`/`mamba` install (see `hands-on/environment.yml`). The lab is
  sized to run on a laptop.

No prior pipeline experience is assumed.

## Module map & suggested timing

| Module | File | Topic | Lecture |
|--------|------|-------|---------|
| 0 | `notes/00-foundations.md` | Pipelines, platforms (Illumina SBS, PacBio HiFi, MinION), experimental design, file formats | ~60 min |
| 1 | `notes/01-qc-preprocessing.md` | FastQC/MultiQC, trimming & filtering | ~30 min |
| 2 | `notes/02-core-processing.md` | Alignment vs assembly — **the branch point** | ~40 min |
| 3a | `notes/03-domain-variant-calling.md` | GATK → VCF → annotation → ACMG | ~40 min |
| 3b | `notes/03-domain-rnaseq.md` | STAR/Salmon → DESeq2/edgeR | ~40 min |
| 3c | `notes/03-domain-phage-metagenomics.md` | Assembly → geNomad/CheckV → Pharokka | ~40 min |
| 4 | `notes/04-interpretation-reporting.md` | Visualization, stats, reporting | ~25 min |
| 5 | `notes/05-reproducibility.md` | nf-core/Snakemake, conda, containers | ~30 min |

**Total**: ~4–5 h of lecture + ~2 h hands-on lab. Modules 3a/3b/3c are parallel — deliver all
three for a survey course, or pick the one matching your audience for a focused session.

## Repository layout

```
bioinfo-pipeline-class/
├── README.md                 ← you are here (syllabus)
├── PLAN.md                   ← the authoring blueprint (design rationale)
├── notes/                    ← lecture notes, one per module
├── slides/slide-outline.md   ← slide-by-slide deck with speaker notes
├── hands-on/                 ← runnable lab (tutorial + conda env + command reference)
└── resources/references.md   ← curated papers, tool docs, datasets, glossary
```

## How to use this package

- **Self-study** → read `notes/` in order (0 → 5). Each note ends with a *checkpoint* question;
  answer it before moving on.
- **Delivering a lecture** → drive from `slides/slide-outline.md`; the notes are your speaker
  reference and handout. The recurring skeleton diagram tells the audience where they are.
- **Running the lab** → follow `hands-on/tutorial.md`. Create the environment first
  (`mamba env create -f hands-on/environment.yml`), then work through QC → trim → both a
  reference-based pass (align + call) and an assembly-based pass (assemble + identify).

## A note on tools

Tool names (BWA, GATK, STAR, Salmon, SPAdes, geNomad, ...) change over the years; the *stages*
do not. Every module leads with the concept and the file format, then names current tools as
interchangeable implementations. When a tool is deprecated, you will still know what slot it
filled and what to swap in.
