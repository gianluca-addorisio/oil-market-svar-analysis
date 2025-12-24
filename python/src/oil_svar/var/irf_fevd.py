from __future__ import annotations
import numpy as np
import pandas as pd
from pathlib import Path
from statsmodels.tsa.api import VAR

DATA_PATH = Path("data/processed/all_d.parquet")
VAR_DIR   = Path("data/processed/var")
OUT_DIR   = VAR_DIR / "irf_fevd"
OUT_DIR.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "Production_DL",
    "OCSE_DL",
    "WTI_real_DL",
    "Inventories_DL",
]

P_CHOSEN = 12
HORIZON  = 30


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

    # IRF (Cholesky)
    irf = res.irf(HORIZON)
    irfs = irf.orth_irfs        # (h+1, k, k)

    # FEVD
    fevd = res.fevd(HORIZON)
    fevd_arr = fevd.decomp      # (h+1, k, k)

    # Save
    np.save(OUT_DIR / "irf_cholesky.npy", irfs)
    np.save(OUT_DIR / "fevd_cholesky.npy", fevd_arr)

    print("=== IRF + FEVD (Cholesky) ===")
    print(f"Horizon: {HORIZON}")
    print(f"IRF shape:  {irfs.shape}  (time, response, shock)")
    print(f"FEVD shape: {fevd_arr.shape}")
    print(f"Saved to: {OUT_DIR.resolve()}")


if __name__ == "__main__":
    main()

