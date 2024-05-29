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
#SBATCH --job-name=kraken2        # name of the task as displayed in squeue & sacc, also encouraged as srun optional parameter
#SBATCH --mail-type END              # when to send an email notiification (END = when the whole sbatch array is finished)
#SBATCH --mail-user joan.escriva_font@med.lu.se

# biggest fastq accnum
accnum="ERR6913236"
datadir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/data/sra_fastq"
workdir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/kraken2"
bracken_workdir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/bracken"
kraken_sif="/proj/applied_bioinformatics/common_data/kraken2.sif"
db_name="/proj/applied_bioinformatics/common_data/kraken_database/"

# run kraken2
srun --job-name="kraken2" singularity exec -B /proj:/proj ${kraken_sif} kraken2 --paired --output ${workdir}/${accnum}.out --report ${workdir}/${accnum}.report --threads 1 -db ${db_name} ${datadir}/${accnum}_1.fastq.gz ${datadir}/${accnum}_2.fastq.gz

# run bracken
srun  --job-name="bracken" singularity exec -B /proj:/proj ${kraken_sif} bracken  -db ${db_name} -i ${workdir}/${accnum}.report -o ${bracken_workdir}/${accnum}.out -w ${bracken_workdir}/${accnum}.report

echo "Done!"
