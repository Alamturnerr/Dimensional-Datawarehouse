-- Junk Dimension
CREATE TABLE sales_order_attribute_dim (
    sales_order_attribute_sk SERIAL PRIMARY KEY,
    verification_ind CHAR(1),
    credit_check_flag CHAR(1),
    new_customer_ind CHAR(1),
    web_order_flag CHAR(1),
    effective_date DATE,
    expiry_date DATE);
--
INSERT INTO sales_order_attribute_dim (verification_ind, credit_check_flag, new_customer_ind, web_order_flag, effective_date, expiry_date) VALUES
  ('Y', 'N', 'N', 'N', '0001-01-01', '9999-12-31'),
  ('Y', 'Y', 'N', 'N', '0001-01-01', '9999-12-31'),
  ('Y', 'Y', 'Y', 'N', '0001-01-01', '9999-12-31'),
  ('Y', 'Y', 'Y', 'Y', '0001-01-01', '9999-12-31'),
  ('Y', 'N', 'Y', 'N', '0001-01-01', '9999-12-31'),
  ('Y', 'N', 'Y', 'Y', '0001-01-01', '9999-12-31'),
  ('Y', 'N', 'N', 'Y', '0001-01-01', '9999-12-31'),
  ('Y', 'Y', 'N', 'Y', '0001-01-01', '9999-12-31'),
  ('N', 'N', 'N', 'N', '0001-01-01', '9999-12-31'),
  ('N', 'Y', 'N', 'N', '0001-01-01', '9999-12-31'),
  ('N', 'Y', 'Y', 'N', '0001-01-01', '9999-12-31'),
  ('N', 'Y', 'Y', 'Y', '0001-01-01', '9999-12-31'),
  ('N', 'N', 'Y', 'N', '0001-01-01', '9999-12-31'),
  ('N', 'N', 'Y', 'Y', '0001-01-01', '9999-12-31'),
  ('N', 'N', 'N', 'Y', '0001-01-01', '9999-12-31'),
  ('N', 'Y', 'N', 'Y', '0001-01-01', '9999-12-31');

--
SELECT sales_order_attribute_sk AS soa_sk,
       verification_ind AS vi,
       credit_check_flag AS ccf,
       new_customer_ind AS nci,
       web_order_flag AS wof
FROM sales_order_attribute_dim;
--
ALTER TABLE sales_order_fact
ADD COLUMN sales_order_attribute_sk INT;

-- Revised The regular populate

TRUNCATE customer_stg;

COPY customer_stg FROM '/private/tmp/adding_column_dataset.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);

-- SCD 2 ON ADDRESSES
UPDATE customer_dim AS a
SET expiry_date = '2007-03-15'
FROM customer_stg AS b
WHERE
    a.customer_number = b.customer_number
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
AND expiry_date = '9999-12-31';

INSERT INTO customer_dim
SELECT
  NULL,
  b.customer_number,
  b.customer_name,
  b.customer_street_address,
  b.customer_zip_code,
  b.customer_city,
  b.customer_state,
  '2007-03-16',
  '9999-12-31',
  b.shipping_address,
  b.shipping_zip_code,
  b.shipping_city,
  b.shipping_state
FROM
  customer_dim AS a
JOIN customer_stg AS b ON a.customer_number = b.customer_number
WHERE (
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
    SELECT *
    FROM customer_dim AS x
    WHERE b.customer_number = x.customer_number
    AND a.expiry_date = '2007-03-15'
)
AND NOT EXISTS (
    SELECT *
    FROM customer_dim AS y
    WHERE b.customer_number = y.customer_number
    AND y.expiry_date = '9999-12-31'
);

-- END OF SCD 2
-- SCD 1 ON NAME
UPDATE customer_dim AS a
SET customer_name = b.customer_name
FROM customer_stg AS b
WHERE
    a.customer_number = b.customer_number
AND a.expiry_date = '9999-12-31'
AND a.customer_name <> b.customer_name;

-- ADD NEW CUSTOMER
INSERT INTO customer_dim
SELECT
    NULL,
    customer_number,
    customer_name,
    customer_street_address,
    customer_zip_code,
    customer_city,
    customer_state,
	'2007-03-16',
    '9999-12-31',
    shipping_address,
    shipping_zip_code,
    shipping_city,
    shipping_state
FROM customer_stg
WHERE customer_number NOT IN (
    SELECT a.customer_number
    FROM customer_dim a
    JOIN customer_stg b ON b.customer_number = a.customer_number
);
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

