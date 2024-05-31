#!/bin/bash
#SBATCH --ntasks=1                  
#SBATCH --nodes=1                    
#SBATCH --cpus-per-task=1     
#SBATCH -A naiss2024-22-540
#SBATCH --mem=1GB       
#SBATCH --time=0-00:15   
#SBATCH -o slurm.%A.%a.out  
#SBATCH -e slurm.%A.%a.err   
#SBATCH --job-name=combine_bracken_report  


bracken_out_dir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/bracken" ## path to directory with bracken output files
accnum_file="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/x_joaes_run_accessions.txt" ## path to file with the list of accessions 

# add header
echo -e "accession_number\tname\ttaxonomy_id\ttaxonomy_lvl\tkraken_assigned_reads\tadded_reads\tnew_est_reads\tfraction_total_reads" > ${bracken_out_dir}/combined_bracken.out
srun xargs -I{} -a $accnum_file awk -v id={} 'NR > 1 {print id "\t" $0}' ${bracken_out_dir}/{}.out >> ${bracken_out_dir}/combined_bracken.out