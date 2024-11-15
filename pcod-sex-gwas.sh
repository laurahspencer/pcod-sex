#!/bin/bash
#SBATCH --time=0-20:00:00
#SBATCH --job-name=gwas-sex
#SBATCH --mail-type=ALL
#SBATCH --mail-user=laura.spencer@noaa.gov
#SBATCH --output=/home/lspencer/pcod-sex/gwas-sex2.out

module load bio/angsd/0.940

base=/home/lspencer/pcod-sex
beagle=${base}/pcod-sex-cleaned.beagle.gz
impute=${base}/imputed.pcod-sex-cleaned.beagle.gz.gprobs.gz

# FIRST PERFORM IMPUTATION (to fill in NA values) with beagles 
#java -Xmx15000m -jar /home/lspencer/programs/beagle.jar \
#like=${beagle} \
#out=${base}/imputed

# PERFORM GWAS WITH ORIGINAL BEAGLE

angsd \
-doMaf 4 \
-beagle ${beagle} \
-yBin ${base}/fish-sex.txt \
-doAsso 4 \
-cov ${base}/fish-region.txt \
-out ${base}/gwas-sex.out \
-fai /home/lspencer/references/pcod-ncbi/GCF_031168955.1_ASM3116895v1_genomic.fna.fai 

# PERFORM GWAS WITH IMPUTED BEAGLE

angsd \
-doMaf 4 \
-beagle ${impute} \
-yBin ${base}/fish-sex.txt \
-doAsso 4 \
-cov ${base}/fish-region.txt \
-out ${base}/gwas-sex-imputed.out \
-fai /home/lspencer/references/pcod-ncbi/GCF_031168955.1_ASM3116895v1_genomic.fna.fai 
