-- DW Regular Population Script
-- Staging Cutomer
TRUNCATE TABLE customer_stg;

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
  shipping_state )
FROM '/private/tmp/adding_column_dataset.csv'
WITH (FORMAT CSV, DELIMITER ',', NULL '', HEADER TRUE, ENCODING 'UTF8');
-- SCD2 On Address
-- Update existing records in customer_dim with expiry_date
UPDATE customer_dim AS a
SET expiry_date = '2007-03-27'::DATE - 1 -- Perhatikan Current Date
FROM customer_stg AS b
WHERE a.customer_number = b.customer_number
  AND (
    a.customer_street_address <> b.customer_street_address OR
    a.customer_city <> b.customer_city OR
    a.customer_zip_code <> b.customer_zip_code OR
    a.customer_state <> b.customer_state OR
    a.shipping_address <> b.shipping_address OR
    a.shipping_city <> b.shipping_city OR
    a.shipping_zip_code <> b.shipping_zip_code OR
    a.shipping_state <> b.shipping_state OR
    a.shipping_address IS NULL OR
    a.shipping_city IS NULL OR
    a.shipping_zip_code IS NULL OR
    a.shipping_state IS NULL
  )
  AND a.expiry_date = '9999-12-31';

-- Insert new records into customer_dim
INSERT INTO customer_dim (
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
)
SELECT
  b.customer_number,
  b.customer_name,
  b.customer_street_address,
  b.customer_zip_code,
  b.customer_city,
  b.customer_state,
  b.shipping_address,
  b.shipping_zip_code,
  b.shipping_city,
  b.shipping_state,
  '2007-03-27'::DATE, -- Perhatikan Current Date
  '9999-12-31'::DATE
FROM
  customer_dim a
JOIN customer_stg b ON a.customer_number = b.customer_number
WHERE (
    a.customer_street_address <> b.customer_street_address OR
    a.customer_city <> b.customer_city OR
    a.customer_zip_code <> b.customer_zip_code OR
    a.customer_state <> b.customer_state OR
    a.shipping_address <> b.shipping_address OR
    a.shipping_city <> b.shipping_city OR
    a.shipping_zip_code <> b.shipping_zip_code OR
    a.shipping_state <> b.shipping_state OR
    a.shipping_address IS NULL OR
    a.shipping_city IS NULL OR
    a.shipping_zip_code IS NULL OR
    a.shipping_state IS NULL )
  AND EXISTS (
    SELECT *
    FROM customer_dim x
    WHERE b.customer_number = x.customer_number
      AND a.expiry_date = '2007-03-27'::DATE - 1) -- Perhatikan Current Date
  AND NOT EXISTS (
    SELECT *
    FROM customer_dim y
    WHERE b.customer_number = y.customer_number
      AND y.expiry_date = '9999-12-31' );
-- SCD 1 On Name
UPDATE customer_dim AS a
SET customer_name = b.customer_name
FROM customer_stg AS b
WHERE a.customer_number = b.customer_number
  AND a.expiry_date = '9999-12-31'
  AND a.customer_name <> b.customer_name;
-- ADD NEW CUSTOMER
INSERT INTO customer_dim (
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
  expiry_date )
SELECT
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
  '2007-03-27', -- Perhatikan Current Date
  '9999-12-31'
FROM customer_stg
WHERE customer_number NOT IN (
  SELECT customer_number
  FROM customer_dim );

-- RE-BUILD PA CUSTOMER DIMENSION
TRUNCATE TABLE pa_customer_dim;

INSERT INTO pa_customer_dim (
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
)
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
FROM
  customer_dim
WHERE
  customer_state = 'PA';
-- END OF CUSTOMER_DIM POPULATION

-- PRODUCT_DIM POPULATION
TRUNCATE TABLE product_stg;

COPY product_stg (
  product_code,
  product_name,
  product_category ) 
FROM '/private/tmp/adding_column_dataset2.csv' WITH (FORMAT CSV,DELIMITER ',', NULL '', HEADER TRUE);

-- SCD2 ON PRODUCT NAME AND GROUP
UPDATE product_dim AS a
SET expiry_date = '2007-03-27'::DATE - 1
FROM product_stg AS b
WHERE a.product_code = b.product_code
AND (
    a.product_name <> b.product_name
    OR a.product_category <> b.product_category
  )
AND expiry_date = '9999-12-31';

INSERT INTO product_dim (
  product_code,
  product_name,
  product_category,
  effective_date,
  expiry_date
)
SELECT
  b.product_code,
  b.product_name,
  b.product_category,
  '2007-03-27'::DATE, -- Perhatikan Tanggal Current Date A
  '9999-12-31'
FROM
  product_dim a
JOIN
  product_stg b ON a.product_code = b.product_code
WHERE
  (a.product_name <> b.product_name OR a.product_category <> b.product_category)
