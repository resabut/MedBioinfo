#!/bin/bash
#
#SBATCH --ntasks=1                   # nb of *tasks* to be run in // (usually 1), this task can be multithreaded (see cpus-per-task)
#SBATCH --nodes=1                    # nb of nodes to reserve for each task (usually 1)
#SBATCH --cpus-per-task=1            # nb of cpu (in fact cores) to reserve for each task /!\ job killed if commands below use more cores
#SBATCH --mem=96GB                  # amount of RAM to reserve for the tasks /!\ job killed if commands below use more RAM
#SBATCH --time=0-01:00               # maximal wall clock duration (D-HH:MM) /!\ job killed if commands below take more time than reservation
#SBATCH -o ./log/kraken2/slurm.%A.%a.out   # standard output (STDOUT) redirected to these files (with Job ID and array ID in file names)
#SBATCH -e ./log/kraken2/slurm.%A.%a.err   # standard error  (STDERR) redirected to these files (with Job ID and array ID in file names)
# /!\ Note that the ./outputs/ dir above needs to exist in the dir where script is submitted **prior** to submitting this script
#SBATCH --array=1-10
#SBATCH --job-name=krona        # name of the task as displayed in squeue & sacc, also encouraged as srun optional parameter
#SBATCH --mail-type END              # when to send an email notiification (END = when the whole sbatch array is finished)
#SBATCH --mail-user joan.escriva_font@med.lu.se

echo START: `date`
kraken2_dir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/kraken2"
workdir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/krona"
kraken_sif="/proj/applied_bioinformatics/common_data/kraken2.sif"
accnum_file="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/x_joaes_run_accessions.txt"

# get accnum
accnum=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${accnum_file})

# convert kraken report to krona report
python /proj/applied_bioinformatics/tools/KrakenTools/kreport2krona.py -r ${kraken2_workdir}/${accnum}.report -o ${workdir}/${accnum}.report

# remove unnecessary prefixes
cat ${workdir}/${accnum}.report | sed 's/\w__//g' > ${workdir}/${accnum}.clean.report 

# run krona
srun  --job-name="$accnum" singularity exec -B /proj:/proj ${kraken_sif} ktImportText -o ${workdir}/${accnum}.clean.report.html   ${workdir}/${accnum}.clean.report 


echo "Done!"
echo END: `date`
