#!/bin/bash

#SBATCH --job-name=subset-beagle
#SBATCH --output=/home/lspencer/pcod-sex/subset-beagle-sex.txt
#SBATCH --mail-user=laura.spencer@noaa.gov
#SBATCH --mail-type=ALL
#SBATCH -t 2-0:0:0

# Input files
input="/home/lspencer/pcod-lcwgs-2023/analysis-20240606/wgsassign2"
input_beagle="${input}/join-beagles-temp/rehead_beagle1.gz"
id_file="/home/lspencer/pcod-sex/fish-ids.txt"
output_beagle="/home/lspencer/pcod-sex/pcod-sex.beagle.gz"
output_beagle_rehead="/home/lspencer/pcod-sex/pcod-sex-cleaned.beagle.gz"

# Extract IDs from the id_file into a regex pattern (exact match)
ids=$(awk '{print "^" $1 "$"}' $id_file | paste -sd '|' -)

# Process the input file
zcat $input_beagle | awk -v ids="$ids" '
BEGIN { FS=OFS="\t"; }
NR==1 {
    # Print the first three columns (marker, allele1, allele2)
    header_line = $1 OFS $2 OFS $3;
    for (i=4; i<=NF; i++) {
        # Remove suffixes and check if the column matches any ID
        col_name = gensub(/_AA$|_AB$|_BB$/, "", "g", $i)
        if (col_name ~ ids) {
            header_line = header_line OFS $i
            cols_to_print[i] = 1
        }
    }
    print header_line
}
NR>1 {
    line = $1 OFS $2 OFS $3;
    for (i=4; i<=NF; i++) {
        if (i in cols_to_print) {
            line = line OFS $i
        }
    }
    print line
}
' | gzip > $output_beagle

# For beagle imputation to work I can't have _AA _AB _BB subscripts in header line for each sample 
zcat $output_beagle | sed '1s/_AA//g; 1s/_AB//g; 1s/_BB//g' | gzip > ${output_beagle_rehead}
