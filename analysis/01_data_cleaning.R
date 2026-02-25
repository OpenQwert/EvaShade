# ============================================================================
# EvaShade Research Project - Data Cleaning Script
# ============================================================================
# Purpose: Clean and validate raw sensor data from experimental groups
# Author: EvaShade Research Team
# Created: 2024-07-15
# ============================================================================

# Load required libraries
library(tidyverse)
library(lubridate)
library(readr)

# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------

# File paths
RAW_DATA_PATH <- "../data/raw_sensor_data.csv"
CLEAN_DATA_PATH <- "../data/clean_temperature_data.csv"
LOG_FILE_PATH <- "../logs/data_cleaning_log.txt"

# Data quality thresholds
TEMP_MIN <- 10   # Minimum valid temperature (°C)
TEMP_MAX <- 50   # Maximum valid temperature (°C)
HUMIDITY_MIN <- 10   # Minimum valid humidity (%)
HUMIDITY_MAX <- 100  # Maximum valid humidity (%)
MAX_MISSING_RATE <- 0.2  # Maximum acceptable missing data rate (20%)

# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------

#' Log messages to file and console
#' @param message The message to log
#' @param log_file Path to log file
log_message <- function(message, log_file = LOG_FILE_PATH) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- paste0("[", timestamp, "] ", message, "\n")
  cat(log_entry)
  cat(log_entry, file = log_file, append = TRUE)
}

#' Detect and flag outliers using IQR method
#' @param x Numeric vector
#' @return Logical vector indicating outliers
detect_outliers <- function(x) {
  qnt <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr <- IQR(x, na.rm = TRUE)
  outliers <- x < (qnt[1] - 1.5 * iqr) | x > (qnt[2] + 1.5 * iqr)
  return(outliers)
}

#' Calculate missing data statistics
#' @param df Data frame
#' @return Data frame with missing data summary
missing_data_summary <- function(df) {
  missing <- df %>%
    summarise(across(everything(), ~ sum(is.na(.)))) %>%
    pivot_longer(cols = everything(), names_to = "variable", values_to = "missing_count") %>%
    mutate(
      total = nrow(df),
      missing_rate = missing_count / total
    )
  return(missing)
}

# ----------------------------------------------------------------------------
# Main Data Cleaning Pipeline
# ----------------------------------------------------------------------------

log_message("=== Starting Data Cleaning Pipeline ===")

# Step 1: Load raw data
log_message(paste("Loading raw data from:", RAW_DATA_PATH))

raw_data <- tryCatch({
  read_csv(RAW_DATA_PATH,
           col_types = cols(
             timestamp = col_datetime(),
             control_temp = col_double(),
             shade_temp = col_double(),
             et_temp = col_double(),
             combined_temp = col_double(),
             control_humidity = col_double(),
             shade_humidity = col_double(),
             et_humidity = col_double(),
             combined_humidity = col_double(),
             solar_radiation = col_double(),
             wind_speed = col_double()
           ))
}, error = function(e) {
  log_message(paste("ERROR loading data:", e$message))
  stop(e)
})

log_message(paste("Loaded", nrow(raw_data), "records with", ncol(raw_data), "variables"))

# Step 2: Initial data quality check
log_message("\n--- Step 1: Initial Data Quality Check ---")

initial_missing <- missing_data_summary(raw_data)
log_message("Missing data summary:")
print(initial_missing)

# Check for duplicate timestamps
duplicates <- raw_data %>%
  count(timestamp) %>%
  filter(n > 1)

if (nrow(duplicates) > 0) {
  log_message(paste("WARNING: Found", nrow(duplicates), "duplicate timestamps"))
} else {
  log_message("No duplicate timestamps found")
}

# Step 3: Validate data ranges
log_message("\n--- Step 2: Range Validation ---")

# Temperature validation
temp_cols <- c("control_temp", "shade_temp", "et_temp", "combined_temp")
for (col in temp_cols) {
  out_of_range <- sum(raw_data[[col]] < TEMP_MIN | raw_data[[col]] > TEMP_MAX, na.rm = TRUE)
  if (out_of_range > 0) {
    log_message(paste("WARNING:", out_of_range, "values out of range in", col))
    # Flag but don't remove (will be interpolated)
    raw_data[[paste0(col, "_flag")]] <- raw_data[[col]] < TEMP_MIN | raw_data[[col]] > TEMP_MAX
  }
}

# Humidity validation
humidity_cols <- c("control_humidity", "shade_humidity", "et_humidity", "combined_humidity")
for (col in humidity_cols) {
  out_of_range <- sum(raw_data[[col]] < HUMIDITY_MIN | raw_data[[col]] > HUMIDITY_MAX, na.rm = TRUE)
  if (out_of_range > 0) {
    log_message(paste("WARNING:", out_of_range, "values out of range in", col))
    raw_data[[paste0(col, "_flag")]] <- raw_data[[col]] < HUMIDITY_MIN | raw_data[[col]] > HUMIDITY_MAX
  }
}

# Step 4: Handle missing data
log_message("\n--- Step 3: Missing Data Imputation ---")

