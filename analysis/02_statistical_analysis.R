# ============================================================================
# EvaShade Research Project - Statistical Analysis
# ============================================================================
# Purpose: Analyze cooling effects using inferential statistics
# Methods: Two-way ANOVA, Post-hoc tests, Effect size calculations
# Author: EvaShade Research Team
# Created: 2024-07-15
# ============================================================================

# Load required libraries
library(tidyverse)
library(lubridate)
library(broom)
library(car)         # For Levene's test
library(emmeans)     # For post-hoc comparisons
library(effectsize)  # For effect size calculations

# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------

DATA_PATH <- "../data/clean_temperature_data.csv"
OUTPUT_DIR <- "../results"
RANDOM_SEED <- 42

# Set seed for reproducibility
set.seed(RANDOM_SEED)

# Create output directory if it doesn't exist
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

# ----------------------------------------------------------------------------
# Helper Functions
# ----------------------------------------------------------------------------

#' Calculate Cohen's d for effect size
#' @param x Group 1 values
#' @param y Group 2 values
#' @return Effect size with confidence interval
calculate_cohens_d <- function(x, y) {
  effectsize::cohens_d(x, y, paired = FALSE)
}

#' Perform normality test (Shapiro-Wilk)
#' @param x Numeric vector
#' @return List with test statistic and p-value
test_normality <- function(x) {
  shapiro.test(x)
}

#' Test homogeneity of variances (Levene's test)
#' @param data Data frame
#' @param formula Formula for testing
#' @return Levene's test result
test_homogeneity <- function(data, formula) {
  car::leveneTest(formula, data = data)
}

# ----------------------------------------------------------------------------
# Load and Prepare Data
# ----------------------------------------------------------------------------

cat("=== EvaShade Statistical Analysis ===\n\n")
cat("Loading cleaned data from:", DATA_PATH, "\n")

data <- read_csv(DATA_PATH, show_col_types = FALSE)

cat("Dataset contains", nrow(data), "observations\n")

# Reshape data to long format for analysis
data_long <- data %>%
  pivot_longer(
    cols = c(control_temp, shade_temp, et_temp, combined_temp),
    names_to = "treatment",
    values_to = "temperature"
  ) %>%
  mutate(
    treatment = factor(treatment, levels = c("control_temp", "shade_temp", "et_temp", "combined_temp")),
    treatment_label = case_when(
      treatment == "control_temp" ~ "Control",
      treatment == "shade_temp" ~ "Shade Only",
      treatment == "et_temp" ~ "ET Only",
      treatment == "combined_temp" ~ "Combined"
    ),
    time_period = case_when(
      hour(timestamp) >= 6 & hour(timestamp) < 12 ~ "Morning",
      hour(timestamp) >= 12 & hour(timestamp) < 18 ~ "Afternoon",
      hour(timestamp) >= 18 | hour(timestamp) < 6 ~ "Evening/Night"
    ),
    time_period = factor(time_period, levels = c("Morning", "Afternoon", "Evening/Night"))
  )

# Filter for peak hours analysis (12:00-16:00)
peak_hours_data <- data_long %>%
  filter(hour(timestamp) >= 12 & hour(timestamp) <= 16)

cat("Analysis subset (peak hours):", nrow(peak_hours_data), "observations\n\n")

# ----------------------------------------------------------------------------
# Descriptive Statistics
# ----------------------------------------------------------------------------

cat("=== Descriptive Statistics ===\n\n")

# Overall statistics
descriptive_stats <- data_long %>%
  group_by(treatment_label) %>%
  summarise(
    n = n(),
    mean_temp = mean(temperature, na.rm = TRUE),
    sd_temp = sd(temperature, na.rm = TRUE),
    se_temp = sd_temp / sqrt(n),
    ci_95_lower = mean_temp - 1.96 * se_temp,
    ci_95_upper = mean_temp + 1.96 * se_temp,
    min_temp = min(temperature, na.rm = TRUE),
    max_temp = max(temperature, na.rm = TRUE),
    .groups = "drop"
  )

cat("Temperature Statistics by Treatment Group:\n")
print(descriptive_stats)
cat("\n")

# Peak hours statistics
peak_stats <- peak_hours_data %>%
  group_by(treatment_label) %>%
  summarise(
    n = n(),
    mean_temp = mean(temperature, na.rm = TRUE),
    sd_temp = sd(temperature, na.rm = TRUE),
    .groups = "drop"
  )

cat("Peak Hours (12:00-16:00) Statistics:\n")
print(peak_stats)
cat("\n")

# Calculate cooling effects relative to control
cooling_effects <- descriptive_stats %>%
  filter(treatment_label != "Control") %>%
  mutate(
    control_mean = descriptive_stats$mean_temp[descriptive_stats$treatment_label == "Control"],
    cooling_effect = control_mean - mean_temp,
    cooling_percent = (cooling_effect / control_mean) * 100
  )

cat("Cooling Effects (relative to Control):\n")
print(cooling_effects %>% select(treatment_label, cooling_effect, cooling_percent))
cat("\n")

