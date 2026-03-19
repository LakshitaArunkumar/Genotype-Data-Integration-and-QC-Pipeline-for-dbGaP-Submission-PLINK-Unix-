#!/bin/bash
#SBATCH-M teach
#SBATCH-A hugen2071-2024f
#SBATCH --mem-per-cpu=100G
#SBATCH -t 6:00:00
set -ve
module load plink/1.90b6.7

#TASK 1 : Converting the vcf file (data_2019_07_08.vcf.gz) to bfiles of plink and saving it in scratch folder
#Using plink --vcf and --make-bed get the ped and map files from data_2019_07_08.vcf.gz.
plink --vcf /ix1/hugen2071-2024f/data/Project_2/data_2019_07_08.vcf.gz \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf
#The bfiles(data_vcf.bim; data_vcf.fam; data_vcf.bed) are made and saved in /ix1/hugen2071-2024f/data/scratch/project_2

#TASK 2 : Making a note of things which needs to be changed for each genetic data

#Subpart 1: to check if the data_vcf.bim; GENOTYPE_DATA.bim and apoe_genotype.txt has ACGT
#To see how the snp is stored - if numeric or anyother data it has to be changed to ACGT
#The head of data_vcf.bim showing ACTG kindof coding
head /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bim
#The tail of data_vcf.bim showing ACTG kindof coding
tail /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bim
#Finally we can check if there is any other alphabet or numric value using grep
set +e
grep -v '[ACGT]' /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bim | head -n10
set -e

#The head of GENOTYPE_DATA.bim showing alphabetical coding but there is a B which is code instead of the other nucleotide"
head /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA.bim
#The tail of GENOTYPE_DATA.bim showing alphabetical coding but there is a B which is code instead of the other nucleotide"
tail /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA.bim
#We see that GENOTYPE_DATA.bim data has to be matched with manifest.csv and use --update-alleles

#The head of apoe_genotype.txt
head -n10 /ix1/hugen2071-2024f/data/Project_2/apoe_genotype.txt
#The tail of apoe_genotype.txt
tail -n10 /ix1/hugen2071-2024f/data/Project_2/apoe_genotype.txt
#Finally we can check if there is any other alphabet or numric value using grep
set +e
grep -v '[ACGT]' /ix1/hugen2071-2024f/data/Project_2/apoe_genotype.txt | head -n10
set -e

#Subpart 2: checking the number of individuals
#In data_vcf.fam
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.fam
#There are exactly 2499 individuals

#In GENOTYPE_DATA.fam
wc -l /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA.fam
#There are 2524 individuals, duplicates has to be removed by checking for dup using grep and --remove to update the .fam file by creating a new set of .bed and .bim file

#In apoe_genotype.txt
wc -l /ix1/hugen2071-2024f/data/Project_2/apoe_genotype.txt
#The wc -l shows 2500 since the first row is header finally we have 2499 individuals again

#Subpart 3: Checking if sex has be extracted properly from vcf but we know that is not the case
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.nosex
#The entire data is doesnot have sex so since there are only 2499 individuals we can take the sex data from the GENOTYPE_DATA

#Subpart 4: Running check-sex command on GENOTYPE_DATA since that will be used for the other data
plink --bfile /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA \
--check-sex 0.9 0.99 \
--out /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_sex_check
set +e
grep "PROBLEM" /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_sex_check.sexcheck
set -e

#The same problem was seen for GENOTYPE_DATA for the individual(HG02597) so a report is made and will get updated 
echo "HG02597 HG02597 1" > sex_update.txt


#Summary from TASK2:
#Major changes need to done to GENOTYPE_DATA bfiles :- 1) duplicates has to be removed and sex of the individual which caused a problem has to be handled 2) the alleles has to be updated
#For apoe_genotype.txt checking if the rsID exists in the other 2 data; if not .map and .ped files has to be created by checking which .fam files will not give difference by using diff.
#If any difference is found the data has to be update to maintain 2499 individuals

