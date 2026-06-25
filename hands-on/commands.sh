#!/usr/bin/env bash
# commands.sh — copy-paste mirror of hands-on/tutorial.md
#
# This is a REFERENCE, not a turnkey script: steps that need network downloads or a chosen SRA
# accession are commented or use placeholders. Read tutorial.md alongside it. Run blocks
# individually rather than executing the whole file blindly.
#
# Env:  mamba env create -f environment.yml && conda activate bioinfo-class
set -euo pipefail

# ─── 0. Setup ────────────────────────────────────────────────────────────────
mkdir -p ~/bioinfo-lab/{data,ref,qc,trimmed,aligned,variants,assembly}
cd ~/bioinfo-lab
mamba env export > environment.lock.yml   # provenance (run after activating the env)

# Reference genome: E. coli K-12 MG1655 (NCBI RefSeq NC_000913.3)
wget -O ref/ecoli.fasta \
  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_000913.3&rettype=fasta&retmode=text"

# Reads — choose ONE:
#   (a) from SRA (network + sra-tools):
# prefetch SRR_ACCESSION && fasterq-dump SRR_ACCESSION -O data/ --split-files
# seqkit sample -p 0.05 -s 11 data/SRR_ACCESSION_1.fastq -o data/ecoli_R1.fastq.gz
# seqkit sample -p 0.05 -s 11 data/SRR_ACCESSION_2.fastq -o data/ecoli_R2.fastq.gz
#   (b) no-network fallback — simulate from the reference (wgsim ships with samtools):
#       NOTE: wgsim writes uniform quality Q17 to every base, so the quality-trimming fastp below
#       would drop ALL reads. If you use this path, use the SIM_FASTP variant (see step 1).
wgsim -N 100000 -1 150 -2 150 -S 11 ref/ecoli.fasta data/ecoli_R1.fastq data/ecoli_R2.fastq
gzip -f data/ecoli_R1.fastq data/ecoli_R2.fastq

# ─── 1. Module 1 — QC & preprocessing (shared) ───────────────────────────────
fastqc data/ecoli_R1.fastq.gz data/ecoli_R2.fastq.gz -o qc/

# Standard command (use with REAL SRA/Illumina reads that have genuine qualities):
fastp \
  -i data/ecoli_R1.fastq.gz -I data/ecoli_R2.fastq.gz \
  -o trimmed/ecoli_R1.trim.fastq.gz -O trimmed/ecoli_R2.trim.fastq.gz \
  --detect_adapter_for_pe --cut_tail --cut_tail_mean_quality 20 \
  --length_required 36 --thread 4 \
  --html qc/fastp.html --json qc/fastp.json

# SIM_FASTP variant — use this INSTEAD when reads came from wgsim (quality filtering disabled):
# fastp \
#   -i data/ecoli_R1.fastq.gz -I data/ecoli_R2.fastq.gz \
#   -o trimmed/ecoli_R1.trim.fastq.gz -O trimmed/ecoli_R2.trim.fastq.gz \
#   --detect_adapter_for_pe --disable_quality_filtering \
#   --length_required 36 --thread 4 \
#   --html qc/fastp.html --json qc/fastp.json

fastqc trimmed/ecoli_R1.trim.fastq.gz trimmed/ecoli_R2.trim.fastq.gz -o qc/
multiqc qc/ -o qc/multiqc/

# ─── 2. Reference-based pass — ALIGN + CALL (E. coli) ─────────────────────────
bwa index ref/ecoli.fasta
samtools faidx ref/ecoli.fasta

bwa mem -t 4 ref/ecoli.fasta \
  trimmed/ecoli_R1.trim.fastq.gz trimmed/ecoli_R2.trim.fastq.gz \
  | samtools sort -@ 4 -o aligned/ecoli.sorted.bam -
samtools index aligned/ecoli.sorted.bam

samtools flagstat aligned/ecoli.sorted.bam
samtools coverage aligned/ecoli.sorted.bam

bcftools mpileup -f ref/ecoli.fasta aligned/ecoli.sorted.bam \
  | bcftools call --ploidy 1 -mv -Oz -o variants/ecoli.vcf.gz
bcftools index variants/ecoli.vcf.gz
bcftools filter -e 'QUAL<20 || DP<10' variants/ecoli.vcf.gz -Oz -o variants/ecoli.filt.vcf.gz
bcftools stats variants/ecoli.filt.vcf.gz | grep -E "number of (SNPs|indels):"

# ─── 3. Assembly-based pass — ASSEMBLE + ASSESS (phage) ───────────────────────
# Phage lambda reference (NCBI NC_001416.1), then simulate + trim reads
wget -O ref/phage.fasta \
  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_001416.1&rettype=fasta&retmode=text"
wgsim -N 50000 -1 150 -2 150 -S 7 ref/phage.fasta data/phage_R1.fastq data/phage_R2.fastq
gzip -f data/phage_R1.fastq data/phage_R2.fastq

fastp -i data/phage_R1.fastq.gz -I data/phage_R2.fastq.gz \
  -o trimmed/phage_R1.trim.fastq.gz -O trimmed/phage_R2.trim.fastq.gz \
  --detect_adapter_for_pe --cut_tail --length_required 36 --thread 4 \
  --html qc/fastp_phage.html --json qc/fastp_phage.json

spades.py --isolate \
  -1 trimmed/phage_R1.trim.fastq.gz -2 trimmed/phage_R2.trim.fastq.gz \
  -o assembly/phage_spades -t 4 -m 8

seqkit stats -a assembly/phage_spades/contigs.fasta

# Viral genome quality (downloads a DB; skip if offline)
# checkv download_database ./checkv_db
# checkv end_to_end assembly/phage_spades/contigs.fasta assembly/phage_checkv -d ./checkv_db/checkv-db-*

# Optional heavier extensions (separate envs — see environment.yml):
# genomad end-to-end assembly/phage_spades/contigs.fasta assembly/genomad genomad_db/
# pharokka.py -i assembly/phage_spades/contigs.fasta -o assembly/pharokka -d pharokka_db -t 4

echo "Done. See tutorial.md for checkpoints and interpretation."
