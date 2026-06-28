# Module 3b — Domain: RNA-seq (Differential Expression)

## Learning objectives
By the end of this module you can:
- Distinguish **spliced alignment** (STAR/HISAT2) from **pseudo-alignment** (Salmon/kallisto) and
  pick one.
- Go from reads to a **counts / abundance matrix**.
- Explain why **normalization** is necessary and what TPM, CPM, and DESeq2's size factors do.
- Run **differential expression** with DESeq2 / edgeR and interpret log2 fold-change + adjusted
  p-values.
- Correct for **multiple testing** and read a volcano plot honestly.

---

## Where we are
```
  ... → Core processing (ALIGN / pseudo-align) → ▶ Quantify → Differential expression → Interpretation
```
Same skeleton — but the "core processing" fork here has a twist: mRNA reads come from spliced
transcripts, so the tools differ from DNA alignment.

---

## 1. The goal and the twist

RNA-seq measures **how much** each gene/transcript is expressed, usually to compare conditions
(treated vs control, disease vs healthy). The twist: mature mRNA has **introns removed**, so a read
spanning an exon–exon junction will *not* align contiguously to the genome — it jumps across an
intron. Hence specialized approaches.

---

## 2. Two routes to a count matrix

### Route A — spliced alignment, then count
Align reads to the **genome** with a splice-aware aligner, then count reads per gene.
| Aligner | Notes |
|---------|-------|
| **STAR** | fast, accurate, splice-aware; standard for genome alignment; can emit gene counts directly |
| **HISAT2** | memory-efficient splice-aware aligner; graph-based |
Counting from the BAM: **featureCounts** (subread) or **HTSeq-count**, using a **GTF** gene model.
Use this route when you need the alignments themselves (novel transcripts, variants in RNA, splice
analysis).

### Route B — pseudo-alignment (alignment-free)
Skip base-level alignment: assign reads to **transcripts** by k-mer compatibility, directly
estimating abundances.
| Tool | Notes |
|------|-------|
| **Salmon** | fast, models GC/sequence bias, "selective alignment"; quantifies against a transcriptome |
| **kallisto** | very fast pseudo-alignment; pairs with sleuth |
Output is per-transcript abundance (`quant.sf`), summarized to gene level with **tximport**.
Use this route — the modern default — when you just want **quantification** for differential
expression. It's dramatically faster and needs less memory.

> **Rule of thumb:** want counts for DE and nothing exotic? **Salmon/kallisto.** Need the
> alignments (splicing, RNA variants, novel isoforms)? **STAR/HISAT2 + featureCounts.**

---

## 3. The count matrix

Whichever route, you converge on a **genes × samples** matrix of (estimated) read counts:
```
            ctrl_1  ctrl_2  ctrl_3  treat_1  treat_2  treat_3
GENE_A         412     388     401      820      795      810
GENE_B           2       0       1        3        1        2
...
```
This matrix is the input to differential expression. Note GENE_B's tiny, noisy counts — low-count
genes are filtered before testing because they carry no power and inflate multiple-testing burden.

---

## 4. Normalization — why raw counts lie

You cannot compare raw counts directly. Two samples differ in:
- **Library size (sequencing depth)** — sample with 2× the reads has ~2× the counts everywhere.
- **Gene length** — longer genes catch more reads (matters for *within-sample* comparisons).
- **Composition** — a few highly-expressed genes can soak up reads and distort everything else.

Normalization metrics and what they fix:
- **CPM** (counts per million) — corrects library size only.
- **TPM** (transcripts per million) — corrects length *and* library size; good for *comparing
  genes within a sample*; the modern replacement for FPKM/RPKM.
- **DESeq2 "median-of-ratios" / edgeR "TMM"** — correct library size **and composition**; these are
  what you use *for differential testing across samples.* They assume most genes are *not*
  changing.

> **Don't feed TPM into DESeq2.** DE tools want **raw counts** and do their own internal
> normalization (size factors / TMM), because their statistical model is built on count
> distributions. TPM is for visualization/within-sample comparison, not for the DE test.

---

## 5. Differential expression with DESeq2 / edgeR

Both model counts with a **negative binomial** distribution (counts are over-dispersed — variance >
mean — so Poisson is insufficient). The workflow:

