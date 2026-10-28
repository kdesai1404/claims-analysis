SELECT month, claims, total_paid,
       ROUND(100.0 * (total_paid - LAG(total_paid) OVER (ORDER BY month))
             / NULLIF(LAG(total_paid) OVER (ORDER BY month), 0), 1) AS mom_pct
FROM (
  SELECT DATE_TRUNC('month', from_dt)::date AS month,
         COUNT(*) AS claims, SUM(paid_amt) AS total_paid
  FROM claims_clean
  WHERE from_dt >= '2008-01-01'
  GROUP BY 1
) m
ORDER BY month;

\copy (SELECT DATE_TRUNC('month', from_dt)::date AS month, claim_type, COUNT(*) AS claims, SUM(paid_amt) AS total_paid, ROUND(AVG(paid_amt), 0) AS avg_paid FROM claims_clean WHERE from_dt >= '2008-01-01' GROUP BY 1, 2 ORDER BY 1, 2) TO 'C:/Users/idesa/OneDrive/Desktop/claims-analysis/exports/monthly_trend.csv' CSV HEADER