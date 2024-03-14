CREATE TABLE factory_dim (
  factory_sk SERIAL PRIMARY KEY,
  factory_code INT,
  factory_name CHAR(30),
  factory_street_address CHAR(50),
  factory_zip_code INT,
  factory_city CHAR(30),
  factory_state CHAR(2),
  effective_date DATE,
  expiry_date DATE
);

CREATE TABLE production_fact (
  product_sk INT,
  production_date_sk INT,
  factory_sk INT,
  production_quantity INT
);

-- Populating the news star table

CREATE TABLE factory_master (
  factory_code INT,
  factory_name CHAR(30),
  factory_street_address CHAR(50),
  factory_zip_code INT,
  factory_city CHAR(30),
  factory_state CHAR(2)
);

INSERT INTO factory_dim
SELECT
  DEFAULT,
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state,
  CURRENT_DATE,
  '9999-12-31'
FROM source.factory_master;

TRUNCATE TABLE factory_stg;
COPY factory_stg (factory_code, factory_name, factory_street_address, factory_zip_code, factory_city, factory_state)
FROM 'factory.csv'
WITH (FORMAT csv, DELIMITER ', ', HEADER true);
UPDATE factory_dim AS a
SET
  factory_name = b.factory_name,
  factory_street_address = b.factory_street_address,
  factory_zip_code = b.factory_zip_code,
  factory_city = b.factory_city,
  factory_state = b.factory_state
FROM factory_stg AS b
WHERE a.factory_code = b.factory_code;
INSERT INTO factory_dim
SELECT
  NULL,
  factory_code,
  factory_name,
  factory_street_address,
  factory_zip_code,
  factory_city,
  factory_state,
  CURRENT_DATE,
  '9999-12-31'
FROM factory_stg
WHERE factory_code NOT IN (
  SELECT factory_code FROM factory_dim
);
INSERT INTO production_fact (product_sk, production_date_sk, factory_sk, production_quantity)
SELECT
  b.product_sk,
  c.date_sk,
  d.factory_sk,
  a.production_quantity
FROM
  source.daily_production a
JOIN product_dim b ON a.product_code = b.product_code
JOIN date_dim c ON a.production_date = c.date
JOIN factory_dim d ON a.factory_code = d.factory_code
WHERE a.production_date = CURRENT_DATE;
