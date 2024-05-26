#!/bin/bash
echo "script start: download and initial sequencing read quality control"
date
# download samples
echo "Downloading samples"
cat /proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/x_joaes_run_accessions.txt | srun --cpus-per-task=1 --time=00:30:00 singularity exec $MYIMAGE fastq-dump xargs --split-files --outdir /proj/applied_bioinformatics/users/x_joaes/MedBioinfo/data/sra_fastq/ --disable-multithreading --readids --gzip 
echo "Done downloading samples"

date
echo "script end."
