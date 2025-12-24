from __future__ import annotations
import numpy as np
import pandas as pd
from dataclasses import dataclass
from pathlib import Path
from statsmodels.tsa.api import VAR
from statsmodels.stats.diagnostic import acorr_ljungbox

@dataclass(frozen=True)
class LagSelConfig:
    data_path: Path = Path("data/processed/all_d.parquet")
    columns: tuple[str, ...] = (
        "Production_DL",
        "OCSE_DL",
        "WTI_real_DL",
        "Inventories_DL",
    )
    p_max: int = 15
    lb_lags: int = 12
    lb_alpha: float = 0.05

def load_all_d(cfg: LagSelConfig) -> pd.DataFrame:
    df = pd.read_parquet(cfg.data_path)
    # all_d ha già Date come colonna/indice dal builder
    if "Date" in df.columns:
        df["Date"] = pd.to_datetime(df["Date"])
        df = df.sort_values("Date").set_index("Date")
    missing = [c for c in cfg.columns if c not in df.columns]
    if missing:
        raise KeyError(f"Missing columns in all_d: {missing}")
    return df.loc[:, cfg.columns].dropna()

def is_stable(res) -> bool:
    # statsmodels: tutti gli autovalori del companion < 1
    eigvals = np.abs(res.roots)
    return np.all(eigvals < 1.0)

def min_ljungbox_pval(resid, lags: int) -> float:
    resid_np = resid.to_numpy()   # converte DataFrame → ndarray
    pvals = []
    for j in range(resid_np.shape[1]):
        lb = acorr_ljungbox(resid_np[:, j], lags=lags, return_df=True)
        pvals.append(lb["lb_pvalue"].min())
    return float(np.min(pvals))

def select_p(cfg: LagSelConfig) -> pd.DataFrame:
    df = load_all_d(cfg)
    results = []
    for p in range(1, cfg.p_max + 1):
        model = VAR(df)
        res = model.fit(p)
        stable = is_stable(res)
        lb_min = min_ljungbox_pval(res.resid, cfg.lb_lags)
        results.append(
            {"p": p, "Stable": stable, "LB_min_pval": lb_min}
        )
        print(f"VAR({p}) | Stable={int(stable)} | min LB p={lb_min:.4f}")
    return pd.DataFrame(results)

def choose_p(results: pd.DataFrame, alpha: float) -> int:
    ok = results[(results["Stable"]) & (results["LB_min_pval"] > alpha)]
    if len(ok) > 0:
        return int(ok.iloc[0]["p"])
    # fallback: massimo p-value
    idx = results["LB_min_pval"].idxmax()
    return int(results.loc[idx, "p"])

if __name__ == "__main__":
    cfg = LagSelConfig()
    res = select_p(cfg)
    p_chosen = choose_p(res, cfg.lb_alpha)
    print("\nSUMMARY")
    print(res)
    print(f"\n*** pChosen = {p_chosen} ***")


