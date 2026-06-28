# Slide Outline — Methods & Workflow of a Bioinformatics Pipeline Analysis

A slide-by-slide deck mirroring `notes/` Modules 0–5. Each slide = **title + 3–5 bullets + a
speaker-note paragraph**. ~64 slides → ~4–5 h with discussion, or trim Module 3 to one domain for a
~2 h focused session.

**Recurring element — the "skeleton" slide.** Slides marked `[skeleton]` re-show the universal
pipeline diagram with the *current stage highlighted*, so the audience always knows where they are.
In the rendered deck (`deck.md`) these carry an **SVG `workflow` icon** — never an emoji — per the
brandbook (`~/estudio/knowledge/brandbook.md` §5).
```
Design → QC → Preprocess → [ALIGN ⟋ ASSEMBLE] → Downstream → Interpret → (Reproducibility wraps all)
```

---

## Title & framing (Slides 1–4)

**Slide 1 — Title**
- Methods & Workflow of a Bioinformatics Pipeline Analysis
- Audience: grad / early-career researchers, biology-comfortable, NGS-newer
- Format: lecture (these slides) + notes handout + hands-on lab
- *Speaker note:* Set expectations — by the end they'll read any NGS pipeline as one skeleton with
  swappable parts, and will have run both an alignment and an assembly pass themselves.

**Slide 2 — Why this class exists**
- Bioinformatics looks like 4 unrelated workflows (variants, RNA-seq, metagenomics, ...)
- It's really ONE skeleton with different middle/back ends
- Learn the skeleton once → instantiate forever
- *Speaker note:* Name the pain — students drown memorizing tool zoos. Reframe: tools are
  implementations of stages; stages are stable. This is the whole thesis of the course.

**Slide 3 — [skeleton] The universal pipeline skeleton**
- Design → QC → Preprocess → Core (align ⟋ assemble) → Downstream → Interpret → Reproducibility
- Each junction is a FILE FORMAT
- Front half shared; back half branches
- *Speaker note:* Walk left to right once. Emphasize the fork at "Core" and that reproducibility is
  the box around everything, not a final step. This diagram returns every module.

**Slide 4 — Roadmap & how to use the materials**
- 6 modules; ~3–4 h lecture + 2 h lab
- Notes for self-study, slides for delivery, hands-on for the lab
- Three parallel domain modules (3a/3b/3c) — survey all or pick one
- *Speaker note:* Tell them the lab deliberately makes them take both forks: align+call on E. coli,
  assemble+identify on a phage.

---

## Module 0 — Foundations (Slides 5–20)

**Slide 5 — [skeleton] Module 0: Foundations (stage: Design + formats)**
- What a pipeline is; why we formalize it (reproducibility, scale, reasoning)
- *Speaker note:* "Pipeline = plumbing; junctions are file formats." Most pain is format-wrangling.

**Slide 6 — Sequencing platforms**
- Short read (Illumina) vs long read (ONT / PacBio HiFi)
- Length, accuracy, throughput trade-offs
- *Speaker note:* The platform is the FIRST fork — it cascades into aligner, assembler, error model.

**Slide 7 — The platform cascade**
- ONT → minimap2 (not BWA), Flye (not SPAdes), indel-heavy error profile
- Illumina → BWA/Bowtie2, SPAdes/MEGAHIT, accurate SNVs
- *Speaker note:* Hammer: a Module-0 choice silently rewrites your Module-2/3 toolset.

**Slide 8 — Illumina (SBS): the high-accuracy workhorse**
- Mechanism: fragment → adapter ligate → cluster amplify → SBS → FASTQ
- Highest accuracy & throughput — Q30+, billions of reads per run; cheapest per base
- Short-read limit: cannot span long repeats or resolve large SVs
- *Speaker note:* The short-read workhorse behind the Illumina branch. Walk the four-step loop:
  library prep → cluster amplification → SBS imaging → FASTQ. Sell the strengths then be honest
  about the limit: short reads can't span repeats, which is exactly why this branch uses BWA/Bowtie2
  + SPAdes/MEGAHIT.

