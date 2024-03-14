-- Multi Star Schema
CREATE TABLE factory_dim (
  factory_sk SERIAL PRIMARY KEY,
  factory_code INT,
  factory_name CHAR(30),
  factory_street_address CHAR(50),
  factory_zip_code INT,
  factory_city CHAR(30),
  factory_state CHAR(2),
  effective_date DATE,
  expiry_date DATE );

CREATE TABLE production_fact (
  product_sk INT,
  production_date_sk INT,
  factory_sk INT,
  production_quantity INT );
 --
INSERT INTO factory_dim (
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state,
  effective_date,
  expiry_date )
SELECT
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state,
  '2007-03-18', --Konversi Tanggal 16 Maret Dong
  '9999-12-31'::DATE
FROM factory_master;
--
CREATE TABLE factory_stg (
  factory_code INT,
  factory_name CHAR(30),
  factory_street_address CHAR(50),
  factory_zip_code INT,
  factory_city CHAR(30),
  factory_state CHAR(2) );
--
TRUNCATE TABLE factory_stg;

COPY factory_stg (
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state )
FROM '/private/tmp/factory_dataset.csv'
WITH (FORMAT CSV, DELIMITER ',', NULL '', HEADER TRUE);
--
UPDATE factory_dim AS a
SET
  factory_name = b.factory_name,
  factory_street_address = b.factory_street_address,
  factory_zip_code = b.factory_zip_code,
  factory_city = b.factory_city,
  factory_state = b.factory_state
FROM factory_stg AS b
WHERE a.factory_code = b.factory_code;
--
INSERT INTO factory_dim (factory_code, factory_name, factory_street_address, factory_zip_code, factory_city, factory_state, effective_date, expiry_date)
SELECT
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state,
  '2007-03-18',
  '9999-12-31'::DATE
FROM factory_stg
WHERE factory_code NOT IN (
  SELECT y.factory_code
  FROM factory_dim x, factory_stg y
  WHERE x.factory_code = y.factory_code
);

INSERT INTO production_fact
SELECT
  b.product_sk,
  c.date_sk,
  d.factory_sk,
  production_quantity
FROM
  daily_production a
JOIN product_dim b ON a.product_code = b.product_code
JOIN date_dim c ON a.production_date = c.date
JOIN factory_dim d ON a.factory_code = d.factory_code
WHERE
    a.production_date = '2007-03-18' -- Tanggal produksi yang diminta
AND a.production_date >= b.effective_date
AND a.production_date <= b.expiry_date;
--
Select * From production_fact
Select * From factory_dim







