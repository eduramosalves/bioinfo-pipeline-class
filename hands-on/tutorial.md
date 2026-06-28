# Hands-on Lab — One Pipeline, Both Forks

You will run the **shared front half** of the skeleton once, then take **both** branches of the
Module 2 fork:

- **Reference-based pass** — QC → trim → **align** *E. coli* reads to a reference → **call variants**.
- **Assembly-based pass** — **assemble** a small phage genome de novo → **assess** it.

```
        ┌─────────────── shared ───────────────┐
reads → QC → trim ─┬─ ALIGN  (E. coli)  → call variants     (reference-based)
                   └─ ASSEMBLE (phage)  → CheckV quality     (assembly-based)
```

Everything is sized to run on a laptop. `commands.sh` is the copy-paste mirror of this file.

> **Note on scope:** these commands are written and syntax-checked for teaching. The first QC+trim
> steps are verified to run on the sample data; full downstream execution is your lab step. Swap in
> any small genome — the *stages* don't change.

---

## 0. Setup

### 0.1 Create and activate the environment
```bash
mamba env create -f environment.yml      # or: conda env create -f environment.yml
conda activate bioinfo-class
mamba env export > environment.lock.yml  # provenance: record exact resolved versions
```

### 0.2 Make a working directory
```bash
mkdir -p ~/bioinfo-lab/{data,ref,qc,trimmed,aligned,variants,assembly} && cd ~/bioinfo-lab
```

### 0.3 Get the data

**Datasets used** (small, public, freely downloadable — document your source):

| Pass | Dataset | Source |
|------|---------|--------|
| Reference-based | *E. coli* K-12 MG1655 reference + a small read set | NCBI / SRA |
| Assembly-based | Enterobacteria phage (e.g. lambda or T4) reads or genome | NCBI |

**Reference genome (E. coli K-12 MG1655):**
```bash
# E. coli K-12 MG1655 reference (NCBI RefSeq NC_000913.3)
wget -O ref/ecoli.fasta.gz \
  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_000913.3&rettype=fasta&retmode=text" \
  || echo "If wget is blocked, download NC_000913.3 FASTA from NCBI manually into ref/"
gunzip -f ref/ecoli.fasta.gz 2>/dev/null; mv -f ref/ecoli.fasta.gz ref/ecoli.fasta 2>/dev/null || true
```
*(The efetch URL returns plain FASTA; if your environment has no network, drop any E. coli FASTA at
`ref/ecoli.fasta` and any paired FASTQ at `data/`.)*

**Reads from SRA (optional, if you have network + sra-tools):**
```bash
# Example accession — replace with any small E. coli Illumina run.
# Subsample to ~100k read pairs so it runs fast on a laptop.
prefetch SRR_ACCESSION && fasterq-dump SRR_ACCESSION -O data/ --split-files
seqkit sample -p 0.05 -s 11 data/SRR_ACCESSION_1.fastq -o data/ecoli_R1.fastq.gz
seqkit sample -p 0.05 -s 11 data/SRR_ACCESSION_2.fastq -o data/ecoli_R2.fastq.gz
```

**No-network fallback — simulate reads from the reference** (great for a self-contained classroom):
```bash
# Use the E. coli (or a phage) FASTA to generate paired reads with seqkit + a simple shredder,
# OR install a read simulator (wgsim ships with samtools):
wgsim -N 100000 -1 150 -2 150 -S 11 ref/ecoli.fasta data/ecoli_R1.fastq data/ecoli_R2.fastq
gzip -f data/ecoli_R1.fastq data/ecoli_R2.fastq
```
This guarantees the lab runs anywhere; reads simulated from the reference will produce few/no
variants, which is itself a teaching point (a sample identical to its reference *should* be quiet).

> ⚠️ **wgsim quality gotcha (verified in this lab).** `wgsim` writes a *uniform* quality of `2`
> (ASCII 50 → Phred **Q17**) to every base — it does not model a real quality profile. So the
> quality-trimming `fastp` command in step 1.2 (`--cut_tail_mean_quality 20`) would trim **every**
> read below the length floor → **0 reads survive**. This is a great live demonstration of
> Module 0 (Phred+33 encoding) and Module 1 (over-aggressive trimming). **If you used the wgsim
> fallback**, run the *simulated-data variant* of step 1.2 below (quality filtering disabled). With
> **real SRA/Illumina reads** (which carry genuine per-base qualities), use the standard command.

---

## 1. Module 1 — QC & preprocessing (shared)

