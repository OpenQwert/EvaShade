# EvaShade Experimental Design

## Overview

This document describes the experimental design for quantifying the independent contributions of **evapotranspiration (ET)** and **shade** to urban vegetation cooling effects.

## Research Objectives

### Primary Objective
Quantify the independent and combined effects of evapotranspiration and shade on urban thermal environments.

### Secondary Objectives
1. Determine the relative contribution of ET vs shade to total cooling
2. Assess diurnal patterns of cooling mechanisms
3. Provide scientific basis for urban vegetation planning strategies

## Hypotheses

### H₁: Vegetation Cooling Effect
- **H₀**: Vegetation treatments show no temperature difference from control
- **H₁**: Vegetation treatments reduce temperature compared to control

### H₂: Mechanism Comparison
- **H₀**: ET cooling = Shade cooling
- **H₁**: ET cooling > Shade cooling

### H₃: Additive Effect
- **H₀**: Combined cooling ≠ Shade + ET
- **H₁**: Combined cooling ≈ Shade + ET (additive)

## Experimental Design

### Design Type
**Four-group controlled comparison** (2×2 factorial design)

### Treatment Groups

| Group | Condition | Purpose | Mechanism Isolated |
|-------|-----------|---------|-------------------|
| **Control** | Open ground, no vegetation | Baseline temperature | N/A |
| **Shade Only** | Artificial shade structure | Pure shading effect | Solar radiation blockage |
| **ET Only** | Irrigated ground cover | Pure evapotranspiration | Water phase change cooling |
| **Combined** | Living vegetation | Total effect | Shade + ET (natural) |

### Site Layout

```
┌─────────────────────────────────────────┐
│           Experimental Site              │
│            15m × 15m                     │
│                                          │
│  ┌─────────┐  ┌─────────┐              │
│  │Control  │  │Shade    │              │
│  │  5m×5m  │  │  5m×5m  │              │
│  └─────────┘  └─────────┘              │
│                                          │
│  ┌─────────┐  ┌─────────┐              │
│  │ET Only  │  │Combined │              │
│  │  5m×5m  │  │  5m×5m  │              │
│  └─────────┘  └─────────┘              │
└─────────────────────────────────────────┘
```

### Layout Specifications

- **Total site area**: 15m × 15m (225 m²)
- **Individual plot size**: 5m × 5m (25 m²)
- **Buffer zone**: 1m between plots
- **Randomization**: Random assignment of plot positions
- **Replication**: Each treatment has 3 sensor positions (within-plot replication)

## Sensor Network

### Temperature/Humidity Sensors

| Specification | Value |
|---------------|-------|
| **Model** | BME280 |
| **Temperature range** | -40 to +85°C |
| **Temperature accuracy** | ±0.5°C |
| **Humidity range** | 0-100% RH |
| **Humidity accuracy** | ±3% RH |
| **Sampling interval** | 10 minutes |
| **Data logger** | ESP32 microcontroller |

### Sensor Placement

```
Each 5m×5m plot:

  Sensor1 ---- Sensor2
      \          /
       \        /
        Sensor3 (center)
```

- **Height**: 1.5m above ground (pedestrian level)
- **Shielding**: Radiation shield on all sensors
- **Calibration**: Pre-experiment calibration against reference thermometer

### Additional Measurements

| Variable | Sensor | Range | Accuracy |
|----------|--------|-------|----------|
| Solar radiation | Pyranometer | 0-1400 W/m² | ±5% |
| Wind speed | Anemometer | 0-50 m/s | ±0.3 m/s |
| Soil moisture | TDR sensor | 0-100% | ±2.5% |

## Experimental Timeline

### Phase 1: Site Preparation (Weeks 1-2)
- [ ] Site clearing and leveling
- [ ] Plot demarcation and buffer zones
- [ ] Sensor installation and calibration
- [ ] Shade structure construction

### Phase 2: Baseline Measurements (Week 3)
- [ ] Control group measurements (no treatment)
- [ ] Environmental conditions monitoring
- [ ] Data quality validation

### Phase 3: Treatment Implementation (Week 4)
- [ ] Install artificial shade (Shade group)
- [ ] Plant ground cover vegetation (ET group)
- [ ] Plant trees/shrubs (Combined group)
- [ ] Install irrigation system

### Phase 4: Data Collection (Weeks 5-12)
- [ ] Continuous sensor readings (10-min intervals)
- [ ] Weekly vegetation measurements (height, LAI)
- [ ] Irrigation scheduling (ET & Combined groups)
- [ ] Data quality checks

### Phase 5: Data Analysis (Weeks 13-14)
- [ ] Data cleaning and validation
- [ ] Statistical analysis (ANOVA, post-hoc tests)
- [ ] Figure generation
- [ ] Report writing

## Measurement Protocol

