WITH first_purchase AS (
  SELECT
    customer_id,
    MIN(DATE_TRUNC('month', order_purchase)) AS cohort_month
  FROM orders
  WHERE order_status = 'delivered'
  GROUP BY customer_id
),
subsequent AS (
  SELECT
    f.customer_id,
    f.cohort_month,
    DATEDIFF('month', f.cohort_month,
      DATE_TRUNC('month', o.order_purchase)) AS months_since
  FROM first_purchase f
  JOIN orders o ON f.customer_id = o.customer_id
  WHERE o.order_purchase > f.cohort_month
    AND o.order_status = 'delivered'
)
SELECT
  cohort_month,
  months_since,
  COUNT(DISTINCT customer_id)              AS retained_users,
  ROUND(COUNT(DISTINCT customer_id) * 100.0
    / cohort_sizes.cohort_size, 1)           AS retention_pct
FROM subsequent
JOIN (
  SELECT cohort_month, COUNT(*) cohort_size
  FROM first_purchase GROUP BY 1
) cohort_sizes USING (cohort_month)
GROUP BY 1, 2
ORDER BY 1, 2;