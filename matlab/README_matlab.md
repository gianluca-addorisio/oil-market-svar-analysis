# MATLAB Pipeline — Oil Market SVAR Analysis

## Requirements
- MATLAB  
- *Recommended*: Econometrics Toolbox (if VAR/SVAR functions are used)
- Run scripts from MATLAB with **Current Folder** set to `matlab/scripts`  
  *(alternatively, add `matlab/scripts` to the MATLAB path)*

## Generated Output Structure
The scripts generate intermediate and output files (e.g. `clean_data.mat`, VAR/SVAR results, structural shocks, etc.).

To keep the repository clean and reproducible, **all generated files are excluded from version control** (see `.gitignore`).

## Recommended Execution Order

### 1) Dataset Construction
1. `build_oil_dataset.m`
   - Builds or updates the dataset
   - Saves intermediate objects (e.g. `clean_data.mat`)
   - **Must be run before almost all other scripts**

### 2) VAR Estimation
2. `var_main.m`
   - Estimates the baseline VAR
   - Saves estimation results and diagnostic outputs

### 3) Structural Identification (SVAR / Sign Restrictions)
3. `svar_sign_restrictions.m`
   - Applies sign restrictions
   - Produces identified structural shocks
4. `extract_structural_shocks.m` *(if used separately)*
   - Extracts and saves shocks in a convenient format for downstream analysis

### 4) Analysis and Plots (Optional)
- `plot_var_series.m`
- `plot_lag_selection.m`
- `plot_ols_diagnostic.m`
- `plot_var_cholesky.m`
- `plot_svar_sign.m`
- `plot_irf_bootstrap.m`
- `plot_stylised_fact.m`  
  *(note: internally calls `run('build_oil_dataset.m')`)*

### 5) Copula Analysis (Requires Structural Shocks)
- `fit_marginal_shocks.m`
- `copula_analysis.m`
- `copula_bivariate_shocks.m`
- `copula_prob_cond_shocks.m`
- `copula_prob_cond_ALL.m`

### 6) Applications (Stress Testing / Hedging)
- `hormuz.m` / `hormuz_mix_scenario.m`
- `scenario_mc_WTI.m`
- `stress_test_hormuz_VAR.m`
- `estimate_jet_fuel.m`
- `estimate_pass_through_jetfuel.m`
- `hedging_application_VAR.m`
- `ita_hedging_full.m`

## Quick Manual Run
Execute the following scripts in order:
1. `build_oil_dataset`
2. `var_main`
3. `svar_sign_restrictions`
4. *(optional)* `copula_analysis`
5. *(optional)* `stress_test_hormuz_VAR` or `ita_hedging_full`

