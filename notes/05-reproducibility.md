# Module 5 — Reproducibility (cross-cutting)

## Learning objectives
By the end of this module you can:
- Justify why a **workflow manager** beats hand-run scripts, and choose **Nextflow/nf-core** vs
  **Snakemake**.
- Manage software with **conda/mamba** and **containers** (Docker/Singularity/Apptainer).
- Apply **provenance** practices: version pinning, parameter logging, seeds, version control.
- Recognize that Modules 0–4 are just *stages a workflow manager runs for you.*

---

## Where we are
```
  Reproducibility ◀── wraps ALL of: design → QC → core → downstream → interpretation
```
This isn't a final step — it's the box around the whole skeleton. The same pipeline you ran by hand
in the lab becomes a *declared, versioned, portable workflow.*

---

## 1. Why a workflow manager

Running tools by hand (or in a bash script) breaks down fast:
- **Resumability** — a 12-hour run dies at step 9; you don't want to redo steps 1–8.
- **Parallelism** — 500 samples should fan out across cores/cluster/cloud automatically.
- **Portability** — the same workflow must run on your laptop, an HPC scheduler, and the cloud.
- **Reproducibility** — the workflow *declares* every step, tool, and version; re-running gives the
  same result.

A workflow manager handles dependency resolution (what must run before what), caching/resume,
scheduling, and environment provisioning — so you describe *what* the pipeline is, not *how* to
babysit it.

---

## 2. Nextflow + nf-core

**Nextflow** is a dataflow workflow language: you define **processes** (a step + its inputs/outputs
+ its container/conda env) connected by **channels** (the data flowing between them). It runs the
same script on local, SLURM/SGE, Kubernetes, AWS/Azure/GCP by changing a config, not the code.

**nf-core** is a community library of **production-grade, peer-reviewed Nextflow pipelines** —
exactly the domains in this course, already built, tested, containerized, and benchmarked:

| nf-core pipeline | = which module |
|---|---|
| **nf-core/sarek** | Module 3a — germline & somatic variant calling (GATK best practices) |
| **nf-core/rnaseq** | Module 3b — RNA-seq quantification & QC (STAR/Salmon → counts) |
| **nf-core/mag** | Module 3c — metagenome assembly & binning (host removal → assembly → taxonomy) |
| **nf-core/viralrecon** | viral genome reconstruction |

```bash
# Run a whole validated variant-calling pipeline with one command
nextflow run nf-core/sarek -r 3.4.0 -profile docker \
  --input samplesheet.csv --genome GATK.GRCh38 --outdir results/
```
> **Punchline of the course:** everything you learned by hand in Modules 0–4 is what nf-core/sarek,
> /rnaseq, and /mag run *for* you — but you now understand each stage, so you can configure, debug,
> and trust them instead of treating them as a black box.

---

## 3. Snakemake

**Snakemake** is the Python-flavored alternative: you write **rules** (`input:`, `output:`,
`shell:`/`run:`), and Snakemake works backward from the desired output files, building the
dependency DAG by matching filenames. Strengths: Pythonic, fine-grained file-level control, very
popular in academic labs, integrates conda/containers per rule.

```python
rule align:
    input:  r1="trimmed/{s}_R1.fq.gz", r2="trimmed/{s}_R2.fq.gz", ref="ref.fa"
    output: "aligned/{s}.sorted.bam"
    threads: 4
    conda:  "envs/align.yaml"
    shell:  "bwa mem -t {threads} {input.ref} {input.r1} {input.r2} | samtools sort -o {output}"
```
**Choosing:** Nextflow/nf-core for portable, production, cloud/HPC, "I want a validated pipeline";
Snakemake for custom academic workflows where you want explicit file-level rules in Python. Both are
excellent — the key point is *use one.*

---

## 4. Environment management

Reproducibility dies if "it works on my machine." Two layers:

- **conda / mamba** — declare tools + exact versions in an `environment.yml`; `mamba` is the fast
  drop-in resolver. Bioconda hosts essentially every tool in this course. **Pin versions** (e.g.
  `bwa=0.7.17`, not `bwa`) so the env is stable over time.
- **Containers (Docker / Singularity / Apptainer)** — package the *entire* OS + tools into one
  immutable image. Docker is the standard for building/cloud; **Singularity/Apptainer** is the HPC
  norm (no root needed, runs on shared clusters). A container is the strongest reproducibility
  guarantee — the exact same binaries everywhere. Workflow managers pull a per-step container
  automatically.

```bash
mamba env create -f environment.yml     # reproducible env from a pinned spec
mamba env export > environment.lock.yml # capture the exact resolved versions
```

---

## 5. Provenance — leaving a trail

Even with a workflow manager, record:
- **Version pinning** — every tool, reference build, and database version (Module 4's methods
  section comes straight from here).
- **Parameter logging** — the exact command lines / config used (workflow managers emit this; nf-core
  writes a full run report and `pipeline_info/`).
- **Random seeds** — set seeds for any stochastic step (subsampling, some assemblers, ML tools) so
  runs are bit-reproducible.
- **Version control (git)** — the workflow code, configs, and sample sheets live in git; tag the
  commit used for a given analysis. Data goes to a data repository (SRA/ENA, Zenodo), not git.
- **Provenance metadata** — keep the sample sheet, run logs, and software manifest *with* the
  results.

> **The reproducibility test:** could someone else — or you in two years — regenerate these exact
> results from the inputs? If "yes," you're done. If "no," you have provenance debt.

---

## Checkpoint
1. You hand-ran a 10-step analysis; it crashed at step 8 after 6 hours. Name two things a workflow
   manager would have given you here.
2. A collaborator can't reproduce your result. Your `environment.yml` lists `bwa`, `samtools`,
   `gatk4` with no versions. What's the problem and the fix?
3. Map nf-core/sarek, nf-core/rnaseq, and nf-core/mag each to the Module 3 domain they implement.

<details><summary>Answers</summary>

1. **Resume/caching** (re-run only step 8 onward, not 1–7) and **declared, reproducible steps** (the
   workflow records exactly what each step did with which tool/version). Bonus: automatic
   parallelism and portability across laptop/HPC/cloud.
2. Unpinned tools mean the collaborator resolves *different* versions than you did, so behavior can
   differ — that's a reproducibility failure. Fix: **pin exact versions** (`bwa=0.7.17`,
   `gatk4=4.5.0.0`, ...) and ideally ship a lock file or container so the environment is identical.
3. **sarek → variant calling (3a)**, **rnaseq → RNA-seq (3b)**, **mag → metagenomics/phage (3c)**.
   Each is a validated, containerized implementation of the by-hand workflow in that module.
</details>

---

## ↗ Try it in Galaxy (GUI alternative)

Galaxy is itself a reproducibility platform — a **GUI workflow manager** alongside the
Nextflow/Snakemake CLI tools here, with provenance captured by default. Via the **Galaxy Training Network**:
- [Creating, Editing and Importing Galaxy Workflows](https://training.galaxyproject.org/training-material/topics/galaxy-interface/tutorials/workflow-editor/tutorial.html) — declare a pipeline visually.
- [Understanding the Galaxy history system](https://training.galaxyproject.org/training-material/topics/galaxy-interface/tutorials/history/tutorial.html) — every step, tool, and parameter recorded automatically.
