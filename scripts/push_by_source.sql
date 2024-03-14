CREATE TABLE source.sales_order (
    order_number INT,
    customer_number INT,
    product_code INT,
    order_date DATE,
    entry_date DATE,
    order_amount DECIMAL(10, 2)
);
-- Insert data into order_dim table
INSERT INTO dw.order_dim (order_sk, order_number, effective_date, expiry_date)
VALUES
  (17, 17, CURRENT_DATE, '9999-12-31'),
  (18, 18, CURRENT_DATE, '9999-12-31'),
  (19, 19, CURRENT_DATE, '9999-12-31'),
  (20, 20, CURRENT_DATE, '9999-12-31');

-- Insert data ke date_dim table
INSERT INTO dw.date_dim (date_sk, date, month_name, month, day, year, effective_date, expiry_date)
VALUES
  (17, '2007-02-06', 'February', 2, 6, 2007, CURRENT_DATE, '9999-12-31');
-- Insert data ke sales_order table did alam source database
INSERT INTO source.sales_order VALUES
  (17, 1, 1, '2007-02-06', '2007-02-06', 1000),
  (18, 2, 1, '2007-02-06', '2007-02-06', 1000),
  (19, 3, 1, '2007-02-06', '2007-02-06', 4000),
  (20, 4, 1, '2007-02-06', '2007-02-06', 4000);

-- Creating Function

CREATE OR REPLACE FUNCTION push_sales_order() RETURNS VOID AS $$
BEGIN
    INSERT INTO dw.sales_order_fact (order_amount, order_sk, customer_sk, product_sk, order_date_sk)
    SELECT
        a.order_amount,
        b.order_sk,
        c.customer_sk,
        d.product_sk,
        e.date_sk
    FROM
        source.sales_order a
    JOIN dw.order_dim b ON a.order_number = b.order_number
    JOIN dw.customer_dim c ON a.customer_number = c.customer_number
    JOIN dw.product_dim d ON a.product_code = d.product_code
    JOIN dw.date_dim e ON a.order_date = e.date
    WHERE
        a.entry_date = CURRENT_DATE
        AND a.order_date >= d.effective_date
        AND a.order_date <= d.expiry_date;
END;
$$ LANGUAGE plpgsql;