-- PRODUCT_DIM POPULATION
TRUNCATE TABLE product_stg;

COPY product_stg(product_code, product_name, product_category)
FROM '/private/tmp/adding_column_dataset2.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER);

-- SCD2 ON PRODUCT NAME AND GROUP
UPDATE product_dim a
SET expiry_date = '2007-03-15'
FROM product_stg b
WHERE a.product_code = b.product_code
AND (a.product_name <> b.product_name OR a.product_category <> b.product_category)
AND a.expiry_date = '9999-12-31';

INSERT INTO product_dim
SELECT
    NULL,
    b.product_code,
    b.product_name,
    b.product_category,
    '2007-03-16',
    '9999-12-31'
FROM product_stg b
WHERE NOT EXISTS (
    SELECT 1
    FROM product_dim x
    WHERE x.product_code = b.product_code
)
AND NOT EXISTS (
    SELECT 1
    FROM product_dim y
    WHERE y.product_code = b.product_code
    AND y.expiry_date = '9999-12-31'
);

-- END OF SCD 2
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
  sales_order a,
  customer_dim b,
  product_dim c,
  order_date_dim d,
  request_delivery_date_dim e,
  sales_order_attribute_dim f
WHERE
  a.order_status = 'N'
  AND a.entry_date = '2007-03-16'
  AND a.customer_number = b.customer_number
  AND a.status_date >= b.effective_date
  AND a.status_date <= b.expiry_date
  AND a.product_code = c.product_code
  AND a.status_date >= c.effective_date
  AND a.status_date <= c.expiry_date
  AND a.status_date = d.order_date
  AND a.request_delivery_date = e.request_delivery_date
  AND verification_ind = f.verification_ind
  AND credit_check_flag = f.credit_check_flag
  AND new_customer_ind = f.new_customer_ind
  AND web_order_flag = f.web_order_flag
  AND status_date >= f.effective_date
  AND status_date <= f.expiry_date;


-- UPDATE allocate_date_sk and allocate_quantity
UPDATE
  sales_order_fact a
SET
  allocate_date_sk = c.allocate_date_sk,
  allocate_quantity = b.order_quantity
FROM
  sales_order b
JOIN allocate_date_dim c ON b.status_date = c.allocate_date
WHERE
  b.order_status = 'A'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number
  AND c.allocate_date = b.status_date;

-- UPDATE packing_date_sk and packing_quantity
UPDATE
  sales_order_fact a
SET
  packing_date_sk = d.packing_date_sk,
  packing_quantity = b.order_quantity
FROM
  sales_order b
JOIN packing_date_dim d ON b.status_date = d.packing_date
WHERE
  b.order_status = 'P'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number
  AND d.packing_date = b.status_date;

-- UPDATE ship_date_sk and ship_quantity
UPDATE
  sales_order_fact a
SET
  ship_date_sk = e.ship_date_sk,
  ship_quantity = b.order_quantity
FROM
  sales_order b
JOIN ship_date_dim e ON b.status_date = e.ship_date
WHERE
  b.order_status = 'S'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number
  AND e.ship_date = b.status_date;

-- UPDATE receive_date_sk and receive_quantity
UPDATE
  sales_order_fact a
SET
  receive_date_sk = f.receive_date_sk,
  receive_quantity = b.order_quantity
FROM
  sales_order b
JOIN receive_date_dim f ON b.status_date = f.receive_date
WHERE
  b.order_status = 'R'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number
  AND f.receive_date = b.status_date;

--
SELECT 
    CASE 
        WHEN (checked + not_checked) = 0 THEN 'No orders found' -- Menghindari pembagian oleh nol
        ELSE CONCAT(ROUND(checked * 100.0 / NULLIF((checked + not_checked), 0)), '%') -- Melakukan pembagian hanya jika tidak ada pembagian oleh nol
    END AS percentage
FROM (
    SELECT 
        (SELECT COUNT(*) 
         FROM sales_order_fact a
         JOIN sales_order_attribute_dim b ON a.sales_order_attribute_sk = b.sales_order_attribute_sk
         WHERE new_customer_ind = 'Y' AND credit_check_flag = 'Y') AS checked,
        (SELECT COUNT(*) 
         FROM sales_order_fact a
         JOIN sales_order_attribute_dim b ON a.sales_order_attribute_sk = b.sales_order_attribute_sk
         WHERE new_customer_ind = 'Y' AND credit_check_flag = 'N') AS not_checked
) AS percentages;


