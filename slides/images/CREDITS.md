# Image credits

Images used in the slide deck (`slides/deck.md`), with source and license. Grouped by origin.

## Galaxy Training Network — CC-BY 4.0

Sourced from the [GTN training-material](https://github.com/galaxyproject/training-material) repo
(branch `main`), licensed **CC-BY 4.0**. Attribution: *Batut et al. 2018, Cell Systems* and the GTN
community. Fetched 2026-06-28.

| File (`images/gtn/`) | Slide | Source path in `topics/` |
|----------------------|-------|--------------------------|
| `mapping.png` | 30 Aligners | `sequence-analysis/images/mapping/mapping.png` |
| `nanoplot-readlength.png` | 24 Long-read QC | `sequence-analysis/images/quality-control/HistogramReadlength.png` |
| `bandage-assembly-graph.png` | 34 Judging an assembly | `assembly/images/bandage_spades.svg` (rasterized) |
| `volcanoplot.png` | 49 Multiple testing & the volcano | `transcriptomics/images/rna-seq-viz-with-volcanoplot/volcanoplot.png` |
| `binning.png` | 53 Binning → MAGs | `microbiome/tutorials/metagenomics-binning/images/binning.png` |
| `krona-taxonomy.png` | 56 Taxonomy | `microbiome/tutorials/taxonomic-profiling/images/krona-kraken.png` |
| `jbrowse-variants.png` | 60 Visualization | `variant-analysis/images/jbrowse2.png` |
| `galaxy-workflow-editor.png` | 63 Workflow managers | `galaxy-interface/images/workflow_editor_new_workflow.png` |

## Tool-output screenshots

| File | Slide | Source / license |
|------|-------|------------------|
| `images_QC/FastQC_seq_qual.png` | 22 FastQC | FastQC (Babraham Bioinformatics, GPL) "Per base sequence quality" plot |
| `images_QC/multiqc_overview.png` | 23 MultiQC | Screenshot of the [MultiQC](https://multiqc.info/) example RNA-seq report (Seqera; MultiQC GPLv3 / Ewels et al. 2016), captured in light theme. The raw report data is not stored in-repo (gitignored). |

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
