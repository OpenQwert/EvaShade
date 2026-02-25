# ============================================================================
# EvaShade Research Project - Data Visualization
# ============================================================================
# Purpose: Create publication-quality figures for research presentations
# Output: High-resolution PNG and PDF figures
# Author: EvaShade Research Team
# Created: 2024-07-15
# ============================================================================

# Load required libraries
library(tidyverse)
library(lubridate)
library(scales)
library(cowplot)  # For multi-panel figures
library(ggpubr)   # For publication-ready plots

# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------

DATA_PATH <- "../data/clean_temperature_data.csv"
OUTPUT_DIR <- "../figures"

# Figure settings
DPI <- 300
THEME_MINIMAL <- theme_minimal(base_size = 12, base_family = "Arial")

# Color palette (colorblind-friendly)
COLORS <- list(
  control = "#E41A1C",   # Red
  shade = "#377EB8",     # Blue
  et = "#4DAF4A",        # Green
  combined = "#984EA3",  # Purple
  neutral = "#999999"    # Gray
)

# Create output directory
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

# ----------------------------------------------------------------------------
# Load Data
# ----------------------------------------------------------------------------

cat("Loading data...\n")
data <- read_csv(DATA_PATH, show_col_types = FALSE)

# Reshape to long format
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
    treatment_label = factor(treatment_label, levels = c("Control", "Shade Only", "ET Only", "Combined"))
  )

# ----------------------------------------------------------------------------
# Figure 1: Time Series Temperature Plot
# ----------------------------------------------------------------------------

cat("Creating Figure 1: Time Series...\n")

fig1 <- data_long %>%
  ggplot(aes(x = timestamp, y = temperature, color = treatment_label)) +
  geom_line(size = 0.8, alpha = 0.8) +
  geom_point(aes(shape = treatment_label), size = 1.5, alpha = 0.6) +
  scale_color_manual(
    name = "Treatment",
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  scale_shape_manual(
    name = "Treatment",
    values = c("Control" = 16, "Shade Only" = 17, "ET Only" = 15, "Combined" = 18)
  ) +
  labs(
    title = "Temperature Time Series by Experimental Group",
    subtitle = "EvaShade Urban Vegetation Cooling Study",
    x = "Timestamp",
    y = "Temperature (°C)",
    caption = "Data shown from three consecutive days (July 15-17, 2024)"
  ) +
  THEME_MINIMAL +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(OUTPUT_DIR, "figure1_timeseries.png"),
       fig1, width = 12, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure1_timeseries.pdf"),
       fig1, width = 12, height = 6)

# ----------------------------------------------------------------------------
# Figure 2: Diurnal Temperature Pattern
# ----------------------------------------------------------------------------

cat("Creating Figure 2: Diurnal Pattern...\n")

