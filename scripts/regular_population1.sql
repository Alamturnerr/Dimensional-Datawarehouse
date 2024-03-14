-- Clean Data
TRUNCATE TABLE customer_stg;
-- Load Data
COPY customer_stg (
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state) 
  FROM '/private/tmp/regular_population_dataset.csv' WITH (
  FORMAT CSV, DELIMITER ',', QUOTE '"', HEADER true);

/* Pertama, nonaktifkan pelanggan yang ada */
UPDATE customer_dim AS a
SET expiry_date = CURRENT_DATE - INTERVAL '1 day'
FROM customer_stg AS b
WHERE a.customer_number = b.customer_number
AND a.customer_street_address <> b.customer_street_address
AND expiry_date = '9999-12-31';

-- Ad customers baru
INSERT INTO customer_dim (
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state,
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
  CURRENT_DATE,
  '9999-12-31'
FROM
  customer_dim a
JOIN
  customer_stg b ON a.customer_number = b.customer_number
WHERE
  a.customer_street_address <> b.customer_street_address
  AND EXISTS (
    SELECT 1
    FROM customer_dim x
    WHERE b.customer_number = x.customer_number
    AND a.expiry_date = CURRENT_DATE - INTERVAL '1 day'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM customer_dim y
    WHERE b.customer_number = y.customer_number
    AND y.expiry_date = '9999-12-31'
  );
  
-- Lakukan SCD 1 di customer Name
UPDATE customer_dim a
SET customer_name = b.customer_name
FROM customer_stg b
WHERE a.customer_number = b.customer_number
AND a.customer_name <> b.customer_name;

-- add another customer
INSERT INTO customer_dim (customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state, effective_date, expiry_date)
SELECT
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
    SELECT y.customer_number
    FROM customer_dim x
    JOIN customer_stg y ON x.customer_number = y.customer_number
);

-- product dimension loading
TRUNCATE TABLE product_stg;

-- Load Data Lagi
COPY product_stg (product_code, product_name, product_category)
FROM '/private/tmp/regular_population_dataset2.csv' DELIMITER ',' CSV HEADER;

-- first, expire the existing product
UPDATE product_dim a
SET expiry_date = CURRENT_DATE - INTERVAL '1 day'
FROM product_stg b
WHERE a.product_code = b.product_code
  AND (a.product_name <> b.product_name OR a.product_category <> b.product_category)
  AND expiry_date = '9999-12-31';
UPDATE product_dim
SET expiry_date = '2007-03-1'
WHERE expiry_date = '9999-12-31';

/* then, add a new row for the product */
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
  b.product_code,
  b.product_name,
  b.product_category,
  DATE '2007-03-01', -- Ubah tanggal ke 1 Maret 2007
  '9999-12-31'
FROM
  product_dim a
JOIN
  product_stg b ON a.product_code = b.product_code
WHERE
    (a.product_name <> b.product_name OR a.product_category <> b.product_category)
AND NOT EXISTS (
  SELECT *
  FROM product_dim x
  WHERE b.product_code = x.product_code
    AND a.expiry_date = DATE '2007-02-28' -- Ubah tanggal ke 28 Februari 2007
)
AND NOT EXISTS (
  SELECT *
  FROM product_dim y
  WHERE b.product_code = y.product_code
    AND y.expiry_date = '9999-12-31'
);

/* add new product */
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
  product_code,
  product_name,
  product_category,
  DATE '2007-03-01', -- Ubah tanggal ke 1 Maret 2007
  '9999-12-31'
FROM product_stg
WHERE product_code NOT IN (
  SELECT y.product_code
  FROM product_dim x, product_stg y
  WHERE x.product_code = y.product_code
);

/* end of product_dim loading */
INSERT INTO order_dim (
  order_number,
  effective_date,
  expiry_date
)
SELECT
  order_number,
  order_date,
  '9999-12-31' -- ubah tanda '-' untuk tanggal
FROM sales_order
WHERE entry_date = CURRENT_DATE;

INSERT INTO sales_order_fact
SELECT
  b.order_sk,
  c.customer_sk,
  d.product_sk,
  e.date_sk,
  a.order_amount
FROM
  sales_order a
JOIN order_dim b ON a.order_number = b.order_number
JOIN customer_dim c ON a.customer_number = c.customer_number
JOIN product_dim d ON a.product_code = d.product_code
JOIN date_dim e ON a.order_date = e.date
WHERE
  a.entry_date = CURRENT_DATE
  AND a.order_date BETWEEN c.effective_date AND c.expiry_date
  AND a.order_date BETWEEN d.effective_date AND d.expiry_date;

select * from customer_dim
select * from product_dim
select * from order_dim
select * from sales_order_fact