# ----------------------------------------------------------------------------
# Assumption Testing
# ----------------------------------------------------------------------------

cat("=== Assumption Testing ===\n\n")

# Normality test by group
cat("Normality Test (Shapiro-Wilk):\n")
normality_results <- data_long %>%
  group_by(treatment_label) %>%
  summarise(
    n = n(),
    statistic = shapiro.test(temperature)$statistic,
    p_value = shapiro.test(temperature)$p.value,
    .groups = "drop"
  )
print(normality_results)
cat("\n")

# Homogeneity of variances (Levene's test)
cat("Homogeneity of Variances (Levene's Test):\n")
levene_result <- test_homogeneity(data_long, temperature ~ treatment_label)
print(levene_result)
cat("\n")

# ----------------------------------------------------------------------------
# Two-way ANOVA (Treatment × Time Period)
# ----------------------------------------------------------------------------

cat("=== Two-Way ANOVA ===\n")
cat("Factors: Treatment (4 levels) × Time Period (3 levels)\n\n")

# Fit the model
anova_model <- aov(temperature ~ treatment_label * time_period, data = data_long)
anova_summary <- summary(ananova_model)

cat("ANOVA Table:\n")
print(anova_summary)
cat("\n")

# Extract main effects and interaction
anova_results <- tidy(anova_model)
cat("Formatted ANOVA Results:\n")
print(anova_results)
cat("\n")

# Effect sizes (eta-squared)
ss_values <- anova_results$sumsq
total_ss <- sum(ss_values)
eta_squared <- ss_values / total_ss

effect_sizes <- data.frame(
  source = anova_results$term,
  eta_squared = eta_squared,
  percent_variance = eta_squared * 100
)

cat("Effect Sizes (Eta-Squared):\n")
print(effect_sizes)
cat("\n")

# ----------------------------------------------------------------------------
# Post-hoc Tests (Tukey's HSD)
# ----------------------------------------------------------------------------

cat("=== Post-hoc Tests (Tukey's HSD) ===\n\n")

# Overall treatment comparison
tukey_overall <- TukeyHSD(anova_model, "treatment_label")
cat("Overall Treatment Comparisons:\n")
print(tukey_overall)
cat("\n")

# Peak hours treatment comparison
peak_anova <- aov(temperature ~ treatment_label, data = peak_hours_data)
tukey_peak <- TukeyHSD(peak_anova, "treatment_label")

cat("Peak Hours Treatment Comparisons:\n")
print(tukey_peak)
cat("\n")

# Format post-hoc results for export
posthoc_results <- tidy(tukey_peak) %>%
  mutate(
    significant = adj.p.value < 0.05,
    ci_lower = diff - conf.low,
    ci_upper = diff + conf.high
  )

cat("Significant Pairwise Differences (Peak Hours):\n")
print(posthoc_results %>% filter(significant))
cat("\n")

# ----------------------------------------------------------------------------
# Estimated Marginal Means
# ----------------------------------------------------------------------------

cat("=== Estimated Marginal Means ===\n\n")

# Get marginal means for each treatment
emm_treatment <- emmeans(anova_model, ~ treatment_label)
cat("Marginal Means by Treatment:\n")
print(emm_treatment)
cat("\n")

# Pairwise contrasts with confidence intervals
emm_contrasts <- pairs(emm_treatment)
cat("Pairwise Contrasts:\n")
print(emm_contrasts)
cat("\n")

# ----------------------------------------------------------------------------
# Peak Hours Analysis (Most Critical Period)
# ----------------------------------------------------------------------------

cat("=== Peak Hours Detailed Analysis (14:00) ===\n\n")

peak_14_data <- data_long %>%
  filter(hour(timestamp) == 14) %>%
  droplevels()

peak_14_stats <- peak_14_data %>%
  group_by(treatment_label) %>%
  summarise(
    n = n(),
    mean = mean(temperature),
    sd = sd(temperature),
    se = sd / sqrt(n),
    .groups = "drop"
  )

cat("14:00 Temperature Statistics:\n")
print(peak_14_stats)
cat("\n")

# One-way ANOVA for peak hour
peak_14_anova <- aov(temperature ~ treatment_label, data = peak_14_data)
cat("One-way ANOVA at 14:00:\n")
print(summary(peak_14_anova))
cat("\n")

# Effect sizes at peak hour
peak_14_cooling <- peak_14_stats %>%
  filter(treatment_label != "Control") %>%
  mutate(
    control_mean = peak_14_stats$mean[peak_14_stats$treatment_label == "Control"],
    cooling = control_mean - mean,
    cooling_pct = (cooling / control_mean) * 100
  )

cat("Cooling Effects at 14:00:\n")
print(peak_14_cooling %>% select(treatment_label, cooling, cooling_pct))
cat("\n")

# ----------------------------------------------------------------------------
# Interaction Effect Analysis
# ----------------------------------------------------------------------------

