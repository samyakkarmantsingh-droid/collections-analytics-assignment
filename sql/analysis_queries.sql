-- ============================================================
-- COLLECTIONS ANALYTICS - SQL ANALYSIS
-- ============================================================
-- Purpose:
-- 1. Clean duplicate payment records
-- 2. Reconstruct successful recovery
-- 3. Calculate monthly recovery and MoM change
-- 4. Investigate payment duplication
-- 5. Analyse recovery by loan type, risk and DPD
-- 6. Analyse collection activity
-- 7. Analyse payment methods
-- ============================================================


-- ============================================================
-- 1. MONTHLY SUCCESSFUL RECOVERY
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    DATE_FORMAT(event_at, '%Y-%m') AS month,
    ROUND(SUM(amount), 2) AS successful_recovery,
    COUNT(DISTINCT account_id) AS recovered_accounts,
    COUNT(DISTINCT payment_id) AS successful_payments
FROM payments_clean
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_FORMAT(event_at, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 2. MONTHLY RECOVERY MoM CHANGE
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
),

monthly AS (
    SELECT
        DATE_FORMAT(event_at, '%Y-%m') AS month,
        SUM(amount) AS recovery
    FROM payments_clean
    WHERE payment_status = 'SUCCESS'
    GROUP BY DATE_FORMAT(event_at, '%Y-%m')
)

SELECT
    month,
    ROUND(recovery, 2) AS recovery,
    ROUND(
        (
            recovery /
            LAG(recovery) OVER (ORDER BY month)
            - 1
        ) * 100,
        2
    ) AS mom_change_pct
FROM monthly
ORDER BY month;


-- ============================================================
-- 3. DUPLICATE PAYMENT ID INVESTIGATION
-- ============================================================

SELECT
    payment_id,
    COUNT(*) AS record_count,
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ),
        2
    ) AS successful_value
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- ============================================================
-- 4. TOTAL DUPLICATE PAYMENT IMPACT
-- ============================================================

WITH payment_counts AS (
    SELECT
        payment_id,
        COUNT(*) AS record_count
    FROM payments
    GROUP BY payment_id
),

payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    COUNT(*) AS duplicate_payment_ids,
    SUM(record_count - 1) AS extra_payment_records
FROM payment_counts
WHERE record_count > 1;


-- ============================================================
-- 5. RECOVERY BY LOAN TYPE
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    a.loan_type,
    ROUND(SUM(p.amount), 2) AS recovery,
    COUNT(DISTINCT p.account_id) AS recovered_accounts,
    COUNT(DISTINCT p.payment_id) AS payments,
    ROUND(
        SUM(p.amount) * 100.0 /
        SUM(SUM(p.amount)) OVER (),
        2
    ) AS share_pct
FROM payments_clean p
JOIN accounts a
    ON p.account_id = a.account_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY a.loan_type
ORDER BY recovery DESC;


-- ============================================================
-- 6. RECOVERY BY RISK SEGMENT
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    a.risk_segment,
    ROUND(SUM(p.amount), 2) AS recovery,
    COUNT(DISTINCT p.account_id) AS recovered_accounts,
    COUNT(DISTINCT p.payment_id) AS payments,
    ROUND(
        SUM(p.amount) * 100.0 /
        SUM(SUM(p.amount)) OVER (),
        2
    ) AS share_pct
FROM payments_clean p
JOIN accounts a
    ON p.account_id = a.account_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY a.risk_segment
ORDER BY recovery DESC;


-- ============================================================
-- 7. RECOVERY BY DPD BAND
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    CASE
        WHEN a.dpd = 0 THEN '0'
        WHEN a.dpd <= 30 THEN '1-30'
        WHEN a.dpd <= 60 THEN '31-60'
        WHEN a.dpd <= 90 THEN '61-90'
        WHEN a.dpd <= 180 THEN '91-180'
        ELSE '180+'
    END AS dpd_band,

    ROUND(SUM(p.amount), 2) AS recovery,
    COUNT(DISTINCT p.account_id) AS recovered_accounts,
    COUNT(DISTINCT p.payment_id) AS payments

FROM payments_clean p
JOIN accounts a
    ON p.account_id = a.account_id

WHERE p.payment_status = 'SUCCESS'

GROUP BY
    CASE
        WHEN a.dpd = 0 THEN '0'
        WHEN a.dpd <= 30 THEN '1-30'
        WHEN a.dpd <= 60 THEN '31-60'
        WHEN a.dpd <= 90 THEN '61-90'
        WHEN a.dpd <= 180 THEN '91-180'
        ELSE '180+'
    END