**Slide 9 — Illumina SBS: step by step**
- (A) Library prep: fragment gDNA + ligate P5/P7 adapters + index
- (B) Cluster amplification: bridge-amplify each fragment into a clonal cluster on the flow cell
- (C) Sequencing-by-synthesis: add one fluorescent reversible-terminator per cycle → image → cleave → repeat
- (D) Alignment & analysis: align reads to reference → call variants/counts
- *Speaker note:* The real SBS methodology in the order it runs. Emphasize that the adapter index
  is what lets many samples share one run (multiplexing). The cluster step is why the signal is
  detectable — one molecule produces no signal; a clonal cluster does.

**Slide 10 — Library preparation: adapters on every fragment**
- Fragment shear gDNA to target insert size
- Ligate P5/P7 adapters + sample index onto both ends (A·T overhang)
- Every fragment now has: flow-cell hybridization handle + amplification primer + sequencing primer + barcode
- *Speaker note:* A zoom on step (A). The adapters are the handles that let the fragment do everything
  else — hybridize to the flow cell, get amplified, and get sequenced. The index inside the adapter
  is what enables multiplexing: many samples, one run, demultiplexed by barcode.

**Slide 11 — Illumina genotyping array: a different workflow**
- BeadArray SNP genotyping — NOT sequencing-by-synthesis
- (1) 200–400 ng gDNA → (2) PCR-free whole-genome amplification → (3) fragment
- (4) Hybridize to 50-mer locus-specific probes → single-base extension with fluorescent dNTP → genotype by color
- *Speaker note:* Flag this explicitly: the Infinium array is a completely different Illumina platform.
  No flow cell, no cluster amplification, no per-base quality string — you get a genotype call per
  probe (0/0, 0/1, 1/1), not sequence reads. Students confuse the two.

**Slide 12 — PacBio HiFi: long AND accurate**
- Mechanism: polymerase in a ZMW reads a circular SMRTbell template repeatedly → CCS → HiFi read
- Long (~10–25 kb) and accurate (Q30+) — circular consensus cancels random per-pass error
- Gold standard for de novo assembly, phasing, and full-length amplicons
- *Speaker note:* The accurate long-read platform. Zero-mode waveguide (ZMW) = nanoscale well that
  illuminates only the polymerase's active site. SMRTbell = hairpin-capped circular template. Many
  passes → CCS → Q30+. Trade-off: more expensive and lower throughput than Illumina, pairs with
  minimap2 + hifiasm/Flye.

**Slide 13 — PacBio HiFi in practice: full-length 16S profiling**
- Amplify V1–V9 (~1,500 bp) with dual-barcoded primers → pool → SMRTbell library → HiFi sequence
- Full-length reads → species/strain-level taxonomy (short V3–V4 cannot)
- Dual index plate layout → up to 192 samples per run
- *Speaker note:* A real HiFi use-case. Stress the key insight: HiFi reads the **entire** 16S gene,
  so taxonomy resolves to species or even strain. Short Illumina reads cover only V3–V4 and top out
  at genus. This is the practical payoff of long + accurate reads.

**Slide 14 — MinION: nanopore sequencing in your palm**
- DNA threads through a protein nanopore → ionic-current squiggle → basecaller (Dorado) → FASTQ
- Real-time & portable — USB-powered, palm-sized; reads stream as they sequence
- Ultra-long reads (>100 kb possible); trade-off: indel-heavy error profile → minimap2 + Flye
- *Speaker note:* The long-read device behind the ONT branch. Sell the three superpowers: real-time,
  portable, ultra-long. Be honest about the trade-off: higher per-base error (especially indels in
  homopolymers), mitigated by modern basecallers and depth. This error profile is exactly why the
  ONT branch uses minimap2 (not BWA) and Flye (not SPAdes).