cat("=== Treatment × Time Period Interaction ===\n\n")

# Calculate cooling effects by time period
interaction_effects <- data_long %>%
  group_by(time_period, treatment_label) %>%
  summarise(mean_temp = mean(temperature), .groups = "drop") %>%
  pivot_wider(names_from = treatment_label, values_from = mean_temp) %>%
  mutate(
    shade_cooling = Control - `Shade Only`,
    et_cooling = Control - `ET Only`,
    combined_cooling = Control - Combined
  )

cat("Cooling Effects by Time Period:\n")
print(interaction_effects)
cat("\n")

# Test for interaction significance
if (any(anova_results$term == "treatment_label:time_period")) {
  interaction_p <- anova_results$p.value[anova_results$term == "treatment_label:time_period"]
  if (interaction_p < 0.05) {
    cat("Significant interaction found (p =", round(interaction_p, 4), ")\n")
    cat("Treatment effects vary significantly by time of day.\n\n")
  } else {
    cat("No significant interaction (p =", round(interaction_p, 4), ")\n")
    cat("Treatment effects are consistent across time periods.\n\n")
  }
}

# ----------------------------------------------------------------------------
# Export Results
# ----------------------------------------------------------------------------

cat("=== Exporting Results ===\n")

# Export descriptive statistics
write_csv(descriptive_stats, file.path(OUTPUT_DIR, "descriptive_statistics.csv"))
cat("Descriptive statistics exported.\n")

# Export ANOVA results
write_csv(anova_results, file.path(OUTPUT_DIR, "anova_results.csv"))
cat("ANOVA results exported.\n")

# Export post-hoc results
write_csv(posthoc_results, file.path(OUTPUT_DIR, "posthoc_comparisons.csv"))
cat("Post-hoc comparisons exported.\n")

# Export cooling effects
write_csv(cooling_effects, file.path(OUTPUT_DIR, "cooling_effects.csv"))
cat("Cooling effects exported.\n")

# Export peak hours analysis
write_csv(peak_14_cooling, file.path(OUTPUT_DIR, "peak_hours_analysis.csv"))
cat("Peak hours analysis exported.\n")

# Create summary report
summary_report <- list(
  analysis_date = Sys.Date(),
  total_observations = nrow(data),
  peak_hours_observations = nrow(peak_hours_data),
  treatment_groups = length(unique(data_long$treatment_label)),
  anova_f_treatment = anova_results$statistic[anova_results$term == "treatment_label"],
  anova_p_treatment = anova_results$p.value[anova_results$term == "treatment_label"],
  total_cooling_combined = cooling_effects$cooling_effect[cool_effects$treatment_label == "Combined"],
  et_contribution_pct = (cooling_effects$cooling_effect[cooling_effects$treatment_label == "ET Only"] /
                          cooling_effects$cooling_effect[cooling_effects$treatment_label == "Combined"]) * 100,
  shade_contribution_pct = (cooling_effects$cooling_effect[cooling_effects$treatment_label == "Shade Only"] /
                             cooling_effects$cooling_effect[cooling_effects$treatment_label == "Combined"]) * 100
)

write_json(summary_report, file.path(OUTPUT_DIR, "summary_report.json"), pretty = TRUE)
cat("Summary report exported.\n\n")

# ----------------------------------------------------------------------------
# Summary and Interpretation
# ----------------------------------------------------------------------------

cat("=== Analysis Summary ===\n\n")

cat("Key Findings:\n")
cat(sprintf("1. Total vegetation cooling: %.2f°C (%.1f%%)\n",
            cooling_effects$cooling_effect[cooling_effects$treatment_label == "Combined"],
            cooling_effects$cooling_percent[cooling_effects$treatment_label == "Combined"]))
cat(sprintf("2. ET contribution: %.2f°C (%.1f%% of total cooling)\n",
            cooling_effects$cooling_effect[cooling_effects$treatment_label == "ET Only"],
            summary_report$et_contribution_pct))
cat(sprintf("3. Shade contribution: %.2f°C (%.1f%% of total cooling)\n",
            cooling_effects$cooling_effect[cooling_effects$treatment_label == "Shade Only"],
            summary_report$shade_contribution_pct))
cat(sprintf("4. Peak cooling (14:00): %.2f°C\n",
            peak_14_cooling$cooling[peak_14_cooling$treatment_label == "Combined"]))

cat("\nStatistical Significance:\n")
if (anova_results$p.value[anova_results$term == "treatment_label"] < 0.001) {
  cat("Treatment effect: HIGHLY SIGNIFICANT (p < 0.001)\n")
} else if (anova_results$p.value[anova_results$term == "treatment_label"] < 0.05) {
  cat("Treatment effect: SIGNIFICANT (p < 0.05)\n")
} else {
  cat("Treatment effect: Not significant (p =", round(anova_results$p.value[anova_results$term == "treatment_label"], 3), ")\n")
}

cat("\n=== Analysis Complete ===\n")
cat("All results saved to:", OUTPUT_DIR, "\n")
