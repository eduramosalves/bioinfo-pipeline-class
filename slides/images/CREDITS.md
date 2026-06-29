# Image credits

Images used in the slide deck (`slides/deck.md`), with source and license. Grouped by origin.

## Galaxy Training Network — CC-BY 4.0

Sourced from the [GTN training-material](https://github.com/galaxyproject/training-material) repo
(branch `main`), licensed **CC-BY 4.0**. Attribution: *Batut et al. 2018, Cell Systems* and the GTN
community. Fetched 2026-06-28.

| File (`assets/`) | Slide | Source path in `topics/` |
|----------------------|-------|--------------------------|
| `fastqc-per-base-quality.png` | 22 FastQC | `sequence-analysis/images/quality-control/per_base_sequence_quality-before.png` |
| `mapping.png` | 30 Aligners | `sequence-analysis/images/mapping/mapping.png` |
| `nanoplot-readlength.png` | 24 Long-read QC | `sequence-analysis/images/quality-control/HistogramReadlength.png` |
| `busco-assessment.png` | 34 Judging an assembly | `assembly/images/denovo_assembly/busco_plot_bacillales_odb10.png` |
| `volcanoplot.png` | 49 Multiple testing & the volcano | `transcriptomics/images/rna-seq-viz-with-volcanoplot/volcanoplot.png` |
| `binning.png` | 53 Binning → MAGs | `microbiome/tutorials/metagenomics-binning/images/binning.png` |
| `krona-taxonomy.png` | 56 Taxonomy | `microbiome/tutorials/taxonomic-profiling/images/krona-kraken.png` |
| `jbrowse-variants.png` | 60 Visualization | `variant-analysis/images/jbrowse2.png` |

## nf-core — CC-BY

| File (`images/gtn/`) | Slide | Source / license |
|----------------------|-------|------------------|
| `nfcore-rnaseq-metromap.png` | 63 Workflow managers | nf-core/rnaseq metro map — <https://github.com/nf-core/rnaseq> `docs/images/nf-core-rnaseq_metro_map_grey.png` (nf-core; diagram CC-BY, pipeline MIT) |

## Tool-output figures

| File (`assets/`) | Slide | Source / license |
|------|-------|------------------|
| `multiqc-general-stats.png` | 23 MultiQC | [MultiQC](https://multiqc.info/) "General Statistics" table — `docs/images/genstats_grouping_ungrouped.png` from the [MultiQC repo](https://github.com/MultiQC/MultiQC) (**GPL-3.0** / Ewels et al. 2016, *Bioinformatics*). |
| `pharokka-genome-map.png` | 56 Pharokka | Pharokka circular phage genome map — `img/SAOMS1_plot.png` from the [Pharokka repo](https://github.com/gbouras13/pharokka) (**MIT** / Bouras et al. 2023, *Bioinformatics*). *Staphylococcus* phage SAOMS1 (GenBank **MW460250.1**; isolated by Yerushalmy et al., Hebrew University). |

## Oxford Nanopore Technologies

| File | Slide | Source |
|------|-------|--------|
| `images_MinION/minion-salmonella-hero.png` | 15 MinION Salmonella | Rendered from the ONT protocol PDF *"Direct-from-colony microbial sequencing: rapid Salmonella serotyping"* (`images_MinION/…salmonella.pdf`). © Oxford Nanopore Technologies — vendor protocol, used for teaching. |

## Vendor platform figures (Illumina / PacBio)

Product photos and educational workflow diagrams from the instrument vendors, provided with the
course materials and used for teaching. © the respective vendors.

| File (`images_illumina/`, `images_PacBio/`) | Slide | Vendor |
|---------------------------------------------|-------|--------|
| `illumina-sbs-workflow.jpg` | 9 SBS step by step | Illumina (SBS A→D workflow) |
| `illumina-library-prep.jpg` | 10 Library prep | Illumina |
| `illumina-genotyping-workflow.jpg` | 11 Genotyping array | Illumina (Infinium workflow) |
| `hires-miseqdx-right.jpg`, `hires-miseq-flowcell-side.jpg` | 8 Illumina workhorse | Illumina (MiSeqDx + flow cell) |
| `pacbio-smrtcell.png` | 12 PacBio HiFi | Pacific Biosciences (SMRT Cell) |
| `pacbio-revio-vega.png` | 13 HiFi in practice | Pacific Biosciences (Revio / Vega) |

> Vendor figures and protocol documents are third-party materials included for educational use; their
> copyright remains with Illumina, PacBio, and Oxford Nanopore respectively. Replace with
> openly-licensed equivalents if the deck is to be redistributed.
