# Module 3c — Domain: Phage / Metagenomics

## Learning objectives
By the end of this module you can:
- Run the metagenomics arc: **host removal → assembly → viral identification → taxonomy →
  annotation.**
- Use **geNomad / VirSorter2** to find viral/phage contigs and **CheckV** to judge their
  completeness & contamination.
- Profile community taxonomy with **Kraken2 / Bracken**.
- Annotate a phage genome with **Pharokka / Prokka**.
- Explain why this domain *assembles* rather than *aligns*.

---

## Where we are
```
  ... → Core processing (ASSEMBLE) → ▶ Viral ID → Taxonomy → Annotation → Interpretation
```
This is the **assembly branch** of Module 2. There is no single reference for a microbial community
— you reconstruct genomes from a soup of organisms.

---

## 1. The goal

A metagenome is **all the DNA in a sample** (gut, soil, wastewater, a phage prep) — many organisms,
unknown and uncultured, mixed together. We want to: recover genomes (especially **bacteriophages /
viruses**), say **who is there** (taxonomy), and say **what they can do** (gene annotation). This
module leans toward the **virome / phage** angle (the user's research direction): finding and
characterizing phages in metagenomic data.

> Why assemble, not align? The community contains novel, uncultured genomes with **no trustworthy
> reference**. Aligning to a database tells you only about what's *already known*; assembly
> reconstructs the actual sequences present — including new phages.

---

## 2. Host / contaminant read removal

Before assembly, strip reads you don't want. In a phage prep from a bacterial culture, or a human
microbiome sample, a large fraction of reads is **host** (bacterial or human) DNA. Remove it so the
assembly focuses on the target and to avoid mapping host sequence into your "viral" results.

```bash
# Map reads to the host genome; keep the reads that DON'T map (unmapped = non-host)
bowtie2 -x host_index -1 R1.fq.gz -2 R2.fq.gz --un-conc-gz nonhost_R%.fq.gz -S /dev/null
# (minimap2 + samtools view -f 4 is the long-read equivalent)
```
Also handle PhiX spike-in and adapters here (Module 1). For human studies, host removal is also a
**privacy** requirement.

---

## 3. Assembly of the community

Use a **metagenome-aware** assembler — communities have wildly uneven coverage (abundant species
deep, rare species shallow), which confuses isolate assemblers.

| Assembler | Notes |
|-----------|-------|
| **metaSPAdes** (`spades.py --meta`) | high-quality short-read metagenome assembly; great for viruses/phages |
| **MEGAHIT** | fast, low-memory; preferred for very large/complex metagenomes |
| **Flye** (`--meta`) | long-read (ONT/PacBio) metagenome assembly |

```bash
spades.py --meta -1 nonhost_R1.fq.gz -2 nonhost_R2.fq.gz -o metaspades_out -t 8 -m 32
# → metaspades_out/contigs.fasta  (a mix of bacterial, phage, plasmid, ... contigs)
```
The output is an undifferentiated pile of contigs. The next step separates the viral wheat from the
cellular chaff.

---

## 4. Viral / phage identification

Pull the **viral contigs** out of the assembly. These tools score each contig for viral signal
(gene content, k-mer signatures, hallmark genes):

| Tool | Notes |
|------|-------|
| **geNomad** | modern, fast; classifies contigs as virus/plasmid/chromosome; also annotates and does taxonomy. A strong default. |
| **VirSorter2** | widely used; detects diverse viruses incl. prophages integrated in bacterial contigs |
| **DeepVirFinder / VIBRANT** | alternative ML/annotation-based identifiers |

```bash
genomad end-to-end metaspades_out/contigs.fasta genomad_out genomad_db/
# → virus-classified contigs + provirus boundaries + taxonomy
```

### CheckV — how good is each viral genome?
A predicted viral contig is not necessarily a *complete* genome. **CheckV** assesses each:
- **Completeness** — what fraction of the expected genome is present (e.g. 100% = complete genome,
  45% = a fragment).
- **Contamination** — host (bacterial) sequence wrongly attached (e.g. flanking a prophage).
- **Provirus detection** — trims host regions off integrated prophages.
```bash
checkv end_to_end viral_contigs.fasta checkv_out -d checkv_db/
```
CheckV is the viral analog of BUSCO/QUAST from Module 2 — *completeness ≠ contiguity.* Report your
phages with their CheckV quality tier (Complete / High / Medium / Low-quality).

---

## 5. Taxonomy — who is in the sample?

To profile the whole community (not just viruses), classify reads/contigs against a reference
database:
- **Kraken2** — ultra-fast k-mer-based read classification against a taxonomic database; assigns
  each read a taxon.
- **Bracken** — re-estimates **abundance** at a chosen rank (e.g. species) from Kraken2 output;
  Kraken2 says "this read is genus X," Bracken says "genus X is 12% of the community."

```bash
kraken2 --db kraken_db --paired nonhost_R1.fq.gz nonhost_R2.fq.gz \
  --report sample.kreport --output sample.kraken
bracken -d kraken_db -i sample.kreport -o sample.bracken -r 150 -l S
```
> **Database caveat:** Kraken2/Bracken can only see what's in the database. Novel phages — the
> interesting ones — are often *unclassified*. That's precisely why assembly + CheckV matters: it
> characterizes genomes the database has never seen.

---

## 6. Phage genome annotation

For a recovered phage genome, predict and label its genes:
| Tool | Notes |
|------|-------|
| **Pharokka** | **phage-specialized** annotation: gene calling (PHANOTATE), function via phage databases (PHROGs), tRNAs, CRISPR, and a genome map figure |
| **Prokka** | general prokaryotic/bacterial annotation; usable for phages but not phage-tuned |
| **Bakta** | modern bacterial annotation alternative |

```bash
pharokka.py -i my_phage.fasta -o pharokka_out -d pharokka_db -t 8
# → annotated GFF/GBK + functional categories + circular genome plot
```
Pharokka is preferred for phages because phage genes are poorly represented in generic bacterial
databases (many "hypothetical protein" calls otherwise), and it understands phage-specific features
(structural modules, lysis genes, integrases, packaging).

---

## 7. The full arc, end to end

```
raw reads
  → QC + trim (Module 1)
  → host-read removal           (bowtie2/minimap2: keep non-host)
  → metagenome assembly         (metaSPAdes / MEGAHIT / Flye --meta) → contigs.fasta
  → viral identification        (geNomad / VirSorter2)               → viral contigs
  → quality assessment          (CheckV: completeness/contamination)
  → taxonomy                    (Kraken2 + Bracken)                  → community profile
  → phage annotation            (Pharokka)                           → annotated genomes
  → interpretation (Module 4)
```
The production version of this is **nf-core/mag** (Module 5).

---

## Checkpoint
1. Why does this domain *assemble* instead of *aligning to a reference*, and what would you miss if
   you only ran Kraken2 on the raw reads?
2. geNomad flags a 38 kb contig as viral; CheckV reports **completeness 96%, contamination 18%**.
   What does the contamination mean and what likely produced it?
3. You annotate a phage genome with Prokka and 80% of genes come back "hypothetical protein." What
   tool would likely do better, and why?

<details><summary>Answers</summary>

1. The community contains **novel/uncultured genomes with no reference**; alignment only reveals
   what's already in a database. Assembly reconstructs the actual sequences, including new phages.
   Kraken2 alone would classify only *known* taxa and leave the novel phages **unclassified** — you'd
   miss the discovery, and get no genome to annotate.
2. **18% contamination = ~18% of the contig is non-viral (host) sequence**, typically because the
   contig is an **integrated prophage** still carrying flanking bacterial DNA. CheckV can detect the
   provirus boundaries and trim the host region before you call it a phage genome.
3. **Pharokka** (phage-specialized, using PHANOTATE gene calling and the PHROGs phage protein
   database). Phage genes are sparsely represented in generic bacterial databases, so Prokka labels
   many as "hypothetical"; a phage-tuned tool assigns real functions to far more of them.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

The metagenomics arc, in a browser via the **Galaxy Training Network**:
- [Assembly of metagenomic sequencing data](https://training.galaxyproject.org/training-material/topics/microbiome/tutorials/metagenomics-assembly/tutorial.html) — assemble the community.
- [Taxonomic Profiling and Visualization](https://training.galaxyproject.org/training-material/topics/microbiome/tutorials/taxonomic-profiling/tutorial.html) — who is there.
- [Pathogen detection from Nanopore data](https://training.galaxyproject.org/training-material/topics/microbiome/tutorials/pathogen-detection-from-nanopore-foodborne-data/tutorial.html).

*(GTN's phage/virome coverage is thinner than this module — keep **geNomad / CheckV / Pharokka** as the CLI primary for viral identification, QC, and annotation.)*
