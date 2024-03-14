ALTER TABLE sales_order_fact
ADD COLUMN order_number INT;

UPDATE sales_order_fact AS a
SET order_number = b.order_number
FROM order_dim AS b
WHERE a.order_sk = b.order_sk;

ALTER TABLE sales_order_fact
DROP COLUMN order_sk;

DROP TABLE order_dim;


INSERT INTO source.sales_order (order_number, customer_number, product_code, status_date, order_status, request_delivery_date, entry_date, order_amount, quantity)
VALUES
  (52, 1, 1, '2007-03-11', 'N', '2007-03-20', '2007-03-11', 7500, 75),
  (53, 2, 2, '2007-03-11', 'N', '2007-03-20', '2007-03-11', 1000, 10),
  (52, 1, 1, '2007-03-12', 'A', '2007-03-20', '2007-03-12', 7500, 75),
  (53, 2, 2, '2007-03-12', 'A', '2007-03-20', '2007-03-12', 1000, 10),
  (52, 1, 1, '2007-03-13', 'P', '2007-03-20', '2007-03-13', 7500, 75),
  (53, 2, 2, '2007-03-13', 'P', '2007-03-20', '2007-03-13', 1000, 10),
  (52, 1, 1, '2007-03-14', 'S', '2007-03-20', '2007-03-14', 7500, 75),
  (53, 2, 2, '2007-03-14', 'S', '2007-03-20', '2007-03-14', 1000, 10),
  (52, 1, 1, '2007-03-15', 'R', '2007-03-20', '2007-03-15', 7500, 75),
  (53, 2, 2, '2007-03-15', 'R', '2007-03-20', '2007-03-15', 1000, 10);

-- Revised The regular populate

TRUNCATE customer_stg;

COPY customer_stg FROM 'customer.csv' WITH (FORMAT CSV, DELIMITER ', ', HEADER);

-- SCD 2 ON ADDRESSES
UPDATE customer_dim AS a
SET expiry_date = CURRENT_DATE - INTERVAL '1 day'
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
AND expiry_date - '9999-12-31';

INSERT INTO customer_dim
SELECT
  NULL,
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
  CURRENT_DATE,
  '9999-12-31'
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
    AND a.expiry_date = CURRENT_DATE - INTERVAL '1 day'
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
    shipping_address,
    shipping_zip_code,
    shipping_city,
    shipping_state,
    CURRENT_DATE,
    '9999-12-31'
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
FROM 'product.txt'
WITH (FORMAT csv, DELIMITER '', NULL '', HEADER false);

-- SCD2 ON PRODUCT NAME AND GROUP
UPDATE product_dim a
SET expiry_date = SUBDATE(CURRENT_DATE, 1)
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
    CURRENT_DATE,
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


-- insert new orders
INSERT INTO sales_order_fact
SELECT
  c.customer_sk,
  d.product_sk,
  e.order_date_sk,
  NULL,
  NULL,
  NULL,
  NULL,
  a.order_number,
  f.request_delivery_date_sk,
  a.order_amount,
  a.quantity,
  NULL,
  NULL,
  NULL,
  NULL
FROM
  source.sales_order a
JOIN customer_dim c ON a.customer_number = c.customer_number
JOIN product_dim d ON a.product_code = d.product_code
JOIN order_date_dim e ON a.status_date = e.order_date
JOIN request_delivery_date_dim f ON a.request_delivery_date = f.request_delivery_date
WHERE
  a.order_status = 'N'
  AND a.entry_date = CURRENT_DATE;

-- update allocate_date_sk and allocate_quantity
UPDATE
  sales_order_fact a
SET
  allocate_date_sk = c.allocate_date_sk,
  allocate_quantity = b.quantity
FROM
  source.sales_order b
JOIN allocate_date_dim c ON b.status_date = c.allocate_date
WHERE
  a.order_status = 'A'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number;

-- update packing_date_sk and packing_quantity
UPDATE
  sales_order_fact a
SET
  packing_date_sk = d.packing_date_sk,
  packing_quantity = b.quantity
FROM
  source.sales_order b
JOIN packing_date_dim d ON b.status_date = d.packing_date
WHERE
  a.order_status = 'P'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number;

-- update ship_date_sk and ship_quantity
UPDATE
  sales_order_fact a
SET
  ship_date_sk = e.ship_date_sk,
  ship_quantity = b.quantity
FROM
  source.sales_order b
JOIN ship_date_dim e ON b.status_date = e.ship_date
WHERE
  a.order_status = 'S'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number;

-- update receive_date_sk and receive_quantity
UPDATE
  sales_order_fact a
SET
  receive_date_sk = f.receive_date_sk,
  receive_quantity = b.quantity
FROM
  source.sales_order b
JOIN receive_date_dim f ON b.status_date = f.receive_date
WHERE
  a.order_status = 'R'
  AND b.entry_date = CURRENT_DATE
  AND b.order_number = a.order_number;


