cat > README.md <<'EOF'
# Oil Market Structural VAR Analysis  
**Structural Identification of Oil Supply, Global Demand, and Precautionary Shocks with Industrial Applications**

This repository contains the full research and applied pipeline for an empirical analysis of the global oil market using Structural Vector Autoregressions (SVAR).

The project was originally developed in MATLAB and is being progressively migrated to Python to ensure full reproducibility, transparency, and long-term maintainability.

---

## 1. Research Motivation

Oil prices are driven by structurally different shocks that have distinct economic and policy implications. Treating oil-price innovations as homogeneous leads to incorrect inference and poor risk assessment.

This project explicitly separates:
- oil supply shocks
- aggregate demand shocks
- precautionary (inventory-driven) demand shocks

and studies their dynamic effects on prices, production, inventories, and downstream industries.

---

## 2. Objectives

### Econometric Objectives
- Construct a monthly oil-market dataset (1990–2024)
- Estimate reduced-form VAR models on stationary variables
- Identify structural shocks using sign restrictions (Kilian–Murphy approach)
- Compute impulse response functions (IRF) and variance decompositions (FEVD)
- Diagnose non-Gaussian features and tail risks

### Industrial / Applied Objectives
- Generate stress scenarios using Monte Carlo simulation
- Evaluate extreme but plausible oil-price paths
- Quantify risk exposure for industrial users (e.g. aviation fuel costs)
- Assess hedging strategies under structural uncertainty

---

## 3. Data and Dataset Construction

### Frequency and Coverage
- Monthly data: January 1990 – December 2024

### Core Variables
- Real WTI price
- Oil production
- OECD activity index (global demand proxy)
- Oil inventories
- Jet fuel prices
- CPI (for deflation)

### Processing
- Log-transformations where appropriate
- First differences or cyclical components for stationarity
- Alignment on common dates
- Z-score normalization for VAR estimation

Dataset construction is implemented in:
- `matlab/scripts/build_oil_dataset.m`
- `python/src/oil_svar/build_dataset.py`

---

## 4. Econometric Methodology

### VAR Framework
- VAR estimated on stationary variables
- Lag selection based on:
  - stability conditions
  - Ljung–Box residual diagnostics
- Reduced-form estimation followed by structural identification

### Structural Identification
- Sign restrictions imposed on impulse responses
- Identification strategy inspired by Kilian (2009) and Kilian & Murphy (2014)
- Structural shocks:
  - Supply shock
  - Aggregate demand shock
  - Precautionary demand shock

### Inference
- Cholesky-based IRF and FEVD
- Residual bootstrap for confidence intervals
- Distributional diagnostics (skewness, kurtosis, normality tests)

---

## 5. Industrial Applications

### Monte Carlo Scenario Generation
- Simulation of future oil-price paths conditional on structural shocks
- Heavy-tail and non-Gaussian behavior explicitly considered

### Stress Testing
- Geopolitical supply disruptions (e.g. Hormuz-type scenarios)
- Demand collapses and surges
- Inventory-driven price spikes

### Hedging Analysis
- Evaluation of futures, swaps, and option-based strategies
- Risk reduction under different shock compositions
- Cost stabilization for industrial consumers (e.g. airlines)

These components are fully implemented in MATLAB and are being migrated to Python.

---

## 6. MATLAB vs Python Migration Status

| Component | MATLAB | Python |
|--------|--------|--------|
| Dataset construction | ✅ | ✅ |
| VAR estimation | ✅ | ✅ |
| Lag selection & diagnostics | ✅ | ✅ |
| IRF / FEVD | ✅ | ✅ |
| SVAR (sign restrictions) | ✅ | ✅ |
| Monte Carlo scenarios | ✅ | ⏳ |
| Stress testing | ✅ | ⏳ |
| Hedging applications | ✅ | ⏳ |

⏳ = planned / in progress

---

## 7. Reproducibility (Python)

The Python pipeline is fully reproducible starting from raw data:

```bash
python python/src/oil_svar/build_dataset.py
python python/src/oil_svar/var/lag_selection.py
python python/src/oil_svar/var/var_fit.py
python python/src/oil_svar/var/irf_fevd.py
python python/src/oil_svar/var/svar_sign.py
Generated datasets and results are stored in data/processed/ (ignored by Git).

---

## 7. Industrial Application

This project includes an industrial risk-management application focused on the airline sector.

Using the estimated structural oil-market shocks, we perform stress-testing and scenario analysis for jet fuel prices, with a specific application to airline cost exposure.

Main components:
- Mapping structural oil shocks to jet fuel prices
- Stress scenarios (e.g. Hormuz supply disruption)
- Cost-at-risk and distributional analysis
- Hedging evaluation (futures, swaps, collars)

These analyses are implemented using Monte Carlo simulation techniques.

---

## 8. Data Output and Reproducibility

All generated datasets and model outputs are stored in:

data/processed/


This directory includes:
- Cleaned and aligned datasets
- VAR and SVAR estimation results
- Impulse Response Functions (IRFs)
- Forecast Error Variance Decomposition (FEVD)
- Monte Carlo simulation outputs
- Stress-test and hedging results

⚠️ The `data/processed/` directory is intentionally **ignored by Git** to ensure repository cleanliness and reproducibility.

All results can be regenerated by running the pipeline scripts.

---

## 9. References

Key references underlying the methodology include:

- Kilian, L. (2009). *Not All Oil Price Shocks Are Alike*. American Economic Review.
- Kilian, L. & Murphy, D. (2014). *The Role of Inventories and Speculative Trading in the Global Market for Crude Oil*. Journal of Applied Econometrics.
- Baumeister, C. & Hamilton, J. (2019). *Structural Interpretation of Vector Autoregressions*. Journal of Econometrics.
- Hamilton, J. (2009). *Causes and Consequences of the Oil Shock of 2007–08*. Brookings Papers.

---

## 10. Disclaimer

This repository is part of an academic research project.

The code and results are provided **for research and educational purposes only** and do not constitute financial, investment, or risk-management advice.

All responsibility for interpretation and use of the results lies with the user.

