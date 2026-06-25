# Module 0 — Foundations

## Learning objectives
By the end of this module you can:
- Explain what a bioinformatics *pipeline* is and why we formalize analysis as a workflow.
- Draw the **universal pipeline skeleton** and name every stage.
- Describe how the **sequencing platform** (short vs long read) cascades through every later tool.
- Reason about **experimental design**: replicates, controls, depth/coverage, batch effects.
- Read the core **file formats** (FASTA, FASTQ, SAM/BAM/CRAM, VCF, GFF/GTF, BED) and trace one
  read from FASTQ → BAM → VCF.

---

## Where we are
This is the backbone of the whole course. Everything else hangs off this diagram.

```
▶ Experimental design
▶ Raw data + QC
▶ Preprocessing
▶ Core processing (align ⟋ assemble)
▶ Domain-specific downstream
▶ Interpretation & reporting
▶ Reproducibility   (cross-cutting, wraps all of the above)
```

Each later module highlights **one** of these stages. Right now we care about the whole picture.

---

## 1. What is a pipeline?

A **pipeline** is an ordered series of computational steps where the *output of one step is the
input to the next*. Sequencing analysis is naturally pipelined: a sequencer emits reads, those
reads get cleaned, the clean reads get aligned or assembled, and the result gets interpreted.

We formalize this for three reasons:
- **Reproducibility** — the same inputs + same steps + same versions → the same outputs.
- **Scale** — one sample or ten thousand, the logic is identical.
- **Reasoning** — naming the stages lets you debug ("the problem is upstream, in QC") and swap
  tools without rethinking the whole analysis.

> **Mental model:** a pipeline is plumbing. Each junction is a *file format*. If two tools agree
> on the format, they connect. Most "bioinformatics is hard" pain is really format-wrangling.

### The universal skeleton, in words
1. **Experimental design** — decisions made *before* any sequencing that constrain everything.
2. **Raw data + QC** — the FASTQ reads off the machine, and an honest look at their quality.
3. **Preprocessing** — trimming adapters/low-quality bases, removing contaminants.
4. **Core processing** — the **branch point**: *align* reads to a known reference, **or**
   *assemble* them de novo into new sequence.
5. **Domain-specific downstream** — call variants / quantify expression / identify organisms.
6. **Interpretation & reporting** — visualize, apply statistics, write up biology.
7. **Reproducibility** — version pinning, workflow managers, provenance — *around* all of it.

---

## 2. Sequencing platforms (and why they matter upstream)

The platform you sequence on is a decision in Module 0 that **changes your tool choices in every
later module.** Two families:

| | **Short read** (Illumina) | **Long read** (Oxford Nanopore, PacBio HiFi) |
|---|---|---|
| Read length | 50–300 bp | 10–100+ kb (ONT), ~15–20 kb (HiFi) |
| Accuracy | very high per-base (~Q30+) | historically lower (ONT); HiFi now ~Q30 |
| Throughput / cost | highest, cheapest per base | lower throughput, higher per base |
| Aligner | BWA-MEM, Bowtie2 | **minimap2** |
| Assembler | SPAdes, MEGAHIT | **Flye**, hifiasm |
| Best at | accurate SNV/short-variant calling, deep counts | spanning repeats, structural variants, complete genomes |

**The cascade:** choose ONT → you will align with minimap2, not BWA; you will assemble with Flye,
not SPAdes; your error profile is indel-heavy, so your variant filters differ. The platform is not
a detail — it is the first fork in the road.

---

## 3. Experimental design

Bioinformatics cannot rescue a broken experiment. The design decisions that matter most:

- **Replicates.** *Biological* replicates (independent samples) measure biological variability and
  are what give you statistical power — especially in RNA-seq. *Technical* replicates measure the
  machine. Rule of thumb: ≥3 biological replicates per condition for differential analysis; more
  for subtle effects.
- **Controls.** Matched normal (tumor/normal in cancer variant calling), untreated condition
  (RNA-seq), negative/blank controls (metagenomics, to catch reagent contamination — the
  "kitome").
- **Depth / coverage.** How many reads cover each position on average (e.g. "30×"). Coverage needs
  differ by goal: germline SNVs ~30×, somatic variants 100×+, RNA-seq is measured in *library
  size* (reads per sample, e.g. 20–30 M), metagenomes are "as deep as you can afford."
- **Batch effects.** Samples processed on different days / kits / lanes acquire systematic,
  non-biological differences. **Randomize** conditions across batches so batch ≠ condition; record
  batch as metadata so it can be modeled out later. A confounded batch can fully fake a result.

> **Checkpoint preview:** if all your treated samples were sequenced in March and all controls in
> June, what have you actually measured?

---

## 4. File formats — the connective tissue

These formats are the "pipe junctions." Know what each holds and which stage emits it.

### FASTA — sequence
Plain sequence: a `>` header line, then the bases. Used for **references** and **assemblies**.
```
>chr1 description
ACGTACGTACGTACGT...
```

