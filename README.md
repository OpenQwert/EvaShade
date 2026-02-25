# EvaShade

> **Eva**potranspiration (蒸散发) + **Shade** (遮荫)

EvaShade is a scientific research project studying urban vegetation cooling mechanisms. Through controlled experiments, we quantify the independent contributions of evapotranspiration and shade to urban thermal environments, providing evidence-based guidance for sustainable urban planning.

## 🎯 Research Overview

EvaShade 探索城市植被降温机制，通过精确的实验测量与统计分析，量化蒸散发与遮荫对城市热环境的独立贡献，为可持续城市规划提供科学依据。

### Research Questions

1. **Primary**: What are the independent contributions of evapotranspiration (ET) and shade to urban vegetation cooling?
2. **Secondary**: Which mechanism dominates the total cooling effect?
3. **Applied**: How can urban vegetation strategies be optimized for maximum cooling benefit?

---

## 📊 Project Highlights

### 🔬 Rigorous Experimental Design

**Four-Group Controlled Comparison** (2×2 factorial design):

| Group | Condition | Mechanism Isolated |
|-------|-----------|-------------------|
| **Control** | Open ground, no vegetation | Baseline temperature |
| **Shade Only** | Artificial shade structure | Solar radiation blockage |
| **ET Only** | Irrigated ground cover | Pure evapotranspiration |
| **Combined** | Living vegetation | Shade + ET (natural) |

### 📈 Data-Driven Analysis

- **Data Collection**: ESP32 microcontrollers + BME280 sensors (10-min intervals)
- **Statistical Methods**: Two-way ANOVA, post-hoc Tukey tests, effect size calculations
- **Software Stack**: R (tidyverse, car, emmeans) for reproducible research

### 🎯 Key Findings (Expected)

- **Total vegetation cooling**: 6-8°C below control at peak hours
- **ET contribution**: 60-80% of total cooling effect
- **Peak cooling time**: 14:00 (maximum solar radiation)
- **Synergistic effect**: Combined ≈ Shade + ET (±0.5°C)

---

## 🚀 Quick Start

### View the Website

```bash
# Option 1: Direct open
# Simply double-click index.html

# Option 2: Local server
python -m http.server 8000
# Then visit http://localhost:8000
```

### Run the Analysis

```bash
# Install R dependencies
Rscript -e "install.packages(c('tidyverse', 'broom', 'car', 'emmeans', 'effectsize'))"

# Execute analysis pipeline
cd analysis
Rscript 01_data_cleaning.R
Rscript 02_statistical_analysis.R
Rscript 03_visualization.R
```

---

## 📁 Project Structure

```
evashade_frontend/
├── index.html                  # Bilingual research showcase website
├── README.md                   # This file
├── LICENSE                     # MIT License
├── .gitignore                  # Git ignore rules
│
├── analysis/                   # 🔬 Data analysis pipeline (R)
│   ├── 01_data_cleaning.R      # Data cleaning and validation
│   ├── 02_statistical_analysis.R  # ANOVA, post-hoc tests
│   ├── 03_visualization.R      # Publication-quality figures
│   └── README.md               # Analysis documentation
│
├── data/                       # 📊 Dataset
│   └── sample_temperature_data.csv  # Sample dataset (demo)
│
├── docs/                       # 📚 Research documentation
│   └── experimental_design.md  # Detailed experimental design
│
├── results/                    # 📈 Analysis outputs (generated)
│   ├── anova_results.csv
│   ├── cooling_effects.csv
│   └── summary_report.json
│
└── figures/                    # 🎨 Generated figures
    ├── figure1_timeseries.png
    ├── figure4_cooling_effects.pdf
    └── ... (7 figures total)
```

---

## 🧪 Technical Details

### Sensor Network

| Component | Specification |
|-----------|---------------|
| **Temperature Sensor** | BME280 (±0.5°C accuracy) |
| **Data Logger** | ESP32 microcontroller |
| **Sampling Interval** | 10 minutes |
| **Data Retention Rate** | > 95% after cleaning |
| **Environmental Variables** | Temperature, humidity, solar radiation, wind speed |

### Statistical Methods

- **Primary Analysis**: Two-way ANOVA (Treatment × Time Period)
- **Assumption Testing**: Shapiro-Wilk (normality), Levene's (homogeneity)
- **Post-hoc Tests**: Tukey's HSD for pairwise comparisons
- **Effect Size**: Eta-squared (η²) and Cohen's d
- **Sample Size**: ~150 observations (power > 0.99 for large effect size f=0.40)

