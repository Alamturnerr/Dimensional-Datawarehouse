ALTER TABLE customer_dim
  ADD COLUMN shipping_address VARCHAR(50),
  ADD COLUMN shipping_zip_code INT,
  ADD COLUMN shipping_city VARCHAR(30),
  ADD COLUMN shipping_state CHAR(2);

ALTER TABLE customer_stg
  ADD COLUMN shipping_address VARCHAR(50),
  ADD COLUMN shipping_zip_code INT,
  ADD COLUMN shipping_city VARCHAR(30),
  ADD COLUMN shipping_state CHAR(2);
--
Select * From customer_dim
Select * From customer_stg
--
ALTER TABLE sales_order_fact
ADD COLUMN order_quantity INT;

-- Revising Regular Population Script
ALTER TABLE sales_order
ADD COLUMN order_quantity INT;
select * from sales_order

INSERT INTO sales_order (order_number, customer_number, product_code, order_date, entry_date, order_amount, order_quantity) VALUES
  (38, 1, 1, '2007-03-02', '2007-03-02', 1000, 10),
  (39, 2, 2, '2007-03-02', '2007-03-02', 2000, 20),
  (40, 3, 3, '2007-03-02', '2007-03-02', 4000, 40),
  (41, 4, 4, '2007-03-02', '2007-03-02', 6000, 60),
  (42, 5, 1, '2007-03-02', '2007-03-02', 2500, 25),
  (43, 6, 2, '2007-03-02', '2007-03-02', 5000, 50),
  (44, 7, 3, '2007-03-02', '2007-03-02', 7500, 75),
  (45, 8, 4, '2007-03-02', '2007-03-02', 1000, 10),
  (46, 9, 1, '2007-03-02', '2007-03-02', 1000, 10);

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
  '2007-03-02',
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
  '2007-03-02',
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
  DATE '2007-03-02',  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
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
  DATE '2007-03-02',  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
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
  order_date,
  DATE '9999-12-31'
FROM sales_order
WHERE entry_date = DATE '2007-03-02';  -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
-- End

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
  date_dim e ON a.order_date = e.date
WHERE
  a.order_date BETWEEN c.effective_date AND c.expiry_date
  AND a.order_date BETWEEN d.effective_date AND d.expiry_date
  AND a.entry_date = DATE '2007-03-02'; -- Menggunakan tanggal 2 Maret 2007 sebagai CURRENT_DATE
-- End Revising Populate

--
SELECT
  customer_number AS no,
  customer_name AS name,
  shipping_city,
  shipping_zip_code AS zip,
  shipping_state AS st,
  effective_date AS eff,
  expiry_date AS exp
FROM
  customer_dim;

SELECT order_sk AS osk, customer_sk AS csk, product_sk AS psk,
       order_date_sk AS odsk,
       order_amount AS amt, order_quantity AS qty
FROM sales_order_fact;











