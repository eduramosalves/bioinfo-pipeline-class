# Notes ↔ GTN comparison

Per-module diff of our `notes/` against the imported GTN tutorials (see [`INDEX.md`](INDEX.md)).
Three buckets per module:

- **Match** — note already covers it well (no action).
- **Divergence** — note and GTN differ on a choice/claim; flagged, *not* silently changed.
- **GTN-only & relevant** — substantive item the note lacks that fits the course; ✅ = applied as a
  surgical edit in Phase C, ⏸ = deferred (reason given).

Excluded by design from all enrichment: Galaxy-UI click mechanics (collections, history, upload,
Zenodo/SRA import steps), which are the bulk of the GTN tutorials and don't fit our CLI-first notes.

---

## Module 0 — Foundations
GTN: `galaxy-intro-101`, `galaxy-intro-ngs-data-managment`, `history`.

- **Match:** file formats (FASTA/FASTQ/SAM/BAM/VCF/GFF/BED), Phred encoding, SRA/ENA as read
  sources, experimental-design framing — all covered, and our platform spotlights (Illumina SBS,
  PacBio HiFi, ONT MinION) are *richer* than the GTN intros.
- **GTN-only & relevant:** none worth adding — the GTN intro tutorials are Galaxy-UI orientation
  (histories, upload, dataset management), excluded by design. **No edit.**

## Module 1 — QC & Preprocessing
GTN: `quality-control`, `quality-contamination-control`, `collections`.

- **Match:** FastQC modules and interpretation, MultiQC aggregation, adapter/quality/length
  trimming, paired-end sync, the "interpret in context of library type" stance.
- **Divergence:** GTN's QC tutorial trims with **Cutadapt/Trimmomatic**; our note defaults to
  **fastp**. Not a conflict — note already lists all three with a rationale. *No change.*
- **GTN-only & relevant:**
  - ✅ **Long-read QC tools — Nanoplot & PycoQC.** The note is short-read-only (FastQC/MultiQC/fastp)
    yet Module 0 covers ONT/PacBio heavily. GTN's QC tutorial has dedicated Nanoplot (read-length ×
    quality) and PycoQC (Nanopore run metrics) sections. **Real gap → add.**
  - ✅ **Taxonomic contamination screening at QC time (Kraken2/Bracken).** GTN's bacterial-isolate QC
    tutorial screens for cross-species contamination, not just GC-curve eyeballing. Add a short
    cross-ref callout (full treatment is Module 3c).
  - ⏸ **FASTQE** (emoji per-base quality) — pedagogically cute but redundant with FastQC; deferred.
  - ⏸ **Falco** (FastQC drop-in, faster C++) — minor; mention deferred to keep the tool table tight.

## Module 2 — Core Processing (align / assemble)
GTN: `mapping`, `general-introduction`, `debruijn-graph-assembly`, `mrsa-illumina`, `mrsa-nanopore`,
`hybrid_denovo_assembly`, `assembly-quality-control`, `assembly-with-preprocessing`.

- **Match:** align-vs-assemble fork, BWA/Bowtie2/minimap2, samtools post-processing, SPAdes/MEGAHIT/
  Flye, N50 + completeness, "N50 ≠ correctness."
- **GTN-only & relevant:**
  - ✅ **Shovill** — SPAdes-based pipeline tuned for bacterial isolate assembly (GTN's MRSA-Illumina
    default). Note lists SPAdes/MEGAHIT/Flye but not Shovill. Add to assembler table.
  - ✅ **Hybrid assembly + Unicycler** — combining short + long reads (GTN `hybrid_denovo_assembly`).
    Note covers each platform separately but never hybrid assembly. Add a row/callout.
  - ✅ **Assembly polishing** as an explicit step — long-read drafts get polished (Medaka, Pilon,
    Polypolish), with read prep (Porechop adapters, filtlong length filter, Nanoplot QC). Note only
    mentions "polish" once in a checkpoint answer. Add to the assembly workflow.
  - ✅ **Merqury** (k-mer/QV-based, reference-free assembly evaluation) and **Bandage** (assembly-graph
    visualization) — modern assembly-QC tools the note's QUAST/BUSCO list omits. Add.
  - **Match (already covered):** human/host read subtraction before assembly
    (`assembly-with-preprocessing`) — note 03c already has host removal.

## Module 3a — Variant Calling
GTN: `microbial-variants`, `tb-variant-analysis`, `exome-seq`, `somatic-variants`.

- **Match:** germline vs somatic, MarkDuplicates + BQSR rationale, VCF anatomy, annotation
  (SnpEff/VEP), ACMG/ClinVar, the bcftools bacterial lab.
- **Divergence:** GTN germline lab uses **FreeBayes** (exome-seq) and **VarScan2** (somatic), where
  our note centers **GATK HaplotypeCaller / Mutect2**. Complementary, not conflicting — note already
  frames GATK as one option among several. *No change beyond adding the callers below.*
