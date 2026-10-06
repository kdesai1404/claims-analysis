DROP TABLE IF EXISTS claims;

CREATE TABLE claims AS
SELECT "DESYNPUF_ID" AS patient_id, "CLM_ID"::text AS claim_id, 'IP' AS claim_type,
       TO_DATE("CLM_FROM_DT"::bigint::text,'YYYYMMDD') AS from_dt,
       TO_DATE("CLM_THRU_DT"::bigint::text,'YYYYMMDD') AS thru_dt,
       "PRVDR_NUM" AS provider_id, "CLM_PMT_AMT" AS paid_amt,
       "ICD9_DGNS_CD_1" AS diagnosis
FROM inpatient
UNION ALL
SELECT "DESYNPUF_ID", "CLM_ID"::text, 'OP',
       TO_DATE("CLM_FROM_DT"::bigint::text,'YYYYMMDD'),
       TO_DATE("CLM_THRU_DT"::bigint::text,'YYYYMMDD'),
       "PRVDR_NUM", "CLM_PMT_AMT", "ICD9_DGNS_CD_1"
FROM outpatient;

ALTER TABLE claims ALTER COLUMN paid_amt TYPE numeric(14,2) USING paid_amt::numeric;
