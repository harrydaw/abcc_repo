# Read the file skipping the messy first row
# paper_table2 <- read.csv("outputs/original_tables/table_2.csv", skip = 1)

# Save it back with proper headers
# write.csv(paper_table2, "outputs/original_tables/table_2.csv", row.names = FALSE)

# Remove the X column
# paper_table2 <- paper_table2[, colnames(paper_table2) != "X"]

# Save the cleaned version
# write.csv(paper_table2, "outputs/original_tables/table_2.csv", row.names = FALSE)

# Load DESeq2 results
my_deseq <- read.csv("deseq2_results/DESeq2_significant_genes.csv")

# Load the paper's Table 2
paper_table2 <- read.csv("outputs/original_tables/table_2.csv")

# Look at the structure
head(my_deseq)
head(paper_table2)

gff <- read.delim("outputs/reference_mapping/s_aureus_usa300.gff",
                  header=FALSE,
                  comment.char="#")

head(gff)


# Filter for gene rows only
genes <- gff[gff$V3 == "gene", ]

# Extract locus_tag and gene name from V9 column
library(stringr)

# Extract locus_tag (SAUSA300_RS IDs)
genes$locus_tag <- str_extract(genes$V9, "locus_tag=[^;]+")
genes$locus_tag <- gsub("locus_tag=", "", genes$locus_tag)

# Extract gene name (if present)
genes$gene_name <- str_extract(genes$V9, "Name=[^;]+")
genes$gene_name <- gsub("Name=", "", genes$gene_name)

# Also extract old_locus_tag (might have USA300HOU_ format)
genes$old_locus_tag <- str_extract(genes$V9, "old_locus_tag=[^;]+")
genes$old_locus_tag <- gsub("old_locus_tag=", "", genes$old_locus_tag)

# Check what we got
head(genes[, c("locus_tag", "gene_name", "old_locus_tag")])

gene_annotation <- genes[, c("locus_tag", "gene_name")]
colnames(gene_annotation) <- c("gene_id", "gene_symbol")

paper_table1 <- read.csv("outputs/original_tables/table_1.csv", skip = 1)

table(paper_table1$Gene.symbol == paper_table1$USA300.numbers)

# Table 2 (downregulated)  
table(paper_table2$Gene.symbol == paper_table2$USA300.numbers)

# How many unique gene symbols are there?
length(unique(paper_table1$Gene.symbol))
length(unique(paper_table2$Gene.symbol))


# Remove genes where Gene.symbol is just the USA300HOU ID
paper_table2_clean <- paper_table2[paper_table2$Gene.symbol != paper_table2$USA300.numbers, ]

# Check how many we have left
nrow(paper_table2_clean)
head(paper_table2_clean)

merged_data <- merge(gene_annotation, 
                     paper_table2_clean[, c("Gene.symbol", "Regulon", "Operon")],
                     by.x = "gene_symbol",
                     by.y = "Gene.symbol",
                     all.x = TRUE)
head(merged_data)
sum(!is.na(merged_data$Regulon))

table(merged_data$Regulon)

final_data <- merge(my_deseq, 
                    merged_data,
                    by.x = "X",  # or whatever your gene_id column is called
                    by.y = "gene_id",
                    all.x = TRUE)

# Check it
head(final_data)

# How many of your significant DESeq2 genes have regulon assignments?
sum(!is.na(final_data$Regulon))

write.csv(final_data, "outputs/deseq_with_regulons_for_treemap.csv", row.names = FALSE)

sum(!is.na(paper_table2$Regulon))

# Create a clean version with only genes that have regulon assignments
treemap_data <- final_data[!is.na(final_data$Regulon), ]

# Check how many genes we have
nrow(treemap_data)

# Save the clean version
write.csv(treemap_data, "outputs/treemap_data_clean.csv", row.names = FALSE)

### Including table 1 data as well
paper_table1_clean <- paper_table1[paper_table1$Gene.symbol != paper_table1$USA300.numbers, ]

# Merge with our data
merged_both <- merge(gene_annotation, 
                     rbind(
                       paper_table1_clean[, c("Gene.symbol", "Regulon", "Operon")],
                       paper_table2_clean[, c("Gene.symbol", "Regulon", "Operon")]
                     ),
                     by.x = "gene_symbol",
                     by.y = "Gene.symbol",
                     all.x = TRUE)

# Now merge with your DESeq2 significant genes
final_data_both <- merge(my_deseq, 
                         merged_both,
                         by.x = "X",
                         by.y = "gene_id",
                         all.x = TRUE)

# Check the improvement
head(final_data_both)

# How many genes now have regulon assignments?
sum(!is.na(final_data_both$Regulon))
sum(!is.na(paper_table2$Regulon))

# Compare to before
cat("Before (Table 2 only):", sum(!is.na(final_data$Regulon)), "genes\n")
cat("After (Tables 1 & 2):", sum(!is.na(final_data_both$Regulon)), "genes\n")
cat("Improvement:", sum(!is.na(final_data_both$Regulon)) - sum(!is.na(final_data$Regulon)), "additional genes\n")

# Create clean version with only regulon-assigned genes
treemap_data_both <- final_data_both[!is.na(final_data_both$Regulon), ]

# Save it
write.csv(treemap_data_both, "outputs/treemap_data_clean_both_tables.csv", row.names = FALSE)

# Show regulon counts
table(treemap_data_both$Regulon)