#TASK 3 : Cleaning data and getting it ready for QC tests
#Subpart 1: The major changes for GENOTYPE_DATA bfiles
#1st change: Using grep to store the dup data in data_dup.txt which will be excluded
grep "dup" /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA.fam > data_dup.txt
head data_dup.txt

#Making the bfiles for GENOTYPE_DATA after removing dup and updating sex of the individual HG02597
plink --bfile /ix1/hugen2071-2024f/data/Project_2/GENOTYPE_DATA \
--remove data_dup.txt \
--update-sex sex_update.txt \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED
#DONE Making the bfiles GENOTYPE_DATA_UPDATED
set +e
grep "dup" /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED.fam | head -n10
grep "HG02597" /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED.fam
set -e
rm data_dup.txt

#2nd change: update the alleles from manifest.csv
#Sort the .bim file by the second column (rsID)
sort -k2,2 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED.bim | cut -f2,5,6 > /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED_SORTED.txt
head /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED_SORTED.txt
#Sort the manifest.csv file by the third column (rsID)
cut -d',' -f1,3,4,5 /ix1/hugen2071-2024f/data/Project_2/manifest.csv | tr ',' '\t' | sort -k2,2 > manifest_sorted.txt
wc -l manifest_sorted.txt
#Refered from chagpt and homework 9
join -i -1 1 -2 2 -o 1.1,1.2,1.3,2.3,2.4 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED_SORTED.txt manifest_sorted.txt > data_extract.txt
#Reference ends here
head data_extract.txt
#done writing data_extract.txt
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED.bim
plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED \
--update-alleles data_extract.txt \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL
#Done creating GENOTYPE_DATA_FINAL .bim, .bed and .fam
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.bim
head -n10 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.bim
rm manifest_sorted.txt data_extract.txt
rm /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_UPDATED*

#Subpart2: To see if .map and .ped files are needed for apoe_genotype.txt
grep -w "rs429358" /ix1/hugen2071-2024f/data/Project_2/manifest.csv | echo "NO data of rs429358 in manifest.csv"
cut -d' ' -f2 /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bim | grep -w "rs429358" | echo "NO data of rs429358 in data_vcf.bim"
cut -d' ' -f2 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.bim | grep -w "rs429358" | echo "NO data of rs429358 in GENOTYPE_DATA_FINAL.bim"
#Since there are no match in any of the above files so .map and .ped has to be created for the apoe_genotype.txt

#First we have to convert 0, 1, 2 as follows: 0 is T T; 1 is C T; 2 is C C this will give the alleles
#The code below is Reference from Chatgpt
awk -F, 'NR > 1 {
    if ($2 == 1)
        print $1, "C T";
    else if ($2 == 2)
        print $1, "C C";
    else if ($2 == 0)
        print $1, "T T";
}' /ix1/hugen2071-2024f/data/Project_2/apoe_genotype.txt > apoe_genotype_changed.txt
#Reference from Chatgpt ends here
#List of Genotype in apoe_genotype.txt after assigning C's and T's"
head apoe_genotype_changed.txt

#Which data should I use to make the apoe_genotype.map and apoe_genotype.ped file?
cut -d' ' -f2 /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.fam | column -t > data_vcf_fam.txt
cut -d' ' -f2 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.fam | column -t > GENOTYPE_DATA_fam.txt
cut -d' ' -f1 apoe_genotype_changed.txt > fam.txt
set +e
diff data_vcf_fam.txt fam.txt
set -e
#diff data_vcf_fam.txt fam.txt it gave a difference in id HG01889a this will affect the 2499 individuals of data so using --update-ids it has to be updated
echo "HG01889a HG01889a HG01889 HG01889" > update_id.txt

plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf \
--update-ids update_id.txt \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_updated
#data_vcf_updated .bed, .bim and .fam files are made
set +e
grep "HG01889" /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final.fam
set -e
echo "Update is done"
rm /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bim /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.fam /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf.bed

