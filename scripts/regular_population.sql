-- Testing Data Prepare

INSERT INTO sales_order VALUES
  (22, 1, 1, '2007-03-01', '2007-03-01', 1000),
  (23, 2, 2, '2007-03-01', '2007-03-01', 2000),
  (24, 3, 3, '2007-03-01', '2007-03-01', 3000),
  (25, 4, 4, '2007-03-01', '2007-03-01', 4000),
  (26, 5, 2, '2007-03-01', '2007-03-01', 1000),
  (27, 6, 2, '2007-03-01', '2007-03-01', 3000),
  (28, 7, 3, '2007-03-01', '2007-03-01', 5000),
  (29, 8, 4, '2007-03-01', '2007-03-01', 7000),
  (30, 1, 1, '2007-03-01', '2007-03-01', 1000),
  (31, 2, 2, '2007-03-01', '2007-03-01', 2000),
  (32, 3, 3, '2007-03-01', '2007-03-01', 4000),
  (33, 4, 4, '2007-03-01', '2007-03-01', 6000),
  (34, 5, 1, '2007-03-01', '2007-03-01', 2500),
  (35, 6, 2, '2007-03-01', '2007-03-01', 5000),
  (36, 7, 3, '2007-03-01', '2007-03-01', 7500),
  (37, 8, 4, '2007-03-01', '2007-03-01', 1000);


-- Regular Population

-- Truncate staging table
TRUNCATE TABLE customer_stg;

-- Load data into staging table
COPY customer_stg(customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state)
FROM 'customer.csv' DELIMITER ',' CSV HEADER;

-- SCD2 on customer street addresses

-- Expire existing customers
UPDATE customer_dim a
SET expiry_date = CURRENT_DATE - INTERVAL '1 day'
FROM customer_stg b
WHERE a.customer_number = b.customer_number
AND a.customer_street_address <> b.customer_street_address
AND expiry_date = '9999-12-31';

-- Add a new row for the customer
INSERT INTO customer_dim
SELECT
  NULL,
  b.customer_number,
  b.customer_name,
  b.customer_street_address,
  b.customer_zip_code,
  b.customer_city,
  b.customer_state,
  CURRENT_DATE,
  '9999-12-31'
FROM
  customer_dim a
JOIN customer_stg b ON a.customer_number = b.customer_number
WHERE a.customer_street_address <> b.customer_street_address
AND NOT EXISTS (
  SELECT 1
  FROM customer_dim x
  WHERE x.customer_number = b.customer_number
  AND a.expiry_date = CURRENT_DATE - INTERVAL '1 day'
)
AND NOT EXISTS (
  SELECT 1
  FROM customer_dim y
  WHERE y.customer_number = b.customer_number
  AND y.expiry_date = '9999-12-31'
);

-- SCD1 on customer name

UPDATE customer_dim a
SET customer_name = b.customer_name
FROM customer_stg b
WHERE a.customer_number = b.customer_number
AND a.customer_name <> b.customer_name;

-- Add new customers

INSERT INTO customer_dim
SELECT
  NULL,
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state,
  CURRENT_DATE,
  '9999-12-31'
FROM customer_stg
WHERE customer_number NOT IN (
  SELECT customer_number
  FROM customer_dim
);
-- SCD2 on product name and group

-- Expire the existing products
UPDATE product_dim a
SET expiry_date = CURRENT_DATE - INTERVAL '1 day'
FROM product_stg b
WHERE a.product_code = b.product_code
AND (a.product_name <> b.product_name OR a.product_category <> b.product_category)
AND expiry_date = '9999-12-31';

-- Add a new row for the products
INSERT INTO product_dim
SELECT
  NULL,
  b.product_code,
  b.product_name,
  b.product_category,
  CURRENT_DATE,
  '9999-12-31'
FROM product_dim a
JOIN product_stg b ON a.product_code = b.product_code
WHERE (a.product_name <> b.product_name OR a.product_category <> b.product_category)
AND NOT EXISTS (
  SELECT 1
  FROM product_dim x
  WHERE b.product_code = x.product_code
  AND a.expiry_date = CURRENT_DATE - INTERVAL '1 day'
)
AND NOT EXISTS (
  SELECT 1
  FROM product_dim y
  WHERE b.product_code = y.product_code
  AND y.expiry_date = '9999-12-31'
);

-- Add new products
INSERT INTO product_dim
SELECT
  NULL,
  product_code,
  product_name,
  product_category,
  CURRENT_DATE,
  '9999-12-31'
FROM product_stg
WHERE product_code NOT IN (
  SELECT product_code
  FROM product_dim
);

-- End of product_dim loading

-- Insert into order_dim
INSERT INTO order_dim (
  order_sk,
  order_number,
  effective_date,
  expiry_date
)
SELECT
  NULL,
  order_number,
  order_date,
  '9999-12-31'
FROM source.sales_order
WHERE entry_date = CURRENT_DATE;

-- Insert into sales_order_fact
INSERT INTO sales_order_fact
SELECT
  b.order_sk,
  c.customer_sk,
  d.product_sk,
  e.date_sk,
  a.order_amount
FROM
  source.sales_order a
JOIN order_dim b ON a.order_number = b.order_number
JOIN customer_dim c ON a.customer_number = c.customer_number
JOIN product_dim d ON a.product_code = d.product_code
JOIN date_dim e ON a.order_date = e.date
WHERE a.entry_date = CURRENT_DATE;
