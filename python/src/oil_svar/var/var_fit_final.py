from __future__ import annotations
import numpy as np
import pandas as pd
from pathlib import Path
from statsmodels.tsa.api import VAR

DATA_PATH = Path("data/processed/all_d.parquet")
OUT_DIR = Path("data/processed/var")
OUT_DIR.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "Production_DL",
    "OCSE_DL",
    "WTI_real_DL",
    "Inventories_DL",
]

P_CHOSEN = 12

def load_data():
    df = pd.read_parquet(DATA_PATH)
    if "Date" in df.columns:
        df["Date"] = pd.to_datetime(df["Date"])
        df = df.sort_values("Date").set_index("Date")
    return df[COLUMNS].dropna()

def main():
    df = load_data()
    model = VAR(df)
    res = model.fit(P_CHOSEN)

    print("=== VAR FINAL FIT ===")
    print(f"nobs: {res.nobs}")
    print(f"neqs: {res.neqs}")
    print(f"k_ar: {res.k_ar}")
    print(f"AIC: {res.aic}")
    print(f"BIC: {res.bic}")

    # Save reduced-form outputs
    res.save(OUT_DIR / "var_final_results.pkl")

    # Save essentials for later steps
    np.save(OUT_DIR / "residuals.npy", res.resid)
    np.save(OUT_DIR / "roots.npy", res.roots)

    print(f"\nSaved to: {OUT_DIR.resolve()}")

if __name__ == "__main__":
    main()

