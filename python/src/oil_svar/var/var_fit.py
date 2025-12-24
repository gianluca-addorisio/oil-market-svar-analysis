from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import pandas as pd
from statsmodels.tsa.api import VAR


@dataclass(frozen=True)
class VarConfig:
    data_path: Path = Path("data/processed/all_d.parquet")
    columns: tuple[str, ...] = ("Production_DL", "OCSE_DL", "WTI_real_DL", "Inventories_DL")


def load_all_d(cfg: VarConfig) -> pd.DataFrame:
    df = pd.read_parquet(cfg.data_path)
    # Expect a Date column (from build_dataset.py)
    df["Date"] = pd.to_datetime(df["Date"])
    df = df.sort_values("Date").set_index("Date")

    missing = [c for c in cfg.columns if c not in df.columns]
    if missing:
        raise KeyError(f"Missing columns in all_d: {missing}")

    return df.loc[:, cfg.columns].dropna()


def fit_var(df: pd.DataFrame, p: int):
    model = VAR(df)
    res = model.fit(p)
    return res


if __name__ == "__main__":
    cfg = VarConfig()
    df = load_all_d(cfg)
    p = 12  # temporary
    res = fit_var(df, p)

    print("nobs:", res.nobs)
    print("neqs:", res.neqs)
    print("k_ar:", res.k_ar)
    print("AIC:", res.aic)
    print("BIC:", res.bic)
    print("Residuals shape:", res.resid.shape)

