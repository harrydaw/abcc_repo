#!/bin/bash
#SBATCH --job-name=align_C1
#SBATCH --partition=msc_appbio
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --output=align_C1_%j.log

# Load modules
module load bowtie2/2.5.1-gcc-13.2.0-python-3.11.6
module load samtools/1.17-gcc-13.2.0-python-3.11.6

# Change to working directory
cd /scratch/grp/msc_appbio/Group5_ABCC

# Run alignment
bowtie2 -x reference/s_aureus_usa300_index \
  -1 fasta_files/C1/ERR2713023_1.fastq.gz \
  -2 fasta_files/C1/ERR2713023_2.fastq.gz \
  -p 4 \
  2> alignments/C1_alignment_stats.txt \
  | samtools view -bS - > alignments/C1.bam

echo "C1 alignment complete!"


