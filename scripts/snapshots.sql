-- SnapshotS

-- Adding new fact table
CREATE TABLE month_end_sales_order_fact (
    month_order_sk SERIAL PRIMARY KEY,
    product_sk INT,
    month_order_amount DECIMAL(10,2),
    month_order_quantity INT);

--
INSERT INTO month_end_sales_order_fact (month_order_sk, product_sk, month_order_amount, month_order_quantity)
SELECT
  b.month_sk,
  a.product_sk,
  SUM(a.order_amount),
  SUM(a.order_quantity)
FROM
  sales_order_fact a
INNER JOIN date_dim d ON a.order_date_sk = d.date_sk
INNER JOIN month_dim b ON b.month = EXTRACT(MONTH FROM d.date) AND b.year = EXTRACT(YEAR FROM d.date)
WHERE
  b.month = 2
  AND b.year = 2007
GROUP BY
  b.month_sk,
  a.product_sk;

select * from month_end_sales_order_fact
--
-- Mengubah tipe data kolom order_date menjadi status_date dan menambahkan kolom order_status
ALTER TABLE sales_order
  RENAME COLUMN order_date TO status_date;

ALTER TABLE sales_order
  ADD COLUMN order_status CHAR(1);

-- Mengubah tipe data kolom order_quantity menjadi INT
ALTER TABLE sales_order
  ALTER COLUMN order_quantity TYPE INT;

--
ALTER TABLE sales_order_fact
  ADD COLUMN allocate_date_sk INT,
  ADD COLUMN allocate_quantity INT,
  ADD COLUMN packing_date_sk INT,
  ADD COLUMN packing_quantity INT,
  ADD COLUMN ship_date_sk INT,
  ADD COLUMN ship_quantity INT,
  ADD COLUMN receive_date_sk INT,
  ADD COLUMN receive_quantity INT;
-- Creating View
CREATE VIEW allocate_date_dim (
  allocate_date_sk,
  allocate_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
)
AS 
SELECT
  date_sk,
  date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;

CREATE VIEW packing_date_dim (
  packing_date_sk,
  packing_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
)
AS 
SELECT
  date_sk,
  date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;

CREATE VIEW ship_date_dim (
  ship_date_sk,
  ship_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
)
AS 
SELECT
  date_sk,
  date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;

CREATE VIEW receive_date_dim (
  receive_date_sk,
  receive_date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
)
AS 
SELECT
  date_sk,
  date,
  month_name,
  month,
  quarter,
  year,
  promo_ind,
  effective_date,
  expiry_date
FROM date_dim;
-- Step 1
INSERT INTO sales_order VALUES
 (50, 1, 1, '2007-03-05', '2007-03-10', 7500, 75, '2007-03-05', 'N'),
 (51, 2, 2, '2007-03-05', '2007-03-10', 1000, 10, '2007-03-05', 'N');
-- Step 2
SELECT 
    order_number, 
    a.order_date_sk, 
    allocate_date_sk,
    packing_date_sk, 
    ship_date_sk, 
    receive_date_sk
FROM 
    sales_order_fact a, 
    order_dim b, 
    date_dim c
WHERE 
    order_number IN (50, 51)
    AND a.order_sk = b.order_sk
    AND a.order_date_sk = date_sk
-- Step 3
INSERT INTO sales_order VALUES
  (50, 1, 1, '2007-03-06', '2007-03-10', 7500, 75, '2007-03-06', 'A'),
  (50, 1, 1, '2007-03-06', '2007-03-10', 7500, 75, '2007-03-06', 'P'),
  (51, 2, 2, '2007-03-06', '2007-03-10', 1000, 10, '2007-03-06', 'A');
-- Step 4
INSERT INTO sales_order VALUES
  (50, 1, 1, '2007-03-07', '2007-03-10', 7500, 75, '2007-03-07', 'S'),
  (50, 1, 1, '2007-03-07', '2007-03-10', 7500, 75, '2007-03-07', 'R'),
  (51, 2, 2, '2007-03-07', '2007-03-10', 1000, 10, '2007-03-07', 'P');
