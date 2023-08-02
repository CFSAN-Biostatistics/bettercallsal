# `bettercallsal`

`bettercallsal` is an automated workflow to assign Salmonella serotype based on [NCBI Pathogen Detection](https://www.ncbi.nlm.nih.gov/pathogens) Project for [Salmonella](https://www.ncbi.nlm.nih.gov/pathogens/isolates/#taxgroup_name:%22Salmonella%20enterica%22). It uses `MASH` to reduce the search space followed by additional genome filtering with `sourmash`. It then performs genome based alignment with `kma` followed by count generation using `salmon`. This workflow can be used to analyze shotgun metagenomics datasets, quasi-metagenomic datasets (enriched for Salmonella) and target enriched datasets (enriched with molecular baits specific for Salmonella) and is especially useful in a case where a sample is of multi-serovar mixture.

It is written in **Nextflow** and is part of the modular data analysis pipelines (**CFSAN PIPELINES** or **CPIPES** for short) at **CFSAN**.

\
&nbsp;

## Workflows

**CPIPES**:

 1. `bettercallsal`       : [README](./readme/bettercallsal.md).
 2. `bettercallsal_db`    : [README](./readme/bettercallsal_db.md).

\
&nbsp;

### Citing `bettercallsal`

---
This work is published in [Frontiers in Microbiology](https://www.frontiersin.org/articles/10.3389/fmicb.2023.1200983/full).

>
>**bettercallsal: better calling of Salmonella serotypes from enrichment cultures using shotgun metagenomic profiling and its application in an outbreak setting.**
>
>Kranti Konganti, Elizabeth Reed, Mark Mammel, Tunc Kayikcioglu, Rachel Binet, Karen Jarvis, Christina M. Ferreira, Rebecca Bell, Jie Zheng, Amanda M. Windsor, Andrea Ottesen, Christopher Grim, and Padmini Ramachandran. *Frontiers in Microbiology*. [https://doi.org/10.3389/fmicb.2023.1200983](https://www.frontiersin.org/articles/10.3389/fmicb.2023.1200983/full).
>

\
&nbsp;

### Caveats

---

- The main workflow has been used for **research purposes** only.
- Analysis results should be interpreted with caution and should be treated as suspect, as the pipeline is dependent on the precision of metadata from the **NCBI Pathogen Detection** project for the `per_snp_cluster` and `per_computed_serotype` databases.
- Internal research with simulated datasets suggests that the `bettercallsal` workflow is more accurate with increased read depth.
  - For Illumina MiSeq, at least 5 million read pairs (2x300 PE) or 10 million reads (1x300 SE) per sample works well.
  - For Illumina NextSeq and NovaSeq, around 10 million read pairs (2x150 PE) or 20 million reads (1x150 SE) per sample works well.
  - That being said, it is not a hard-cutoff and you can still try the workflow on low read-depth samples.
- **No genome hit** assignment should be interpreted with caution.

\
&nbsp;

### Acknowledgements

---
**NCBI Pathogen Detection**:

We gratefully acknowledge all data contributors, i.e., the Authors and their Originating laboratories responsible for obtaining the specimens, and their Submitting laboratories for generating the sequence and metadata and sharing it via the **NCBI Pathogen Detection** site, some of which this research utilizes.

\
&nbsp;

### Disclaimer

---
**CFSAN, FDA** assumes no responsibility whatsoever for use by other parties of the Software, its source code, documentation or compiled or uncompiled executables, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. Further, **CFSAN, FDA** makes no representations that the use of the Software will not infringe any patent or proprietary rights of third parties. The use of this code in no way implies endorsement by the **CFSAN, FDA** or confers any advantage in regulatory decisions.
