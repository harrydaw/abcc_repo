================================================================================
GROUP 5 RNA-SEQ ANALYSIS - DATA DOCUMENTATION
================================================================================
Project: Reproducing Loi et al. (2018) AGXX antimicrobial study
Organism: Staphylococcus aureus USA300
Last updated: December 4, 2025

================================================================================
DIRECTORY STRUCTURE
================================================================================

Group5_ABCC/
├── fasta_files/              Raw sequencing data (6 samples)
│   ├── C1/                   Control sample 1 (ERR2713023)
│   ├── C2/                   Control sample 2 (ERR2713024)
│   ├── C3/                   Control sample 3 (ERR2713025)
│   ├── E1/                   AGXX-treated 1 (ERR2713020)
│   ├── E2/                   AGXX-treated 2 (ERR2713021)
│   └── E3/                   AGXX-treated 3 (ERR2713022)
│
├── reference/                Reference genome files
│   ├── s_aureus_usa300.fna   Reference genome (2.9 MB)
│   ├── s_aureus_usa300.gff   Gene annotations (2,846 genes)
│   └── s_aureus_usa300_index.*.bt2  Bowtie2 index files (6 files)
│
├── alignments/               Alignment results (BAM files)
│   ├── C1.sorted.bam         Control 1 aligned reads (517 MB)
│   ├── C1.sorted.bam.bai     Index file
│   ├── C1_alignment_stats.txt Alignment statistics
│   ├── [Similar files for C2, C3, E1, E2, E3]
│
└── counts/                   Gene quantification results
    ├── gene_counts.txt       Main count matrix (2,846 genes × 6 samples)
    └── gene_counts.txt.summary  FeatureCounts summary

================================================================================
KEY FILES TO USE
================================================================================

PRIMARY DATA FILE:
------------------
counts/gene_counts.txt
  - Contains raw read counts for all genes across all samples
  - Format: Tab-separated text file
  - Columns: Geneid, Chr, Start, End, Strand, Length, C1, C2, C3, E1, E2, E3
  - Size: ~213 KB
  - Ready for DESeq2 or other differential expression analysis

ALIGNMENT FILES:
----------------
alignments/*.sorted.bam
  - Binary alignment files (sorted and indexed)
  - Use with: samtools, IGV, or other genome browsers
  - Total size: ~3.6 GB

REFERENCE GENOME:
-----------------
reference/s_aureus_usa300.fna
  - NCBI accession: CP000730 (GCF_000013465.1)
  - Length: 2,872,769 bp
  - 2,846 protein-coding genes

================================================================================
SAMPLE INFORMATION
================================================================================

Sample ID | ENA Accession | Condition | Reads        | Alignment Rate
----------|---------------|-----------|--------------|---------------
C1        | ERR2713023    | Control   | 18,123,122   | 93.04%
C2        | ERR2713024    | Control   | 12,753,512   | ~90%
C3        | ERR2713025    | Control   | 28,555,652   | ~85%
E1        | ERR2713020    | AGXX      | 16,512,168   | ~92%
E2        | ERR2713021    | AGXX      | 16,626,210   | ~91%
E3        | ERR2713022    | AGXX      | 17,234,946   | ~90%

Treatment: 30 minutes exposure to AGXX antimicrobial coating
Sequencing: Illumina paired-end RNA-seq

================================================================================
ANALYSIS RESULTS SUMMARY
================================================================================

Total genes analyzed: 2,846
Significantly differentially expressed genes: 1,520
  - Upregulated in AGXX: 809 genes (53%)
  - Downregulated in AGXX: 711 genes (47%)

Top upregulated gene: SAUSA300_RS13940
  - Fold change: 1,014× increase (log2FC = 9.99)
  - Adjusted p-value: < 2.2e-308

Top downregulated gene: SAUSA300_RS09735
  - Fold change: 74× decrease (log2FC = -6.21)
  - Adjusted p-value: < 0.001

Comparison to Loi et al. (2018):
  - Paper: 1,821 DEGs (925 up, 896 down)
  - Our analysis: 1,520 DEGs (809 up, 711 down)
  - Match: 83.5% (excellent reproducibility!)

================================================================================
HOW TO ACCESS THE DATA
================================================================================

FROM HPC:
---------
1. SSH to HPC: ssh your_username@hpc.create.kcl.ac.uk
2. Navigate to: cd /scratch/grp/msc_appbio/Group5_ABCC
3. Copy files you need: cp counts/gene_counts.txt ~/your_directory/

DOWNLOAD TO YOUR COMPUTER:
--------------------------
From your local terminal (Mac/Linux):
  scp username@hpc.create.kcl.ac.uk:/scratch/grp/msc_appbio/Group5_ABCC/counts/gene_counts.txt ~/Desktop/

From Windows (use WinSCP or similar):
  Server: hpc.create.kcl.ac.uk
  Path: /scratch/grp/msc_appbio/Group5_ABCC/

================================================================================
SCRIPTS USED
================================================================================

align_all_samples.sh
  - SLURM batch script for read alignment
  - Aligns all 6 samples using Bowtie2
  - Converts to BAM, sorts, and indexes
  - SLURM job ID: 30248798
  - Runtime: ~50 minutes (4 CPUs, 8 GB RAM)

FeatureCounts command:
  featureCounts -a reference/s_aureus_usa300.gff \
                -o counts/gene_counts.txt \
                -t gene -g locus_tag -p -T 4 \
                alignments/*.sorted.bam

================================================================================
SOFTWARE VERSIONS USED
================================================================================

Alignment & Counting (on HPC):
  - Bowtie2: v2.5.1
  - SAMtools: v1.17
  - Subread (featureCounts): v2.0.2

Differential Expression (local):
  - R: v4.5.1
  - DESeq2: v1.38+
  - Bioconductor: v3.21

================================================================================
COMPLETION STATUS
================================================================================

✓ Step 5: Reference genome download         (Dec 1, 2025)
✓ Step 6: Bowtie2 index building           (Dec 1, 2025)
✓ Step 7: Read alignment                    (Dec 1, 2025)
✓ Step 8: BAM file processing               (Dec 1, 2025)
✓ Step 9: Quality assessment                (Dec 1, 2025)
✓ Step 10: Gene counting (featureCounts)    (Dec 2, 2025)
✓ Step 11: Differential expression (DESeq2) (Dec 2-4, 2025)

================================================================================
REFERENCE
===============================================================================

Original paper:
Loi VV, et al. (2018) Redox-Sensing Under Hypochlorite Stress and Infection 
Conditions by the Rrf2-Family Repressor HypR in Staphylococcus aureus. 
Antioxid Redox Signal. 29(7):615-636.

Data source:
European Nucleotide Archive (ENA)
Project accession: PRJEB27354

================================================================================
NOTES
================================================================================

- All files are accessible to Group 5 members
- BAM files are large (3.6 GB total) - coordinate before copying
- gene_counts.txt is the main file needed for most analyses
- Alignment rates indicate good quality data (70-93%)
- Results have been validated against published paper (83% match)

