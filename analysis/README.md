# EvaShade Data Analysis

This directory contains the complete data analysis pipeline for the EvaShade urban vegetation cooling research project.

## 📁 Directory Structure

```
analysis/
├── 01_data_cleaning.R         # Data cleaning and validation
├── 02_statistical_analysis.R  # Inferential statistics and hypothesis testing
├── 03_visualization.R         # Publication-quality figure generation
├── README.md                  # This file
└── requirements.txt           # R package dependencies
```

## 🚀 Quick Start

### Prerequisites

Install R (>= 4.0.0) from [CRAN](https://cran.r-project.org/)

### Required R Packages

```r
# Install required packages
install.packages(c(
  "tidyverse",      # Data manipulation and visualization
  "lubridate",      # Date/time handling
  "broom",          # Tidy statistical outputs
  "car",            # Levene's test for ANOVA assumptions
  "emmeans",        # Estimated marginal means and post-hoc tests
  "effectsize",     # Effect size calculations
  "cowplot",        # Multi-panel figures
  "ggpubr",         # Publication-ready plots
  "scales",         # Scale functions for ggplot2
  "zoo"             # Time series interpolation
))
```

### Running the Analysis

Execute scripts in order:

```bash
# Step 1: Clean and validate raw data
Rscript 01_data_cleaning.R

# Step 2: Perform statistical analysis
Rscript 02_statistical_analysis.R

# Step 3: Generate figures
Rscript 03_visualization.R
```

## 📊 Analysis Pipeline

### 1. Data Cleaning (`01_data_cleaning.R`)

**Purpose**: Transform raw sensor data into analysis-ready dataset

**Key Steps**:
- Load raw CSV data from ESP32/BME280 sensors
- Validate data ranges (temperature: 10-50°C, humidity: 10-100%)
- Detect outliers using IQR method
- Impute missing values via linear interpolation
- Calculate derived variables (cooling effects, vapor pressure deficit)

**Outputs**:
- `../data/clean_temperature_data.csv` - Cleaned dataset
- `../logs/data_cleaning_log.txt` - Processing log
- `../docs/data_quality_check.png` - Data quality visualization

**Quality Metrics**:
- Data retention rate: > 95%
- Missing data after imputation: < 1%
- Outlier flag rate: ~5%

### 2. Statistical Analysis (`02_statistical_analysis.R`)

**Purpose**: Test hypotheses about cooling mechanisms

**Statistical Methods**:
- **Two-way ANOVA**: Treatment (4 levels) × Time Period (3 levels)
- **Assumption Testing**:
  - Shapiro-Wilk test for normality
  - Levene's test for homogeneity of variances
- **Post-hoc Tests**: Tukey's HSD for pairwise comparisons
- **Effect Size**: Eta-squared (η²) and Cohen's d

**Key Hypotheses**:
- H₁: Vegetation treatments show significant cooling vs control
- H₂: ET cooling > Shade cooling
- H₃: Combined cooling ≈ Shade + ET (additive effect)

**Outputs**:
- `../results/descriptive_statistics.csv` - Summary statistics
- `../results/anova_results.csv` - ANOVA table
- `../results/posthoc_comparisons.csv` - Pairwise test results
- `../results/cooling_effects.csv` - Cooling effect magnitudes
- `../results/summary_report.json` - Key findings summary

**Expected Findings**:
- Main treatment effect: **p < 0.001** (highly significant)
- Total vegetation cooling: **2-5°C**
- ET contribution: **60-80%** of total cooling
- Peak cooling (14:00): **up to 9°C**

### 3. Visualization (`03_visualization.R`)

**Purpose**: Create publication-quality figures

**Figures Generated**:

| Figure | Description | Type |
|--------|-------------|------|
| Figure 1 | Temperature time series by group | Line plot |
| Figure 2 | Diurnal temperature pattern | Line plot with error ribbons |
| Figure 3 | Peak hours distribution | Box plot |
| Figure 4 | Cooling effects comparison | Bar chart |
| Figure 5 | Mechanism decomposition | Pie chart |
| Figure 6 | Multi-panel summary | 4-panel composite |
| Figure 7 | Environmental correlations | Heatmap |

**Output Formats**:
- PNG at 300 DPI (for presentations/web)
- PDF vector graphics (for publications)

**Color Palette**: Colorblind-friendly (ColorBrewer Set1)
- Control: Red (#E41A1C)
- Shade Only: Blue (#377EB8)
- ET Only: Green (#4DAF4A)
- Combined: Purple (#984EA3)

## 📈 Data Dictionary

### Input Variables

| Variable | Type | Description | Range |
|----------|------|-------------|-------|
| `timestamp` | datetime | Measurement timestamp | - |
| `control_temp` | numeric | Control group temperature (°C) | 10-50 |
| `shade_temp` | numeric | Shade only temperature (°C) | 10-50 |
| `et_temp` | numeric | ET only temperature (°C) | 10-50 |
| `combined_temp` | numeric | Combined vegetation temperature (°C) | 10-50 |
| `*_humidity` | numeric | Relative humidity (%) | 10-100 |
| `solar_radiation` | numeric | Solar radiation (W/m²) | 0-1200 |
| `wind_speed` | numeric | Wind speed (m/s) | 0-10 |

### Derived Variables

| Variable | Formula | Interpretation |
|----------|---------|----------------|
| `shade_cooling` | control_temp - shade_temp | Shade cooling effect (°C) |
| `et_cooling` | control_temp - et_temp | ET cooling effect (°C) |
| `combined_cooling` | control_temp - combined_temp | Total cooling effect (°C) |
| `vpd` | (1 - RH/100) × 0.611 × exp(17.27×T/(T+237.3)) | Vapor pressure deficit (kPa) |

## 🔬 Statistical Methods Summary

### Two-Way ANOVA Model

```
Y = μ + αᵢ + βⱼ + (αβ)ᵢⱼ + εᵢⱼₖ
```

Where:
- Y = Temperature
- αᵢ = Treatment effect (i = 1,2,3,4)
- βⱼ = Time period effect (j = 1,2,3)
- (αβ)ᵢⱼ = Interaction effect
- εᵢⱼₖ ~ N(0, σ²) = Residual error

### Effect Size Interpretation

| Eta-squared (η²) | Interpretation |
|------------------|----------------|
| 0.01 - 0.06 | Small effect |
| 0.06 - 0.14 | Medium effect |
| > 0.14 | Large effect |

### Sample Size Justification

- **Total observations**: ~150 (25 time points × 6 days)
- **Power analysis** (G*Power 3.1):
  - Effect size f = 0.40 (large)
  - α = 0.05, Power = 0.95
  - Required sample: 52 observations
  - **Achieved power: > 0.99**

## 🧪 Reproducibility

All analyses are fully reproducible:

- **Random seed**: Set to 42 for consistency
- **R version**: 4.0.0 or higher
- **Session info**: Logged in `../results/session_info.txt`

```r
# Save session information
sessionInfo()
```

## 📝 Citation

If you use this analysis pipeline, please cite:

```bibtex
@misc{evashade2024,
  title={EvaShade: Quantifying Vegetation Cooling Mechanisms in Urban Environments},
  author={EvaShade Research Team},
  year={2024},
  url={https://github.com/OpenQwert}
}
```

## 🤝 Contributing

To extend the analysis:

1. Create a new script: `04_your_analysis.R`
2. Follow the naming convention and structure
3. Document all functions with roxygen2 comments
4. Test on sample data before running on full dataset

## 📧 Contact

For questions about the analysis:
- **Email**: contact@evashade.org
- **GitHub Issues**: https://github.com/OpenQwert/evashade/issues

---

**EvaShade Research Team** © 2024
