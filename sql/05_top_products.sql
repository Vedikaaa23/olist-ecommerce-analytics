SELECT
  p.product_category,
  COUNT(DISTINCT i.order_id)                         AS total_orders,
  SUM(i.price)                                        AS total_revenue,
  AVG(i.price)                                        AS avg_price,
  RANK() OVER (ORDER BY SUM(i.price) DESC)          AS revenue_rank,
  SUM(SUM(i.price)) OVER (
    ORDER BY SUM(i.price) DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )                                                   AS running_revenue,
  ROUND(SUM(i.price) * 100.0
    / SUM(SUM(i.price)) OVER (), 1)                  AS pct_of_total
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN orders o    ON i.order_id  = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category
ORDER BY revenue_rank
LIMIT 10;