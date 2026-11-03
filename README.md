
# Genotype Data Integration and Quality Control for dbGaP Using PLINK and Unix

**Graduate Coursework Project | M.S. Genome Bioinformatics | University of Pittsburgh**

## Project Overview

This project was completed as part of my graduate coursework at the University of Pittsburgh. It involved developing a Unix-based workflow to integrate genotype data from multiple platforms and prepare a harmonized dataset for downstream genomic analysis and potential dbGaP submission.

The analysis combined **SNP array data, VCF-based genotype data, and TaqMan assay data** using PLINK. The workflow addressed differences in allele encoding, sample identifiers, sex annotations, duplicate records, and genotype missingness.

The pipeline was implemented using Bash and PLINK v1.9 and executed in a high-performance computing (HPC) environment.

## Objectives

- Convert VCF genotype data into PLINK binary format.
- Harmonize allele encoding across different genotyping platforms.
- Identify and remove duplicate sample records.
- Investigate sex annotation discrepancies.
- Standardize sample identifiers across datasets.
- Convert TaqMan assay results into PLINK-compatible genotype files.
- Merge genotype datasets into a unified dataset.
- Perform genotype quality control and missingness filtering.

## Tools and Technologies

| Tool | Purpose |
|------|---------|
| PLINK v1.9 | Genotype conversion, merging, and quality control |
| Bash / Unix | Pipeline scripting and automation |
| AWK | Genotype recoding and data filtering |
| grep / sort / join / diff | Data inspection and identifier harmonization |
| SLURM | HPC job scheduling |

## Analysis Workflow

```text id="69hcba"
SNP Array Data   VCF Data   TaqMan Genotypes
      |             |              |
      v             v              v
   Data Inspection and Format Conversion
                    |
                    v
       Allele Harmonization
                    |
                    v
     Duplicate Sample Removal
                    |
                    v
  Sex Annotation and Sample ID Updates
                    |
                    v
       Multi-Platform Data Merging
                    |
                    v
          Genotype Quality Control
                    |
                    v
       Variant Missingness Filtering
                    |
                    v
         Final PLINK Binary Dataset
```

## Methods and Results

### 1. Genotype Data Preparation

- Converted compressed VCF data into PLINK binary files (`.bed`, `.bim`, `.fam`).
- Examined allele encodings across the input datasets.
- Used an SNP manifest file to standardize allele annotations.
- Compared sample identifiers to identify inconsistencies between platforms.

### 2. Sample Cleaning and Harmonization

- Identified duplicate records in the SNP array dataset.
- Removed 25 duplicate sample records, reducing the dataset from 2,524 to 2,499 individuals.
- Performed sex consistency checks using PLINK `--check-sex`.
- Updated a flagged sex annotation in the coursework dataset.
- Standardized sample identifiers and transferred sex annotations to the VCF-derived dataset.

### 3. TaqMan Genotype Integration

- Processed APOE-related TaqMan genotype data.
- Converted numerical genotype codes into nucleotide allele pairs.
- Generated PLINK-compatible PED/MAP files.
- Converted these files into binary PLINK format for integration.

### 4. Multi-Platform Genotype Merging

Performed sequential genotype merges using PLINK:

1. Combined SNP array and VCF-derived genotype data.
2. Integrated the TaqMan genotype dataset.
3. Verified the number of individuals and variants after merging.

**Merged dataset:**

| Metric | Result |
|--------|--------|
| Individuals | 2,499 |
| Male | 1,232 |
| Female | 1,267 |
| Variants | 48,044,502 |

### 5. Genotype Quality Control

- Performed sex consistency checks using `--check-sex 0.9 0.99`.
- Calculated sample-level and variant-level missingness using `--missing`.
- Generated missingness reports for evaluating genotype completeness.
- Identified variants with a missing genotype rate of 100%.

### 6. Variant Filtering

Removed variants with completely missing genotype calls using PLINK.

**Final filtering results:**

| Metric | Result |
|--------|--------|
| Variants before filtering | 48,044,502 |
| Variants removed | 48 |
| Variants retained | 48,044,454 |
| Individuals retained | 2,499 |

The filtering step produced an updated PLINK binary dataset for downstream analysis.

## Repository Contents

**Main script:** [project_2.sh](project_2.sh)

| File | Description |
|------|-------------|
| `project_2.sh` | Bash pipeline for genotype integration and quality control |
| `slurm-5143.out` | SLURM execution log documenting processing steps and outputs |
| `README.md` | Project documentation |

## Outputs

The workflow generated:

- Converted PLINK genotype files (`.bed`, `.bim`, `.fam`)
- Harmonized intermediate genotype datasets
- Merged multi-platform genotype data
- Sex consistency reports (`.sexcheck`)
- Sample and variant missingness reports (`.imiss`, `.lmiss`)
- Final filtered PLINK dataset (`filtered_data.bed`, `.bim`, `.fam`)

## Limitations

- The workflow was developed as a graduate coursework exercise using provided datasets.
- The script contains HPC-specific paths that require modification before execution elsewhere.
- The filtering step removes completely missing variants but does not implement all standard genotype QC procedures.
- The APOE variant identifier in the generated MAP file should be verified against the original assay documentation.
- Additional genotype validation and submission-specific checks would be required before an actual dbGaP submission.

## Skills Demonstrated

- Multi-platform genotype data integration
- Genomic data processing using PLINK
- VCF and PLINK file format conversion
- Allele and sample identifier harmonization
- Duplicate sample detection and removal
- Sex consistency assessment
- Genotype missingness analysis
- Bash scripting and Unix text processing
- HPC workflow execution using SLURM

## Coursework Acknowledgment

This project was completed as part of the **M.S. Genome Bioinformatics curriculum at the University of Pittsburgh**, using coursework-provided data and assignment materials.

## Author

**Lakshita Arunkumar**

M.S. Genome Bioinformatics  
University of Pittsburgh

[GitHub Profile](https://github.com/LakshitaArunkumar)
