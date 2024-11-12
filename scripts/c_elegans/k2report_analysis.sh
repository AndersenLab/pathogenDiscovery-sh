#!/bin/bash

#SBATCH -J KrakenBracken
#SBATCH -A eande106
#SBATCH -p parallel
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=loconn13@jh.edu
#SBATCH --mail-type=END
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/initial_krakenBracken_run/initialRun.oe  
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/initial_krakenBracken_run/initialRun.rr 

if [[ $1 == "c_elegans" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/C_elegans_Kraken2classification_10perc.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/C_tropicalis_Kraken2classification_10perc.txt"
elif [[ $1 == "c_briggsae" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/C_briggsae_Kraken2classification_10perc.txt"
elif [[ $1 == "control" ]]; then
    infected="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/infected/core_nt"
    not_infected="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/notInfected/core_nt"
    Kraken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/analysis/microsporCtrKraken2classification_11perc.txt"
else
    echo "Invalid argument"
    exit 1
fi

# Initialize a blank file
echo -e "*\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > "$Kraken_class_file"

for strain in "$k2reports"/*.k2report; do 
    strain_name=$(basename "$strain" .k2report)
    hits_found=0
    awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
    awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
    awk -v strain_name="$strain_name" '
        BEGIN {found_genus=0}
        $1 >= 10.0 && $6 == "G" {found_genus=1}
        $1 >= 10.0 && $6 == "S" && found_genus {
            print strain_name, $0
            found_genus=0
        }s
    ' $strain >> $Kraken_class_file
    if grep -q "$strain_name" "$Kraken_class_file"; then
            hits_found=1
    fi
    if [[ $hits_found -eq 0 ]]; then
        echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
    fi
done

if [[ $1 == "control" ]]; then 
    for strain in "$infected"/*.k2report; do 
        strain_name=$(basename $strain .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 11.0 && $6 == "G" {found_genus=1}
            $1 >= 11.0 && $6 == "S" && found_genus {
                print strain_name, $0
                found_genus=0
            }
        ' $strain >> $Kraken_class_file
        if grep -q "$strain_name" "$Kraken_class_file"; then
            hits_found=1
        fi
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
        fi
    done
    for strain in "$not_infected"/*.k2report; do 
        strain_name=$(basename $strain .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 11.0 && $6 == "G" {found_genus=1}
            $1 >= 11.0 && $6 == "S" && found_genus {
                print strain_name, $0
                found_genus=0
            }
        ' $strain >> $Kraken_class_file
        if grep -q "$strain_name" "$Kraken_class_file"; then
            hits_found=1
        fi
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
        fi
    done
fi

sed -i '1d' "$Kraken_class_file"

