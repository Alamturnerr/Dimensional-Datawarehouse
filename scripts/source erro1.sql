CREATE EXTENSION IF NOT EXISTS dblink;



-- Creating Table
CREATE TABLE sales_order(
 order_number INT,
 customer_number INT,
 product_code INT,
 order_date INT,
 entry_date DATE,
 order_amount DECIMAL (10, 2));
 drop table if exists sales_order
-- Insert Into
 TRUNCATE sales_order

INSERT INTO sales_order VALUES
  (17, 1, 1, 2007-02-06, '2007-02-06', 1000),
  (18, 2, 1, 2007-02-06, '2007-02-06', 1000),
  (19, 3, 1, 2007-02-06, '2007-02-06', 4000),
  (20, 4, 1, 2007-02-06, '2007-02-06', 4000);
 
-- Create Function