### Software & Tools

- **Frontend**: HTML5 + Tailwind CSS + Chart.js
- **Data Analysis**: R 4.0+ (tidyverse ecosystem)
- **Version Control**: Git + GitHub
- **Visualization**: ggplot2, cowplot, ggpubr
- **Reproducibility**: Fixed random seed, roxygen2 documentation

---

## 🌐 Features

### Website Showcase

- 🔄 **Bilingual Interface** - English/Chinese toggle with localStorage persistence
- 🌗 **Responsive Design** - Mobile-first, works on all devices
- 🌙 **Dark Mode** - Eye-friendly theme switching
- 📊 **Interactive Charts** - Compact, performance-optimized data visualization
- ⚡ **Lightweight** - Single-file deployment, no build process needed

### Analysis Pipeline

- 📥 **Automated Data Cleaning** - Outlier detection, missing data imputation
- 🔍 **Inferential Statistics** - Hypothesis testing with confidence intervals
- 📊 **Publication-Ready Figures** - High-resolution PNG and PDF outputs
- 📝 **Comprehensive Documentation** - Experimental design, methods, code comments

---

## 📈 Research Impact

### Scientific Contribution

- ✅ Quantifies independent cooling mechanisms (ET vs shade)
- ✅ Provides evidence for urban vegetation planning
- ✅ Demonstrates rigorous experimental methodology
- ✅ Open data and code for reproducibility

### Potential Applications

- 🏙️ Urban planning policy (vegetation requirements)
- 🌳 Tree species selection guidance
- 🏗️ Building design optimization
- 🌡️ Urban heat island mitigation strategies

---

## 📚 Documentation

- **[Experimental Design](docs/experimental_design.md)** - Detailed methodology and timeline
- **[Analysis README](analysis/README.md)** - Data processing and statistical methods
- **Website** - Interactive data visualization and research overview

---

## 🚢 Deployment

### Static Website Deployment

Deploy `index.html` to any static hosting service:

- **Netlify Drop**: Drag & drop to [app.netlify.com/drop](https://app.netlify.com/drop)
- **GitHub Pages**: Push to repository and enable Pages
- **Vercel**: Import repository for automatic deployment
- **Nginx/Apache**: Copy to web server document root

### GitHub Repository Structure

```bash
# Initialize repository
git init
git add .
git commit -m "Initial commit: EvaShade research project"

# Add remote
git remote add origin https://github.com/OpenQwert/evashade.git

# Push to GitHub
git push -u origin main
```

---

## 🤝 Contributing

We welcome research collaborators, data analysts, and science communication volunteers!

### Ways to Contribute

- 📊 **Data Analysis**: Extend statistical methods, add visualizations
- 🌐 **Website**: Improve UI/UX, add interactive features
- 📝 **Documentation**: Translate to other languages, improve clarity
- 🔬 **Research**: Replicate study in different climates/contexts

### Contribution Guidelines

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit changes (`git commit -m 'Add YourFeature'`)
4. Push to branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

This project is open source and freely available for educational and research purposes.

---

## 📞 Contact

- **Email**: contact@evashade.org
- **GitHub**: https://github.com/OpenQwert
- **Website**: [View Live Demo](#) (add deployment URL)

---

## 🙏 Acknowledgments

- **Research Collaborators**: Partner institutions and fieldwork assistants
- **Open Source Community**: R, tidyverse, and GitHub communities
- **Funding Support**: [Add funding sources if applicable]
- **Equipment Sponsors**: Sensor and hardware manufacturers

---

## 📖 Citation

If you use this project in your research, please cite:

```bibtex
@misc{evashade2024,
  title={EvaShade: Quantifying Vegetation Cooling Mechanisms in Urban Environments},
  author={EvaShade Research Team},
  year={2024},
  url={https://github.com/OpenQwert},
  doi={[Add DOI if available]}
}
```

---

## 🔗 Related Resources

- [IPCC Urban Climate Change Report](https://www.ipcc.ch/srccl/)
- [FAO Urban Forestry Guidelines](http://www.fao.org/forestry/urbanforestry/)
- [NASA Urban Heat Island Resources](https://earthobservatory.nasa.gov/features/UrbanHeat/)

---

**EvaShade Research Team** © 2024 | MIT License

*"Understanding urban vegetation cooling through rigorous science"*
