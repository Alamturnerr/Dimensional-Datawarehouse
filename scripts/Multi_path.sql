-- Multi Path Hierarchies
ALTER TABLE month_dim
ADD COLUMN campaign_session CHAR(30);
--
CREATE TABLE campaign_session_stg (
    campaign_session CHAR(30),
    month CHAR(9),
    year INT);
---- Kosongkan tabel 'campaign_session_stg'
TRUNCATE TABLE campaign_session_stg;

-- Memuat data dari file CSV ke tabel 'campaign_session_stg' menggunakan COPY
COPY campaign_session_stg (campaign_session, month, year)
FROM '/private/tmp/campaign_session_dataset.csv'
WITH CSV HEADER DELIMITER ',';

-- Melakukan pembaruan ke 'month_dim' berdasarkan data dari 'campaign_session_stg'
UPDATE month_dim a
SET campaign_session = b.campaign_session
FROM campaign_session_stg b
WHERE a.month::TEXT = b.month AND a.year = b.year;

--
SELECT month_sk, month_name, year, campaign_session
FROM month_dim
WHERE year = 2006
Order by month;
--
INSERT INTO month_end_sales_order_fact (month_order_sk, product_sk, month_order_amount, month_order_quantity)
SELECT
  b.month_sk,
  a.product_sk,
  SUM(order_amount),
  SUM(order_quantity)
FROM
  sales_order_fact a
JOIN month_dim b ON b.month = 3 AND b.year = 2007
JOIN order_date_dim d ON a.order_date_sk = d.order_date_sk AND b.month = EXTRACT(MONTH FROM d.order_date) AND b.year = EXTRACT(YEAR FROM d.order_date)
GROUP BY b.month_sk, b.year, a.product_sk
ON CONFLICT (month_order_sk) DO NOTHING;
--
SELECT b.month_name AS month, 
       b.year, 
       c.product_name,
       a.month_order_amount AS mo_amt, 
       a.month_order_quantity AS mo_qty
FROM month_end_sales_order_fact a
JOIN month_dim b ON a.month_order_sk = b.month_sk
JOIN product_dim c ON a.product_sk = c.product_sk
WHERE b.year = 2006
ORDER BY b.month_name, b.year, c.product_name;

-- 
SELECT
    product_category,
    time,
    order_amount,
    order_quantity
FROM (
    (SELECT
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
        year)
    
    UNION ALL
    
    (SELECT
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
        month,
        quarter)
    
    UNION ALL
    
    (SELECT
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
        month,
        month_name)
) x
ORDER BY
    product_category,
    year,
    month,
    sequence;

