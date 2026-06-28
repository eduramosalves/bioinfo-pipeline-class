# Module 2 — Core Processing: Alignment vs Assembly (the branch point)

## Learning objectives
By the end of this module you can:
- Explain the central fork: **align to a reference** vs **assemble de novo**, and decide which a
  given project needs.
- Run reference alignment with **BWA-MEM / Bowtie2 / minimap2** and post-process with `samtools`.
- Run de novo assembly with **SPAdes / MEGAHIT / Flye** and judge a draft with **N50** and other
  assembly QC.
- Map each downstream domain to its usual branch.

---

## Where we are
```
  Experimental design
  Raw data + QC
  Preprocessing
  Core processing (align ⟋ assemble)   ◀── you are here — THE FORK
  Domain-specific downstream
  Interpretation & reporting
  Reproducibility
```

This is the most important conceptual slide in the course. **Everything before this is shared;
everything after this diverges from here.**

---

## 1. The fork: do you have a map already?

> **Align** when a trustworthy reference genome exists and you want to know *how your sample
> differs* from it.
> **Assemble** when there is no good reference (novel organism, mixed community, structural
> rearrangement) and you want to *reconstruct the sequence itself.*

| | **Reference alignment** | **De novo assembly** |
|---|---|---|
| Question | "How does my sample differ from a known genome?" | "What is the sequence I just sequenced?" |
| Needs | a reference FASTA | no reference |
| Output | BAM (reads placed on a coordinate system) | FASTA (new contigs/scaffolds) |
| Cheaper/faster | yes | no (compute- and memory-heavy) |
| Used by | **variant calling, RNA-seq** | **metagenomics, phage, novel-genome projects** |

The puzzle analogy: alignment is doing a jigsaw *with the picture on the box* (place each piece on
the reference). Assembly is doing it *with no box* — you fit pieces to each other by overlap.

---

## 2. Reference alignment

### Choosing an aligner
| Aligner | Best for |
|---------|----------|
| **BWA-MEM / BWA-MEM2** | short reads for DNA variant calling — the de-facto standard |
| **Bowtie2** | short reads; very common, tunable end-to-end vs local; popular for ChIP-seq |
| **minimap2** | **long reads (ONT/PacBio)** and spliced long-read; also short reads. The long-read standard |

(Spliced *short*-read RNA-seq aligners — STAR, HISAT2 — are a special case covered in Module 3b,
because mRNA reads jump across introns.)

### The reference matters
Align to the *right* genome build and version, and document it (e.g. human GRCh38, *E. coli*
K-12 MG1655). The reference must be **indexed** once before alignment. Garbage reference →
garbage coordinates.

### From reads to a usable BAM
Alignment emits SAM; you almost always immediately convert, sort, and index:
```bash
# Index the reference once
bwa index reference.fasta

# Align paired reads → pipe straight into a sorted BAM (avoid a huge SAM on disk)
bwa mem -t 4 reference.fasta sample_R1.trim.fastq.gz sample_R2.trim.fastq.gz \
  | samtools sort -@ 4 -o sample.sorted.bam -

# Index the BAM (random access for callers/viewers)
samtools index sample.sorted.bam

# Sanity-check the alignment
samtools flagstat sample.sorted.bam      # % mapped, properly paired, duplicates
```
`samtools` is the swiss-army knife here: `view` (filter/convert), `sort`, `index`, `flagstat`/
`stats` (QC), `depth`/`coverage` (how deep). A low "% mapped" in `flagstat` is a red flag — wrong
reference, contamination, or unremoved adapters.

---

## 3. De novo assembly

When there's no reference, reconstruct the sequence by overlapping reads. Modern short-read
assemblers use **de Bruijn graphs** (break reads into k-mers, find a path through the graph);
long-read assemblers use overlap-based methods.

### Choosing an assembler
| Assembler | Best for |
|-----------|----------|
| **SPAdes** | bacterial / small-genome short-read assembly; `--isolate`, `--meta` (= metaSPAdes), `--rna` modes |
| **Shovill** | a SPAdes/SKESA *wrapper* tuned for **bacterial isolates** — trims, subsamples, assembles, and corrects in one fast pass; the pragmatic default for a single short-read bacterial genome |
| **MEGAHIT** | large/complex **metagenomes**, memory-efficient and fast |
| **Flye** | **long-read** assembly (ONT/PacBio); `--meta` for metagenomes; great for complete genomes |
| **Unicycler** | **hybrid** (short + long) bacterial assembly — uses long reads to scaffold/resolve repeats and short reads for base accuracy; also does short-read-only |

**Short + long together (hybrid).** When you have both Illumina and ONT/PacBio for one isolate, a
hybrid assembly beats either alone: long reads span repeats to give contiguity, short reads supply
per-base accuracy. **Unicycler** orchestrates this directly; the alternative is *long-read assemble
then short-read polish* (next).

### Running an assembly
```bash
# Short-read isolate (e.g. a phage or bacterial genome)
spades.py --isolate -1 sample_R1.trim.fastq.gz -2 sample_R2.trim.fastq.gz \
  -o spades_out -t 4 -m 16
# → spades_out/contigs.fasta and scaffolds.fasta

# Long-read assembly
flye --nano-raw reads.fastq.gz --out-dir flye_out --threads 4
```

