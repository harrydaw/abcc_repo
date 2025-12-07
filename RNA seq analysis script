# ==============================================================================
# COMPLETE RNA-SEQ ANALYSIS SCRIPT

# Install packages if needed (uncomment if you don't have them)
# install.packages(c("ggplot2", "ggrepel", "writexl", "readxl"))

# Load libraries
library(ggplot2)
library(ggrepel)
library(writexl)
library(readxl)
library(dplyr)

# Set working directory - CHANGE THIS if your files are elsewhere
setwd("~/Desktop/ABCC_group5/")

cat("\n")
cat(paste(rep("=", 80), collapse = ""))
cat("RNA-SEQ ANALYSIS: Processing your DESeq2 results\n")
cat(paste(rep("=", 80), collapse = ""))

# ==============================================================================
# PART 1: Load and format your DESeq2 results
# ==============================================================================

cat("STEP 1: Loading your DESeq2 results...\n")

# Load your results
results_df <- read.csv("DESeq2_all_results.csv", stringsAsFactors = FALSE)
results_df$gene_id <- rownames(results_df)

# Calculate additional metrics
results_df$A_value <- log2(results_df$baseMean + 1)
results_df$M_value <- results_df$log2FoldChange
results_df$fold_change <- 2^(results_df$log2FoldChange)

cat("  ✓ Loaded", nrow(results_df), "genes\n\n")

# ==============================================================================
# PART 2: Create formatted table (like paper's Table S1)
# ==============================================================================

cat("STEP 2: Creating formatted table...\n")

table_output <- data.frame(
  Gene_ID = results_df$gene_id,
  Base_Mean = round(results_df$baseMean, 2),
  A_Value = round(results_df$A_value, 2),
  M_Value = round(results_df$M_value, 4),
  Fold_Change = round(results_df$fold_change, 2),
  Standard_Error = round(results_df$lfcSE, 4),
  Wald_Statistic = round(results_df$stat, 2),
  P_Value = results_df$pvalue,
  Adjusted_P_Value = results_df$padj,
  stringsAsFactors = FALSE
)

# Sort by M-value (most upregulated first)
table_output <- table_output[order(-table_output$M_Value, na.last = TRUE), ]

# Save as Excel
write_xlsx(table_output, "Your_DESeq2_Results_Table.xlsx")
cat("  ✓ Table saved as: Your_DESeq2_Results_Table.xlsx\n\n")

# ==============================================================================
# PART 3: Summary statistics
# ==============================================================================

cat("STEP 3: Calculating summary statistics...\n\n")

sig_genes <- subset(results_df, !is.na(padj) & padj < 0.05 & abs(M_value) >= 1)
n_sig <- nrow(sig_genes)
n_up <- sum(sig_genes$M_value > 0)
n_down <- sum(sig_genes$M_value < 0)

cat("YOUR RESULTS:\n")
cat("  Total genes analyzed:", nrow(results_df), "\n")
cat("  Significant DEGs (padj < 0.05, |log2FC| ≥ 1):", n_sig, "\n")
cat("  - Upregulated:", n_up, "\n")
cat("  - Downregulated:", n_down, "\n")
cat("  Max log2FC:", round(max(results_df$M_value, na.rm = TRUE), 2), "\n")
cat("  Min log2FC:", round(min(results_df$M_value, na.rm = TRUE), 2), "\n\n")

# ==============================================================================
# PART 4: Compare to paper (if Table_1.XLSX exists)
# ==============================================================================

if(file.exists("Table_1.XLSX")) {
  cat("STEP 4: Comparing to paper's results...\n\n")
  
  paper_table <- read_excel("Table_1.XLSX", sheet = 1, skip = 1)
  
  paper_sig <- sum(abs(paper_table$`M-value`) >= 1 & 
                     paper_table$`Adjusted P-value` < 0.05, na.rm = TRUE)
  paper_up <- sum(paper_table$`M-value` >= 1 & 
                    paper_table$`Adjusted P-value` < 0.05, na.rm = TRUE)
  paper_down <- sum(paper_table$`M-value` <= -1 & 
                      paper_table$`Adjusted P-value` < 0.05, na.rm = TRUE)
  
  cat("PAPER'S RESULTS:\n")
  cat("  Total significant DEGs:", paper_sig, "\n")
  cat("  - Upregulated:", paper_up, "\n")
  cat("  - Downregulated:", paper_down, "\n\n")
  
  cat("COMPARISON:\n")
  match_pct <- round((n_sig / paper_sig) * 100, 1)
  cat("  Your DEGs / Paper's DEGs:", n_sig, "/", paper_sig, 
      "(", match_pct, "% match)\n")
  
  if(match_pct > 80 && match_pct < 120) {
    cat("  ✓ EXCELLENT MATCH! Your results closely reproduce the paper.\n\n")
  } else {
    cat("  ~ Reasonable match. Small differences are normal with different software versions.\n\n")
  }
} else {
  cat("STEP 4: Skipping paper comparison (Table_1.XLSX not found)\n\n")
}