### 1.1 QC the raw reads
```bash
fastqc data/ecoli_R1.fastq.gz data/ecoli_R2.fastq.gz -o qc/
```
Open `qc/*_fastqc.html`. Look at **per-base quality** (decay at the 3' end?) and **adapter content**.

### 1.2 Trim (fastp, paired-end, light)
```bash
fastp \
  -i data/ecoli_R1.fastq.gz -I data/ecoli_R2.fastq.gz \
  -o trimmed/ecoli_R1.trim.fastq.gz -O trimmed/ecoli_R2.trim.fastq.gz \
  --detect_adapter_for_pe --cut_tail --cut_tail_mean_quality 20 \
  --length_required 36 --thread 4 \
  --html qc/fastp.html --json qc/fastp.json
```

**Simulated-data variant** (use this *instead* if you generated reads with `wgsim` — see the
quality gotcha above; otherwise all reads get filtered):
```bash
fastp \
  -i data/ecoli_R1.fastq.gz -I data/ecoli_R2.fastq.gz \
  -o trimmed/ecoli_R1.trim.fastq.gz -O trimmed/ecoli_R2.trim.fastq.gz \
  --detect_adapter_for_pe --disable_quality_filtering \
  --length_required 36 --thread 4 \
  --html qc/fastp.html --json qc/fastp.json
```

### 1.3 Re-QC and aggregate
```bash
fastqc trimmed/ecoli_R1.trim.fastq.gz trimmed/ecoli_R2.trim.fastq.gz -o qc/
multiqc qc/ -o qc/multiqc/
```
**Checkpoint:** open `qc/multiqc/multiqc_report.html` — did trimming improve the per-base quality
and remove adapter content? This MultiQC report is your evidence the data are usable.

---

## 2. Reference-based pass — ALIGN + CALL (E. coli)

### 2.1 Index the reference and align
```bash
bwa index ref/ecoli.fasta
samtools faidx ref/ecoli.fasta

bwa mem -t 4 ref/ecoli.fasta \
  trimmed/ecoli_R1.trim.fastq.gz trimmed/ecoli_R2.trim.fastq.gz \
  | samtools sort -@ 4 -o aligned/ecoli.sorted.bam -
samtools index aligned/ecoli.sorted.bam
```

### 2.2 Reality-check the alignment
```bash
samtools flagstat aligned/ecoli.sorted.bam     # expect a high % mapped to the right reference
samtools coverage aligned/ecoli.sorted.bam     # mean depth per contig
```
**Checkpoint:** what is your `% mapped`? A low value means wrong reference / contamination /
unremoved adapters (revisit Module 1).

### 2.3 Call variants (bcftools, haploid for a bacterial genome)
```bash
bcftools mpileup -f ref/ecoli.fasta aligned/ecoli.sorted.bam \
  | bcftools call --ploidy 1 -mv -Oz -o variants/ecoli.vcf.gz
bcftools index variants/ecoli.vcf.gz

# Light quality filter, then count
bcftools filter -e 'QUAL<20 || DP<10' variants/ecoli.vcf.gz -Oz -o variants/ecoli.filt.vcf.gz
bcftools stats variants/ecoli.filt.vcf.gz | grep -E "number of (SNPs|indels):"
```
**Checkpoint:** inspect a few records with `bcftools view variants/ecoli.filt.vcf.gz | less`. Read
one row as a sentence (CHROM/POS/REF→ALT/QUAL/DP). If you simulated reads from the reference, you'll
see very few variants — and that's the *correct* result.

> *Optional:* load `ref/ecoli.fasta` + `aligned/ecoli.sorted.bam` + `variants/ecoli.filt.vcf.gz`
> into **IGV** and eyeball a call (Module 4): is it supported on both strands?

---

## 3. Assembly-based pass — ASSEMBLE + ASSESS (phage)

### 3.1 Get phage reads
```bash
# Download a small phage genome (e.g. Enterobacteria phage lambda, NC_001416.1) and simulate reads,
# OR use a real phage SRA run subsampled with seqkit as in step 0.3.
wget -O ref/phage.fasta \
  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_001416.1&rettype=fasta&retmode=text" \
  || echo "Download NC_001416.1 (phage lambda) FASTA into ref/phage.fasta manually"
wgsim -N 50000 -1 150 -2 150 -S 7 ref/phage.fasta data/phage_R1.fastq data/phage_R2.fastq
gzip -f data/phage_R1.fastq data/phage_R2.fastq

# QC + trim the phage reads the same way (shared front half)
fastp -i data/phage_R1.fastq.gz -I data/phage_R2.fastq.gz \
  -o trimmed/phage_R1.trim.fastq.gz -O trimmed/phage_R2.trim.fastq.gz \
  --detect_adapter_for_pe --cut_tail --length_required 36 --thread 4 \
  --html qc/fastp_phage.html --json qc/fastp_phage.json
```

### 3.2 Assemble de novo (SPAdes isolate mode)
```bash
spades.py --isolate \
  -1 trimmed/phage_R1.trim.fastq.gz -2 trimmed/phage_R2.trim.fastq.gz \
  -o assembly/phage_spades -t 4 -m 8
# → assembly/phage_spades/contigs.fasta
```

### 3.3 Assess the assembly
```bash
# Quick contiguity stats (contig count, N50, total length)
seqkit stats -a assembly/phage_spades/contigs.fasta
```
**Checkpoint:** how many contigs, and what is the N50 vs the known ~48.5 kb lambda genome? A good
small-phage assembly should collapse to one (or very few) contig(s) near the expected length.

### 3.4 Viral genome quality (CheckV)
```bash
# One-time: download the CheckV database (skip if offline)
checkv download_database ./checkv_db
checkv end_to_end assembly/phage_spades/contigs.fasta assembly/phage_checkv -d ./checkv_db/checkv-db-*
```
**Checkpoint:** open `assembly/phage_checkv/quality_summary.tsv` — what **completeness** and
**contamination** does CheckV report? (Completeness ≠ contiguity — Module 2/3c.)

> *Optional extension (heavier, separate envs):* run **geNomad** to classify contigs as viral and
> **Pharokka** to annotate the phage genome and draw a genome map (Module 3c). These need larger
> databases — see the notes in `environment.yml`.

---

## 4. Wrap-up

You have now, on one dataset, executed the universal skeleton **and both forks**:
- shared: QC → trim (Module 1)
- align branch: BWA → samtools → bcftools VCF (Modules 2 + 3a)
- assemble branch: SPAdes → seqkit/CheckV (Modules 2 + 3c)

**Reproducibility (Module 5):** you pinned the env (`environment.yml`), captured the resolved
versions (`environment.lock.yml`), and every command is logged in `commands.sh`. The production
versions of these passes are **nf-core/sarek** (variants) and **nf-core/mag** (metagenomes) — now
you understand what they do under the hood.

> **Same lab, in a browser (Galaxy).** If the conda setup is a barrier, the **Galaxy Training
> Network** runs the identical logic through a web GUI:
> - Reference-based pass → [Microbial Variant Calling](https://training.galaxyproject.org/training-material/topics/variant-analysis/tutorials/microbial-variants/tutorial.html) (align + call on a bacterial genome).
> - Assembly-based pass → [Genome Assembly (MRSA, Illumina)](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/mrsa-illumina/tutorial.html) + [Assembly Quality Control](https://training.galaxyproject.org/training-material/topics/assembly/tutorials/assembly-quality-control/tutorial.html).
>
> The tools differ slightly (e.g. Snippy in the GTN vs `bcftools` here), but the *stages and the
> file formats are the same* — which is the whole point of the skeleton.

### Final checkpoint
1. You ran the *same* QC + trim front half for both passes, then diverged. At which file/format did
   the two passes stop sharing steps, and why?
2. Your *E. coli* alignment shows 99% mapped but only 4× mean depth. Which downstream conclusions
   are you *underpowered* to make, and why?
3. CheckV reports your phage contig at 100% completeness, 0% contamination, but `seqkit stats` shows
   3 contigs. Reconcile these — is the genome "done"?

<details><summary>Answers</summary>

1. They share through the **trimmed FASTQ**. They diverge at **Module 2's core-processing fork**:
   one path turns FASTQ into a **BAM** (align), the other into a **FASTA** of contigs (assemble),
   because E. coli has a trustworthy reference and the phage assembly demonstrates the no-reference
   path. After that the formats and tools differ.
2. At 4× depth you can't confidently call **heterozygous/low-frequency variants** or trust any call
   needing depth (most filters want DP≥10–30); you also can't assess uniform coverage well. Low
   depth means *absence of a variant isn't evidence of absence.* You'd need deeper sequencing.
3. The single best contig can be 100% complete while the assembly *as a whole* has 3 contigs — the
   extras may be small artifacts, a partial duplicate, or low-coverage junk. CheckV scored the
   *viral* contig; contiguity (N50/contig count) is a separate axis. "Done" needs both: a complete
   *and* contiguous genome. Inspect the other two contigs before declaring victory.
</details>
