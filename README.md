
---

## Data and Methodology (Summary)

- **Frequency:** Monthly (Jan 1990 – Dec 2024)  
- **Core variables:** Real WTI price, oil production, OECD activity index, inventories, jet fuel prices  
- **Preprocessing:** log transformations, stationarity enforcement, standardization  

### Econometric Framework
- Reduced-form VAR with diagnostic-based lag selection  
- Structural identification via **sign restrictions**  
- Inference based on IRFs, FEVDs, and bootstrap confidence intervals  
- Explicit analysis of distributional asymmetries and tail risk  

---

## Industrial Applications

- **Monte Carlo simulation** of oil-price paths conditional on structural shocks  
- **Stress testing** (geopolitical supply disruptions, demand collapses, inventory shocks)  
- **Hedging analysis** using futures, swaps, and option-based strategies  
- **Airline-sector case study** linking oil shocks to jet-fuel prices and cost-at-risk metrics  

MATLAB implementation is complete; Python versions are in progress.

---

## MATLAB–Python Migration Status

| Component                 | MATLAB | Python |
|--------------------------|--------|--------|
| Dataset construction     | ✅     | ✅     |
| VAR estimation           | ✅     | ✅     |
| SVAR (sign restrictions) | ✅     | ✅     |
| Monte Carlo scenarios    | ✅     | ⏳     |
| Stress testing           | ✅     | ⏳     |
| Hedging applications     | ✅     | ⏳     |

⏳ = in progress

---

## Reproducibility

Generated datasets and outputs are stored in:

data/processed/


This directory is excluded from version control.  
All results can be **fully regenerated** by running the pipeline scripts.

---

## Disclaimer

This repository is part of an academic research project.  
Code and results are provided for **research and educational purposes only** and do not constitute financial or investment advice.