**Slide 15 — MinION in practice: Salmonella colony → serotype same day**
- Direct-from-colony: pick colony → Rapid PCR Barcoding Kit → 24 barcoded samples → load R10.4.1 flow cell
- MinKNOW real-time HAC basecalling → EPI2ME wf-bacterial-genomes → Flye assembly + Medaka polish
- Output: species ID + serotype + MLST + AMR profile — no DNA extraction required
- *Speaker note:* A real end-to-end ONT workflow that threads every idea from the branch together.
  Key teaching points: (1) library prep skips DNA extraction entirely (direct-from-colony); (2) real-time
  basecalling means you watch results arrive; (3) this is the ASSEMBLE branch — the genome is
  reconstructed de novo, no reference needed. Returns in Module 3c (pathogen typing: AMR/MLST).

**Slide 16 — Experimental design**
- Replicates (biological ≫ technical), controls, depth/coverage
- Batch effects: randomize, record as metadata
- *Speaker note:* Bioinformatics can't rescue a confounded design. The March/June batch story (use
  it as a recurring cautionary tale; it returns in Module 4).

**Slide 17 — File formats: the connective tissue (overview)**
- FASTA, FASTQ, SAM/BAM/CRAM, VCF, GFF/GTF, BED
- Each format = output of one stage, input of the next
- *Speaker note:* Don't memorize columns; learn *which stage emits each*. Detail on next slides.

**Slide 18 — FASTQ & Phred quality**
- 4 lines/read; quality string = per-base Phred (Q = −10·log10 P)
- Q20=1%, Q30=0.1%; Phred+33 ASCII encoding
- *Speaker note:* This quality string is the entire reason QC (Module 1) exists. Quick ASCII demo.

**Slide 19 — BAM, VCF, GFF/BED in one breath**
- BAM = aligned reads (POS, MAPQ, CIGAR); VCF = variants; GFF/GTF = features; BED = plain intervals
- BED is 0-based; GFF/VCF 1-based (off-by-one trap)
- *Speaker note:* "BED counts from zero" — say it twice; it bites everyone once.

**Slide 20 — Worked example: one read, FASTQ → BAM → VCF**
- Same observation, three formats: quality letter → CIGAR mismatch → genotyped row
- *Speaker note:* This is the whole pipeline in one slide. The read never changes; the *format*
  does. Return to this image whenever someone is lost.

---

## Module 1 — QC & Preprocessing (Slides 21–27)

**Slide 21 — [skeleton] Module 1: QC & Preprocessing (stage highlighted)**
- Garbage in → garbage out; cheapest place to catch disaster
- *Speaker note:* Raw FASTQ is NOT trustworthy raw material — adapters, low-qual tails, contaminants.

**Slide 22 — FastQC: the metrics that matter**
- Per-base quality, adapter content, overrepresented seqs, duplication, GC
- Pass/Warn/Fail = a prompt, not a verdict
- Make the GC second-peak explicit: screen contamination with Kraken2/Bracken
- *Speaker note:* "Read FastQC like a doctor reads a chart" — interpret in context of library type.
  A GC second peak only hints at contamination; a taxonomic screen (Kraken2) confirms the sample is
  your target species. Full profiling is Module 3c.

**Slide 23 — MultiQC: aggregate & spot the outlier**
- One report, all samples, every step
- The outlier view is the payoff
- *Speaker note:* Highest value / lowest effort tool in the course. Run after every batch step.

**Slide 24 — [new] Long reads need different QC tools**
- FastQC's plots assume short, fixed-length reads
- Nanoplot — read-length × quality (the long-read analog of the FastQC panels)
- PycoQC — Nanopore run health: per-channel activity, yield over time, basecall quality
- *Speaker note:* Module 0 spent three slides on ONT/PacBio, but QC tools so far were short-read only.
  Read-length distribution is the headline metric — a healthy ONT run is long-tailed; a collapse
  toward short reads = degraded input or failing pores. Long-read trimming/filtering (Porechop,
  filtlong) shows up in the Module 2 assembly workflow.

**Slide 25 — Trimming tools**
- fastp (default), Trimmomatic (explicit/legacy), cutadapt (adapter specialist)
- What trimming does: adapters, quality, length, polyG
- *Speaker note:* fastp = one fast pass + its own report. Show the table; default to fastp.

