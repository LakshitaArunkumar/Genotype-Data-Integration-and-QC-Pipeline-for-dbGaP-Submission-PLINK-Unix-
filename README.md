# Genotype-Data-Integration-and-QC-Pipeline-for-dbGaP-Submission-PLINK-Unix-
Reproducible Unix and PLINK pipeline for integrating, harmonizing, and quality-controlling multi-platform genotype data into a dbGaP-ready dataset.

## Genotype Data Integration and QC Pipeline for dbGaP Submission (PLINK/Unix)

This project implements a reproducible Unix-based pipeline using PLINK to process, harmonize, and merge genotype data from multiple platforms into a single dbGaP-compliant dataset.

---

## Project Overview

This workflow integrates genotype data from three sources:

- SNP array data (PLINK binary format)  
- VCF-based genotype data  
- TaqMan assay genotype data (APOE variant)  

The goal is to generate a clean, merged dataset of 2,499 individuals suitable for dbGaP submission.

---

## Key Objectives

- Convert VCF genotype data into PLINK format  
- Harmonize allele encoding across datasets (ACGT standard)  
- Remove duplicate samples and resolve inconsistencies  
- Correct phenotype/genotype sex discrepancies  
- Standardize sample IDs across datasets  
- Construct missing genotype datasets (APOE variant)  
- Merge multiple genotype datasets  
- Perform quality control (QC) checks  
- Remove variants with high missingness  

---

## Pipeline Overview

### Step 1: VCF Conversion

- Converted VCF file into PLINK binary format using:
  - `--vcf`
  - `--make-bed`

---

### Step 2: Data Inspection and Validation

- Verified allele encoding (ACGT format)  
- Checked sample counts across datasets  
- Identified duplicate samples  
- Evaluated missing phenotype fields (e.g., sex)  

---

### Step 3: Data Cleaning

- Removed expected duplicate samples (`dup`)  
- Updated incorrect sex annotations using `--update-sex`  
- Harmonized allele coding using `--update-alleles` with manifest file  

---

### Step 4: APOE Variant Processing

- Converted coded genotype values (0/1/2) into allele pairs:
  - 0 → T T  
  - 1 → C T  
  - 2 → C C  

- Created:
  - `.ped` and `.map` files  
  - Converted to PLINK binary format  

---

### Step 5: Sample ID Harmonization

- Identified mismatched sample IDs  
- Corrected IDs using `--update-ids`  
- Ensured consistency across all datasets  

---

### Step 6: Data Merging

- Merged datasets in stages:
  - GENOTYPE + VCF  
  - Result + APOE  

- Verified:
  - Number of samples  
  - Number of variants  

---

### Step 7: Quality Control (QC)

- Sex check using:
  - `--check-sex 0.9 0.99`  

- Missingness analysis using:
  - `--missing`  

---

### Step 8: Filtering

- Removed SNPs with 100% missing call rate  
- Generated final filtered dataset  

---

## Technologies Used

- Unix (bash scripting)  
- PLINK v1.9  
- awk, grep, sort, join, diff  

---

## Input Data

The pipeline processes the following input files:

- PLINK binary genotype data (.bed, .bim, .fam)  
- VCF genotype data (.vcf.gz)  
- TaqMan genotype data (text format)  
- SNP annotation file (manifest.csv)  

---

## Output

Final processed dataset:

- Merged PLINK binary files (.bed, .bim, .fam)  
- Quality-controlled and filtered genotype dataset  

---

## Key Features

- Fully reproducible bash pipeline  
- Multi-platform genotype data integration  
- Implementation of dbGaP submission requirements  
- SLURM-based execution for large-scale data processing  
- Efficient handling of large genomic datasets  

---

## Reproducibility

- Script-based workflow (no manual edits)  
- Includes error handling (`set -e`) and command tracing (`set -v`)  
- Designed for high-performance computing environments  

---

## Key Skills Demonstrated

- Genomic data processing with PLINK  
- Multi-source data integration  
- Quality control of genotype datasets  
- Unix scripting and automation  
- HPC workflow execution  
- Data harmonization and validation  

---

## Notes

- Expected duplicate samples were removed  
- Sex discrepancies were resolved using genotype data  
- SNPs with complete missingness were excluded  

---

## Author

Lakshita Arunkumar
