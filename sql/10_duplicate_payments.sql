-- 10_duplicate_payments.sql: potential duplicate payments
-- Different claim IDs with the same patient, provider, type, dates and amount.
-- Upper bound: some repeats (e.g. recurring visits) are legitimate.
SELECT COUNT(*) AS dup_groups,
       SUM(n - 1) AS extra_claims,
       SUM(paid * (n - 1)) AS potential_leakage
FROM (
  SELECT patient_id, provider_id, claim_type, from_dt, thru_dt,
         paid_amt AS paid, COUNT(*) AS n
  FROM claims_clean
  WHERE paid_amt > 0 AND from_dt IS NOT NULL
  GROUP BY patient_id, provider_id, claim_type, from_dt, thru_dt, paid_amt
  HAVING COUNT(*) > 1
) t;