**Slide 26 — Decision rules**
- Always remove adapters; quality-trim only decayed 3' tails
- Don't over-trim (hurts mappability); don't hard-trim the 5' wobble
- Paired-end: keep mates in sync (pair-aware tool!)
- *Speaker note:* By goal — variants: light; assembly: more; pseudo-align RNA: often adapters only.

**Slide 27 — Module 1 checkpoint**
- Duplication FAIL in deep RNA-seq → panic? (no)
- *Speaker note:* Use as a discussion beat; let them answer before revealing.

---

## Module 2 — Core Processing: the fork (Slides 28–35)

**Slide 28 — [skeleton] Module 2: Core processing — THE BRANCH POINT**
- Align to a reference ⟋ Assemble de novo
- Everything before = shared; everything after = diverges here
- *Speaker note:* The single most important conceptual slide. Slow down.

**Slide 29 — The fork: do you already have a map?**
- Align: "how does my sample differ from a known genome?" → BAM
- Assemble: "what is the sequence I just got?" → FASTA
- Jigsaw with the box picture (align) vs without (assemble)
- *Speaker note:* The decision rule = does a trustworthy reference exist?

**Slide 30 — Aligners**
- BWA-MEM (DNA/variants), Bowtie2 (general/ChIP), minimap2 (long reads)
- Right reference, indexed, documented
- *Speaker note:* Spliced RNA aligners (STAR/HISAT2) are a special case → Module 3b.

**Slide 31 — Reads → usable BAM (samtools)**
- bwa mem | samtools sort → index → flagstat
- Low % mapped = wrong ref / contamination / adapters
- *Speaker note:* samtools is the swiss-army knife. flagstat is your first reality check.

**Slide 32 — De novo assembly**
- SPAdes (isolate/meta), MEGAHIT (big metagenomes), Flye (long read)
- Shovill (SPAdes wrapper for bacterial isolates), Unicycler (hybrid short+long)
- de Bruijn graphs (short) vs overlap (long)
- *Speaker note:* No reference → reconstruct by overlap. Compute/memory heavy. Shovill is the
  pragmatic default for one short-read bacterial genome; when you have both Illumina and ONT, hybrid
  (Unicycler) beats either alone.

**Slide 33 — [new] Long-read prep & polishing**
- Prep first: Porechop (adapters) + filtlong (keep best reads) + Nanoplot QC
- Polish after: Medaka (ONT consensus), Pilon / Polypolish (short reads)
- Polishing lifts a raw Flye draft from ~Q30 to near-finished
- *Speaker note:* Two steps short-read work doesn't have. Long-read drafts carry indel/homopolymer
  errors — polishing is not optional. Hybrid in disguise: long-read assemble then short-read polish
  = the same short+long combination Unicycler automates.

**Slide 34 — Judging an assembly: N50 & friends**
- # contigs, N50 (contiguity), total length, completeness (BUSCO/CheckV)
- Merqury (k-mer QV, reference-free), Bandage (look at the assembly graph)
- N50 rewards length, NOT correctness → always pair with completeness
- *Speaker note:* The "higher N50 but 71% complete" trap (returns in checkpoint). Merqury estimates
  consensus quality from read k-mers with no reference; Bandage shows tangles (repeats/contamination)
  the linear FASTA hides.

**Slide 35 — Mapping domains to branches**
- Variants & RNA-seq → ALIGN; metagenomics/phage → ASSEMBLE
- *Speaker note:* The line to memorize. Lab makes them do both. Transition into Module 3.

---

## Module 3a — Variant Calling (Slides 36–42)

**Slide 36 — [skeleton] Module 3a: Variant calling (ALIGN branch)**
- BAM → where & how does the sample differ → does it matter?
- Germline vs somatic
- *Speaker note:* This branch consumes the aligned BAM.

