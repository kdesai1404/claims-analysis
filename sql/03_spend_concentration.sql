WITH patient_spend AS (
  SELECT patient_id, SUM(paid_amt) AS total
  FROM claims GROUP BY patient_id
),
ranked AS (
  SELECT *, NTILE(10) OVER (ORDER BY total DESC) AS decile
  FROM patient_spend
)
SELECT decile,
       COUNT(*) AS patients,
       SUM(total) AS spend,
       ROUND(100.0 * SUM(total) / SUM(SUM(total)) OVER (), 1) AS pct_of_total
FROM ranked
GROUP BY decile
ORDER BY decile;