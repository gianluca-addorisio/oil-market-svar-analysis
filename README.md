# Oil Market Structural VAR Analysis  
**Structural Identification of Oil Supply, Global Demand, and Precautionary Shocks with Industrial Applications**

This repository contains a complete research and applied pipeline for the empirical analysis of the global oil market using Structural Vector Autoregressions (SVAR).

The project was originally developed in MATLAB and is being progressively migrated to Python to ensure reproducibility, transparency, and long-term maintainability.

---

## 1. Research Motivation

Oil price fluctuations originate from fundamentally different structural forces that carry distinct economic and policy implications. Empirical evidence shows that treating oil-price innovations as homogeneous shocks leads to incorrect structural inference, misleading impulse responses, and distorted risk assessments.

In particular, supply disruptions, shifts in global real activity, and precautionary (inventory-driven) demand pressures affect prices, quantities, and expectations through different transmission mechanisms. Ignoring this heterogeneity obscures the economic interpretation of oil-market dynamics and limits the usefulness of standard reduced-form analyses for policy evaluation and industrial risk management.

This project is motivated by the need for a structurally interpretable framework that disentangles these forces and links academic oil-market econometrics to real-world decision-making under uncertainty.

---

## 2. Objectives

### Econometric Objectives
- Construct a consistent monthly oil-market dataset covering 1990–2024
- Estimate reduced-form VAR models on stationary variables
- Identify structural shocks using sign restrictions inspired by Kilian (2009) and Kilian & Murphy (2014)
- Compute impulse response functions (IRFs) and forecast error variance decompositions (FEVDs)
- Assess non-Gaussian features, tail behavior, and distributional asymmetries of shocks

### Applied and Industrial Objectives
- Translate identified structural shocks into economically meaningful scenarios
- Generate stress scenarios via Monte Carlo simulation
- Evaluate extreme but plausible oil-price paths
- Quantify cost and risk exposure for energy-intensive industries
- Assess hedging strategies under structural and distributional uncertainty

---

## 3. Data and Dataset Construction

### Frequency and Coverage
- Monthly data from January 1990 to December 2024

### Core Variables
- Real WTI crude oil price  
- Oil production  
- OECD activity index (proxy for global demand)  
- Oil inventories  
- Jet fuel prices  
- Consumer Price Index (for deflation)

### Data Processing
- Log transformations where appropriate  
- Differencing or cyclical filtering to ensure stationarity  
- Alignment on common observation windows  
- Standardization for VAR estimation  

Dataset construction is implemented in:
- `matlab/scripts/build_oil_dataset.m`
- `python/src/oil_svar/build_dataset.py`

---

## 4. Econometric Methodology

### VAR Framework
- Estimation on stationary variables
- Lag length selection based on:
  - model stability
  - residual autocorrelation diagnostics (Ljung–Box)
- Reduced-form VAR estimation followed by structural identification

### Structural Identification
- Sign restrictions imposed on impulse responses
- Identification strategy grounded in the oil-market literature
- Structural shocks identified:
  - Oil supply shocks
  - Aggregate demand shocks
  - Precautionary (inventory-driven) demand shocks

### Inference and Diagnostics
- Reduced-form and structural IRFs and FEVDs
- Residual bootstrap for confidence intervals
- Distributional diagnostics (skewness, kurtosis, normality tests)

---

## 5. Industrial Applications

### Monte Carlo Scenario Generation
- Simulation of future oil-price paths conditional on structural shocks
- Explicit treatment of heavy tails and non-Gaussian behavior

### Stress Testing
- Geopolitical supply disruptions (e.g. Hormuz-type scenarios)
- Demand-driven collapses and booms
- Inventory-induced price spikes

### Hedging Analysis
- Evaluation of futures, swaps, and option-based strategies
- Risk mitigation under different structural shock compositions
- Cost stabilization for industrial consumers (e.g. airlines)

All applications are fully implemented in MATLAB; Python re-implementation is ongoing to ensure consistency and reproducibility across environments.

---

## 6. MATLAB–Python Migration Status

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

## 7. Industrial Case Study
This section presents a concrete implementation of the industrial applications described above, focusing on a case study in the airline sector.

Using structurally identified oil-market shocks, the project performs stress testing and scenario analysis for jet fuel prices, with particular attention to cost exposure and tail risk.

Key components:
- Mapping structural oil shocks to jet fuel prices
- Geopolitical and demand-driven stress scenarios
- Cost-at-risk and distributional analysis
- Evaluation of hedging strategies (futures, swaps, collars)

All analyses rely on Monte Carlo simulation techniques.

---

## 8. Reproducibility and Output Management

All generated datasets and model outputs are stored in:

data/processed/


This directory contains:
- Cleaned and aligned datasets
- VAR and SVAR estimation results
- IRFs and FEVDs
- Monte Carlo simulation outputs
- Stress-test and hedging results

⚠️ The `data/processed/` directory is intentionally **excluded from version control** to ensure repository cleanliness and full reproducibility.

All results can be regenerated by running the pipeline scripts.

---

## 9. Contribution and Positioning

This project contributes to the oil-market literature by providing a fully reproducible and modular implementation of sign-restricted SVAR models tailored to structural oil shocks. Relative to standard reduced-form VAR analyses, the framework emphasizes structural interpretability, distributional diagnostics, and applicability to industrial risk management.

The repository is positioned at the intersection of academic macro-energy econometrics and applied quantitative risk analysis, translating structural identification results into stress testing and hedging applications relevant for energy-exposed firms.

---

## 10. Limitations

Several limitations should be acknowledged:

- Structural identification relies on sign restrictions, which impose economically motivated but non-unique identifying assumptions.
- The VAR framework is linear and may not fully capture nonlinear dynamics during extreme market stress.
- Results are sensitive to variable selection, lag length, and data transformations.
- Industrial applications are illustrative and not calibrated to firm-specific balance sheets or contractual constraints.

These limitations are intrinsic to the chosen econometric framework and motivate further methodological extensions.

---

## 11. Extensions and Ongoing Work

Ongoing and planned extensions include:
- Completion of the full MATLAB-to-Python migration
- Integration of alternative identification schemes (e.g. narrative or proxy SVARs)
- Explicit modeling of nonlinearities and regime shifts
- Extension of stress-testing applications to additional energy-intensive sectors
- Formal comparison between Gaussian and non-Gaussian shock propagation mechanisms

These extensions aim to strengthen both the econometric robustness and the practical relevance of the framework.

---

## 12. References

Key methodological references include:

- Kilian, L. (2009). *Not All Oil Price Shocks Are Alike*. American Economic Review.  
- Kilian, L. & Murphy, D. (2014). *The Role of Inventories and Speculative Trading in the Global Market for Crude Oil*. Journal of Applied Econometrics.  
- Baumeister, C. & Hamilton, J. (2019). *Structural Interpretation of Vector Autoregressions*. Journal of Econometrics.  
- Hamilton, J. (2009). *Causes and Consequences of the Oil Shock of 2007–08*. Brookings Papers.

---

## 13. Disclaimer

This repository is part of an academic research project.

The code and results are provided **for research and educational purposes only** and do not constitute financial, investment, or risk-management advice.

All responsibility for interpretation and use of the results lies with the user.

---

## 14. Replication Guide (Minimal)

To replicate the core empirical results:

1. Run `build_oil_dataset` to construct the processed dataset  
2. Estimate the reduced-form VAR using `var_main`  
3. Identify structural shocks via `svar_sign_restrictions`  
4. Generate IRFs and FEVDs  
5. (Optional) Run stress-testing and hedging scripts  

All results reported in this repository can be reproduced using the provided pipeline.