**Slide 37 — GATK Best Practices arc**
- MarkDuplicates → BQSR → HaplotypeCaller → joint genotyping → filtering
- *Speaker note:* Each step kills a specific false-call source. Dedup+BQSR make evidence honest;
  HaplotypeCaller makes calls; filtering keeps the defensible ones.

**Slide 38 — Alternative callers**
- bcftools (light/bacterial — used in lab), Snippy (bacterial all-in-one), FreeBayes (pooled/odd ploidy)
- DeepVariant (DL, long-read), Mutect2 (somatic)
- *Speaker note:* Right tool for scale. GATK's full arc is overkill on a phage/E. coli genome. Snippy
  is the de-facto bacterial pipeline (the GTN microbial labs use it); FreeBayes is Snippy's engine
  and handles non-diploid samples.

**Slide 39 — VCF anatomy**
- CHROM POS REF ALT QUAL FILTER INFO FORMAT/sample; GT 0/0,0/1,1/1
- *Speaker note:* Read one row aloud as a sentence. DP/AD/GQ are the trust signals.

**Slide 40 — [new] Normalize variants first**
- The same indel can be written several equivalent ways
- `bcftools norm -f ref.fa -m -` — left-align indels + split multi-allelic sites
- Un-normalized → won't match ClinVar/gnomAD or another caller's VCF → annotation silently misses
- *Speaker note:* Easy to skip, quietly costly — a standard step in the GTN exome/somatic labs. Two
  callers can emit the "same" variant at different positions/representations; normalization makes
  them comparable and lets annotation databases match. Do it before annotating or comparing VCFs.

**Slide 41 — Annotation: coordinate → consequence**
- VEP / SnpEff / ANNOVAR; gene, consequence, gnomAD frequency, in-silico scores
- *Speaker note:* Raw VCF says *where*, not *what it does*. Annotation feeds interpretation.

**Slide 42 — Clinical interpretation: ACMG/AMP + ClinVar**
- 5 tiers (Pathogenic → VUS → Benign); evidence criteria (PVS1/PS/PM2/PP3/BA1...)
- ClinVar = prior interpretations; VUS is the honest common verdict
- *Speaker note:* Ties to VariantScribe. A statistical call ≠ a diagnosis. Conservative + uncertainty.

---

## Module 3b — RNA-seq (Slides 43–50)

**Slide 43 — [skeleton] Module 3b: RNA-seq (ALIGN / pseudo-align)**
- Measure how much each gene is expressed; compare conditions
- The twist: introns removed → reads span junctions
- *Speaker note:* Why DNA aligners don't suffice for mRNA.

**Slide 44 — Two routes to counts**
- A: spliced alignment (STAR/HISAT2) + featureCounts/HTSeq (or DEXSeq for exon usage)
- B: pseudo-alignment (Salmon/kallisto) + tximport — the fast default
- *Speaker note:* Want counts for DE? Salmon. Need alignments (isoforms/RNA variants, differential
  exon usage via DEXSeq)? STAR.

**Slide 45 — [new] Strandedness: the silent count-killer**
- Preps are unstranded / forward / reverse → featureCounts -s 0/1/2 must match
- Wrong setting → counts come back near-zero for every gene, no error
- Infer it first — RSeQC Infer Experiment (or Salmon auto-detects)
- *Speaker note:* A classic that wastes a day. The run "succeeds"; the counts are garbage.
  Pseudo-aligners detect strandedness automatically — one less foot-gun. If a whole-experiment count
  matrix looks empty, suspect this first.

**Slide 46 — The count matrix**
- genes × samples; filter low-count genes
- *Speaker note:* The convergence point — both routes end here; it's the DE input.

**Slide 47 — Normalization: raw counts lie**
- Library size, gene length, composition
- CPM / TPM (within-sample) vs DESeq2 size factors / edgeR TMM (across-sample DE)
- DON'T feed TPM to DESeq2 — it wants raw counts
- *Speaker note:* The most common RNA-seq mistake. Say the "raw counts" rule explicitly.

