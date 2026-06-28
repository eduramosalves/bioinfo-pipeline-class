# Galaxy Training Network — imported tutorials (reference)

Local copies of the **Galaxy Training Network (GTN)** tutorials that align with this course, kept as
read-only source material for comparison against our notes. These are the GUI/Galaxy companions to the
CLI-first modules in `notes/`.

- **Source:** <https://github.com/galaxyproject/training-material> (branch `main`)
- **Raw path pattern:** `topics/<topic>/tutorials/<name>/tutorial.md`
- **Fetched:** 2026-06-28 via `curl` (see import loop in project history)
- **License:** GTN content is **CC-BY 4.0**. Original frontmatter/attribution is preserved in each file —
  do not strip it. Cite as Batut et al. 2018, *Cell Systems* and the per-tutorial `contributions`.
- **Format note:** these are GTN-flavored markdown (Jekyll/Liquid: `{% tool %}`, `{% snippet %}`,
  `<hands-on-title>` boxes). They are reference, not meant to render in our plain-markdown deck.

"Linked?" = ✓ if a `notes/` module already pointed to it before this import; ✦ = newly surfaced by the
topic-index sweep.

## Module 0 — Foundations  → `notes/00-foundations.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `introduction/galaxy-intro-101` | Galaxy Basics for genomics | Introductory | 1h | ✓ |
| `introduction/galaxy-intro-ngs-data-managment` | NGS data logistics | Introductory | 1h30 | ✓ |
| `galaxy-interface/history` | Understanding Galaxy history system | Introductory | 30m | ✓ |

## Module 1 — QC & Preprocessing  → `notes/01-qc-preprocessing.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `sequence-analysis/quality-control` | Quality Control | Introductory | 1h30 | ✓ |
| `sequence-analysis/quality-contamination-control` | Quality and contamination control in bacterial isolate (Illumina MiSeq) | Introductory | 2h | ✦ |
| `galaxy-interface/collections` | Using dataset collections (scaling to many samples) | Intermediate | 30m | ✦ |

## Module 2 — Core Processing (align / assemble)  → `notes/02-core-processing.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `sequence-analysis/mapping` | Mapping | Introductory | 1h | ✓ |
| `assembly/general-introduction` | An Introduction to Genome Assembly | Introductory | 30m | ✓ |
| `assembly/debruijn-graph-assembly` | De Bruijn Graph Assembly | Introductory | 2h | ✦ |
| `assembly/mrsa-illumina` | Genome Assembly of MRSA (Illumina MiSeq) | — | 2h | ✓ |
| `assembly/mrsa-nanopore` | Genome Assembly of MRSA (Oxford Nanopore MinION) | Introductory | 2h | ✓ |
| `assembly/hybrid_denovo_assembly` | Hybrid genome assembly — Nanopore + Illumina | — | 2h | ✦ |
| `assembly/assembly-quality-control` | Genome Assembly Quality Control | Intermediate | 2h | ✓ |
| `assembly/assembly-with-preprocessing` | Unicycler assembly with preprocessing (human-read removal) | Intermediate | 4h | ✦ |

## Module 3a — Variant Calling  → `notes/03-domain-variant-calling.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `variant-analysis/microbial-variants` | Microbial Variant Calling | — | 45m | ✓ |
| `variant-analysis/tb-variant-analysis` | M. tuberculosis Variant Analysis | Intermediate | 2h | ✦ |
| `variant-analysis/exome-seq` | Exome sequencing for diagnosing a genetic disease | — | 5h | ✓ |
| `variant-analysis/somatic-variants` | Somatic & germline variants from tumor/normal pairs | — | 7h | ✓ |

## Module 3b — RNA-seq  → `notes/03-domain-rnaseq.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `transcriptomics/ref-based` | Reference-based RNA-Seq data analysis | Introductory | 8h | ✓ |
| `transcriptomics/rna-seq-reads-to-counts` | 1: RNA-Seq reads to counts | — | 3h | ✓ |
| `transcriptomics/rna-seq-counts-to-genes` | 2: RNA-seq counts to genes | — | 2h | ✓ |
| `transcriptomics/rna-seq-genes-to-pathways` | 3: RNA-seq genes to pathways | — | 2h | ✦ |
| `transcriptomics/rna-seq-viz-with-volcanoplot` | Visualization of RNA-Seq results with Volcano Plot | Introductory | 30m | ✦ |

## Module 3c — Phage / Metagenomics  → `notes/03-domain-phage-metagenomics.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `microbiome/metagenomics-assembly` | Assembly of metagenomic sequencing data | Introductory | 2h | ✓ |
| `microbiome/metagenomics-binning` | Binning of metagenomic sequencing data (MAGs) | Intermediate | 2h | ✦ |
| `microbiome/taxonomic-profiling` | Taxonomic Profiling and Visualization of Metagenomic Data | Introductory | 2h | ✓ |
| `microbiome/pathogen-detection-from-nanopore-foodborne-data` | Pathogen detection from Nanopore (foodborne) | Introductory | 4h | ✓ |
| `microbiome/host-removal` | Remove contamination and host reads | Introductory | 1h | ✦ |
| `sequence-analysis/human-reads-removal` | Removal of human reads from SARS-CoV-2 data | Intermediate | 1h | ✦ |

## Module 4 — Interpretation & Reporting  → `notes/04-interpretation-reporting.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `visualisation/jbrowse2` | Genomic Data Visualisation with JBrowse2 | Intermediate | 1h | ✓ |
| `visualisation/circos` | Visualisation with Circos | Intermediate | 2h | ✦ |
| `introduction/igv-introduction` | IGV Introduction | — | 2h | ✦ |

## Module 5 — Reproducibility  → `notes/05-reproducibility.md`
| Tutorial | Title | Level | Time | Linked? |
|----------|-------|-------|------|:--:|
| `galaxy-interface/workflow-editor` | Creating, Editing and Importing Galaxy Workflows | Intermediate | 30m | ✓ |
| `galaxy-interface/workflow-reports` | Workflow Reports | Intermediate | 30m | ✦ |
| `introduction/galaxy-reproduce` | How to reproduce published Galaxy analyses | Introductory | 1h | ✦ |

---

**Comparison of these against our notes:** see [`COMPARISON.md`](COMPARISON.md).
