DROP TABLE IF EXISTS claims_clean;

CREATE TABLE claims_clean AS
SELECT DISTINCT ON (claim_id, claim_type)
       patient_id, claim_id, claim_type, from_dt, thru_dt, provider_id,
       SUM(paid_amt) OVER (PARTITION BY claim_id, claim_type) AS paid_amt,
       diagnosis
FROM claims
ORDER BY claim_id, claim_type, from_dt NULLS LAST;

SELECT COUNT(*) AS claims, SUM(paid_amt) AS total_paid FROM claims_clean;