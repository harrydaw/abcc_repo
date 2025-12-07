#!/bin/bash
#SBATCH --job-name=align_all
#SBATCH --partition=msc_appbio
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --output=align_all_%j.log

# Load modules
module load bowtie2/2.5.1-gcc-13.2.0-python-3.11.6
module load samtools/1.17-gcc-13.2.0-python-3.11.6

cd /scratch/grp/msc_appbio/Group5_ABCC

# Array of sample names and their ERR numbers
declare -A samples
samples=(
  ["C1"]="ERR2713023"
  ["C2"]="ERR2713024"
  ["C3"]="ERR2713025"
  ["E1"]="ERR2713020"
  ["E2"]="ERR2713021"
  ["E3"]="ERR2713022"
)

# Process each sample
for sample in C1 C2 C3 E1 E2 E3; do
  err=${samples[$sample]}
  echo "Processing $sample ($err)..."
  
  # Align and convert to BAM in one step
  bowtie2 -x reference/s_aureus_usa300_index \
    -1 fasta_files/$sample/${err}_1.fastq.gz \
    -2 fasta_files/$sample/${err}_2.fastq.gz \
    -p 4 \
    2> alignments/${sample}_alignment_stats.txt \
    | samtools view -bS - \
    | samtools sort -o alignments/${sample}.sorted.bam -
  
  # Index the sorted BAM
  samtools index alignments/${sample}.sorted.bam
  
  echo "$sample complete!"
done

echo "All alignments complete!"

