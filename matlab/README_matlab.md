# MATLAB pipeline (oil-market SVAR analysis)

## Prerequisiti
- MATLAB (consigliato: Econometrics Toolbox per VAR/SVAR, se usata)
- Lanciare gli script da MATLAB con **Current Folder** impostata su `matlab/scripts`
  (oppure aggiungere `matlab/scripts` al MATLAB path)

## Struttura output (generata)
Gli script generano file intermedi (es. `clean_data.mat`, risultati VAR/SVAR, shock, ecc.).
Per tenere il repo pulito, questi file NON sono versionati (vedi `.gitignore`).

## Ordine di esecuzione consigliato

### 1) Costruzione dataset
1. `build_oil_dataset.m`
   - Crea/aggiorna il dataset e salva gli oggetti intermedi (es. `clean_data.mat`)
   - Deve essere eseguito prima di quasi tutto il resto.

### 2) Stima VAR
2. `var_main.m`
   - Stima il VAR principale e salva risultati/diagnostica.

### 3) Identificazione strutturale (SVAR / sign restrictions)
3. `svar_sign_restrictions.m`
   - Applica le restrizioni di segno e produce gli shock strutturali.
4. `extract_structural_shocks.m` (se usato separatamente)
   - Estrae e salva gli shock in formato comodo per analisi successive.

### 4) Analisi/plot (opzionali)
- `plot_var_series.m`
- `plot_lag_selection.m`
- `plot_ols_diagnostic.m`
- `plot_var_cholesky.m`
- `plot_svar_sign.m`
- `plot_irf_bootstrap.m`
- `plot_stylised_fact.m` (nota: esegue `run('build_oil_dataset.m')`)

### 5) Copule (dipende dagli shock)
- `fit_marginal_shocks.m`
- `copula_analysis.m`
- `copula_bivariate_shocks.m`
- `copula_prob_cond_shocks.m`
- `copula_prob_cond_ALL.m`

### 6) Applicazioni (stress test / hedging)
- `hormuz.m` / `hormuz_mix_scenario.m`
- `scenario_mc_WTI.m`
- `stress_test_hormuz_VAR.m`
- `estimate_jet_fuel.m`
- `estimate_pass_through_jetfuel.m`
- `hedging_application_VAR.m`
- `ita_hedging_full.m`

## Run rapido (manuale)
Eseguire in sequenza:
1) `build_oil_dataset`
2) `var_main`
3) `svar_sign_restrictions`
4) (opzionale) `copula_analysis`
5) (opzionale) `stress_test_hormuz_VAR` / `ita_hedging_full`
