-- Create Function

CREATE OR REPLACE FUNCTION pre_populate_date(start_dt DATE, end_dt DATE)
RETURNS VOID AS $$
DECLARE
    curr_date DATE := start_dt;
BEGIN
    WHILE curr_date <= end_dt LOOP
        INSERT INTO date_dim(
            date_sk,
            date,
            month_name,
            month,
            quarter,
            year,
            effective_date,
            expiry_date
        )
        VALUES(
            DEFAULT, -- Assuming date_sk is auto-generated
            curr_date,
            TO_CHAR(curr_date, 'Month'),
            EXTRACT(MONTH FROM curr_date),
            EXTRACT(QUARTER FROM curr_date),
            EXTRACT(YEAR FROM curr_date),
            '0001-01-01',
            '9999-12-31'
        );
        
        curr_date := curr_date + INTERVAL '1 day';
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-----
select pre_populate_date('2007-01-01', '2010-12-31')

select count(0) from date_dim
truncate date_dim

select * from date_dim limit 10

-- One Date
INSERT INTO date_dim (
    date_sk,
    date,
    month_name,
    month,
    quarter,
    year,
    effective_date,
    expiry_date
) 
VALUES (
    DEFAULT,
    '2007-02-07',  -- Ubah CURRENT_DATE menjadi tanggal yang diinginkan
    TO_CHAR('2007-02-07'::DATE, 'Month'),
    EXTRACT(MONTH FROM '2007-02-07'::DATE),
    EXTRACT(QUARTER FROM '2007-02-07'::DATE),
    EXTRACT(YEAR FROM '2007-02-07'::DATE),
    '0001-01-01',
    '9999-12-31'
);

Select * from date_dim

---
truncate date_dim
INSERT INTO date_dim(date, month_name, month, quarter, year, effective_date, expiry_date)
SELECT DISTINCT
  order_date,
  TO_CHAR(order_date, 'Month'),
  EXTRACT(MONTH FROM order_date),
  EXTRACT(QUARTER FROM order_date),
  EXTRACT(YEAR FROM order_date),
  DATE '0001-01-01',
  DATE '9999-12-31'
FROM sales_order
WHERE order_date NOT IN (
  SELECT date FROM date_dim
);

select * from sales_order
select * from date_dim
----
truncate date_dim
INSERT INTO date_dim(date, month_name, month, quarter, year, effective_date, expiry_date)
SELECT DISTINCT
  order_date,
  TO_CHAR(order_date, 'Month'),
  EXTRACT(MONTH FROM order_date),
  EXTRACT(QUARTER FROM order_date),
  EXTRACT(YEAR FROM order_date),
  DATE '0001-01-01',
  DATE '9999-12-31'
FROM sales_order
WHERE order_date NOT IN (
  SELECT date FROM date_dim
);
truncate date_dim
select * from sales_order
SELECT * FROM date_dim ORDER BY date







