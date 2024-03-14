--- Grouping Drilling Queries
SELECT
  b.product_category,
  c.year,
  c.quarter,
  c.month_name,
  SUM(a.order_amount)
FROM
  sales_order_fact a
JOIN
  product_dim b ON a.product_sk = b.product_sk
JOIN
  date_dim c ON a.order_date_sk = c.date_sk
GROUP BY
  b.product_category,
  c.year,
  c.quarter,
  c.month,
  c.month_name
ORDER BY
  b.product_category,
  c.year,
  c.quarter,
  c.month;

-- Drilling 
SELECT
  product_category,
  time,
  order_amount
FROM (
  (SELECT
    product_category,
    EXTRACT(YEAR FROM date) AS time,
    1 AS sequence,
    SUM(order_amount) AS order_amount
  FROM
    sales_order_fact a
  JOIN
    product_dim b ON a.product_sk = b.product_sk
  JOIN
    date_dim c ON a.order_date_sk = c.date_sk
  GROUP BY
    product_category,
    EXTRACT(YEAR FROM date)
  ORDER BY
    date)

  UNION ALL

  (SELECT
    product_category,
    EXTRACT(QUARTER FROM date) AS time,
    2 AS sequence,
    SUM(order_amount) AS order_amount
  FROM
    sales_order_fact a
  JOIN
    product_dim b ON a.product_sk = b.product_sk
  JOIN
    date_dim c ON a.order_date_sk = c.date_sk
  GROUP BY
    product_category,
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date)
  ORDER BY
    date) -- Assuming "date" column exists in date_dim table

  UNION ALL

  (SELECT
    product_category,
    month_name AS time,
    3 AS sequence,
    SUM(order_amount) AS order_amount
  FROM
    sales_order_fact a
  JOIN
    product_dim b ON a.product_sk = b.product_sk
  JOIN
    date_dim c ON a.order_date_sk = c.date_sk
  GROUP BY
    product_category,
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date),
    month_name
  ORDER BY
    date)
) x
ORDER BY
  product_category,
  time,
  sequence;