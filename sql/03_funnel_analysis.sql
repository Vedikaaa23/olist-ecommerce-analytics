SELECT
  COUNT(DISTINCT session_id)                          AS visited,
  COUNT(DISTINCT CASE WHEN viewed_product  THEN session_id END) AS viewed,
  COUNT(DISTINCT CASE WHEN added_to_cart   THEN session_id END) AS carted,
  COUNT(DISTINCT CASE WHEN started_checkout THEN session_id END) AS checkout,
  COUNT(DISTINCT CASE WHEN purchased       THEN session_id END) AS purchased,
  -- Drop-off rates
  ROUND(viewed    * 100.0 / visited,  1) AS view_rate,
  ROUND(carted    * 100.0 / viewed,   1) AS cart_rate,
  ROUND(checkout  * 100.0 / carted,   1) AS checkout_rate,
  ROUND(purchased * 100.0 / checkout, 1) AS purchase_rate
FROM user_sessions;