# Linear interpolation for small gaps
clean_data <- raw_data %>%
  arrange(timestamp) %>%
  mutate(across(all_of(temp_cols), ~ zoo::na.approx(., na.rm = FALSE))) %>%
  mutate(across(all_of(humidity_cols), ~ zoo::na.approx(., na.rm = FALSE)))

# Forward/backward fill for remaining NAs at edges
clean_data <- clean_data %>%
  mutate(across(all_of(temp_cols), ~ tidyr::fill(., .direction = "downup"))) %>%
  mutate(across(all_of(humidity_cols), ~ tidyr::fill(., .direction = "downup")))

# Count remaining missing values
remaining_missing <- missing_data_summary(clean_data %>% select(all_of(c(temp_cols, humidity_cols))))
log_message("Missing data after imputation:")
print(remaining_missing)

# Step 5: Outlier detection
log_message("\n--- Step 4: Outlier Detection ---")

for (col in temp_cols) {
  outliers <- detect_outliers(clean_data[[col]])
  n_outliers <- sum(outliers, na.rm = TRUE)
  log_message(paste(col, ":", n_outliers, "outliers detected (IQR method)"))

  # Add outlier flag
  clean_data[[paste0(col, "_outlier")]] <- outliers
}

# Step 6: Calculate derived variables
log_message("\n--- Step 5: Derived Variables ---")

clean_data <- clean_data %>%
  mutate(
    # Cooling effects
    shade_cooling = control_temp - shade_temp,
    et_cooling = control_temp - et_temp,
    combined_cooling = control_temp - combined_temp,

    # Temperature differentials
    shade_et_diff = shade_temp - et_temp,

    # Vapor pressure deficit (approximate)
    vpd_control = (1 - control_humidity / 100) * 0.611 * exp((17.27 * control_temp) / (control_temp + 237.3)),

    # Time variables
    hour = hour(timestamp),
    date = as_date(timestamp),

    # Data quality flag
    quality_flag = ifelse(
      select(., ends_with("_flag")) %>% rowSums() > 0 |
      select(., ends_with("_outlier")) %>% rowSums() > 0,
      TRUE, FALSE
    )
  )

# Step 7: Final data summary
log_message("\n--- Step 6: Final Data Summary ---")

log_message(paste("Final dataset:", nrow(clean_data), "records"))
log_message(paste("Quality flag rate:", round(sum(clean_data$quality_flag) / nrow(clean_data) * 100, 2), "%"))

# Calculate statistics for each group
stats_summary <- clean_data %>%
  summarise(
    across(
      all_of(temp_cols),
      list(
        mean = ~mean(., na.rm = TRUE),
        sd = ~sd(., na.rm = TRUE),
        min = ~min(., na.rm = TRUE),
        max = ~max(., na.rm = TRUE)
      ),
      .names = "{.col}_{.fn}"
    )
  )

log_message("\nTemperature statistics by group:")
print(stats_summary)

# Step 8: Export cleaned data
log_message(paste("\nExporting cleaned data to:", CLEAN_DATA_PATH))

# Select only relevant columns for export
export_data <- clean_data %>%
  select(
    timestamp, date, hour,
    control_temp, shade_temp, et_temp, combined_temp,
    control_humidity, shade_humidity, et_humidity, combined_humidity,
    solar_radiation, wind_speed,
    shade_cooling, et_cooling, combined_cooling,
    quality_flag
  )

write_csv(export_data, CLEAN_DATA_PATH)
log_message("Cleaned data exported successfully")

# Step 9: Generate data quality report
log_message("\n=== Data Cleaning Complete ===")
log_message(paste("Input records:", nrow(raw_data)))
log_message(paste("Output records:", nrow(clean_data)))
log_message(paste("Records flagged:", sum(clean_data$quality_flag)))
log_message(paste("Data retention rate:", round(nrow(clean_data) / nrow(raw_data) * 100, 2), "%"))

# ----------------------------------------------------------------------------
# Summary Plot (Optional - requires ggplot2)
# ----------------------------------------------------------------------------

if (require("ggplot2", quietly = TRUE)) {
  log_message("\nGenerating data quality visualization...")

  p <- clean_data %>%
    pivot_longer(
      cols = all_of(temp_cols),
      names_to = "group",
      values_to = "temperature"
    ) %>%
    mutate(
      group = factor(group, levels = temp_cols),
      group_label = case_when(
        group == "control_temp" ~ "Control",
        group == "shade_temp" ~ "Shade Only",
        group == "et_temp" ~ "ET Only",
        group == "combined_temp" ~ "Combined"
      )
    ) %>%
    ggplot(aes(x = timestamp, y = temperature, color = group_label)) +
    geom_line(alpha = 0.7) +
    geom_point(aes(shape = quality_flag), size = 0.8, alpha = 0.5) +
    scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 4)) +
    labs(
      title = "Temperature Data Quality Check",
      subtitle = "EvaShade Experimental Groups",
      x = "Timestamp",
      y = "Temperature (°C)",
      color = "Experimental Group",
      shape = "Quality Flag"
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold", size = 14),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  # Save plot
  ggsave("../docs/data_quality_check.png", p, width = 10, height = 6, dpi = 300)
  log_message("Data quality plot saved to: ../docs/data_quality_check.png")
}

log_message("\n=== Script Complete ===")
