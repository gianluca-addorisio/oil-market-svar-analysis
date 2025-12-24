from __future__ import annotations
import numpy as np
import pandas as pd
from pathlib import Path
from numpy.linalg import qr
from statsmodels.tsa.api import VAR

DATA_PATH = Path("data/processed/all_d.parquet")
OUT_DIR   = Path("data/processed/var/svar_sign")
OUT_DIR.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "Production_DL",
    "OCSE_DL",
    "WTI_real_DL",
    "Inventories_DL",
]

P_CHOSEN   = 12
HORIZON    = 30
N_DRAWS    = 20000
N_ACCEPT   = 200

# Sign restrictions: dict[var_idx][shock_idx] -> sign (+1 / -1)
# shock order: [Supply, AggDemand, Precautionary]
SIGNS = {
    0: {0: -1, 1: +1},   # Production
    2: {0: +1, 1: +1, 2: +1},  # Price
    3: {2: +1},          # Inventories
}

CHECK_H = 1  # horizons to check (0..CHECK_H-1)

def load_data():
    df = pd.read_parquet(DATA_PATH)
    if "Date" in df.columns:
        df["Date"] = pd.to_datetime(df["Date"])
        df = df.sort_values("Date").set_index("Date")
    return df[COLUMNS].dropna()

def random_orthonormal(k: int) -> np.ndarray:
    Q, _ = qr(np.random.randn(k, k))
    return Q

def main():
    df = load_data()
    model = VAR(df)
    res = model.fit(P_CHOSEN)

    irf_rf = res.irf(HORIZON).irfs   # reduced-form IRF (h, k, k)
    k = irf_rf.shape[1]

    accepted = []

    draws = 0
    while len(accepted) < N_ACCEPT and draws < N_DRAWS:
        draws += 1
        Q = random_orthonormal(k)
        irf_s = np.einsum("hij,jk->hik", irf_rf, Q)

        ok = True
        for h in range(CHECK_H):
            for var_idx, rules in SIGNS.items():
                for shock_idx, sgn in rules.items():
                    if np.sign(irf_s[h, var_idx, shock_idx]) != sgn:
                        ok = False
                        break
                if not ok:
                    break
            if not ok:
                break

        if ok:
            accepted.append(irf_s)

    if len(accepted) == 0:
        raise RuntimeError("No accepted draws. Relax sign restrictions.")

    irf_acc = np.stack(accepted, axis=0)  # (n_acc, h, k, k)

    irf_med  = np.median(irf_acc, axis=0)
    irf_low  = np.percentile(irf_acc, 5, axis=0)
    irf_high = np.percentile(irf_acc, 95, axis=0)

    np.save(OUT_DIR / "irf_median.npy", irf_med)
    np.save(OUT_DIR / "irf_low.npy", irf_low)
    np.save(OUT_DIR / "irf_high.npy", irf_high)

    print("=== SVAR SIGN RESTRICTIONS ===")
    print(f"Draws tried: {draws}")
    print(f"Accepted: {len(accepted)}")
    print(f"Saved to: {OUT_DIR.resolve()}")

if __name__ == "__main__":
    main()

