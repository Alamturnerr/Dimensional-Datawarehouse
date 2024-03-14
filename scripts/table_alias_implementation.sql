-- Table Alias Implemantation
SELECT
  order_date_dim.date AS order_date,
  request_delivery_date_dim.date AS request_delivery_date,
  SUM(order_amount) AS total_order_amount,
  COUNT(*) AS order_count
FROM
  sales_order_fact a
JOIN
  date_dim order_date_dim ON a.order_date_sk = order_date_dim.date_sk
JOIN
  date_dim request_delivery_date_dim ON a.request_delivery_date_sk = request_delivery_date_dim.date_sk
GROUP BY
  order_date_dim.date,
  request_delivery_date_dim.date
ORDER BY
  order_date_dim.date,
  request_delivery_date_dim.date;
