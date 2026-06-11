WITH rfm_base AS (
  SELECT
    customer_id,
    DATEDIFF('day', MAX(order_purchase), CURRENT_DATE) AS recency,
    COUNT(order_id)                                       AS frequency,
    SUM(total_amount)                                     AS monetary
  FROM orders
  WHERE order_status = 'delivered'
  GROUP BY customer_id
),
rfm_scores AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency  DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC)  AS f_score,
    NTILE(5) OVER (ORDER BY monetary  ASC)  AS m_score
  FROM rfm_base
)
SELECT *,
  CASE
    WHEN r_score >= 4 AND f_score >= 4              THEN 'Champions'
    WHEN f_score >= 3 AND r_score >= 3              THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score < 3              THEN 'Potential Loyalists'
    WHEN r_score >= 4                               THEN 'New Customers'
    WHEN r_score < 3 AND f_score >= 3              THEN 'At-Risk'
    ELSE 'Lost Customers'
  END AS segment
FROM rfm_scores;