ORDER BY recovery DESC;


-- ============================================================
-- 8. RECOVERY BY PAYMENT METHOD
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
)

SELECT
    payment_method,
    ROUND(SUM(amount), 2) AS recovery,
    COUNT(DISTINCT account_id) AS recovered_accounts,
    COUNT(DISTINCT payment_id) AS successful_payments,
    ROUND(
        SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (),
        2
    ) AS share_pct
FROM payments_clean
WHERE payment_status = 'SUCCESS'
GROUP BY payment_method
ORDER BY recovery DESC;


-- ============================================================
-- 9. CALL ACTIVITY BY MONTH
-- ============================================================

SELECT
    DATE_FORMAT(event_at, '%Y-%m') AS month,
    COUNT(*) AS calls,
    COUNT(DISTINCT account_id) AS contacted_accounts,
    COUNT(DISTINCT agent_id) AS active_agents
FROM calls
GROUP BY DATE_FORMAT(event_at, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 10. CALL STATUS DISTRIBUTION
-- ============================================================

SELECT
    call_status,
    COUNT(*) AS calls,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM calls
GROUP BY call_status
ORDER BY calls DESC;


-- ============================================================
-- 11. CALL ATTEMPTS BY MONTH
-- ============================================================

SELECT
    DATE_FORMAT(event_at, '%Y-%m') AS month,
    COUNT(*) AS attempts,
    COUNT(DISTINCT account_id) AS attempted_accounts,
    COUNT(DISTINCT agent_id) AS active_agents
FROM call_attempts
GROUP BY DATE_FORMAT(event_at, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 12. CALLS VS SUCCESSFUL RECOVERY
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
),

monthly_recovery AS (
    SELECT
        DATE_FORMAT(event_at, '%Y-%m') AS month,
        SUM(amount) AS recovery
    FROM payments_clean
    WHERE payment_status = 'SUCCESS'
    GROUP BY DATE_FORMAT(event_at, '%Y-%m')
),

monthly_calls AS (
    SELECT
        DATE_FORMAT(event_at, '%Y-%m') AS month,
        COUNT(*) AS calls
    FROM calls
    GROUP BY DATE_FORMAT(event_at, '%Y-%m')
)

SELECT
    COALESCE(r.month, c.month) AS month,
    ROUND(COALESCE(r.recovery, 0), 2) AS recovery,
    COALESCE(c.calls, 0) AS calls
FROM monthly_recovery r
LEFT JOIN monthly_calls c
    ON r.month = c.month

UNION

SELECT
    c.month,
    ROUND(COALESCE(r.recovery, 0), 2) AS recovery,
    c.calls
FROM monthly_calls c
LEFT JOIN monthly_recovery r
    ON c.month = r.month

ORDER BY month;


-- ============================================================
-- 13. ACCOUNT-LEVEL RECOVERY RATE
-- ============================================================

WITH payments_clean AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at DESC
            ) AS rn
        FROM payments p
    ) x
    WHERE rn = 1
),

account_recovery AS (
    SELECT
        account_id,
        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount
    FROM payments_clean
    GROUP BY account_id
)

SELECT
    ROUND(
        SUM(ar.recovered_amount) * 100.0 /
        SUM(a.outstanding_amount),
        2
    ) AS recovery_to_outstanding_pct
FROM accounts a
LEFT JOIN account_recovery ar
    ON a.account_id = ar.account_id;


-- ============================================================
-- 14. BASIC GOLDEN DATASET VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT account_id) AS unique_accounts
FROM accounts;


-- ============================================================
-- 15. DATA QUALITY - ACCOUNT/BORROWER DUPLICATION
-- ============================================================

SELECT
    borrower_id,
    COUNT(*) AS account_count
FROM accounts
GROUP BY borrower_id
HAVING COUNT(*) > 1
ORDER BY account_count DESC;


-- ============================================================
-- 16. DATA QUALITY - STATUS TIMESTAMP CONFLICT
-- ============================================================

SELECT
    COUNT(*) AS total_status_records,

    SUM(
        CASE
            WHEN recorded_at < event_at
            THEN 1
            ELSE 0
        END
    ) AS timestamp_conflicts,

    ROUND(
        SUM(
            CASE
                WHEN recorded_at < event_at
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS conflict_pct

FROM account_status_history;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================