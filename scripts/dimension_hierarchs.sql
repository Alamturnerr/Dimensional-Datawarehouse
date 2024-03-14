-- Dimension Hierarchies
SELECT
  b.product_category,
  c.year,
  c.quarter,
  c.month_name,
  SUM(a.order_amount) AS total_order_amount
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
  c.month_name,
  c.month  -- Tambahkan c.month ke dalam GROUP BY
ORDER BY
  b.product_category,
  c.year,
  c.quarter,
  c.month;
-- Drilling Queries 
SELECT
    product_category,
    time,
    order_amount
FROM (
    (SELECT
        product_category,
        date,
        EXTRACT(YEAR FROM date) AS time,
        1 AS sequence,
        SUM(order_amount) AS order_amount
    FROM
        sales_order_fact a
    JOIN product_dim b ON a.product_sk = b.product_sk
    JOIN date_dim c ON a.order_date_sk = c.date_sk
    GROUP BY
        product_category,
        EXTRACT(YEAR FROM date)
    ORDER BY date)
    
    UNION ALL
    
    (SELECT
        product_category,
        date,
        EXTRACT(QUARTER FROM date) AS time,
        2 AS sequence,
        SUM(order_amount) AS order_amount
    FROM
        sales_order_fact a
    JOIN product_dim b ON a.product_sk = b.product_sk
    JOIN date_dim c ON a.order_date_sk = c.date_sk
    GROUP BY
        product_category,
        EXTRACT(YEAR FROM date),
        EXTRACT(QUARTER FROM date)
    ORDER BY date)
    
    UNION ALL
    
    (SELECT
        product_category,
        date,
        TO_CHAR(date, 'Month') AS time,
        3 AS sequence,
        SUM(order_amount) AS order_amount
    FROM
        sales_order_fact a
    JOIN product_dim b ON a.product_sk = b.product_sk
    JOIN date_dim c ON a.order_date_sk = c.date_sk
    GROUP BY
        product_category,
        EXTRACT(YEAR FROM date),
        EXTRACT(QUARTER FROM date),
        TO_CHAR(date, 'Month')
    ORDER BY date)
) x
ORDER BY
    product_category,
    date,
    sequence,
    time;