### Long-read prep & polishing
Long-read assembly has two extra steps short-read work doesn't:
- **Read prep first** — **Porechop** removes ONT adapters, **filtlong** length/quality-filters to
  keep the best reads, and **Nanoplot** (Module 1) confirms the read-length profile.
- **Polish after** — a raw long-read draft still carries indel/homopolymer errors. **Medaka**
  (ONT consensus) polishes using the long reads; **Pilon** or **Polypolish** polish using *short*
  reads when you have them (the second half of a hybrid strategy). Polishing is what lifts a Flye
  draft from ~Q30 to near-finished quality.

### Judging a draft assembly
A FASTA of contigs needs evaluation before you trust it:
- **Number of contigs** — fewer, longer contigs = more contiguous (better). Thousands of tiny
  contigs = fragmented.
- **N50** — the contig length such that 50% of the assembly is in contigs ≥ that length. A *single
  summary of contiguity*; bigger is better. (Think: "half my assembly sits in pieces at least this
  long.")
- **Total length** — should roughly match the expected genome size.
- **Completeness** — **BUSCO** (expected single-copy genes present?) for cellular genomes;
  **CheckV** for viral genomes (Module 3c). Completeness ≠ contiguity — you can have a complete
  but fragmented assembly.
- **Contamination/misassembly** — `QUAST` for general assembly stats; CheckV/CheckM for
  contamination of viral/bacterial genomes.
- **Base accuracy (reference-free)** — **Merqury** compares *k*-mers in the assembly against k-mers
  in the raw reads to estimate a **QV** (consensus quality) and k-mer completeness — no reference
  needed, which is exactly the assembly situation.
- **Look at the graph** — **Bandage** visualizes the assembly *graph* (not just the contigs): a
  clean genome is a few long, untangled paths; a hairball of short, branching nodes means repeats or
  contamination the linear FASTA hides.

> **N50 caveat:** N50 rewards length, not correctness. A tool can boost N50 by aggressively
> joining contigs and introducing misassemblies. Always pair N50 with a completeness/contamination
> check.

---

## 4. Mapping domains to branches

| Domain (Module 3) | Usual branch | Why |
|---|---|---|
| **Variant calling** (3a) | **Align** | the human/organism reference is excellent; you want differences from it |
| **RNA-seq** (3b) | **Align** (spliced) or pseudo-align | reference transcriptome/genome exists; you're counting, not reconstructing |
| **Phage / metagenomics** (3c) | **Assemble** | the community contains unknown/novel genomes with no reference |

> The explicit framing to remember: **"variant calling & RNA-seq usually *align*;
> metagenomics/phage usually *assemble*."** Same skeleton, different fork — and the fork is chosen
> by *whether a trustworthy reference exists.*

The hands-on lab deliberately makes you take **both** branches once: align + call on *E. coli*
reads, and assemble + identify on a phage genome.

---

## Checkpoint
1. You receive ONT long reads from a bacterial isolate with no closely related reference genome.
   Which branch, which aligner-or-assembler, and why?
2. Two assemblies of the same 5 Mb genome: A has N50 = 250 kb in 40 contigs; B has N50 = 900 kb in
   8 contigs but BUSCO completeness 71% vs A's 98%. Which do you trust, and what does this teach
   about N50?
3. `samtools flagstat` reports only 42% of reads mapped to your chosen reference. Give two
   plausible causes.

<details><summary>Answers</summary>

1. **Assemble** (no good reference), with **Flye** (`--nano-raw`) because the reads are long ONT.
   You'd then polish and assess completeness with BUSCO. Aligning would be pointless without a
   reference, and BWA is the wrong tool for long error-prone reads anyway.
2. Trust **A**. B's higher N50 came at the cost of completeness (71%) — it likely over-joined
   contigs or lost content, inflating contiguity while dropping real genes. Lesson: **N50 measures
   contiguity, not correctness**; always pair it with a completeness/contamination metric.
3. Possible causes: (i) wrong/mismatched reference (different organism, build, or strain); (ii)
   contamination (host DNA, another organism); (iii) unremoved adapters or untrimmed low-quality
   reads failing to map. Check the reference identity and revisit Module 1 QC.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

Both forks of this module, in a browser via the **Galaxy Training Network**:
- **ALIGN** → [Mapping](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/mapping/tutorial.html) (BWA-MEM / Bowtie2).
- **ASSEMBLE** → [An Introduction to Genome Assembly](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/general-introduction/tutorial.html), then [MRSA from Illumina](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/mrsa-illumina/tutorial.html) (short-read/Shovill) or [from Nanopore](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/mrsa-nanopore/tutorial.html) (long-read/Flye + polishing), and [Hybrid assembly](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/hybrid_denovo_assembly/tutorial.html) (Nanopore + Illumina/Unicycler), plus [Assembly Quality Control](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/assembly-quality-control/tutorial.html) (QUAST/BUSCO/Merqury).