**Slide 48 — Differential expression (DESeq2/edgeR/limma-voom)**
- Negative binomial (DESeq2/edgeR); size factors + dispersion + GLM + test
- limma-voom: third engine (log-CPM + precision weights), robust with many samples
- Output: log2FC + padj; lfcShrink for stable effect sizes
- *Speaker note:* n≥3 replicates floor; more replicates beat more depth. Any of the three is
  defensible — pick one and report it (limma-voom is the GTN default).

**Slide 49 — Multiple testing & the volcano**
- ~20k genes → ~1000 false "hits" at p<0.05; use BH FDR (padj)
- Combine padj threshold WITH effect size; volcano/MA plots
- *Speaker note:* Significant ≠ meaningful (padj 1e-30, log2FC 0.08). Big idea.

**Slide 50 — [new] Functional enrichment: from list to biology**
- A DE table is a means, not the end — which pathways/processes moved?
- ORA (goseq — RNA-seq length-aware) on the significant list
- GSEA (fgsea) ranks all genes; KEGG/Pathview to map
- *Speaker note:* The missing downstream — the notes end at the gene list; real analysis continues
  here. ORA thresholds then tests over-representation; GSEA needs no threshold. The trap: use the
  right background (expressed genes, not the genome) and correct length bias (goseq).

---

## Module 3c — Phage / Metagenomics (Slides 51–58)

**Slide 51 — [skeleton] Module 3c: Phage/metagenomics (ASSEMBLE branch)**
- All DNA in a sample; novel, uncultured genomes; no single reference
- Lean: virome/phage
- *Speaker note:* Why assemble not align — alignment only sees the known.

**Slide 52 — Host removal → assembly**
- Strip host/PhiX reads (keep non-host); metaSPAdes/MEGAHIT/Flye --meta
- *Speaker note:* Phage prep is mostly host DNA; also a privacy step for human samples.

**Slide 53 — [new] Binning → MAGs (the bacterial side)**
- The same assembly feeds the bacterial side, not just viruses
- MetaBAT2/MaxBin2 (bin) → DAS Tool/Binette (reconcile) → CheckM (quality) → dRep (de-dup)
- Groups contigs into MAGs by tetranucleotide signature + coverage
- *Speaker note:* This module follows the viral contigs, but binning recovers the organisms. CheckM
  is the bacterial analog of CheckV (completeness + contamination per genome). Reach for it when you
  want "who is here, as genomes," not just read-level taxonomy.

**Slide 54 — Viral identification**
- geNomad / VirSorter2 score contigs for viral signal; find proviruses
- *Speaker note:* Output of assembly is an undifferentiated contig pile; this separates viral.

**Slide 55 — CheckV: how good is each viral genome?**
- Completeness + contamination + provirus trimming
- Viral analog of BUSCO/QUAST; completeness ≠ contiguity
- *Speaker note:* Report phages with their CheckV tier. 18% contamination ≈ host on a prophage.

