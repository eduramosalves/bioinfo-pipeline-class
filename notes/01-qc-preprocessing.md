# Module 1 — Quality Control & Preprocessing

## Learning objectives
By the end of this module you can:
- Read a **FastQC** report and name the metrics that decide downstream action.
- Aggregate many samples with **MultiQC** and spot the outlier.
- Choose and run a trimmer (**fastp**, Trimmomatic, cutadapt) and justify the settings.
- Apply **decision rules**: when to trim, how aggressive, and paired-end gotchas.
- State the golden rule: *garbage in, garbage out — QC is not optional.*

---

## Where we are
```
  Experimental design
  Raw data + QC          ◀── you are here
▶ Preprocessing           ◀── and here
  Core processing (align ⟋ assemble)
  Domain-specific downstream
  Interpretation & reporting
  Reproducibility
```
QC is the cheapest place to catch a ruined experiment. Every minute here saves hours downstream.

---

## 1. Why QC first

The FASTQ off the machine is *not* trustworthy raw material. It contains:
- **Adapter sequence** — the synthetic oligos used during library prep, read through when the
  insert is shorter than the read length.
- **Low-quality bases**, especially at the 3' end (Illumina quality decays along the read).
- **Contaminants** — host DNA in a microbiome sample, PhiX spike-in, the reagent "kitome."
- **Optical/PCR duplicates** — the same molecule counted many times.

If you align or assemble this directly, adapters become fake mismatches/indels, low-quality tails
become false variants, and duplicates inflate your confidence. **QC tells you what's wrong;
preprocessing fixes it.**

---

## 2. FastQC — the per-sample report

`FastQC` scans a FASTQ and emits a per-module pass/warn/fail report. The modules that actually
drive decisions:

- **Per-base sequence quality.** Boxplots of Phred score by position. The classic shape: high and
  flat, decaying at the 3' end. If it dives below Q20 → trim the tail.
- **Adapter content.** A rising curve toward the 3' end = adapter read-through → trim adapters.
- **Per-base sequence content.** Should be ~flat across positions. A wobble in the first ~10–12
  bases is *normal* for Illumina (random-priming bias) and **not** a reason to hard-trim.
- **Overrepresented sequences.** Flags adapters, rRNA, or contamination; FastQC often names the
  source.
- **Sequence duplication levels.** High duplication can mean low library complexity / PCR
  over-amplification. *Context matters:* high duplication is expected in amplicon or deep RNA-seq,
  alarming in a shallow WGS library.
- **GC content.** A clean unimodal curve matching your organism is good; a second peak suggests
  contamination from another genome.

> **Read FastQC like a doctor reads a chart:** a "FAIL" is not a verdict, it's a prompt to ask
> *"is this expected for my library type?"* A FAIL on duplication in RNA-seq is normal.

---

## 3. MultiQC — aggregate across samples

One FastQC report per sample doesn't scale. **MultiQC** crawls a directory, finds outputs from
FastQC (and dozens of other tools — trimmers, aligners, callers), and renders **one interactive
report** with every sample side by side.

The payoff is the **outlier view**: 47 samples cluster together and 1 has half the reads or a GC
shift — you see it instantly. Run MultiQC after *every* batch step (post-QC, post-trim,
post-align) to track samples through the pipeline. It is the single highest-value, lowest-effort
tool in this course.

---

## 4. Trimming & filtering tools

Three workhorses; pick based on the job:

| Tool | Strengths | Use when |
|------|-----------|----------|
| **fastp** | adapter *auto-detection*, quality trimming, length/complexity filtering, polyG trimming, **its own HTML report** — all in one fast pass | **default choice** for most short-read work |
| **Trimmomatic** | mature, very explicit step ordering (sliding window, leading/trailing), Java | legacy pipelines, fine-grained control, when reproducing a published method |
| **cutadapt** | the adapter-removal specialist; precise primer/adapter handling | amplicon/primer removal, custom adapter logic, building blocks for other tools |

**What trimming does, concretely:**
- **Adapter removal** — detect and cut adapter sequence (fastp/cutadapt auto-detect; you can also
  supply the known adapter).
- **Quality trimming** — remove low-quality bases, usually from the 3' end, often via a *sliding
  window* (cut once the windowed mean Phred drops below a threshold).
