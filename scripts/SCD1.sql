-- Staging Procces SCD1
CREATE TABLE customer_stg (
    customer_number INT,
    customer_name VARCHAR(50),
    customer_street_address VARCHAR(50),
    customer_zip_code INT,
    customer_city VARCHAR(30),
    customer_state CHAR(2));

-- Clean Up Data
TRUNCATE customer_stg

-- Load Data Dari File Eksternal
COPY customer_stg (customer_number, customer_name, customer_street_address, customer_zip_code, customer_city, customer_state)
FROM '/private/tmp/scd1.csv'
DELIMITER ',' CSV HEADER;

-- UPDATE existing customers
UPDATE customer_dim -- Melakukan perintah Update
SET customer_name = b.customer_name -- Mengubah isi dari Customer_name Table dim dengan Customer_name dari Customer_stg
FROM customer_stg b -- Data baru di ambil dari customer_stg
WHERE customer_dim.customer_number = b.customer_number -- Menentukan baris menggunakan customer_number
  AND customer_dim.expiry_date = '9999-12-31' -- Memperbarui data belangkan yang masih aktif
  AND customer_dim.customer_name <> b.customer_name; -- Memperbarui customer_name yang memiliki nilai berbeda

-- INSERT new customers
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
  SELECT b.customer_number
  FROM customer_dim a JOIN customer_stg b ON a.customer_number = b.customer_number
);

Select * From customer_dim

