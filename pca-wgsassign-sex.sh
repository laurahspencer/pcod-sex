#!/bin/bash

#SBATCH --job-name=pca-wgsassign
#SBATCH --output=/home/lspencer/pcod-sex/pca-wgsassign-out.txt
#SBATCH --mail-user=laura.spencer@noaa.gov
#SBATCH --mail-type=ALL
#SBATCH -t 2-0:0:0

# load pcangsd programs 
module unload bio/pcangsd/0.99
module load bio/pcangsd/0.99
source /opt/bioinformatics/venv/pcangsd-0.99/bin/activate

# load wgsassign programs
source ~/.bashrc
mamba activate WGSassign

base=/home/lspencer/pcod-sex
beagle=${base}/pcod-sex.beagle.gz
sites=${base}/sex-markers-logp4.txt
ids=${base}/fish-ids-sex.txt
sex_marks_beagle=${base}/pcod-sex-markers.beagle
outname=${base}/sex-assign
#sex_marks_afs=${assign}/snp-testing/top-1250.pop_af.npy

# Filter beagle for sex markers (identified from GWAS)
# combine header row with filtered sites
zcat ${beagle} | head -n 1 > ${sex_marks_beagle}
awk 'NR==FNR{c[$1]++;next};c[$1]' ${sites} <(zcat ${beagle}) >> ${sex_marks_beagle}
gzip ${sex_marks_beagle}

# IF BEAGLE FILE HAS NAMES OF SAMPLES IN HEADER ROW
# Generate file listing samples in order they appear in beagle file using sample IDs in header row
zcat ${sex_marks_beagle}.gz | cut --complement -f1-3 | head -n 1 | tr '\t' '\n' | \
sed -e 's/_AA//g' -e 's/_AB//g' -e 's/_BB//g' | uniq > ${base}/sex-sample-order.txt

# Run PCAnagsd to generate covariance matrix of sex-assigned fish using only GWAS-identified sex markers
pcangsd.py -threads 10 \
-beagle /home/lspencer/pcod-sex/pcod-sex-markers.beagle.gz \
-o /home/lspencer/pcod-sex/pcod-sex -pcadapt

# Get allele frequencies by sex 
WGSassign --beagle ${sex_marks_beagle}.gz --pop_af_IDs ${ids} --get_reference_af --out ${base}/sex-marks --threads 10

## Run assignment to identify source population of experimental fish
#WGSassign --beagle ${sex_marks_beagle} --pop_af_file ${TBD} --get_pop_like --out ${outname} --threads 20

