#!/bin/bash

# bash WS_filtering.sh c_elegans known_pathogens

# performed awk '($7 == "G" || $7 == "S") && $9 != "Caenorhabditis" {print $0}' C_tropicalis_Kraken2classification_10perc.txt > non_CaenGenera_10percKraken2class_Ct.txt
# to filter out Caenorhabditis from being classified and only keep genera

if [[ $1 == "c_elegans" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Ce.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Ct.txt"
elif [[ $1 == "c_briggsae" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Cb.txt"
else
    echo "Invalid argument"
    exit 1
fi

if [[ $2 == "known_pathogens" ]]; then
    key="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/test.txt"
elif [[ $2 == "VTM_novel" ]]; then
    key="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/XXXX.txt"

output_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/filtGenera_knownPatho_$1.txt"

> "$output_file"

while IFS= read -r genus; do
    awk -v genus="$genus" '$9 == genus {print $0}' $concat_file >> $output_file
done < $key


