#!/bin/bash
#
#SBATCH --ntasks=1                   # nb of *tasks* to be run in // (usually 1), this task can be multithreaded (see cpus-per-task)
#SBATCH --nodes=1                    # nb of nodes to reserve for each task (usually 1)
#SBATCH --cpus-per-task=2            # nb of cpu (in fact cores) to reserve for each task /!\ job killed if commands below use more cores
#SBATCH --mem=96GB                  # amount of RAM to reserve for the tasks /!\ job killed if commands below use more RAM
#SBATCH --time=0-02:00               # maximal wall clock duration (D-HH:MM) /!\ job killed if commands below take more time than reservation
#SBATCH -o ./log/slurm.%A.%a.out   # standard output (STDOUT) redirected to these files (with Job ID and array ID in file names)
#SBATCH -e ./log/slurm.%A.%a.err   # standard error  (STDERR) redirected to these files (with Job ID and array ID in file names)
# /!\ Note that the ./outputs/ dir above needs to exist in the dir where script is submitted **prior** to submitting this script
#SBATCH --array=1-10                # 1-N: clone this script in an array of N tasks: $SLURM_ARRAY_TASK_ID will take the value of 1,2,...,N
#SBATCH --job-name=MedBioinfo        # name of the task as displayed in squeue & sacc, also encouraged as srun optional parameter
#SBATCH --mail-type END              # when to send an email notiification (END = when the whole sbatch array is finished)
#SBATCH --mail-user joan.escriva_font@med.lu.se

#################################################################
# Preparing work (cd to working dir, get hold of input data, convert/un-compress input data when needed etc.)
workdir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/blastn_output"
datadir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/data/blastn_read_subsets"
accnum_file="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/x_joaes_run_accessions.txt"
alias blastn='/proj/applied_bioinformatics/tools/ncbi-blast-2.15.0+-src/blastn'
dbdir="/proj/applied_bioinformatics/users/x_joaes/MedBioinfo/data/blast_db"
MYIMAGE="/proj/applied_bioinformatics/users/x_joaes/apptainer/fastq_image_x_joaes.sif"
echo START: `date`


mkdir -p ${workdir}      # -p because it creates all required dir levels **and** doesn't throw an error if the dir exists :)
cd ${workdir}

# this extracts the item number $SLURM_ARRAY_TASK_ID from the file of accnums
accnum=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${accnum_file})

input_file="${datadir}/${accnum}.fq.gz"

# alternatively, just extract the input file as the item number $SLURM_ARRAY_TASK_ID in the data dir listing
# this alternative is less handy since we don't get hold of the isolated "accnum", which is very handy to name the srun step below :)
# input_file=$(ls "${datadir}/*.fastq.gz" | sed -n ${SLURM_ARRAY_TASK_ID}p)

# convert to fasta
srun --cpus-per-task=2 singularity exec ${MYIMAGE} seqkit fq2fa ${input_file} -o ${workdir}/${accnum}.fa.gz --threads 2 

# new input_file
input_file="${workdir}/${accnum}.fa"
# if the command below can't cope with compressed input
srun gunzip "${input_file}.gz"

# because there are mutliple jobs running in // each output file needs to be made unique by post-fixing with $SLURM_ARRAY_TASK_ID and/or $accnum
output_file="${workdir}/ABCjob.${SLURM_ARRAY_TASK_ID}.${accnum}.out"

#################################################################
# Start work
srun --job-name=${accnum} /proj/applied_bioinformatics/tools/ncbi-blast-2.15.0+-src/blastn --threads ${SLURM_CPUS_PER_TASK} \
-query ${input_file} \
-db ${dbdir}/refseq_viral_genomic \
-out ${output_file} \
-evalue 1 \
-perc_identity 75 \
-max_target_seqs 5 \
-outfmt 6



#################################################################
# Clean up (eg delete temp files, compress output, recompress input etc)
srun gzip ${input_file}
srun gzip ${output_file}
echo END: `date`


