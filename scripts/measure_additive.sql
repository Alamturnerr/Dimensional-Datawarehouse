-- Insert into order_dim table
INSERT INTO order_dim (order_sk, order_number, effective_date, expiry_date)
VALUES
  (DEFAULT, 1, '2007-02-05', '9999-12-31'),
  (DEFAULT, 2, '2007-02-05', '9999-12-31'),
  (DEFAULT, 3, '2007-02-05', '9999-12-31'),
  (DEFAULT, 4, '2007-02-05', '9999-12-31'),
  (DEFAULT, 5, '2007-02-05', '9999-12-31'),
  (DEFAULT, 6, '2007-02-05', '9999-12-31'),
  (DEFAULT, 7, '2007-02-05', '9999-12-31'),
  (DEFAULT, 8, '2007-02-05', '9999-12-31'),
  (DEFAULT, 9, '2007-02-05', '9999-12-31'),
  (DEFAULT, 10, '2007-02-05', '9999-12-31');

-- Insert into date_dim table
INSERT INTO date_dim (date_sk, date, month_name, month, quarter, year, effective_date, expiry_date)
VALUES
  (DEFAULT, '2007-10-31', 'October', 10, 4, 2007, '2007-02-05', '9999-12-31');


-- Insert into sales_order_fact table
INSERT INTO sales_order_fact (order_sk, customer_sk, product_sk, order_date_sk, order_amount)
VALUES
  (1, 1, 2, 1, 1000),
  (2, 2, 3, 1, 1000),
  (3, 3, 4, 1, 4000),
  (4, 4, 2, 1, 4000),
  (5, 5, 3, 1, 6000),
  (6, 1, 4, 1, 6000),
  (7, 2, 2, 1, 8000),
  (8, 3, 3, 1, 8000),
  (9, 4, 4, 1, 10000),
  (10, 5, 2, 1, 10000);

-- Menghitung total order_amount
SELECT SUM (order_amount) sum_of_order_amount
FROM sales_order_fact a;

-- Menghitung order_amount berdasarkan Customer Number
SELECT customer_number, 
SUM (order_amount) sum_of_order_amount
FROM sales_order_fact a, customer_dim b
WHERE a.customer_sk = b.customer_sk
GROUP BY customer_number
ORDER BY customer_number;

-- Menghitung order_amount berdasarkan product_code
SELECT product_code, 
SUM (order_amount) sum_of_order_amount
FROM sales_order_fact a, product_dim b
WHERE a.product_sk = b.product_sk
GROUP BY product_code
ORDER BY product_code;

-- Menghitung Order Amount berdasarkan Customer Number dan Product Code
SELECT
  customer_number, 
  product_code, 
  SUM (order_amount) sum_of_order_amount
FROM
  sales_order_fact a, 
  customer_dim b, 
  product_dim c
WHERE a.customer_sk = b.customer_sk AND a.product_sk = c.product_sk
GROUP BY customer_number, product_code
ORDER BY customer_number

select * from product_dim
