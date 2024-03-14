-- Month Roll Up
CREATE TABLE month_dim (
  month_sk SERIAL PRIMARY KEY,
  month_name CHAR(9),
  month INT,
  quarter INT,
  year INT,
  effective_date DATE,
  expiry_date DATE
);
INSERT INTO month_dim (month_name, month, quarter, year, effective_date, expiry_date)
SELECT DISTINCT
    month_name,
    month,
    quarter,
    year,
    effective_date,
    expiry_date
FROM date_dim

SELECT month_sk AS msk,
       month_name,
       month,
       quarter AS q,
       year,
       effective_date AS efdate,
       expiry_date AS exdate
FROM month_dim
Order by year, month;
-- 
---- Revising Populate Date
CREATE OR REPLACE FUNCTION pre_populate_date(start_dt DATE, end_dt DATE)
RETURNS VOID AS $$
BEGIN
    WHILE start_dt <= end_dt LOOP
        INSERT INTO date_dim(date, month_name, month, quarter, year, effective_date, expiry_date)
        SELECT
            start_dt,
            TO_CHAR(start_dt, 'Month'),
            EXTRACT(MONTH FROM start_dt),
            EXTRACT(QUARTER FROM start_dt),
            EXTRACT(YEAR FROM start_dt),
            '0001-01-01'::DATE,
            '9999-12-31'::DATE;
        
        start_dt := start_dt + INTERVAL '1 day';
    END LOOP;

    INSERT INTO month_dim(month_name, month, quarter, year, effective_date, expiry_date)
    SELECT DISTINCT
        month_name,
        month,
        quarter,
        year,
        effective_date,
        expiry_date
    FROM date_dim
    WHERE (month, year) NOT IN (SELECT month, year FROM month_dim);
END;
$$ LANGUAGE plpgsql;

Select pre_populate_date('2011-01-01', '2011-12-31');

select * from month_dim where year = 2011 order by month

--
INSERT INTO customer_dim
( customer_sk
, customer_number
, customer_name
, customer_street_address
, customer_zip_code
, customer_city
, customer_state
, effective_date
, expiry_date 
, shipping_address
, shipping_zip_code
, shipping_city
, shipping_state)
VALUES
(DEFAULT, 10, 'Bigger Customers', '7777 Ridge Rd.', '44102',
       'Cleveland', 'OH', DATE '2007-03-03', '9999-12-31', '7777 Ridge Rd.', '44102', 'Cleveland',
       'OH'),
(DEFAULT, 11, 'Smaller Stores', '8888 Jennings Fwy.', '44102',
       'Cleveland', 'OH', DATE '2007-03-03', '9999-12-31', '8888 Jennings Fwy.', '44102',
       'Cleveland', 'OH'),
(DEFAULT, 12, 'Small-Medium Retailers', '9999 Memphis Ave.', '44102',
       'Cleveland', 'OH', DATE '2007-03-03', '9999-12-31', '9999 Memphis Ave.', '44102', 'Cleveland',
       'OH');
--
CREATE TABLE pa_customer_dim (
  customer_sk SERIAL PRIMARY KEY,
  customer_number INT,
  customer_name CHAR(50),
  customer_street_address CHAR(50),
  customer_zip_code INT,
  customer_city CHAR(30),
  customer_state CHAR(2),
  shipping_address CHAR(50),
  shipping_zip_code INT,
  shipping_city CHAR(30),
  shipping_state CHAR(2),
  effective_date DATE,
  expiry_date DATE
);

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

--
SELECT customer_name, customer_state, effective_date
FROM customer_dim;
--
INSERT INTO customer_dim
( customer_sk
, customer_number
, customer_name
, customer_street_address
, customer_zip_code
, customer_city
, customer_state
, effective_date
, expiry_date 
, shipping_address
, shipping_zip_code
, shipping_city
, shipping_state)
VALUES
(DEFAULT, 13, 'PA Customer', '1111 Louise Dr.', '17050',
       'Mechanicsburg', 'PA', DATE '2007-03-03', DATE '9999-12-31', '1111 Louise Dr.', '17050',
       'Mechanicsburg', 'PA'),
(DEFAULT, 14, 'OH Customer', '6666 Ridge Rd.', '44102',
       'Cleveland', 'OH', DATE '2007-03-03', DATE '9999-12-31', '6666 Ridge Rd.', '44102',
       'Cleveland', 'OH') ;
--

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
SELECT customer_name, customer_state, effective_date
FROM pa_customer_dim;


