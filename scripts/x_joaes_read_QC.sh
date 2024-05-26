#!/bin/bash
echo "script start: download and initial sequencing read quality control"
date
# download samples
echo "Downloading samples"
cat /proj/applied_bioinformatics/users/x_joaes/MedBioinfo/analyses/x_joaes_run_accessions.txt | srun --cpus-per-task=1 --time=00:30:00 singularity exec $MYIMAGE fastq-dump xargs --split-files --outdir /proj/applied_bioinformatics/users/x_joaes/MedBioinfo/data/sra_fastq/ --disable-multithreading --readids --gzip 
echo "Done downloading samples"

# run seqkit stats
echo "Running seqkit"
srun --cpus-per-task=2 singularity exec $MYIMAGE seqkit stats $MEDBIOINFO/data/sra_fastq/*fastq.gz --threads 2

# run fastqc
echo "Running fastqc"
srun --cpus-per-task=2 --time=00:30:00 singularity exec $MYIMAGE xargs -I{} -a $MEDBIOINFO/analyses/x_joaes_run_accessions.txt fastqc data/sra_fastq/{}_1.fastq.gz data/sra_fastq/{}_2.fastq.gz -o analyses/fastqc --threads 2 --noextract

date
echo "script end."
