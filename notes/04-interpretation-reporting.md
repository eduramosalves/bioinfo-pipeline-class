# Module 4 — Interpretation & Reporting

## Learning objectives
By the end of this module you can:
- Choose the right **visualization** for each domain and use it to sanity-check results.
- Apply the right **statistics** and recognize common over-interpretation pitfalls.
- Write a **results report** a collaborator (or reviewer) can trust and reproduce.

---

## Where we are
```
  ... → Domain-specific downstream → ▶ Interpretation & reporting → Reproducibility
```
The pipeline produced numbers. This stage turns numbers into **defensible biological claims** —
and is where most real-world mistakes happen, because the tools all "ran successfully."

---

## 1. Visualization — see before you believe

A figure is a debugging tool first, a communication tool second. Per domain:

- **Variant calling → IGV (Integrative Genomics Viewer).** Load the BAM + VCF + reference and
  *look at the reads* under a call. Real variants show consistent support across many reads on both
  strands; artifacts cluster at read ends, on one strand, near homopolymers/indels, or in
  low-mappability regions. **Eyeballing a call in IGV catches false positives no filter does.**
  (**JBrowse2** is the shareable, browser-based equivalent — same habit, and it embeds straight into
  a report or shared workflow.)
- **RNA-seq → volcano plot & MA plot.** *Volcano* (−log10 padj vs log2FC): significant, large-effect
  genes sit in the upper corners. *MA plot* (log fold-change vs mean expression): should be
  centered on zero — a tilt signals a normalization problem. Add **PCA of samples** to confirm
  replicates cluster by condition (and to expose batch effects / swapped labels).
- **Phage / metagenomics → genome maps & abundance bars.** A **circular/linear genome map**
  (Pharokka output) shows gene modules and orientation; **stacked bar / Krona** plots show
  community composition; a **coverage plot** confirms a phage contig is evenly covered (uneven
  coverage = misassembly or chimera).
- **Structural / comparative → Circos.** For whole-genome comparisons, structural variants, copy
  number, or B-allele frequency, a **Circos** plot lays multiple tracks around a circular ideogram —
  the standard view for cancer-genome SV/CNV and for comparing genomes side by side. Powerful but
  fiddly (it's an iterative, layer-by-layer build), so reach for it when a linear browser can't show
  the relationships.

> **Universal habit:** before reporting a result, *visualize the raw evidence behind it.* The
> pipeline exiting 0 means it ran, not that it's right.

---

## 2. Statistics & biological interpretation

- **Effect size *and* significance.** A p-value says "probably not chance"; it says nothing about
  magnitude or importance. Always pair `padj` with a fold-change / allele-fraction / coverage
  threshold (see Module 3b).
- **Multiple testing is everywhere.** Not just RNA-seq — any time you scan many positions, genes,
  or taxa, control the FDR. Reporting raw p-values across thousands of tests is the single most
  common error.
- **Correlation ≠ causation; differential ≠ functional.** A differentially expressed gene is a
  *correlate* of the condition, not a proven driver. A variant in a gene is not proof it's
  causal — see ACMG (Module 3a).
- **Coverage/power define what you *can* conclude.** Low depth → you cannot rule out variants you
  didn't see. Few replicates → you cannot detect subtle expression changes. State the limit, don't
  hide it.

### Common over-interpretation pitfalls
| Pitfall | Reality |
|---------|---------|
| "padj = 1e-30, huge effect!" with log2FC = 0.1 | significant ≠ meaningful; tiny effect |
| Reporting a variant as "causal/pathogenic" from prediction alone | needs ACMG evidence; usually a **VUS** |
| Batch confounded with condition (Module 0) | the "result" may be the batch |
| Trusting a call without looking in IGV | strand/end/homopolymer artifacts pass filters |
| Kraken2 "unclassified = absent" | database limits; novel taxa are simply unknown, not absent |
| n = 2 replicates → confident DE list | barely enough to estimate variance; weak power |

---

## 3. What a good results report contains

A report should let a reader **trust** and **reproduce** the work:

1. **Question & design** — what was asked, the experimental design (conditions, replicates,
   controls, platform/depth).
2. **Methods with versions** — every tool, **its version**, key parameters, the reference build,
   and databases used (forward-references Module 5). "Aligned with BWA-MEM" is not reproducible;
   "BWA-MEM 0.7.17, default params, GRCh38" is.
3. **QC summary** — the MultiQC-level evidence that the data were usable (and any samples dropped,
   with reasons).
4. **Results** — the key tables/figures with effect sizes *and* uncertainty (CIs, FDR), not just
   "significant."
5. **Interpretation** — biological meaning, *bounded by* the limitations (depth, power, confounders).
6. **Reproducibility pointers** — where the code/workflow, parameters, and data live (Module 5).

> A report a reviewer can't reproduce from the methods section is, scientifically, incomplete —
> regardless of how clean the figures look.

---

## Checkpoint
1. A variant passes all filters with QUAL 300. In IGV you see all 14 supporting reads are on the
   reverse strand and the alt allele sits 2 bp from a homopolymer run. Report it as real, or not —
   and why?
2. Your RNA-seq PCA shows samples cluster by **sequencing date**, not by treatment. What does this
   mean for the differential-expression results, and what should the methods/analysis do about it?
3. Name two things a "Methods" section must include for the variant-calling result to be
   reproducible.

<details><summary>Answers</summary>

1. **Be very skeptical / likely artifact.** A real variant should have support on *both* strands;
   all-one-strand support plus proximity to a homopolymer is a classic strand-bias / alignment
   artifact pattern, despite the high QUAL and PASS. The filter missed it; IGV caught it.
2. It indicates a **batch effect confounded with (or dominating) the biological signal** — date is
   explaining more variance than treatment. The DE results are untrustworthy as-is. Fix: include
   batch/date in the design model (e.g. `~ batch + condition` in DESeq2) so it's controlled for,
   and ideally never confound batch with condition in the first place.
3. Any two of: exact **tool versions**, **reference genome build/version**, **key parameters**, the
   **databases used** for annotation (e.g. gnomAD/ClinVar version), and the **command lines /
   workflow**. Tool names without versions/params are not reproducible.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

Visualization, in a browser via the **Galaxy Training Network**:
- [Genomic Data Visualisation with JBrowse2](https://training.galaxyproject.org/training-material/topics/visualisation/tutorials/jbrowse2/tutorial.html) — Galaxy's in-browser genome browser, the GUI analog of IGV in this module (load a BAM + VCF + reference and *look at the reads*).
- [Visualisation with Circos](https://training.galaxyproject.org/training-material/topics/visualisation/tutorials/circos/tutorial.html) — circular genome plots for SV/CNV/comparative views (cancer-genomics worked example).
- [IGV Introduction](https://training.galaxyproject.org/training-material/topics/introduction/tutorials/igv-introduction/tutorial.html) — the desktop viewer itself, end to end.