fig2 <- data_long %>%
  mutate(hour = hour(timestamp)) %>%
  group_by(treatment_label, hour) %>%
  summarise(
    mean_temp = mean(temperature),
    se_temp = sd(temperature) / sqrt(n()),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = hour, y = mean_temp, color = treatment_label)) +
  geom_line(size = 1) +
  geom_ribbon(aes(
    ymin = mean_temp - se_temp,
    ymax = mean_temp + se_temp,
    fill = treatment_label
  ), alpha = 0.2, color = NA) +
  geom_point(size = 2) +
  scale_color_manual(
    name = "Treatment",
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  scale_fill_manual(
    name = "Treatment",
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  scale_x_continuous(breaks = seq(0, 24, 4)) +
  labs(
    title = "Diurnal Temperature Pattern",
    subtitle = "Mean hourly temperatures with standard error bars",
    x = "Hour of Day",
    y = "Temperature (°C)"
  ) +
  THEME_MINIMAL +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor.x = element_blank()
  )

ggsave(file.path(OUTPUT_DIR, "figure2_diurnal_pattern.png"),
       fig2, width = 10, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure2_diurnal_pattern.pdf"),
       fig2, width = 10, height = 6)

# ----------------------------------------------------------------------------
# Figure 3: Box Plot - Temperature Distribution
# ----------------------------------------------------------------------------

cat("Creating Figure 3: Box Plot...\n")

fig3 <- data_long %>%
  filter(hour(timestamp) >= 12 & hour(timestamp) <= 16) %>%
  ggplot(aes(x = treatment_label, y = temperature, fill = treatment_label)) +
  geom_boxplot(
    outlier.shape = 21,
    outlier.fill = "white",
    outlier.alpha = 0.5,
    alpha = 0.8,
    width = 0.6
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 18,
    size = 3,
    color = "black"
  ) +
  geom_jitter(width = 0.1, alpha = 0.3, size = 1) +
  scale_fill_manual(
    name = "Treatment",
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(
    title = "Temperature Distribution by Treatment Group",
    subtitle = "Peak hours (12:00-16:00). Diamonds indicate group means.",
    x = "Treatment Group",
    y = "Temperature (°C)"
  ) +
  THEME_MINIMAL +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave(file.path(OUTPUT_DIR, "figure3_boxplot.png"),
       fig3, width = 8, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure3_boxplot.pdf"),
       fig3, width = 8, height = 6)

# ----------------------------------------------------------------------------
# Figure 4: Cooling Effects Bar Chart
# ----------------------------------------------------------------------------

cat("Creating Figure 4: Cooling Effects...\n")

# Calculate cooling effects
cooling_data <- data %>%
  summarise(
    control_mean = mean(control_temp),
    shade_mean = mean(shade_temp),
    et_mean = mean(et_temp),
    combined_mean = mean(combined_temp),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = ends_with("mean"),
    names_to = "treatment",
    values_to = "temperature"
  ) %>%
  mutate(
    treatment_label = case_when(
      treatment == "control_mean" ~ "Control",
      treatment == "shade_mean" ~ "Shade Only",
      treatment == "et_mean" ~ "ET Only",
      treatment == "combined_mean" ~ "Combined"
    ),
    cooling = control_mean - temperature
  ) %>%
  filter(treatment_label != "Control")

fig4 <- ggplot(cooling_data, aes(x = treatment_label, y = cooling, fill = treatment_label)) +
  geom_col(alpha = 0.8, width = 0.6) +
  geom_text(
    aes(label = sprintf("%.1f°C", cooling)),
    vjust = -0.5,
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_manual(
    name = "Treatment",
    values = c("Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(
    title = "Mean Cooling Effects Relative to Control",
    subtitle = "Average temperature reduction across all measurement periods",
    x = "Treatment Group",
    y = "Cooling Effect (°C)"
  ) +
  THEME_MINIMAL +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 15, hjust = 1),
    panel.grid.major.x = element_blank()
  ) +
  ylim(0, max(cooling_data$cooling) * 1.2)

ggsave(file.path(OUTPUT_DIR, "figure4_cooling_effects.png"),
       fig4, width = 8, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure4_cooling_effects.pdf"),
       fig4, width = 8, height = 6)

# ----------------------------------------------------------------------------
# Figure 5: Pie Chart - Cooling Mechanism Decomposition
# ----------------------------------------------------------------------------

cat("Creating Figure 5: Mechanism Decomposition...\n")

mechanism_data <- data.frame(
  mechanism = c("Shade Cooling", "ET Cooling", "Interaction"),
  contribution = c(1.8, 4.2, 0.5),
  colors = c(COLORS$shade, COLORS$et, COLORS$combined)
)

fig5 <- ggplot(mechanism_data, aes(x = "", y = contribution, fill = mechanism)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  scale_fill_manual(
    values = c("Shade Cooling" = COLORS$shade,
               "ET Cooling" = COLORS$et,
               "Interaction" = COLORS$combined)
  ) +
  geom_text(
    aes(label = paste0(round(contribution / sum(contribution) * 100), "%")),
    position = position_stack(vjust = 0.5),
    color = "white",
    fontface = "bold",
    size = 5
  ) +
  labs(
    title = "Cooling Mechanism Decomposition",
    subtitle = "Relative contribution of each mechanism to total cooling effect"
  ) +
  THEME_MINIMAL +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(OUTPUT_DIR, "figure5_mechanism_pie.png"),
       fig5, width = 8, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure5_mechanism_pie.pdf"),
       fig5, width = 8, height = 6)

# ----------------------------------------------------------------------------
# Figure 6: Multi-Panel Summary Figure
# ----------------------------------------------------------------------------

cat("Creating Figure 6: Multi-Panel Summary...\n")

# Panel A: Time series
panel_a <- data_long %>%
  filter(date == as_date("2024-07-16")) %>%
  ggplot(aes(x = timestamp, y = temperature, color = treatment_label)) +
  geom_line(size = 0.8) +
  scale_color_manual(
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(title = "A. Single-Day Time Series", x = "", y = "Temperature (°C)") +
  THEME_MINIMAL +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

# Panel B: Box plot
panel_b <- data_long %>%
  filter(hour(timestamp) >= 12 & hour(timestamp) <= 16) %>%
  ggplot(aes(x = treatment_label, y = temperature, fill = treatment_label)) +
  geom_boxplot(alpha = 0.8, outlier.shape = NA) +
  scale_fill_manual(
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(title = "B. Peak Hours Distribution", x = "", y = "") +
  THEME_MINIMAL +
  theme(legend.position = "none", plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1))

# Panel C: Cooling effects
panel_c <- ggplot(cooling_data, aes(x = treatment_label, y = cooling)) +
  geom_col(aes(fill = treatment_label), alpha = 0.8) +
  scale_fill_manual(
    values = c("Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(title = "C. Cooling Effects", x = "", y = "Cooling (°C)") +
  THEME_MINIMAL +
  theme(legend.position = "none", plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1))

# Panel D: Hourly pattern
panel_d <- data_long %>%
  mutate(hour = hour(timestamp)) %>%
  group_by(treatment_label, hour) %>%
  summarise(mean_temp = mean(temperature), .groups = "drop") %>%
  ggplot(aes(x = hour, y = mean_temp, color = treatment_label)) +
  geom_line(size = 0.8) +
  scale_color_manual(
    values = c("Control" = COLORS$control,
               "Shade Only" = COLORS$shade,
               "ET Only" = COLORS$et,
               "Combined" = COLORS$combined)
  ) +
  labs(title = "D. Diurnal Pattern", x = "Hour", y = "") +
  THEME_MINIMAL +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

# Combine panels
fig6 <- plot_grid(
  panel_a, panel_b,
  panel_c, panel_d,
  ncol = 2, nrow = 2,
  align = "hv",
  labels = c("AUTO", "AUTO", "AUTO", "AUTO"),
  label_fontface = "bold"
)

# Add overall title
fig6_final <- plot_grid(
  fig6,
  NULL,
  ncol = 1,
  rel_heights = c(10, 1),
  labels = c("", "Figure 6. Summary of EvaShade Experimental Results"),
  label_size = 12
)

ggsave(file.path(OUTPUT_DIR, "figure6_summary.png"),
       fig6_final, width = 12, height = 10, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure6_summary.pdf"),
       fig6_final, width = 12, height = 10)

# ----------------------------------------------------------------------------
# Figure 7: Correlation Plot - Environmental Factors
# ----------------------------------------------------------------------------

cat("Creating Figure 7: Correlation Analysis...\n")

cor_data <- data %>%
  select(
    control_temp, shade_temp, et_temp, combined_temp,
    solar_radiation, wind_speed
  )

cor_matrix <- cor(cor_data, use = "complete.obs")

# Convert to long format for plotting
cor_long <- as.data.frame(as.table(cor_matrix)) %>%
  rename(Var1 = Var1, Var2 = Var2, cor = Freq) %>%
  mutate(
    Var1 = factor(Var1, levels = colnames(cor_matrix)),
    Var2 = factor(Var2, levels = colnames(cor_matrix))
  )

fig7 <- ggplot(cor_long, aes(x = Var2, y = Var1, fill = cor)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", cor)), color = "white", size = 3) +
  scale_fill_gradient2(
    low = "#2166AC", mid = "white", high = "#B2182B",
    midpoint = 0, limit = c(-1, 1),
    name = "Correlation"
  ) +
  labs(
    title = "Correlation Matrix of Environmental Variables",
    x = "", y = ""
  ) +
  THEME_MINIMAL +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )

ggsave(file.path(OUTPUT_DIR, "figure7_correlation.png"),
       fig7, width = 8, height = 6, dpi = DPI)
ggsave(file.path(OUTPUT_DIR, "figure7_correlation.pdf"),
       fig7, width = 8, height = 6)

# ----------------------------------------------------------------------------
# Save Figure Metadata
# ----------------------------------------------------------------------------

cat("\nSaving figure metadata...\n")

figure_metadata <- data.frame(
  figure_number = 1:7,
  filename = c(
    "figure1_timeseries",
    "figure2_diurnal_pattern",
    "figure3_boxplot",
    "figure4_cooling_effects",
    "figure5_mechanism_pie",
    "figure6_summary",
    "figure7_correlation"
  ),
  title = c(
    "Temperature Time Series by Experimental Group",
    "Diurnal Temperature Pattern",
    "Temperature Distribution by Treatment Group",
    "Mean Cooling Effects Relative to Control",
    "Cooling Mechanism Decomposition",
    "Multi-Panel Summary Figure",
    "Correlation Matrix of Environmental Variables"
  ),
  type = c("Time Series", "Line Plot", "Box Plot", "Bar Chart", "Pie Chart", "Multi-Panel", "Heatmap"),
  description = c(
    "Full time series showing temperature variations across all treatments",
    "Mean hourly temperatures with standard error ribbons",
    "Box plots showing distribution during peak hours (12:00-16:00)",
    "Bar chart comparing mean cooling effects",
    "Pie chart showing contribution of shade, ET, and interaction",
    "Four-panel summary: time series, distribution, cooling effects, diurnal pattern",
    "Correlation heatmap of temperature and environmental variables"
  )
)

write.csv(figure_metadata, file.path(OUTPUT_DIR, "figure_metadata.csv"), row.names = FALSE)

cat("\n=== Visualization Complete ===\n")
cat("All figures saved to:", OUTPUT_DIR, "\n")
cat("Total figures generated:", nrow(figure_metadata), "\n")
