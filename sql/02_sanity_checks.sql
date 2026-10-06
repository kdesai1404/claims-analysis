SELECT claim_type, COUNT(*) AS claims, SUM(paid_amt) AS total_paid
FROM claims GROUP BY 1;

SELECT COUNT(*) FILTER (WHERE paid_amt = 0) AS zero_paid,
       COUNT(*) FILTER (WHERE provider_id IS NULL) AS no_provider,
       COUNT(*) FILTER (WHERE diagnosis IS NULL) AS no_diagnosis
FROM claims;

SELECT MIN(from_dt), MAX(from_dt) FROM claims;

SELECT claim_id, COUNT(*) FROM claims GROUP BY 1 HAVING COUNT(*) > 1 LIMIT 5;