#The sex column is 0 since the vcf file was converted using the data from GENOTYPE_DATA.fam
cut -d' ' -f1,2,5 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.fam > data_sex.txt
head data_sex.txt

plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_updated \
--update-sex data_sex.txt \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final
#data_vcf_final .bed, .bim and .fam files are made

set +e
diff GENOTYPE_DATA_fam.txt fam.txt
set -e
#diff GENOTYPE_DATA_fam.txt fam.txt no difference so this can be used to make .ped and .map file of apoe_genotype.txt"
rm data_vcf_fam.txt fam.txt GENOTYPE_DATA_fam.txt

#Making apoe_genotype.map
echo "0 rs42958 0 0" > apoe_genotype.map
#Done with creating apoe_genotype.map
cat apoe_genotype.map

#Making apoe_genotype.ped
sort -k2,2 /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.fam > apoe_genotype_start.txt
sort -k1,1 apoe_genotype_changed.txt | cut -d' ' -f2,3 > apoe_genotype_sorted.txt
#DONE With Sorting
paste -d' ' apoe_genotype_start.txt apoe_genotype_sorted.txt > apoe_genotype.ped
#Done creating apoe_genotype.ped
head apoe_genotype.ped
rm apoe_genotype_start.txt

#Making .bim; .fam and .bed files
plink --file apoe_genotype \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final
#Created .bim, .fam and .bed file for apoe_genotype
cat /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final.bim
head /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final.fam
rm apoe_genotype.ped apoe_genotype.map apoe_genotype_sorted.txt apoe_genotype_changed.txt
                                                                                    
#Task 4: Merging apoe_genotype_final, data_vcf_final, GENOTYPE_DATA_FINAL

#The number of variants in total before merging in GENOTYPE_DATA:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.bim
#The number of individual in total before merging in GENOTYPE_DATA:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL.fam

#The number of variants in total before merging in data_vcf_final:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final.bim
#The number of individual in before merging in data_vcf_final:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final.fam

#The number of variants in total before merging in apoe_genotype_final:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final.bim
#The number of individual in before merging in apoe_genotype_final:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final.fam

plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL \
--bmerge /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_VCF_DATA_MERGED
rm /ix1/hugen2071-2024f/data/scratch/project_2/data_vcf_final*
rm /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_DATA_FINAL*

plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final \
--bmerge /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_VCF_DATA_MERGED \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA
rm /ix1/hugen2071-2024f/data/scratch/project_2/apoe_genotype_final*
rm /ix1/hugen2071-2024f/data/scratch/project_2/GENOTYPE_VCF_DATA_MERGED*
rm /ix1/hugen2071-2024f/data/scratch/project_2/data*

#The number of variants in total after merge:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA.bim
#The number of individual in total after merge:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA.fam

#TASK 5: Check for QC - check-sex
plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA \
--check-sex 0.9 0.99 \
--out /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA


#TASK 6: Check missingness:
plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA \
--missing \
--out /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA_missing
head /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA_missing.imiss
head /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA_missing.lmiss

#MISSINGNESS is removed
#Reference from Chatgpt
awk '$5 == 1 {print $2}' /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA_missing.lmiss > exclude_snps.txt
#Reference ends here
wc -l exclude_snps.txt
head exclude_snps.txt

plink --bfile /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA \
--exclude exclude_snps.txt \
--make-bed \
--out /ix1/hugen2071-2024f/data/scratch/project_2/filtered_data

rm /ix1/hugen2071-2024f/data/scratch/project_2/COMPLETED_MEREGED_DATA*
rm *.txt

#The number of variants in total after removing missingness data:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/filtered_data.bim
#The number of individual in total after removing missingness data:
wc -l /ix1/hugen2071-2024f/data/scratch/project_2/filtered_data.fam