- **GTN-only & relevant:**
  - ✅ **Snippy** — the de-facto bacterial align+call pipeline (both GTN microbial tutorials use it).
    Note's bacterial lab uses raw bcftools; Snippy is the standard one-shot tool. Add to caller table.
  - ✅ **FreeBayes** — haplotype-based caller (GTN exome lab). Add to caller table.
  - ✅ **Variant normalization** (`bcftools norm`, left-align/decompose indels) before annotation —
    GTN does this in exome + somatic labs; note jumps straight from VCF to annotation. Real gap → add.
  - ⏸ **GEMINI** (load VCF → SQL-queryable variant DB for candidate/inheritance filtering) — useful
    but heavier; add a one-line pointer only.
  - ⏸ **Bacterial AMR/typing** (TB-Profiler, MLST) — lives more naturally in Module 3c pathogen work;
    cross-ref there instead.

## Module 3b — RNA-seq
GTN: `ref-based`, `rna-seq-reads-to-counts`, `rna-seq-counts-to-genes`, `rna-seq-genes-to-pathways`,
`rna-seq-viz-with-volcanoplot`.

- **Match:** spliced (STAR/HISAT2) vs pseudo-alignment (Salmon/kallisto), counts matrix, TPM/CPM vs
  size-factor normalization, "don't feed TPM to DESeq2," negative-binomial DE, BH-FDR, volcano/MA.
- **GTN-only & relevant:**
  - ✅ **Strandedness check before counting** (GTN "Infer Experiment"/`Infer Experiment` step). Wrong
    `-s` setting in featureCounts silently zeros counts — a classic trap the note doesn't warn about.
    Real, high-value gap → add a gotcha callout.
  - ✅ **Functional/pathway enrichment as the next step** — GO (goseq), GSEA (fgsea), KEGG/Pathview.
    The note ends at the DE gene list + volcano; the whole `genes-to-pathways` tutorial is this
    missing downstream. Real gap → add a short "what's next" pointer (also serves Module 4).
  - ✅ **limma-voom** as a third DE engine (GTN `counts-to-genes` default), promoting it from the
    note's footnote into the DE-tools line.
  - ⏸ **DEXSeq** (differential *exon usage* / isoform level) — note is gene-level by design; add only
    a one-clause mention.

## Module 3c — Phage / Metagenomics
GTN: `metagenomics-assembly`, `metagenomics-binning`, `taxonomic-profiling`,
`pathogen-detection-from-nanopore-foodborne-data`, `host-removal`, `human-reads-removal`.

- **Match:** host removal, metagenome-aware assembly (metaSPAdes/MEGAHIT/Flye --meta), Kraken2 +
  Bracken, "database can't see novel phages," CheckV completeness/contamination.
- **GTN-only & relevant:**
  - ✅ **Binning → MAGs** (MetaBAT2/MaxBin2 → DAS Tool/Binette refinement → CheckM quality → dRep
    de-replication). Note goes assembly→viral-ID→taxonomy→annotation and skips recovering *bacterial*
    genomes from the community. Add a short binning callout (the note is phage-leaning, so keep brief).
  - ✅ **MetaPhlAn** — marker-gene taxonomic profiler, the standard alternative to k-mer Kraken2.
    Add to the taxonomy options.
  - ✅ **AMR + virulence + typing** for pathogen genomes — ABRicate (AMR/virulence gene screen), MLST
    (sequence typing), consensus genome building (`bcftools consensus`/medaka), FastTree phylogeny for
    outbreak comparison (GTN foodborne tutorial). Ties back to Module 0's Salmonella example. Add a
    brief "pathogen characterization" pointer.
  - ⏸ **Krona/Pavian** taxonomy viz — already named in Module 4; no duplicate.

## Module 4 — Interpretation & Reporting
GTN: `jbrowse2`, `circos`, `igv-introduction`.

- **Match:** IGV for eyeballing variant calls, volcano/MA/PCA, genome maps + Krona + coverage plots,
  effect-size-vs-significance, methods-with-versions reporting.
- **GTN-only & relevant:**
  - ✅ **Circos** — circular genome plots for SV/CNV/BAF and comparative/whole-genome views (GTN
    cancer-genomics example). Note mentions Pharokka's circular map but not Circos as a general tool.
    Add to the visualization toolkit.
  - ✅ **JBrowse2** — Galaxy-native, shareable genome browser; name it alongside IGV.
  - ⏸ **pyGenomeTracks** (publication track figures) — one-line mention at most; deferred.

## Module 5 — Reproducibility
GTN: `workflow-editor`, `workflow-reports`, `galaxy-reproduce`.

- **Match:** workflow-manager rationale, provenance, version pinning, Galaxy-as-GUI-workflow-manager
  framing (already in the note's "Try it in Galaxy").
- **GTN-only & relevant:**
  - ✅ Refresh the "Try it in Galaxy" list to add **workflow-reports** (automated, shareable run
    reports = reproducible reporting) and **galaxy-reproduce** (re-running a published analysis from a
    shared history/workflow) — both reinforce the note's provenance theme.
  - ⏸ Workflow-editor UI mechanics — excluded (UI-specific).
