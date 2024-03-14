TRUNCATE customer_dim;
TRUNCATE product_dim;
TRUNCATE order_dim;
TRUNCATE date_dim;
TRUNCATE sales_order_fact;
TRUNCATE customer_stg;
TRUNCATE product_stg;
TRUNCATE sales_order;

select pre_populate_date('2005-03-01','2010-12-31')

INSERT INTO sales_order VALUES
  (1, 1, 1, '2005-02-01', '2005-02-01', 1000),
  (2, 2, 2, '2005-02-10', '2005-02-10', 1000),
  (3, 3, 3, '2005-03-01', '2005-03-01', 4000),
  (4, 4, 1, '2005-04-15', '2005-04-15', 4000),
  (5, 5, 2, '2005-05-20', '2005-05-20', 6000),
  (6, 6, 3, '2005-07-30', '2005-07-30', 6000),
  (7, 7, 1, '2005-09-01', '2005-09-01', 8000),
  (8, 1, 2, '2005-11-10', '2005-11-10', 8000),
  (9, 2, 3, '2006-01-05', '2006-01-05', 1000),
  (10, 3, 1, '2006-02-10', '2006-02-10', 1000),
  (11, 4, 2, '2006-03-15', '2006-03-15', 2000),
  (12, 5, 3, '2006-04-20', '2006-04-20', 2500),
  (13, 6, 1, '2006-05-30', '2006-05-30', 3000),
  (14, 7, 2, '2006-06-01', '2006-06-01', 3500),
  (15, 1, 3, '2006-07-15', '2006-07-15', 4000),
  (16, 2, 1, '2006-08-30', '2006-08-30', 4500),
  (17, 3, 2, '2006-09-05', '2006-09-05', 1000),
  (18, 4, 3, '2006-10-05', '2006-10-05', 1000),
  (19, 5, 1, '2007-01-10', '2007-01-10', 4000),
  (20, 6, 2, '2007-02-20', '2007-02-20', 4000),
  (21, 7, 3, '2007-02-28', '2007-02-28', 4000);

-- Memuat data customer dari file CSV ke dalam tabel customer_stg
COPY customer_stg FROM '/private/tmp/customer.csv' DELIMITER ',' CSV HEADER;

-- Memindahkan data dari customer_stg ke customer_dim
INSERT INTO customer_dim (customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state, effective_date, expiry_date)
SELECT
  customer_number,
  customer_name,
  customer_street_address,
  customer_zip_code,
  customer_city,
  customer_state,
  '2005-03-01'::DATE, -- Tanggal efektif
  '9999-12-31'::DATE  -- Tanggal berakhir
FROM
  customer_stg;

-- Memuat data product dari file teks ke dalam tabel product_stg
COPY product_stg FROM '/private/tmp/product.csv' DELIMITER ',' CSV HEADER;

-- Memindahkan data dari product_stg ke product_dim
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
  product_code,
  product_name,
  product_category,
  '2005-03-01'::DATE, -- Tanggal efektif
  '9999-12-31'::DATE  -- Tanggal berakhir
FROM
  product_stg;

INSERT INTO order_dim (order_number, effective_date, expiry_date)
SELECT
  order_number,
  order_date,
  '9999-12-31'::DATE  -- Tanggal berakhir
FROM
  sales_order
WHERE
  order_date >= '2005-03-01'
  AND
  order_date < '2007-02-28';  -- Sesuaikan dengan rentang tanggal yang diinginkan



INSERT INTO sales_order_fact
SELECT
  b.order_sk,
  c.customer_sk,
  d.product_sk,
  e.date_sk,
  a.order_amount
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
  a.order_date >= '2005-03-01'
  AND a.order_date < '2007-02-28';

------------

SELECT
  d.order_number,
  b.customer_name,
  c.product_name,
  e.date,
  a.order_amount AS amount
FROM
  sales_order_fact a
JOIN
  customer_dim b ON a.customer_sk = b.customer_sk
JOIN
  product_dim c ON a.product_sk = c.product_sk
JOIN
  order_dim d ON a.order_sk = d.order_sk
JOIN
  date_dim e ON a.order_date_sk = e.date_sk;