### FASTQ — sequence + per-base quality
The raw output of sequencing. **Four lines per read:**
```
@read_id            ← 1. identifier (starts with @)
ACGTACGTACGT        ← 2. the bases
+                   ← 3. separator (optionally repeats the id)
IIIIIIFFF###        ← 4. quality string, one ASCII char per base
```
The quality line encodes a **Phred score** per base: `Q = -10 · log10(P_error)`. So Q20 = 1%
error, Q30 = 0.1%, Q40 = 0.01%. The ASCII character = Phred score + 33 (Phred+33 encoding). A `#`
is low quality; an `I` is high. *This quality string is the entire reason Module 1 (QC) exists.*

### SAM / BAM / CRAM — alignments
After aligning reads to a reference, each read becomes an **alignment record**: where it mapped,
how well, and any mismatches/indels (the CIGAR string). 
- **SAM** = human-readable text.
- **BAM** = compressed binary SAM (what you actually store/process).
- **CRAM** = even smaller, references the FASTA to avoid storing matching bases.
Key per-read fields: FLAG (paired? mapped? reverse strand?), POS (coordinate), MAPQ (mapping
confidence), CIGAR (match/insert/delete layout). `samtools` is the universal tool here.

### VCF — variants
**V**ariant **C**all **F**ormat: positions where your sample differs from the reference. A header
(`##` lines) then one row per variant: `CHROM POS ID REF ALT QUAL FILTER INFO FORMAT sample...`.
This is the output of Module 3a (variant calling).

### GFF / GTF — annotations (features on a genome)
Tab-delimited *intervals with meaning*: "bases 1000–2000 of chr1 are gene X, exon 2." GTF is a
GFF dialect used heavily for genes/transcripts; RNA-seq quantification needs it to know where
genes are. Columns: `seqid source type start end score strand frame attributes`.

### BED — plain intervals
The minimalist interval format: `chrom  start  end  [name score strand ...]`. Used to say "look
only at these regions" (e.g. exome capture targets). **BED is 0-based, half-open**; GFF/VCF are
1-based — a classic off-by-one source. Remember: *BED counts from zero.*

---

## 5. Worked example — one read, FASTQ → BAM → VCF

Watch a single read flow through the skeleton and change format at each junction.

**(a) In FASTQ** — raw off the machine, no idea where it belongs:
```
@SEQ_42
GATCACAGGTCTATCACCCTATTAACCAC
+
IIIIIIIIIIIIIIIIIIIIFFFFF#####   ← note: quality drops at the 3' end
```

**(b) After alignment, in SAM/BAM** — now it has a coordinate and a CIGAR:
```
SEQ_42  0  chr1  10042  60  24M5S  *  0  0  GATC...  IIII...  NM:i:1
        │  │     │      │   │                                  └ 1 mismatch vs reference
        │  │     │      │   └ CIGAR: 24 bases align (M), 5 soft-clipped (S, the low-qual tail)
        │  │     │      └ MAPQ 60 (high-confidence placement)
        │  │     └ mapped at position 10042 on chr1
        │  └ reference name
        └ FLAG 0 = mapped, forward strand, not paired
```
The low-quality 3' tail got **soft-clipped** — the aligner ignored it. (This is also exactly what
QC/trimming in Module 1 would have cleaned proactively.)

**(c) After variant calling, in VCF** — that one mismatch, seen across enough reads, becomes a
call:
```
#CHROM  POS    ID  REF  ALT  QUAL  FILTER  INFO        FORMAT  sample1
chr1    10055  .   A    G    255   PASS    DP=31;AF=0.5  GT:DP   0/1:31
                                            │             │
                                            │             └ genotype 0/1 = heterozygous, depth 31
                                            └ 31 reads covered it, allele frequency 0.5
```

**The same biological observation** — a base that differs from the reference — was a quality-scored
letter in FASTQ, a CIGAR mismatch in BAM, and a genotyped row in VCF. The *formats* changed; the
*read* did not. That is the whole pipeline in one example.

---

## Checkpoint
1. Your collaborator sequenced all 6 treated samples on an Illumina run in March and all 6
   controls on a run in June. Name the design flaw and one thing that would have prevented it.
2. A base in a FASTQ read has quality character `+` (ASCII 43). What is its Phred score and
   approximate error probability? *(Hint: Phred+33.)*
3. You are handed a `.bam` and a `.vcf` for the same sample. Which stage of the skeleton produced
   each, and which file format connects them?

<details><summary>Answers</summary>

1. **Batch is fully confounded with condition** — any difference could be biology *or* the
   March-vs-June batch, and they're inseparable. Prevention: randomize conditions across runs (mix
   treated + control on each run) and record run/date as metadata.
2. ASCII 43 − 33 = **Phred 10** → P(error) = 10^(−10/10) = **0.1 (10%)**. A poor base.
3. The **VCF** came from Module 3a (variant calling); the **BAM** from Module 2 (core
   processing / alignment). The BAM is the *input* to the caller — the **BAM → VCF** junction.
</details>
