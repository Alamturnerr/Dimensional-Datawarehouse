-- Insert data ke tabel order_dim
INSERT INTO order_dim VALUES
  (DEFAULT, 11, '2007-02-06', '9999-12-31'),
  (DEFAULT, 12, '2007-02-06', '9999-12-31'),
  (DEFAULT, 13, '2007-02-06', '9999-12-31'),
  (DEFAULT, 14, '2007-02-06', '9999-12-31'),
  (DEFAULT, 15, '2007-02-06', '9999-12-31'),
  (DEFAULT, 16, '2007-02-06', '9999-12-31');

-- Insert data ke tabel date_dim
INSERT INTO date_dim (date_sk, date, month_name, month, quarter, year, effective_date, expiry_date)
VALUES
  (DEFAULT, '2007-02-01', 'February', 2, 1, 2007, '2007-02-05', '9999-12-31'),
  (DEFAULT, '2007-11-06', 'November', 11, 4, 2007, '2007-02-05', '9999-12-31');

select * from date_dim

-- Insert data ke tabel sales_order_fact
INSERT INTO sales_order_fact VALUES
  (11, 1, 2, 2, 20000),
  (12, 2, 3, 2, 25000),
  (13, 3, 4, 2, 30000),
  (14, 4, 2, 2, 35000),
  (15, 5, 3, 2, 40000),
  (16, 1, 4, 2, 45000);

--
SELECT
  date, 
  SUM (order_amount) ,COUNT(*)
FROM sales_order_fact a, date_dim b
WHERE a.order_date_sk = b.date_sk
GROUP BY date
ORDER BY sum;

--
SELECT year, product_name, customer_city, SUM (order_amount),
  COUNT(*)
FROM
  sales_order_fact a, 
  date_dim b,
  product_dim c, 
  customer_dim d
WHERE a.order_date_sk = b.date_sk
AND a.product_sk = c.product_sk
AND a.customer_sk = d.customer_sk
GROUP BY year, product_name, customer_city
ORDER BY year, product_name, customer_city;

--
SELECT
  product_name, 
  month_name,
  year,
  SUM (order_amount),
  COUNT(*)
FROM
  sales_order_fact a, 
  product_dim b, 
  date_dim c
WHERE a.product_sk = b.product_sk
AND a.order_date_sk = c.date_sk
GROUP BY
  product_name,
  product_category,
  month_name,
  year
HAVING product_category = 'Storage'
ORDER BY
  count;
  
--
SELECT
  customer_city,
  quarter,
  year,
  SUM (order_amount),
  COUNT (order_sk)
FROM
  sales_order_fact a,
  customer_dim b,
  date_dim c
WHERE
    a.customer_sk = b.customer_sk
AND a.order_date_sk = c.date_sk
GROUP BY
  customer_city,
  quarter,
  year
HAVING customer_city = 'Mechanicsburg'
ORDER BY
  year,
  quarter;

--
SELECT
    month_name,
    year,
    product_name,
    SUM(order_amount) AS total_order_amount,
    COUNT(*) AS total_orders
FROM
    sales_order_fact a
JOIN
    product_dim b ON a.product_sk = b.product_sk
JOIN
    date_dim c ON a.order_date_sk = c.date_sk
GROUP BY
    month_name,
    year,
    product_name
HAVING
    SUM(order_amount) >= 75000
ORDER BY
    month_name,
    year,
    product_name;

--
SELECT
    customer_number,
    year,
    COUNT(*) AS total_orders
FROM
    sales_order_fact a
JOIN
    customer_dim b ON a.customer_sk = b.customer_sk
JOIN
    date_dim c ON a.order_date_sk = c.date_sk
GROUP BY
    customer_number,
    year
HAVING
    COUNT(*) > 3
    AND (12 - EXTRACT(MONTH FROM MAX(c.date))) < 7;

