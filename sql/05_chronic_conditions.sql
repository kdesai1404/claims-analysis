WITH pat AS (
  SELECT patient_id, SUM(paid_amt) AS spend
  FROM claims_clean
  WHERE EXTRACT(YEAR FROM from_dt) = 2009
  GROUP BY patient_id
),
c AS (
  SELECT "DESYNPUF_ID" AS patient_id,
         ("SP_DIABETES"=1)::int + ("SP_CHF"=1)::int + ("SP_CHRNKIDN"=1)::int
       + ("SP_CNCR"=1)::int + ("SP_COPD"=1)::int + ("SP_DEPRESSN"=1)::int
       + ("SP_ISCHMCHT"=1)::int + ("SP_ALZHDMTA"=1)::int AS n_cond
  FROM beneficiary WHERE year = 2009
)
SELECT n_cond, COUNT(*) AS patients,
       ROUND(AVG(COALESCE(p.spend, 0)), 0) AS avg_spend
FROM c LEFT JOIN pat p USING (patient_id)
GROUP BY n_cond ORDER BY n_cond;