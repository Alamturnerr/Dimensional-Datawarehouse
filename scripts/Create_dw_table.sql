-- creating customer_dim table
CREATE TABLE customer_dim (
    customer_sk SERIAL PRIMARY KEY,
    customer_number INT,
    customer_name VARCHAR(50),
    customer_street_address VARCHAR(50),
    customer_zip_code INT,
    customer_city VARCHAR(30),
    customer_state CHAR(2),
    effective_date DATE,
    expiry_date DATE
);

-- creating product_dim table
CREATE TABLE product_dim (
    product_sk SERIAL PRIMARY KEY,
    product_code INT,
    product_name VARCHAR(30),
    product_category VARCHAR(30),
    effective_date DATE,
    expiry_date DATE
);

-- creating order_dim table
CREATE TABLE order_dim (
    order_sk SERIAL PRIMARY KEY,
    order_number INT,
    effective_date DATE,
    expiry_date DATE
);

-- creating date_dim table
CREATE TABLE date_dim (
    date_sk SERIAL PRIMARY KEY,
    date DATE,
    month_name VARCHAR(9),
    month INT,
    quarter INT,
    year INT,
    effective_date DATE,
    expiry_date DATE
);

-- creating sales_order_fact_table
CREATE TABLE sales_order_fact (
    order_sk INT,
    customer_sk INT,
    product_sk INT,
    order_date_sk INT,
    order_amount DECIMAL(10, 2)
);

select * from sales_order_fact
