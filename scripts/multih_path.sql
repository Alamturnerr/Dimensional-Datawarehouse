ALTER TABLE month_dim
ADD campaign_session CHAR (30) AFTER month;

CREATE TABLE campaign_session_stg
( campaign_session CHAR (30,
month CHAR (9),
year INT);

-- TRUNCATE campaign_session_stg;
TRUNCATE TABLE campaign_session_stg;

-- COPY data from CSV file into campaign_session_stg table
COPY campaign_session_stg
FROM 'campaign_session.csv'
CSV HEADER;

-- UPDATE month_dim table based on data from campaign_session_stg
UPDATE month_dim a
SET campaign_session = b.campaign_session
FROM campaign_session_stg b
WHERE a.month = b.month
AND a.year = b.year;

SELECT
  product_category,
  time,
  SUM(order_amount) AS order_amount,
  SUM(order_quantity) AS order_quantity
FROM (
  (
    SELECT
      product_category,
      year,
      1 AS month,
      year AS time,
      1 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year
  )
  UNION ALL
  (
    SELECT
      product_category,
      year,
      month,
      quarter AS time,
      2 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year,
      quarter
  )
  UNION ALL
  (
    SELECT
      product_category,
      year,
      month,
      month_name AS time,
      3 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year,
      quarter,
      month
  )
) x
GROUP BY
  product_category,
  year,
  month,
  time
ORDER BY
  product_category,
  year,
  month,
  sequence;
SELECT
  pc AS product_category,
  time,
  amt AS order_amount,
  qty AS order_quantity
FROM (
  (
    SELECT
      product_category,
      year,
      1 AS month,
      year AS time,
      1 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a 
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year
  )
  UNION ALL
  (
    SELECT
      product_category,
      year,
      month,
      campaign_session AS time,
      2 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year,
      campaign_session,
      month
  )
  UNION ALL
  (
    SELECT
      product_category,
      year,
      month,
      month_name AS time,
      3 AS sequence,
      SUM(month_order_amount) AS order_amount,
      SUM(month_order_quantity) AS order_quantity
    FROM
      month_end_sales_order_fact a
      JOIN product_dim b ON a.product_sk = b.product_sk
      JOIN month_dim c ON a.month_order_sk = c.month_sk
    WHERE
      year = 2006
    GROUP BY
      product_category,
      year,
      campaign_session,
      month_name
  )
) x
ORDER BY
  product_category,
  year,
  month,
  sequence;