### Data Collection Schedule

| Time | Measurements | Frequency |
|------|--------------|-----------|
| 00:00-06:00 | T, RH, Solar, Wind | Every 10 min |
| 06:00-18:00 | T, RH, Solar, Wind | Every 10 min |
| 18:00-24:00 | T, RH, Solar, Wind | Every 10 min |
| Weekly | Vegetation metrics | Once |
| Daily | Irrigation check | Once |

### Quality Control

1. **Sensor calibration**: Biweekly validation
2. **Data completeness**: > 95% data retention required
3. **Outlier detection**: IQR method (±1.5×IQR)
4. **Missing data**: Linear interpolation for gaps < 2 hours
5. **Backup system**: Redundant sensors in each plot

## Statistical Analysis Plan

### Primary Analysis: Two-Way ANOVA

**Model**: Temperature ~ Treatment (4) × Time Period (3)

**Factors**:
- Treatment: Control, Shade, ET, Combined (4 levels)
- Time Period: Morning (6-12), Afternoon (12-18), Evening (18-6) (3 levels)

**Assumptions**:
- [ ] Normality (Shapiro-Wilk test)
- [ ] Homogeneity of variances (Levene's test)
- [ ] Independence of observations

### Post-Hoc Tests

- **Tukey's HSD**: Pairwise treatment comparisons
- **Effect size**: Eta-squared (η²) and Cohen's d
- **Confidence intervals**: 95% CI for all estimates

### Sample Size Justification

- **Power analysis** (G*Power 3.1):
  - Effect size f = 0.40 (large, based on pilot data)
  - α = 0.05, Power = 0.95
  - Required sample: 52 observations
  - **Achieved**: ~150 observations (25 days × 6 time blocks)

## Data Management

### Data Storage

1. **Raw data**: SD cards on ESP32 (local backup)
2. **Daily uploads**: Cloud storage (automatic)
3. **Weekly backups**: External hard drive
4. **Version control**: Git for analysis scripts

### Data Format

- **Raw data**: CSV with ISO 8601 timestamps
- **Cleaned data**: TSV with standardized variable names
- **Metadata**: JSON with sensor specifications
- **Code**: R scripts with roxygen2 documentation

## Expected Results

### Hypothesized Outcomes

| Treatment | Expected Cooling (°C) | Relative to Control |
|-----------|----------------------|---------------------|
| Control | 0.0 | - |
| Shade Only | 2.0-3.0 | Solar radiation blockage |
| ET Only | 4.0-5.0 | Latent heat flux |
| Combined | 6.0-8.0 | Additive effect |

### Key Metrics

1. **Total vegetation cooling**: 6-8°C below control
2. **ET contribution ratio**: 60-80% of total cooling
3. **Peak cooling time**: 14:00 (maximum solar radiation)
4. **Synergistic effect**: Combined ≈ Shade + ET (±0.5°C)

## Potential Limitations

### Environmental Factors
- **Weather variability**: Uncontrolled seasonal changes
- **Soil heterogeneity**: Pre-existing soil differences
- **Pest/disease pressure**: May affect vegetation health

### Technical Limitations
- **Sensor accuracy**: ±0.5°C may mask small effects
- **Shade structure**: Artificial vs natural shade differences
- **Scale**: 5m×5m plots may not represent real-world conditions

### Mitigation Strategies
- Randomized plot assignment
- Within-plot sensor replication (n=3)
- Extended data collection period (8 weeks)
- Sensitivity analysis with cleaned data

## Ethical Considerations

- **Land use permission**: Obtained from site owner
- **Water usage**: Efficient irrigation (drip system)
- **Vegetation disposal**: Composted after experiment
- **Data transparency**: Open-source data and code

## Timeline Summary

| Week | Activity |
|------|----------|
| 1-2 | Site preparation, sensor installation |
| 3 | Baseline measurements |
| 4 | Treatment implementation |
| 5-12 | Data collection (8 weeks) |
| 13-14 | Data analysis and visualization |
| 15 | Report writing and submission |

## References

1. **Monteiro, M. V., et al.** (2016). The carbon cost of urban greening. *Nature Climate Change*, 6(7), 682-684.

2. **Zhang, Z., et al.** (2021). Separating the effects of shading and transpiration on vegetation cooling. *Agricultural and Forest Meteorology*, 305, 108368.

3. **Bowman, D., et al.** (2022). Experimental design for urban ecology studies. *Methods in Ecology and Evolution*, 13(4), 789-801.

4. **Shashua-Bar, L., & Hoffman, M. E.** (2000). Vegetation as a climatic component in the design of an urban street. *Energy and Buildings*, 31(3), 221-235.

---

**Document Version**: 1.0
**Last Updated**: 2024-07-15
**Author**: EvaShade Research Team
**Contact**: contact@evashade.org