1. **Input raw counts** + a sample/condition design.
2. **Estimate size factors** (normalization) and **dispersion** (gene-wise variability, shrunk
   across genes to stabilize estimates with few replicates).
3. **Fit a generalized linear model** per gene; **test** each gene's condition effect.
4. Output per gene: **log2 fold-change** (effect size & direction) and a **p-value** → adjusted
   p-value.

```r
# DESeq2 sketch (counts = genes × samples integer matrix; coldata has 'condition')
library(DESeq2)
dds <- DESeqDataSetFromMatrix(countData = counts, colData = coldata, design = ~ condition)
dds <- dds[rowSums(counts(dds)) >= 10, ]          # filter low-count genes
dds <- DESeq(dds)                                  # normalize, dispersion, fit, test
res <- results(dds, contrast = c("condition","treated","control"))
res <- lfcShrink(dds, coef="condition_treated_vs_control", type="apeglm")  # stabilize LFCs
summary(res)
```

**Reading results:** `log2FoldChange` = +1 → 2× up in treated; −1 → 2× down. `padj` = the
adjusted p-value (use this, not the raw `pvalue`).

---

## 6. Multiple testing — the trap

You test ~20,000 genes at once. At p < 0.05, **~1,000 genes would look "significant" by chance
alone.** Controlling this is mandatory:
- **Benjamini–Hochberg FDR** — the standard. `padj` controls the *false discovery rate*: "of the
  genes I call significant, what fraction are expected to be false?" An FDR of 0.05 means ~5% of
  your hit list is noise.
- Use **`padj`**, set a threshold (commonly FDR < 0.05 or 0.1), and *also* require a meaningful
  effect size (e.g. |log2FC| > 1). Statistical significance ≠ biological importance — a gene can
  have padj = 1e-30 and a 1.05× change.

> **Replicates buy power.** With n=2 per group you can barely estimate variance; n≥3 is the floor,
> and more replicates beat more depth for detecting differential expression.

The classic visualization is the **volcano plot** (Module 4): −log10(padj) vs log2FC — significant,
large-effect genes sit in the top corners. An **MA plot** (log fold-change vs mean expression)
checks for normalization artifacts.

---

## Checkpoint
1. A colleague normalizes counts to **TPM** and runs DESeq2 on the TPM values. What's wrong, and
   what should they feed in instead?
2. Gene X has `padj = 2e-12` and `log2FoldChange = 0.08`. Gene Y has `padj = 0.03` and
   `log2FoldChange = 2.4`. Which is more biologically interesting and why? What does this say about
   filtering on significance alone?
3. You test 18,000 genes at raw p < 0.05 and report the 1,100 "significant" genes without
   adjustment. Roughly how many of those do you expect to be false positives, and which correction
   fixes this?

<details><summary>Answers</summary>

1. DESeq2's negative-binomial model expects **raw integer counts** and computes its own size
   factors; TPM is already normalized (and non-integer), breaking the model's assumptions. Feed
   **raw counts** and let DESeq2 normalize internally. TPM is for within-sample/visualization use.
2. **Gene Y.** Gene X is highly *significant* but its effect is tiny (log2FC 0.08 ≈ 1.06× change) —
   statistically detectable, biologically trivial. Gene Y has a real 2.4 log2FC (~5×) change at an
   acceptable FDR. Lesson: combine significance (`padj`) **with** an effect-size threshold;
   don't rank by p-value alone.
3. At p < 0.05 over 18,000 tests, ~0.05 × 18,000 = **~900 false positives by chance**, so a large
   chunk of the 1,100 could be noise. **Benjamini–Hochberg FDR** (the `padj` column) controls this.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

The reads → counts → differential-expression arc, in a browser via the **Galaxy Training Network**:
- [Reference-based RNA-Seq data analysis](https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/ref-based/tutorial.html) — spliced alignment → counts → DE end-to-end.
- [RNA-Seq reads to counts](https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/rna-seq-reads-to-counts/tutorial.html) then [counts to genes](https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/rna-seq-counts-to-genes/tutorial.html) — the count-matrix → DE step in detail.

*(GTN leans HISAT2/featureCounts + limma-voom/DESeq2; there is no standalone Salmon tutorial, but the normalization and FDR concepts here apply unchanged.)*