AND EXISTS (
  SELECT *
  FROM product_dim x
  WHERE b.product_code = x.product_code
  AND a.expiry_date = '2007-03-27'::DATE - 1 ) -- Perhatikan Tanggal Current Date
AND NOT EXISTS (
  SELECT *
  FROM product_dim y
  WHERE b.product_code = y.product_code
  AND y.expiry_date = '9999-12-31' );
-- END OF SCD 2

-- ADD NEW PRODUCT
INSERT INTO product_dim
SELECT
  NULL,
  product_code,
  product_name,
  product_category,
  '2007-03-27', -- Perhatikan Current Date
  '9999-12-31'
FROM
  product_stg
WHERE
  product_code NOT IN (
    SELECT y.product_code
    FROM product_dim x, product_stg y
    WHERE x.product_code = y.product_code );
-- END OF PRODUCT_DIM POPULATION

-- PRODUCT_COUNT_FACT POPULATION
TRUNCATE product_count_fact;

-- Populate product_count_fact for products with only one effective date
INSERT INTO product_count_fact (product_sk, product_launch_date_sk)
SELECT
  a.product_sk,
  MIN(b.date_sk) -- Misalkan Anda memilih nilai minimum tanggal sebagai tanggal peluncuran produk
FROM
  product_dim a
JOIN
  date_dim b ON a.effective_date = b.date
GROUP BY
  a.product_sk -- Menggunakan product_sk sebagai kolom GROUP BY
HAVING
  COUNT(a.product_code) > 1;

-- Populate product_count_fact for products updated by SCD2
INSERT INTO product_count_fact (product_sk, product_launch_date_sk)
SELECT
  a.product_sk,
  MIN(b.date_sk)
FROM
  product_dim a
JOIN
  date_dim b ON a.effective_date = b.date
GROUP BY
  a.product_sk
HAVING
  COUNT(a.product_code) > 1;
-- END OF PRODUCT_COUNT_FACT POPULATION

/* insert new orders */
INSERT INTO sales_order_fact
SELECT
  b.customer_sk,
  c.product_sk,
  f.sales_order_attribute_sk,
  d.order_date_sk,
  NULL,
  NULL,
  NULL,
  NULL,
  a.order_number,
  e.request_delivery_date_sk,
  a.order_amount,
  a.order_quantity,
  NULL,
  NULL,
  NULL,
  NULL
FROM
  sales_order a
JOIN
  customer_dim b ON a.customer_number = b.customer_number
JOIN
  product_dim c ON a.product_code = c.product_code
JOIN
  order_date_dim d ON a.status_date = d.order_date
JOIN
  request_delivery_date_dim e ON a.request_delivery_date = e.request_delivery_date
JOIN
  sales_order_attribute_dim f ON a.verification_ind = f.verification_ind
                             AND a.credit_check_flag = f.credit_check_flag
                             AND a.new_customer_ind = f.new_customer_ind
                             AND a.web_order_flag = f.web_order_flag

WHERE
  a.order_status = 'N'
  AND a.entry_date = '2007-03-27' -- Perhatikan Current Date
  AND a.status_date BETWEEN b.effective_date AND b.expiry_date
  AND a.status_date BETWEEN c.effective_date AND c.expiry_date
  AND a.status_date BETWEEN f.effective_date AND f.expiry_date;

UPDATE sales_order_fact a
SET
  allocate_date_sk = c.allocate_date_sk,
  allocate_quantity = b.order_quantity
FROM
  sales_order b
JOIN
  allocate_date_dim c ON b.status_date = c.allocate_date
WHERE
  a.order_status = 'A'
  AND b.entry_date = '2007-03-27' --Perhatikan Current Date
  AND b.order_number = a.order_number;

UPDATE sales_order_fact a
SET
  packing_date_sk = d.packing_date_sk,
  packing_quantity = b.order_quantity
FROM
  sales_order b
JOIN
  packing_date_dim d ON b.status_date = d.packing_date
WHERE
  a.order_status = 'P'
  AND b.entry_date = '2007-03-27' -- Perhatikan Current Date
  AND b.order_number = a.order_number;

UPDATE sales_order_fact a
SET
  ship_date_sk = e.ship_date_sk,
  ship_quantity = b.order_quantity
FROM
  sales_order b
JOIN
  ship_date_dim e ON b.status_date = e.ship_date
WHERE
  a.order_status = 'S'
  AND b.entry_date = '2007-03-27' -- Perhatikan tanggal Current Date
  AND b.order_number = a.order_number;

UPDATE sales_order_fact a
SET
  receive_date_sk = f.receive_date_sk,
  receive_quantity = b.order_quantity
FROM
  sales_order b
JOIN
  receive_date_dim f ON b.status_date = f.receive_date
WHERE
  a.order_status = 'R'
  AND b.entry_date = '2007-03-27' -- Perhatikan Tanggal Current Date
  AND b.order_number = a.order_number;




