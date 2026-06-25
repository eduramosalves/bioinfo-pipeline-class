# Resources — Papers, Docs, Datasets & Glossary

Curated pointers for going deeper. Tool docs are the fastest path to current options/flags;
the papers explain *why* a method works.

---

## Tool documentation

### QC & preprocessing
- **FastQC** — https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
- **MultiQC** — https://multiqc.info/ (docs) · paper: Ewels et al. 2016, *Bioinformatics*
- **fastp** — https://github.com/OpenGene/fastp · paper: Chen et al. 2018, *Bioinformatics*
- **Trimmomatic** — http://www.usadellab.org/cms/?page=trimmomatic · Bolger et al. 2014
- **cutadapt** — https://cutadapt.readthedocs.io/ · Martin 2011

### Alignment & assembly
- **BWA / BWA-MEM** — https://github.com/lh3/bwa · Li & Durbin 2009; Li 2013 (MEM, arXiv:1303.3997)
- **Bowtie2** — https://bowtie-bio.sourceforge.net/bowtie2/ · Langmead & Salzberg 2012
- **minimap2** — https://github.com/lh3/minimap2 · Li 2018, *Bioinformatics*
- **samtools / bcftools / htslib** — https://www.htslib.org/ · Danecek et al. 2021, *GigaScience*
- **SPAdes / metaSPAdes** — https://github.com/ablab/spades · Bankevich 2012; Nurk 2017 (metaSPAdes)
- **MEGAHIT** — https://github.com/voutcn/megahit · Li et al. 2015
- **Flye / metaFlye** — https://github.com/fenderglass/Flye · Kolmogorov 2019, 2020
- **QUAST** (assembly QC) — https://quast.sourceforge.net/ · **BUSCO** — https://busco.ezlab.org/

### Variant calling & annotation
- **GATK** + Best Practices — https://gatk.broadinstitute.org/ · DePristo 2011; Van der Auwera & O'Connor 2020 (*Genomics in the Cloud*, O'Reilly)
- **DeepVariant** — https://github.com/google/deepvariant · Poplin et al. 2018, *Nat Biotech*
- **VCF spec** — https://samtools.github.io/hts-specs/VCFv4.3.pdf
- **VEP** — https://www.ensembl.org/info/docs/tools/vep/ · McLaren et al. 2016
- **SnpEff / SnpSift** — https://pcingola.github.io/SnpEff/ · Cingolani et al. 2012
- **ANNOVAR** — https://annovar.openbioinformatics.org/ · Wang et al. 2010
- **ClinVar** — https://www.ncbi.nlm.nih.gov/clinvar/ · **gnomAD** — https://gnomad.broadinstitute.org/
- **ACMG/AMP guidelines** — Richards et al. 2015, *Genet Med* 17:405 (variant interpretation standard)

### RNA-seq
- **STAR** — https://github.com/alexdobin/STAR · Dobin et al. 2013
- **HISAT2** — http://daehwankimlab.github.io/hisat2/ · Kim et al. 2019
- **Salmon** — https://salmon.readthedocs.io/ · Patro et al. 2017, *Nat Methods*
- **kallisto** — https://pachterlab.github.io/kallisto/ · Bray et al. 2016
- **featureCounts** (subread) — https://subread.sourceforge.net/ · Liao et al. 2014
- **DESeq2** — https://bioconductor.org/packages/DESeq2/ · Love et al. 2014, *Genome Biol*
- **edgeR** — https://bioconductor.org/packages/edgeR/ · Robinson et al. 2010
- **tximport** — https://bioconductor.org/packages/tximport/ · Soneson et al. 2015

### Phage / metagenomics
- **geNomad** — https://github.com/apcamargo/genomad · Camargo et al. 2024, *Nat Biotech*
- **VirSorter2** — https://github.com/jiarong/VirSorter2 · Guo et al. 2021, *Microbiome*
- **CheckV** — https://bitbucket.org/berkeleylab/checkv · Nayfach et al. 2021, *Nat Biotech*
- **Kraken2** — https://github.com/DerrickWood/kraken2 · Wood et al. 2019, *Genome Biol*
- **Bracken** — https://github.com/jenniferlu717/Bracken · Lu et al. 2017
- **Pharokka** — https://github.com/gbouras13/pharokka · Bouras et al. 2023, *Bioinformatics*
- **Prokka** — https://github.com/tseemann/prokka · Seemann 2014 · **Bakta** — Schwengers et al. 2021

