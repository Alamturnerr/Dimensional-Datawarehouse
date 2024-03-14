-- Create Table Staging
CREATE TABLE product_stg(
product_code INT,
product_name CHAR (30),
product_category CHAR (30));

-- Clean Up Staging Table
TRUNCATE product_stg

-- Load data 
COPY product_stg (product_code, product_name, product_category)
FROM '/private/tmp/scd2 1.csv'
DELIMITER ','
CSV HEADER;

select * from product_stg

-- Update 
UPDATE product_dim AS a
SET expiry_date = DATE '2007-02-02' -- Tanggal 2 Februari 2007
FROM product_stg AS b
WHERE a.product_code = b.product_code
  AND (a.product_name <> b.product_name OR a.product_category <> b.product_category)
  AND a.expiry_date = '9999-12-31';

-- Menambahkan tabel baru untuk data yang berubah
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
    b.product_code,
    b.product_name,
    b.product_category,
    CURRENT_DATE,
    '9999-12-31'
FROM product_dim AS a 
JOIN product_stg AS b ON a.product_code = b.product_code 
WHERE a.expiry_date = DATE '2007-02-02'
  AND NOT EXISTS (
    SELECT 1
    FROM product_dim AS y
    WHERE b.product_code = y.product_code
      AND y.expiry_date = '9999-12-31'
  );


-- Menambahkan produk baru
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT -- Data select diambil dari porduct_stg
  product_code,
  product_name,
  product_category,
  DATE '2007-02-03',
  '9999-12-31'
FROM product_stg
WHERE product_code NOT IN ( -- Memilih semua baris dari tabel (product_stg) yang memiliki product_code yang tidak ada di dalam tabel product_dim. Ini memastikan bahwa kita hanya memasukkan produk yang belum ada sebelumnya di dalam dimensi.
  SELECT y.product_code 
  FROM product_dim AS x
  JOIN product_stg AS y ON x.product_code = y.product_code
);

select * from product_dim
---------------------------------------------------

-- Clean Up Staging Table
TRUNCATE product_stg

-- Load data 
COPY product_stg (product_code, product_name, product_category)
FROM '/private/tmp/scd2.csv'
DELIMITER ','
CSV HEADER;

select * from product_stg


-- Update 
UPDATE product_dim AS a
SET expiry_date = DATE '2007-02-05' -- Tanggal 5 Februari 2007
FROM product_stg AS b
WHERE a.product_code = b.product_code
  AND (a.product_name <> b.product_name OR a.product_category <> b.product_category)
  AND a.expiry_date = '9999-12-31';

-- Menambahkan tabel baru untuk data yang berubah
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT
    b.product_code,
    b.product_name,
    b.product_category,
    DATE '2007-02-05',
    '9999-12-31'
FROM product_dim AS a 
JOIN product_stg AS b ON a.product_code = b.product_code 
WHERE a.expiry_date = DATE '2007-02-05'
  AND NOT EXISTS (
    SELECT 1
    FROM product_dim AS y
    WHERE b.product_code = y.product_code
      AND y.expiry_date = '9999-12-31'
  );


-- Menambahkan produk baru
INSERT INTO product_dim (product_code, product_name, product_category, effective_date, expiry_date)
SELECT -- Data select diambil dari porduct_stg
  product_code,
  product_name,
  product_category,
  DATE '2007-02-05',
  '9999-12-31'
FROM product_stg
WHERE product_code NOT IN ( -- Memilih semua baris dari tabel (product_stg) yang memiliki product_code yang tidak ada di dalam tabel product_dim. Ini memastikan bahwa kita hanya memasukkan produk yang belum ada sebelumnya di dalam dimensi.
  SELECT y.product_code 
  FROM product_dim AS x
  JOIN product_stg AS y ON x.product_code = y.product_code
);

Select * from product_dim


