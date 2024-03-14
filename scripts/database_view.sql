CREATE VIEW order_date_dim AS
SELECT
  date_sk AS order_date_sk,
  date AS order_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;

CREATE VIEW request_delivery_date_dim AS
SELECT
  date_sk AS request_delivery_date_sk,
  date AS request_delivery_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;

SELECT
  b.order_date,
  c.request_delivery_date,
  SUM(a.order_amount),
  COUNT(*)
FROM
  sales_order_fact a
JOIN order_date_dim b ON a.order_date_sk = b.order_date_sk
JOIN request_delivery_date_dim c ON a.request_delivery_date_sk = c.request_delivery_date_sk
GROUP BY
  b.order_date,
  c.request_delivery_date
ORDER BY
  b.order_date,
  c.request_delivery_date;
