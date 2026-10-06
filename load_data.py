import os
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

PASSWORD = os.environ["PGPASSWORD"]
DATA = "data"                # folder with the CSVs

engine = create_engine(URL.create(
    "postgresql+psycopg2", username="postgres", password=PASSWORD,
    host="localhost", port=5432, database="claims_analysis"))

def load(fname, table, cols, extra=None, first=True):
    path = None
    for root, _, files in os.walk(DATA):
        if fname in files:
            path = os.path.join(root, fname)
            break
    if path is None:
        print(f"SKIPPED (not found): {fname}")
        return

    df = pd.read_csv(path, usecols=cols, low_memory=False)
    if extra:
        for k, v in extra.items():
            df[k] = v
    df.to_sql(table, engine, if_exists="replace" if first else "append",
              index=False, chunksize=50000)
    print(f"Loaded {len(df):,} rows into {table} from {fname}")

bene_cols = ["DESYNPUF_ID", "BENE_BIRTH_DT", "BENE_SEX_IDENT_CD", "SP_STATE_CODE",
             "SP_DIABETES", "SP_CHF", "SP_CHRNKIDN", "SP_CNCR", "SP_COPD",
             "SP_DEPRESSN", "SP_ISCHMCHT", "SP_ALZHDMTA"]
for i, yr in enumerate((2008, 2009, 2010)):
    load(f"DE1_0_{yr}_Beneficiary_Summary_File_Sample_1.csv", "beneficiary",
         bene_cols, extra={"year": yr}, first=(i == 0))

load("DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv", "inpatient",
     ["DESYNPUF_ID", "CLM_ID", "CLM_FROM_DT", "CLM_THRU_DT", "PRVDR_NUM",
      "CLM_PMT_AMT", "CLM_UTLZTN_DAY_CNT", "CLM_DRG_CD", "ICD9_DGNS_CD_1"])

load("DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv", "outpatient",
     ["DESYNPUF_ID", "CLM_ID", "CLM_FROM_DT", "CLM_THRU_DT", "PRVDR_NUM",
      "CLM_PMT_AMT", "ICD9_DGNS_CD_1", "HCPCS_CD_1"])

print("Done.")