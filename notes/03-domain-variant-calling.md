# Module 3a — Domain: Variant Calling

## Learning objectives
By the end of this module you can:
- Walk the **GATK Best Practices** arc for germline short variants and say what each step fixes.
- Name alternative callers (**bcftools**, **DeepVariant**) and when to reach for them.
- Read a **VCF** record field by field.
- Annotate variants with **VEP / SnpEff / ANNOVAR** and explain functional consequence.
- Apply the **ACMG/AMP** framework + **ClinVar** to move from "a variant" to "a clinical
  interpretation."

---

## Where we are
```
  ... → Core processing (ALIGN) → ▶ Variant calling → Interpretation
```
This branch takes the **aligned BAM** from Module 2 and asks: *where, and how, does this sample
differ from the reference — and does it matter?*

---

## 1. The goal

A variant is a position where the sample's genome differs from the reference: **SNVs** (single
nucleotide), small **indels** (insertions/deletions), and larger **structural variants** (this
module focuses on SNVs/indels — "short variants"). We distinguish:
- **Germline** variants — inherited, present in ~50% (het) or ~100% (hom) of reads.
- **Somatic** variants — acquired (e.g. in a tumor), often at *low* allele fraction, needing a
  matched normal and deeper coverage.

---

## 2. GATK Best Practices arc (germline short variants)

The reference workflow. Each step exists to remove a specific source of false calls:

```
sorted BAM
  → Mark Duplicates          (flag PCR/optical dupes so one molecule ≠ many "votes")
  → Base Quality Score
    Recalibration (BQSR)     (correct systematic, machine-specific quality miscalibration)
  → HaplotypeCaller          (local re-assembly around active regions → raw variants / GVCF)
  → Joint genotyping         (combine GVCFs across samples for consistent genotypes)
  → Variant filtering        (VQSR or hard filters → keep confident calls)
VCF
```

- **Mark Duplicates** (`gatk MarkDuplicates` / `samtools markdup`): PCR amplification and optical
  artifacts create identical reads. Left in, they fake confidence (10 copies of one error look
  like strong evidence). Marked, the caller counts the molecule once.
- **BQSR** (`BaseRecalibrator` + `ApplyBQSR`): the sequencer's reported Phred scores are
  systematically off in patterns tied to machine cycle and sequence context. BQSR learns the bias
  from known-variant sites and corrects it, so the caller's per-base error model is honest.
- **HaplotypeCaller**: the heart of GATK. In "active" regions it **locally re-assembles** the
  reads into candidate haplotypes (rather than trusting the original alignment base by base), which
  is far more accurate around indels. Emit per-sample **GVCF** (`-ERC GVCF`) for scalable cohorts.
- **Joint genotyping** (`GenomicsDBImport` + `GenotypeGVCFs`): genotype all samples together so a
  position is evaluated consistently across the cohort (and "no call" vs "hom-ref" is resolved).
- **Filtering**: **VQSR** (a model trained on known/true sites) for large WGS/WES cohorts; **hard
  filters** (fixed thresholds on QD, FS, MQ, ...) for small projects or single samples.

> **Pattern to remember:** dedup and BQSR make the *evidence* trustworthy; HaplotypeCaller turns
> evidence into *calls*; filtering keeps the calls you can defend.

---

## 3. Alternative callers

| Caller | Reach for it when |
|--------|-------------------|
| **bcftools** (`mpileup` + `call`) | fast, lightweight, great for bacterial/viral genomes, simple germline; the hands-on lab uses it |
| **GATK HaplotypeCaller** | human germline gold standard, large cohorts, clinical pipelines |
| **DeepVariant** | deep-learning caller; state-of-the-art accuracy, strong on PacBio HiFi/ONT, less parameter fiddling |
| **Mutect2** (GATK) | **somatic** calling (tumor/normal), low-AF variants |

For the lab's small *E. coli* genome, **bcftools** is the pragmatic, fast choice — GATK's full arc
is overkill there but essential for human clinical work.

---

## 4. VCF anatomy

A VCF has a **header** (`##` metadata + one `#CHROM...` column line) then one row per variant:

```
#CHROM  POS    ID         REF  ALT  QUAL  FILTER  INFO              FORMAT    sample1
chr7    117559590 rs397508 G    A    312   PASS    DP=54;AF=0.5;AC=1  GT:AD:DP:GQ  0/1:27,27:54:99
```
- **CHROM, POS** — location (1-based).
- **ID** — known-variant identifier (e.g. dbSNP `rs...`) or `.`.
- **REF / ALT** — reference allele vs alternate allele(s).
- **QUAL** — Phred-scaled confidence that a variant exists here.
- **FILTER** — `PASS` or the name of a filter it failed.
- **INFO** — site-level annotations: `DP` (depth), `AF` (allele frequency), `AC/AN`, etc.
- **FORMAT + sample** — per-sample fields. The key one is **GT** (genotype): `0/0` hom-ref, `0/1`
  het, `1/1` hom-alt; plus `AD` (allelic depths), `DP`, `GQ` (genotype quality).

Reading a row: *"at chr7:117559590, the sample is heterozygous G/A, 27 reads each allele, depth 54,
high genotype quality, passed filters."* (This locus is in *CFTR* — see ACMG below.)