-- Revised Populat
-- Clear Data
TRUNCATE TABLE customer_stg;
-- Load Data
COPY customer_stg (
    customer_number,
    customer_name,
    customer_street_address,
    customer_zip_code,
    customer_city,
    customer_state,
    shipping_address,
    shipping_zip_code,
    shipping_city,
    shipping_state
) FROM '/private/tmp/adding_column_dataset.csv' DELIMITER ',' CSV HEADER;

-- SCD 2 ON ADDRESSES
UPDATE customer_dim AS a
SET expiry_date = '2007-03-01'
FROM customer_stg AS b
WHERE a.customer_number = b.customer_number
AND (
    a.customer_street_address <> b.customer_street_address
    OR a.customer_city <> b.customer_city
    OR a.customer_zip_code <> b.customer_zip_code
    OR a.customer_state <> b.customer_state
    OR a.shipping_address <> b.shipping_address
    OR a.shipping_city <> b.shipping_city
    OR a.shipping_zip_code <> b.shipping_zip_code
    OR a.shipping_state <> b.shipping_state
    OR a.shipping_address IS NULL
    OR a.shipping_city IS NULL
    OR a.shipping_zip_code IS NULL
    OR a.shipping_state IS NULL
)
AND a.expiry_date = '9999-12-31';

-- INSERT INTO customer_dim
INSERT INTO customer_dim (customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state, effective_date, expiry_date, shipping_address, shipping_zip_code, shipping_city, shipping_state)
SELECT
  b.customer_number,
  b.customer_name,
  b.customer_street_address,
  b.customer_zip_code,
  b.customer_city,
  b.customer_state,
  '2007-03-04',
  '9999-12-31',
  b.shipping_address,
  b.shipping_zip_code,
  b.shipping_city,
  b.shipping_state
FROM
  customer_dim AS a
JOIN
  customer_stg AS b ON a.customer_number = b.customer_number
WHERE
  (
    a.customer_street_address <> b.customer_street_address
    OR a.customer_city <> b.customer_city
    OR a.customer_zip_code <> b.customer_zip_code
    OR a.customer_state <> b.customer_state
    OR a.shipping_address <> b.shipping_address
    OR a.shipping_city <> b.shipping_city
    OR a.shipping_zip_code <> b.shipping_zip_code
    OR a.shipping_state <> b.shipping_state
    OR a.shipping_address IS NULL
    OR a.shipping_city IS NULL
    OR a.shipping_zip_code IS NULL
    OR a.shipping_state IS NULL
  )
AND EXISTS (
  SELECT 1
  FROM customer_dim AS x
  WHERE b.customer_number = x.customer_number
  AND a.expiry_date = '2007-03-01'
)
AND NOT EXISTS (
  SELECT 1
  FROM customer_dim AS y
  WHERE b.customer_number = y.customer_number
  AND y.expiry_date = '9999-12-31'
);
-- END OF SCD 2

-- SCD 1 ON NAME

UPDATE customer_dim AS a
SET customer_name = b.customer_name
FROM customer_stg AS b
WHERE a.customer_number = b.customer_number
AND a.expiry_date = '9999-12-31'
AND a.customer_name <> b.customer_name;

-- ADD NEW CUSTOMER
INSERT INTO customer_dim (customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state, effective_date, expiry_date, shipping_address, shipping_zip_code, shipping_city, shipping_state)
SELECT
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state,
  '2007-03-024',
  '9999-12-31',
  shipping_address,
  shipping_zip_code,
  shipping_city,
  shipping_state
FROM customer_stg
WHERE customer_number NOT IN (
  SELECT a.customer_number
  FROM customer_dim a
  JOIN customer_stg b ON b.customer_number = a.customer_number);
-- END OF CUSTOMER_DIM POPULATION

-- RE-BUILD PA CUSTOMER DIMENSION
TRUNCATE TABLE pa_customer_dim;

INSERT INTO pa_customer_dim
SELECT
  customer_sk,
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state,
  shipping_address,
  shipping_zip_code,
  shipping_city,
  shipping_state,
  effective_date,
  expiry_date
FROM customer_dim
WHERE customer_state = 'PA';
-- END OF CUSTOMER_DIM POPULATION


-- product dimension loading
TRUNCATE TABLE product_stg;
-- load data
COPY product_stg (
    product_code,
    product_name,
    product_category
) FROM '/private/tmp/adding_column_dataset2.csv' DELIMITER ',' CSV HEADER;
-- PRODUCT_DIM POPULATION

