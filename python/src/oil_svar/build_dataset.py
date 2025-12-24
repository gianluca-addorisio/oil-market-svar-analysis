"""
Dataset builder (Python port of matlab/scripts/build_oil_dataset.m).

Outputs:
- data/processed/clean_data.parquet : main aligned table (equivalent to MATLAB 'All')
- data/processed/all_var.parquet    : VAR dataset (equivalent to MATLAB 'ALL_VAR')
- data/processed/all_d.parquet      : stationary/z-scored diffs (equivalent to MATLAB 'All_d')
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np


@dataclass(frozen=True)
class BuildConfig:
    raw_dir: Path
    processed_dir: Path
    start_date: str = "1990-01-01"
    end_date: str = "2024-12-31"


def _month_start(dt: pd.Series) -> pd.Series:
    dt = pd.to_datetime(dt, errors="coerce")
    return dt.dt.to_period("M").dt.to_timestamp()


def _zscore(df: pd.DataFrame) -> pd.DataFrame:
    # match MATLAB zscore: (x - mean) / std with std computed over sample
    # pandas std default is sample std (ddof=1), same as MATLAB.
    return (df - df.mean()) / df.std(ddof=1)


def _read_wti(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "wti.csv", sep=";", skiprows=1, usecols=["Date", "Value"])
    df["Date"] = _month_start(df["Date"])
    df["WTI"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "WTI"]].dropna()


def _read_cpi(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "cpi.csv", sep=";", skiprows=1, usecols=["Date", "Value"])
    df["Date"] = _month_start(df["Date"])
    df["CPI"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "CPI"]].dropna()


def _read_ffr(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "ffr.csv", sep=";", skiprows=1, usecols=["Date", "Value"])
    df["Date"] = _month_start(df["Date"])
    df["FFR"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "FFR"]].dropna()


def _read_ocse(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "ocse.csv", sep=";")
    # take first two columns (date + value), as in MATLAB
    df = df.iloc[:, :2].copy()
    df.columns = ["Date", "Value"]
    df["Date"] = _month_start(df["Date"])
    df["OCSE"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "OCSE"]].dropna()


def _read_rea(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "rea.csv", sep=";", skiprows=1, usecols=["Date", "Value"])
    df["Date"] = _month_start(df["Date"])
    df["REA"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "REA"]].dropna()


def _read_inventories(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_excel(raw_dir / "inventories.xlsx", header=None, skiprows=2, usecols=[0, 1], names=["Date", "Value"])
    # MATLAB uses InputFormat 'MM/yyyy'
    df["Date"] = pd.to_datetime(df["Date"].astype(str), format="%m/%Y", errors="coerce")
    df["Date"] = _month_start(df["Date"])
    df["Inventories"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "Inventories"]].dropna()


def _read_production(raw_dir: Path) -> pd.DataFrame:
    df = pd.read_csv(raw_dir / "production.csv", sep=";")
    df = df.iloc[:, :2].copy()
    df.columns = ["Date", "Value"]
    # 'MMM-yyyy' with Italian month names sometimes; pandas locale parsing is unreliable.
    # We'll try both Italian and English by mapping Italian abbreviations to English.
    s = df["Date"].astype(str).str.strip().str.lower()

    it_to_en = {
        "gen": "jan", "feb": "feb", "mar": "mar", "apr": "apr", "mag": "may", "giu": "jun",
        "lug": "jul", "ago": "aug", "set": "sep", "ott": "oct", "nov": "nov", "dic": "dec",
    }
    # replace leading month token (e.g., "gen-1990")
    s2 = s.copy()
    for it, en in it_to_en.items():
        s2 = s2.str.replace(f"{it}-", f"{en}-", regex=False)

    dt = pd.to_datetime(s2, format="%b-%Y", errors="coerce")
    df["Date"] = _month_start(dt)
    df["Production"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "Production"]].dropna()


def _read_jetfuel(raw_dir: Path) -> pd.DataFrame:
    # jetfuel1.xls: one text column like "1991-01,0.741" possibly with header "Datetime,Value"
    raw = pd.read_excel(raw_dir / "jetfuel1.xls", header=None, dtype=str)
    col = raw.iloc[:, 0].dropna().astype(str)
    if col.str.contains("Datetime", case=False, na=False).iloc[0]:
        col = col.iloc[1:]
    parts = col.str.split(",", n=1, expand=True)
    df = pd.DataFrame({"Date": parts[0], "Value": parts[1]})
    df["Date"] = pd.to_datetime(df["Date"], format="%Y-%m", errors="coerce")
    df["Date"] = _month_start(df["Date"])
    df["JetFuel_USGC"] = pd.to_numeric(df["Value"].astype(str).str.replace(",", "", regex=False), errors="coerce")
    return df[["Date", "JetFuel_USGC"]].dropna()


def build_oil_dataset(cfg: BuildConfig) -> dict[str, pd.DataFrame]:
    start = pd.to_datetime(cfg.start_date)
    end = pd.to_datetime(cfg.end_date)

    cfg.processed_dir.mkdir(parents=True, exist_ok=True)

    wti = _read_wti(cfg.raw_dir)
    cpi = _read_cpi(cfg.raw_dir)
    ocse = _read_ocse(cfg.raw_dir)
    rea = _read_rea(cfg.raw_dir)
    inv = _read_inventories(cfg.raw_dir)
    prd = _read_production(cfg.raw_dir)
    ffr = _read_ffr(cfg.raw_dir)
    jet = _read_jetfuel(cfg.raw_dir)

    # intersection on Date (inner join across all)
    all_df = wti.merge(cpi, on="Date", how="inner")
    all_df = all_df.merge(ocse, on="Date", how="inner")
    all_df = all_df.merge(rea, on="Date", how="inner")
    all_df = all_df.merge(inv, on="Date", how="inner")
    all_df = all_df.merge(prd, on="Date", how="inner")
    all_df = all_df.merge(ffr, on="Date", how="inner")
    all_df = all_df.merge(jet, on="Date", how="inner")

    all_df = all_df[(all_df["Date"] >= start) & (all_df["Date"] <= end)].copy()
    all_df = all_df.sort_values("Date").reset_index(drop=True)

    # WTI real price
    all_df["WTI_real"] = (all_df["WTI"] / all_df["CPI"]) * 100.0
    all_df = all_df.drop(columns=["WTI"])

    # All_d (diffs + zscore), matching MATLAB columns
    # Note: MATLAB uses diff(log(...)) for positive series, diff(level) for cycles (OCSE/REA)
    d = pd.DataFrame({"Date": all_df["Date"].iloc[1:].values})
    d["WTI_real_DL"] = np.diff(np.log(all_df["WTI_real"].values))
    d["Production_DL"] = np.diff(np.log(all_df["Production"].values))
    d["OCSE_DL"] = np.diff(all_df["OCSE"].values)
    d["REA_DL"] = np.diff(all_df["REA"].values)
    d["Inventories_DL"] = np.diff(np.log(all_df["Inventories"].values))
    d["JetFuel_DL"] = np.diff(np.log(all_df["JetFuel_USGC"].values))

    d = d.dropna().reset_index(drop=True)
    zcols = [c for c in d.columns if c != "Date"]
    d[zcols] = _zscore(d[zcols])
    all_d = d.copy()

    # ALL_VAR (structural VAR dataset)
    all_df["WTI_log"] = np.log(all_df["WTI_real"])
    all_df["Prod_log"] = np.log(all_df["Production"])
    all_df["Inv_log"] = np.log(all_df["Inventories"])

    all_var = all_df[["Date", "OCSE", "Prod_log", "WTI_log", "Inv_log"]].copy()
    all_var = all_var.rename(columns={"OCSE": "OCSE_cycle"})

    # persist (parquet)
    all_df.to_parquet(cfg.processed_dir / "clean_data.parquet", index=False)
    all_d.to_parquet(cfg.processed_dir / "all_d.parquet", index=False)
    all_var.to_parquet(cfg.processed_dir / "all_var.parquet", index=False)

    return {"all": all_df, "all_d": all_d, "all_var": all_var}