### Visualization & reproducibility
- **IGV** — https://igv.org/ · Robinson et al. 2011, *Nat Biotech*
- **Nextflow** — https://www.nextflow.io/ · Di Tommaso et al. 2017, *Nat Biotech*
- **nf-core** — https://nf-co.re/ (sarek, rnaseq, mag, viralrecon) · Ewels et al. 2020, *Nat Biotech*
- **Snakemake** — https://snakemake.readthedocs.io/ · Mölder et al. 2021, *F1000Research*
- **Bioconda** — https://bioconda.github.io/ · Grüning et al. 2018 · **conda/mamba** — https://mamba.readthedocs.io/
- **Apptainer/Singularity** — https://apptainer.org/ · Kurtzer et al. 2017

---

## File-format specifications (hts-specs)
All canonical specs live at https://samtools.github.io/hts-specs/ — SAM/BAM, CRAM, VCF/BCF.
- FASTQ + Phred encoding overview: Cock et al. 2010, *Nucleic Acids Research*
- GFF3 spec — https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md
- BED format — https://genome.ucsc.edu/FAQ/FAQformat.html#format1

---

## Datasets for teaching / the lab
- **E. coli K-12 MG1655 reference** — NCBI RefSeq **NC_000913.3**
- **Phage lambda reference** — NCBI **NC_001416.1** (~48.5 kb)
- **NCBI SRA / ENA** — public raw reads: https://www.ncbi.nlm.nih.gov/sra · https://www.ebi.ac.uk/ena
- **nf-core test datasets** — small, curated inputs for every nf-core pipeline: https://github.com/nf-core/test-datasets
- **Zenodo** — archived datasets with DOIs: https://zenodo.org/

---

## Glossary

| Term | Meaning |
|------|---------|
| **Adapter** | synthetic oligo added in library prep; read-through must be trimmed |
| **Allele fraction (AF)** | proportion of reads supporting the alternate allele at a site |
| **BAM** | binary, compressed SAM — aligned reads on a coordinate system |
| **Batch effect** | systematic non-biological variation from processing groups (day/kit/lane) |
| **BQSR** | Base Quality Score Recalibration — corrects systematic per-base quality bias |
| **Coverage / depth** | average number of reads spanning a position (e.g. "30×") |
| **CIGAR** | string in BAM describing match/insert/delete/clip layout of an alignment |
| **Contig** | a contiguous sequence reconstructed in assembly |
| **de Bruijn graph** | k-mer graph structure short-read assemblers traverse |
| **Dispersion** | gene-wise variability estimate in negative-binomial DE models |
| **FDR** | False Discovery Rate — expected fraction of false positives among hits (BH-adjusted `padj`) |
| **GVCF** | per-sample VCF holding all sites (incl. non-variant) for joint genotyping |
| **Genotype (GT)** | 0/0 hom-ref, 0/1 het, 1/1 hom-alt at a variant site |
| **Indel** | small insertion or deletion variant |
| **log2 fold-change** | log2 ratio of expression between conditions (effect size) |
| **MAPQ** | Phred-scaled confidence that a read is correctly placed |
| **N50** | contig length at which 50% of the assembly sits in contigs ≥ that length (contiguity) |
| **Negative binomial** | count distribution (over-dispersed) used by DESeq2/edgeR |
| **Phred score (Q)** | −10·log10(error prob); Q30 = 0.1% error; FASTQ encodes it Phred+33 |
| **Provirus / prophage** | a phage genome integrated into a host chromosome |
| **Pseudo-alignment** | k-mer-based read-to-transcript assignment without base-level alignment |
| **Reference genome** | the known sequence reads are aligned/compared against |
| **Replicate (biological)** | independent sample; the basis of statistical power |
| **Soft-clipping** | aligner ignoring read ends (e.g. low-quality tail) while still placing the read |
| **TPM** | Transcripts Per Million — length+depth normalized abundance (within-sample) |
| **VCF** | Variant Call Format — positions where a sample differs from the reference |
| **VUS** | Variant of Uncertain Significance — ACMG class when evidence is insufficient |
| **Workflow manager** | tool (Nextflow/Snakemake) that declares, runs, resumes, and parallelizes a pipeline |