-- SCD2 ON PRODUCT NAME AND GROUP
UPDATE product_dim AS a
SET expiry_date = DATE '2007-03-01'
FROM product_stg AS b
WHERE a.product_code = b.product_code
AND (
    a.product_name <> b.product_name
    OR a.product_category <> b.product_category
)
AND expiry_date = DATE '9999-12-31';

-- INSERT INTO product_dim
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
  b.product_code,
  b.product_name,
  b.product_category,
  DATE '2007-03-06',  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
  DATE '9999-12-31'
FROM
  product_dim AS a
JOIN
  product_stg AS b ON a.product_code = b.product_code
WHERE
  a.product_name <> b.product_name
  AND a.product_category <> b.product_category
  AND EXISTS (
    SELECT 1
    FROM product_dim AS x
    WHERE b.product_code = x.product_code
    AND a.expiry_date = DATE '2007-03-01'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM product_dim AS y
    WHERE b.product_code = y.product_code
    AND y.expiry_date = DATE '9999-12-31'
  );
-- END OF SCD 2

-- ADD NEW PRODUCT
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
  product_code,
  product_name,
  product_category,
  DATE '2007-03-06',  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
  DATE '9999-12-31'
FROM product_stg
WHERE product_code NOT IN (
  SELECT y.product_code
  FROM product_dim x
  JOIN product_stg y ON x.product_code = y.product_code
);
-- END OF PRODUCT_DIM POPULATION

-- ORDER_DIM POPULATION
INSERT INTO order_dim (
  order_number,
  effective_date,
  expiry_date
)
SELECT
  order_number,
  status_date,
  DATE '9999-12-31'
FROM sales_order
WHERE entry_date = DATE '2007-03-06';  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
-- End
/* INSERTING New ORDER */
INSERT INTO sales_order_fact
SELECT
  b.order_sk,
  c.customer_sk,
  d.product_sk,
  e.order_date_sk,
  NULL,
  NULL,
  NULL,
  NULL,
  f.request_delivery_date_sk,
  a.order_amount,
  a.order_quantity,
  NULL,
  NULL,
  NULL,
  NULL
FROM
  sales_order a
JOIN order_dim b ON a.order_number = b.order_number
JOIN customer_dim c ON a.customer_number = c.customer_number
JOIN product_dim d ON a.product_code = d.product_code
JOIN order_date_dim e ON a.status_date = e.order_date
JOIN request_delivery_date_dim f ON a.request_delivery_date = f.request_delivery_date
WHERE
  a.order_status = 'N'
  AND a.entry_date = '2007-03-06'; -- Mengubah tanggal saat ini menjadi 6 Maret 2007

/* UPDATING the new sales order to Allocated status */

UPDATE
  sales_order_fact a
SET
  allocate_date_sk = c.allocate_date_sk,
  allocate_quantity = b.order_quantity
FROM
  sales_order b
JOIN allocate_date_dim c ON b.status_date = c.allocate_date
JOIN order_dim g ON b.order_number = g.order_number
WHERE
  b.order_status = 'A'
  AND b.entry_date = '2007-03-06' -- Mengubah tanggal saat ini menjadi 6 Maret 2007
  AND a.order_sk = g.order_sk;

-- SALES_ORDER_FACT POPULATION
INSERT INTO sales_order_fact
SELECT
  b.order_sk,
  c.customer_sk,
  d.product_sk,
  e.date_sk,
  a.order_amount,
  a.order_quantity
FROM
  sales_order a
JOIN
  order_dim b ON a.order_number = b.order_number
JOIN
  customer_dim c ON a.customer_number = c.customer_number
JOIN
  product_dim d ON a.product_code = d.product_code
JOIN
  date_dim e ON a.status_date = e.date -- Bergabung berdasarkan tanggal pesanan dengan tanggal di date_dim
WHERE
  a.status_date BETWEEN c.effective_date AND c.expiry_date
  AND a.status_date BETWEEN d.effective_date AND d.expiry_date
  AND a.entry_date = DATE '2007-03-06'; -- Menggunakan tanggal 6 Maret 2007 sebagai entry_date

--