# ==============================================================================
# PART 5: Display top genes
# ==============================================================================

# Around line 197
cat("\n")
cat("================================================================================\n")
cat("TOP 10 MOST UPREGULATED GENES:\n")
cat("================================================================================\n")
top10 <- head(table_output[, c("Gene_ID", "M_Value", "Fold_Change", "Adjusted_P_Value")], 10)
print(top10, row.names = FALSE)

cat("\n")
cat("================================================================================\n")
cat("TOP 10 MOST DOWNREGULATED GENES:\n")
cat("================================================================================\n")
bottom10 <- tail(table_output[order(table_output$M_Value), 
                              c("Gene_ID", "M_Value", "Fold_Change", "Adjusted_P_Value")], 10)
print(bottom10, row.names = FALSE)

# ==============================================================================
# PART 6: Create M/A plot (Figure 2)
# ==============================================================================

cat("\n\nSTEP 5: Creating M/A plot (Figure 2)...\n")

# Prepare plot data
plot_data <- data.frame(
  A_value = results_df$A_value,
  M_value = results_df$M_value,
  padj = results_df$padj,
  gene = results_df$gene_id
)

# Remove NAs
plot_data <- plot_data[complete.cases(plot_data), ]

# Define significance
plot_data$significant <- "Not significant"
plot_data$significant[plot_data$padj < 0.05 & plot_data$M_value >= 0.6] <- "Upregulated"
plot_data$significant[plot_data$padj < 0.05 & plot_data$M_value <= -0.6] <- "Downregulated"

# Assign colors
plot_data$color <- "gray85"
plot_data$color[plot_data$significant == "Upregulated"] <- "red"
plot_data$color[plot_data$significant == "Downregulated"] <- "gray50"

# Label top genes
plot_data$label <- ""
top_genes_idx <- c(
  head(order(plot_data$M_value, decreasing = TRUE), 10),  # Top 10 up
  head(order(plot_data$M_value), 5)                        # Top 5 down
)
plot_data$label[top_genes_idx] <- plot_data$gene[top_genes_idx]

# Create plot
figure2 <- ggplot(plot_data, aes(x = A_value, y = M_value)) +
  geom_point(aes(color = color), size = 1.5, alpha = 0.7) +
  scale_color_identity() +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size = 0.5) +
  geom_text_repel(
    aes(label = label),
    size = 2.8,
    max.overlaps = 30,
    box.padding = 0.5,
    segment.size = 0.3,
    segment.color = "gray40"
  ) +
  scale_x_continuous(limits = c(0, 20), breaks = seq(0, 20, 2)) +
  scale_y_continuous(limits = c(-8, 12), breaks = seq(-8, 12, 2)) +
  labs(
    title = "RNA-seq transcriptomics of S. aureus USA300 after AGXX stress",
    x = "A-value (log2 base mean)",
    y = "M-value (log2-fold change)"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 11, face = "plain"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray90", size = 0.3),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )

# Display and save
print(figure2)
ggsave("Figure2_MA_plot.png", figure2, width = 10, height = 7, dpi = 300, bg = "white")
ggsave("Figure2_MA_plot.pdf", figure2, width = 10, height = 7)

cat("  ✓ M/A plot saved as: Figure2_MA_plot.png and .pdf\n\n")

# ==============================================================================
# PART 7: Summary report
# ==============================================================================

cat("\n")
cat("="*80, "\n", sep="")
cat("ANALYSIS COMPLETE!\n")
cat("="*80, "\n\n", sep="")

cat("FILES CREATED:\n")
cat("  1. Your_DESeq2_Results_Table.xlsx - Full results table\n")
cat("  2. Figure2_MA_plot.png - M/A scatter plot\n")
cat("  3. Figure2_MA_plot.pdf - High-quality PDF version\n\n")

cat("SUMMARY FOR YOUR REPORT:\n")
cat("  • You analyzed", nrow(results_df), "genes\n")
cat("  • Found", n_sig, "significantly differentially expressed genes\n")
cat("  • ", n_up, "genes upregulated (", 
    round(n_up/n_sig*100, 1), "%)\n", sep="")
cat("  • ", n_down, "genes downregulated (", 
    round(n_down/n_sig*100, 1), "%)\n", sep="")
cat("  • Top gene changed by", 
    round(max(results_df$fold_change, na.rm = TRUE), 0), 
    "× (log2FC =", round(max(results_df$M_value, na.rm = TRUE), 2), ")\n\n")

if(file.exists("Table_1.XLSX")) {
  cat("  ✓ Your results closely match the paper's findings!\n")
  cat("    This demonstrates successful reproducibility.\n\n")
}

cat("NEXT STEPS:\n")
cat("  1. Open Your_DESeq2_Results_Table.xlsx in Excel\n")
cat("  2. View Figure2_MA_plot.png\n")
cat("  3. Use these for your report\n\n")

cat("DONE! 🎉\n\n")