---

## 5. Annotation — from coordinate to consequence

A raw VCF says *where* a variant is, not *what it does*. Annotation tools intersect variants with
gene models and databases to predict **functional consequence**:

| Tool | Notes |
|------|-------|
| **VEP** (Ensembl Variant Effect Predictor) | comprehensive, plugin ecosystem (gnomAD, SpliceAI, CADD), Ensembl/RefSeq transcripts |
| **SnpEff** | fast, self-contained databases, easy to run; pairs with SnpSift for filtering |
| **ANNOVAR** | long-standing, many gene/region/filter-based annotation sources |

Annotation answers: which **gene/transcript**? what **consequence** (missense, nonsense,
frameshift, splice, synonymous, intronic)? what **population frequency** (gnomAD — is it rare?)?
what **in-silico pathogenicity** predictions (CADD, SIFT, PolyPhen, SpliceAI)? These are the
*inputs* to clinical interpretation.

```bash
# SnpEff: annotate a VCF against a prebuilt genome database
snpeff -v GRCh38.105 sample.vcf > sample.annotated.vcf

# VEP equivalent (cache mode)
vep -i sample.vcf -o sample.vep.vcf --cache --species homo_sapiens --vcf
```

---

## 6. Clinical interpretation — ACMG/AMP + ClinVar

For a clinically relevant variant, "missense in gene X at 0.01% frequency" is not an answer. The
**ACMG/AMP guidelines** (Richards et al., 2015) give a structured rubric that weighs **evidence
criteria** to a **5-tier classification**:

```
Pathogenic  ·  Likely Pathogenic  ·  VUS (Uncertain)  ·  Likely Benign  ·  Benign
```

Evidence criteria are coded and weighted, e.g.:
- **PVS1** — null variant (nonsense/frameshift/canonical splice) in a gene where LoF causes disease
  (*very strong* pathogenic).
- **PS** — strong pathogenic (e.g. PS1 same amino-acid change as a known pathogenic; PS3
  functional studies).
- **PM2** — absent/rare in population databases (gnomAD) — *moderate* pathogenic.
- **PP3** — multiple computational tools support a deleterious effect (*supporting*).
- **BA1/BS/BP** — benign criteria (e.g. BA1 = allele frequency too common to be pathogenic).

The criteria combine via rules into the final class. **ClinVar** is the public archive of
variant–condition interpretations submitted by labs — your first lookup to see whether a variant is
already classified (and with what confidence / how many submitters agree). A **VUS** is the honest,
common verdict when evidence is insufficient — *not* a license to over-call.

> This is exactly the territory of the user's **VariantScribe** work: structuring ACMG evidence and
> ClinVar/gnomAD/PubMed signals into a defensible classification. Keep terminology aligned with
> that project so the course and the tool speak the same language.

> **Responsibility note (ties to Module 4):** a statistical call is not a diagnosis. Clinical
> reporting requires the gene–disease relationship to be valid, the criteria applied conservatively,
> and uncertainty (VUS) stated plainly.

---

## Worked command block (lab-style, bacterial scale with bcftools)
```bash
# From an aligned, sorted, indexed BAM (Module 2) + reference FASTA:
samtools faidx reference.fasta

# Call variants: pileup → call (haploid for a bacterial genome)
bcftools mpileup -f reference.fasta sample.sorted.bam \
  | bcftools call --ploidy 1 -mv -Oz -o sample.vcf.gz
bcftools index sample.vcf.gz

# Basic quality filter, then summarize
bcftools filter -e 'QUAL<20 || DP<10' sample.vcf.gz -Oz -o sample.filt.vcf.gz
bcftools stats sample.filt.vcf.gz | grep "number of SNPs:"
```

---

## Checkpoint
1. In the GATK arc, what *specific* false-call source do **Mark Duplicates** and **BQSR** each
   remove? Why are they before, not after, HaplotypeCaller?
2. A VCF row shows `FILTER=PASS`, `INFO=DP=8;AF=0.5`, `FORMAT GT:DP = 0/1:8`. Give one reason to be
   cautious about this heterozygous call despite `PASS`.
3. A missense variant is absent from gnomAD (PM2), predicted deleterious by several tools (PP3),
   but has no functional studies and isn't in ClinVar. What ACMG class is most likely, and what
   would *not* be appropriate to tell a clinician?

<details><summary>Answers</summary>

1. **Mark Duplicates** removes inflated confidence from PCR/optical duplicates (one molecule
   masquerading as many independent observations). **BQSR** removes systematic miscalibration of
   the per-base quality scores. Both must run *before* calling because HaplotypeCaller's
   probability model trusts read counts and base qualities — fix the evidence before you weigh it.
2. **Depth is only 8.** A het call needs enough reads of *each* allele to be reliable; at DP=8 the
   genotype is fragile (sampling noise, possible mapping artifact). `PASS` from a simple filter
   doesn't guarantee robustness at low depth.
3. Most likely **VUS** (Uncertain Significance) — PM2 + PP3 alone are insufficient for Likely
   Pathogenic under ACMG. It would be **inappropriate** to report it as pathogenic/causal or to
   base a clinical decision on it; report it as uncertain and note what evidence (e.g. functional
   data, segregation) would resolve it.
</details>
