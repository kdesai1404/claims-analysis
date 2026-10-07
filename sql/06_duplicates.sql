-- 06_duplicates.sql: duplicate claim keys in raw claims

-- 1. How many keys are duplicated, by claim type
SELECT claim_type,
       COUNT(*)                         AS duplicated_keys,
       SUM(n) - COUNT(*)                AS extra_rows
FROM (
    SELECT claim_id, claim_type, COUNT(*) AS n
    FROM claims
    GROUP BY claim_id, claim_type
    HAVING COUNT(*) > 1
) d
GROUP BY claim_type;

-- 2. Exact copies vs. different rows sharing a key
SELECT claim_type,
       COUNT(*) FILTER (WHERE distinct_rows = 1) AS exact_copies,
       COUNT(*) FILTER (WHERE distinct_rows > 1) AS differing_rows
FROM (
    SELECT claim_id, claim_type,
           COUNT(DISTINCT (patient_id, from_dt, thru_dt, provider_id, paid_amt, diagnosis)) AS distinct_rows
    FROM claims
    GROUP BY claim_id, claim_type
    HAVING COUNT(*) > 1
) d
GROUP BY claim_type;