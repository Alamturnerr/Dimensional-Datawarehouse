-- INSERT INTO order_dim
INSERT INTO order_dim (order_number, effective_date, expiry_date)
VALUES
  (17, '2007-02-06', '9999-12-31'),
  (18, '2007-02-06', '9999-12-31'),
  (19, '2007-02-06', '9999-12-31'),
  (20, '2007-02-06', '9999-12-31');


-- INSERT INTO date_dim
INSERT INTO date_dim (date, month_name, month, quarter, year, effective_date, expiry_date)
VALUES
  ('2007-02-06', 'February', 2, 6, 2007, '2007-02-05', '9999-12-31');
select * from date_dim

-- Creating 
DROP PROCEDURE IF EXISTS push_sales_order()


call push_sales_order()
select push_sales_order()
CREATE OR REPLACE FUNCTION push_sales_order() RETURNS VOID AS $$
BEGIN
    -- Menghapus data lama dari tabel data warehouse jika diperlukan
    -- DELETE FROM data_warehouse_table;
    
    -- Menambahkan data baru dari database sumber menggunakan dblink
    INSERT INTO sales_order_fact (order_sk, customer_sk, product_sk, order_date_sk, order_amount)
    SELECT 
        order_number, 
        customer_number, 
        product_code, 
        order_date, 
        order_amount
    FROM dblink('host=localhost dbname=sumber user=postgres', 'SELECT * FROM sales_order') 
    AS sales_order (order_number INT, customer_number INT, product_code INT, order_date INT, order_amount DECIMAL(10,2));
END;
$$ LANGUAGE plpgsql;





-- Testing
-- Creating Table
CREATE TABLE sales_order(
 order_number INT,
 customer_number INT,
 product_code INT,
 order_date DATE,
 entry_date DATE,
 order_amount DECIMAL (10, 2));

-- Insert Into
INSERT INTO sales_order VALUES
  (17, 1, 1, '2007-02-06', '2007-02-06', 1000),
  (18, 2, 1, '2007-02-06', '2007-02-06', 1000),
  (19, 3, 1, '2007-02-06', '2007-02-06', 4000),
  (20, 4, 1, '2007-02-06', '2007-02-06', 4000);
INSERT INTO sales_order VALUES
  (21, 1, 3, '2007-02-07', '2007-02-07', 1000)
, (22, 2, 3, '2007-02-08', '2007-02-08', 1000)
, (23, 3, 3, '2007-02-09', '2007-02-09', 4000)
, (24, 4, 3, '2007-02-10', '2007-02-10', 4000);

INSERT INTO sales_order VALUES
  (22, 1, 1, '2007-03-01', '2007-03-01', 1000),
  (23, 2, 2, '2007-03-01', '2007-03-01', 2000),
  (24, 3, 3, '2007-03-01', '2007-03-01', 3000),
  (25, 4, 4, '2007-03-01', '2007-03-01', 4000),
  (26, 5, 2, '2007-03-01', '2007-03-01', 1000),
  (27, 6, 2, '2007-03-01', '2007-03-01', 3000),
  (28, 7, 3, '2007-03-01', '2007-03-01', 5000),
  (29, 8, 4, '2007-03-01', '2007-03-01', 7000),
  (30, 1, 1, '2007-03-01', '2007-03-01', 1000),
  (31, 2, 2, '2007-03-01', '2007-03-01', 2000),
  (32, 3, 3, '2007-03-01', '2007-03-01', 4000),
  (33, 4, 4, '2007-03-01', '2007-03-01', 6000),
  (34, 5, 1, '2007-03-01', '2007-03-01', 2500),
  (35, 6, 2, '2007-03-01', '2007-03-01', 5000),
  (36, 7, 3, '2007-03-01', '2007-03-01', 7500),
  (37, 8, 4, '2007-03-01', '2007-03-01', 1000);