- **Length filtering** — discard reads that become too short after trimming (they map ambiguously).
- **Complexity/polyG filtering** — fastp can drop low-complexity reads and trim the polyG
  artifacts that two-color Illumina chemistry (NovaSeq/NextSeq) produces at read ends.

---

## 5. Decision rules

Trimming is reversible damage if overdone — you throw away real signal. Be deliberate:

- **Always remove adapters.** No downside; adapters are never biological signal.
- **Quality-trim the 3' tail** when FastQC shows decay below ~Q20. A sliding window (e.g. mean
  Q20 over 4 bp) is safer than a hard length cut.
- **Don't over-trim.** Aggressive quality trimming shortens reads, hurts mappability, and can bias
  results. Modern aligners *soft-clip* low-quality ends anyway, and modern callers use base
  qualities directly. For variant calling especially, **light** trimming is preferred.
- **Don't hard-trim the 5' "wobble."** The first ~10 bp content bias is priming chemistry, not
  adapter — trimming it just discards good bases.
- **Paired-end: keep mates in sync.** Reads come in R1/R2 pairs. If trimming drops a read,
  its mate is now "orphaned." A pair-aware trimmer (fastp, Trimmomatic in PE mode) writes the
  surviving pairs to paired output and orphans to a separate "singletons" file. **Never** trim R1
  and R2 in independent single-end runs — you'll desynchronize the pairs and break alignment.

> **Rule of thumb by goal:** variant calling → trim *gently* (adapters + light quality), let the
> caller use qualities. Assembly → trimming helps more (clean reads = cleaner contigs).
> RNA-seq quantification with pseudo-aligners (Salmon/kallisto) → often only adapter trimming is
> needed.

---

## 6. Worked command block

QC → trim → re-QC → aggregate, paired-end, with `fastp`:

```bash
# 1. Inspect raw reads
fastqc sample_R1.fastq.gz sample_R2.fastq.gz -o qc_raw/

# 2. Trim: adapter auto-detect + light quality trim + length filter, paired-end
fastp \
  -i sample_R1.fastq.gz -I sample_R2.fastq.gz \
  -o sample_R1.trim.fastq.gz -O sample_R2.trim.fastq.gz \
  --detect_adapter_for_pe \
  --cut_tail --cut_tail_mean_quality 20 \
  --length_required 36 \
  --thread 4 \
  --html fastp_report.html --json fastp_report.json

# 3. Re-QC the trimmed reads to confirm the fix
fastqc sample_R1.trim.fastq.gz sample_R2.trim.fastq.gz -o qc_trimmed/

# 4. Aggregate everything (raw QC, fastp, trimmed QC) into one report
multiqc qc_raw/ qc_trimmed/ . -o multiqc/
```

After this, your `sample_*.trim.fastq.gz` are clean inputs for Module 2.

---

## Checkpoint
1. FastQC reports a **FAIL** on "Sequence Duplication Levels" for a deep RNA-seq library. Panic or
   not? Why?
2. You're prepping reads for **germline variant calling**. Your colleague suggests aggressive
   quality trimming (sliding window mean Q30, hard-cut everything below). What's the risk, and
   what would you do instead?
3. Why must paired-end trimming be done by a *pair-aware* tool rather than two single-end runs?

<details><summary>Answers</summary>

1. **Not panic.** High duplication is expected when you sequence a transcriptome deeply — highly
   expressed genes legitimately produce many identical reads. Duplication FAIL matters for shallow
   WGS, not deep RNA-seq. Interpret QC *in the context of the library type.*
2. Over-aggressive trimming shortens reads → worse mappability → loss of real coverage and
   potential bias, while gaining little (callers already weight by base quality and aligners
   soft-clip). Do **light** trimming: remove adapters, gently quality-trim the 3' tail, keep a
   minimum length, and let GATK/bcftools use the base qualities.
3. R1 and R2 must stay in the same order and 1:1 correspondence. If a read is discarded in one
   independent run but its mate survives in the other, the files desynchronize — the aligner pairs
   the wrong R1 with the wrong R2. A pair-aware tool drops/keeps mates together and routes orphans
   to a separate file.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

Same logic, in a browser via the **Galaxy Training Network**:
- [Quality Control](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html) — FastQC + MultiQC + trimming (Cutadapt/Trimmomatic), the GUI version of this module.
