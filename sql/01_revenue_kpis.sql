SELECT
  DATE_TRUNC('month', o.order_purchase)   AS order_month,
  COUNT(DISTINCT o.order_id)                AS total_orders,
  SUM(i.price + i.freight_value)            AS total_revenue,
  AVG(i.price + i.freight_value)            AS avg_order_value,
  COUNT(DISTINCT o.customer_id)            AS unique_customers
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;