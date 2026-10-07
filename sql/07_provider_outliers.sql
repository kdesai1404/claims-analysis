DROP TABLE IF EXISTS provider_outliers;

CREATE TABLE provider_outliers AS
WITH base AS (
  SELECT provider_id, claim_type, diagnosis, paid_amt
  FROM claims_clean
  WHERE paid_amt > 0 AND diagnosis IS NOT NULL
),
peer AS (
  SELECT claim_type, diagnosis, AVG(paid_amt) AS peer_avg,
         STDDEV(paid_amt) AS peer_sd
  FROM base GROUP BY 1, 2 HAVING COUNT(*) >= 30
),
prov AS (
  SELECT provider_id, claim_type, diagnosis,
         COUNT(*) AS claims, AVG(paid_amt) AS prov_avg
  FROM base GROUP BY 1, 2, 3 HAVING COUNT(*) >= 5
)
SELECT p.provider_id, p.claim_type, p.diagnosis, p.claims,
       ROUND(p.prov_avg::numeric, 0) AS prov_avg,
       ROUND(e.peer_avg::numeric, 0) AS peer_avg,
       ROUND(((p.prov_avg - e.peer_avg)
              / NULLIF(e.peer_sd / SQRT(p.claims), 0))::numeric, 1) AS z,
       ROUND(((p.prov_avg - e.peer_avg) * p.claims)::numeric, 0) AS excess_paid
FROM prov p JOIN peer e USING (claim_type, diagnosis);

SELECT COUNT(*) AS flagged_provider_dx,
       SUM(excess_paid) AS est_review_opportunity,
       ROUND(100.0 * SUM(excess_paid) / (SELECT SUM(paid_amt) FROM claims_clean), 2) AS pct_of_total_spend
FROM provider_outliers
WHERE z >= 3 AND excess_paid > 0;