**Slide 56 — Taxonomy: Kraken2 + Bracken (+ MetaPhlAn)**
- Kraken2 classifies reads; Bracken re-estimates abundance
- MetaPhlAn — marker-gene alternative (cleaner species/strain, smaller DB); cross-check
- Database caveat: novel phages = unclassified (that's the interesting bit)
- *Speaker note:* This is exactly why assembly+CheckV matters — characterize the unknown. Kraken2 =
  k-mer (sees everything in the DB); MetaPhlAn = clade markers (fewer spurious low-level hits).
  Visualize either with Krona/Pavian.

**Slide 57 — Phage annotation: Pharokka**
- PHANOTATE gene calling + PHROGs DB; phage-tuned; genome map
- Prokka/Bakta = general bacterial (more "hypothetical")
- *Speaker note:* Phage genes sparse in generic DBs → use the phage-specialized tool.

**Slide 58 — [new] When it's a pathogen: AMR / virulence / typing**
- ABRicate — screen contigs for AMR + virulence genes
- MLST — sequence type for outbreak tracking; bcftools consensus / medaka — consensus genome
- FastTree — phylogeny to compare isolates
- *Speaker note:* Shifts the annotation question from "what gene" to "is it resistant, virulent,
  which strain." This is the Module-0 Salmonella example (serotype + 7-gene MLST + AMR); the GTN
  foodborne Nanopore tutorial walks the whole arc. Ties the module back to the opening ONT story.

---

## Module 4 — Interpretation & Reporting (Slides 59–61)

**Slide 59 — [skeleton] Module 4: Interpretation & reporting**
- Numbers → defensible biological claims
- Visualize BEFORE you believe
- *Speaker note:* Pipeline exiting 0 means it ran, not that it's right.

**Slide 60 — Visualization & stats per domain**
- IGV / JBrowse2 (variants — strand/end/homopolymer artifacts; JBrowse2 = shareable)
- Volcano/MA/PCA (RNA-seq), genome maps/Krona (phage), Circos (SV/CNV/comparative)
- Effect size + significance; multiple testing everywhere; differential ≠ functional
- *Speaker note:* The IGV strand-bias story and the PCA-clusters-by-date story (= batch effect).
  JBrowse2 embeds in a report/shared workflow; Circos is the circular multi-track view for
  structural/comparative genomics — powerful but fiddly.

**Slide 61 — What a good report contains**
- Question/design, methods WITH versions, QC summary, results with uncertainty, bounded
  interpretation, reproducibility pointers
- *Speaker note:* "BWA-MEM" ≠ reproducible; "BWA-MEM 0.7.17, GRCh38, default params" is.

---

## Module 5 — Reproducibility (Slides 62–64)

**Slide 62 — [skeleton] Module 5: Reproducibility wraps everything**
- Why a workflow manager: resume, parallelism, portability, reproducibility
- *Speaker note:* Not a final step — the box around the whole skeleton.

**Slide 63 — Workflow managers & environments**
- Nextflow + nf-core (sarek=3a, rnaseq=3b, mag=3c) | Snakemake (Pythonic, file rules)
- conda/mamba (pin versions!) + containers (Docker/Singularity/Apptainer)
- *Speaker note:* THE punchline — everything you did by hand, nf-core runs for you; now you can
  trust/configure/debug it instead of black-boxing it.

**Slide 64 — Provenance & close**
- Version pinning, parameter logging, seeds, git for code, data in SRA/ENA/Zenodo
- The reproducibility test: could you/someone regenerate this in 2 years?
- *Speaker note:* Recap the skeleton one last time; point them to the hands-on lab. Close.

---

### Delivery notes
- **Full survey:** all 64 slides, ~4–5 h with the checkpoint discussion beats.
- **Focused session (~2 h):** Slides 1–35 (through Module 2) + ONE of {3a, 3b, 3c} + 59–64. Drop the
  other two domain blocks.
- The [skeleton] skeleton slides are your navigation anchors — never skip them; they're how the audience
  keeps orientation across a long session.
- **Galaxy (GUI) companion.** Each module's speaker notes in `deck.md` carry a "GUI alternative (GTN)"
  pointer to the matching [Galaxy Training Network](https://training.galaxyproject.org/) tutorial —
  same stages/tools, web interface, no terminal. Mention it for mixed-skill audiences or when conda
  setup is a barrier; the course stays CLI-first. Full map in `resources/references.md`; 35 of these
  tutorials are mirrored locally under `resources/galaxy/` (see its `INDEX.md` / `COMPARISON.md`).
  Per module: M0→introduction · M1→sequence-analysis/quality-control + quality-contamination-control ·
  M2→sequence-analysis/mapping + assembly (incl. hybrid, assembly-quality-control) ·
  M3a→variant-analysis (incl. tb-variant-analysis) · M3b→transcriptomics (incl. genes-to-pathways) ·
  M3c→microbiome (incl. metagenomics-binning, host-removal; phage/virome thinner, keep
  geNomad/CheckV/Pharokka CLI) · M4→visualisation/jbrowse2 + circos + igv-introduction ·
  M5→galaxy-interface/workflows + workflow-reports + introduction/galaxy-reproduce.
