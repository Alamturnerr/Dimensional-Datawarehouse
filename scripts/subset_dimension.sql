-- Month Roll Up Dimension
CREATE TABLE month_dim (
  month_sk SERIAL PRIMARY KEY,
  month_name CHAR(9),
  month INT,
  quarter INT,
  year INT,
  effective_date DATE,
  expiry_date DATE
);

INSERT INTO month_dim (month_name, month, quarter, year, effective_date, expiry_date)
SELECT DISTINCT
  month_name,
  month,
  quarter,
  year,
  effective_date,
  expiry_date
FROM date_dim;

select month_sk msk, month_name, month, quarter q, year, effective_date efdate, expiry_date exdate from month_dim;

-- Pensylvania Customer Dimension
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
    
    -- Insert distinct months into month_dim
    INSERT INTO month_dim
    SELECT DISTINCT
        NULL,
        month_name,
        month,
        quarter,
        year,
        effective_date,
        expiry_date
    FROM date_dim
    WHERE (month, year) NOT IN (
        SELECT month, year FROM month_dim
    );
END;
$$ LANGUAGE plpgsql;

INSERT INTO customer_dim (
    customer_number,
    customer_name,
    customer_street_address,
    customer_zip_code,
    customer_city,
    customer_state,
    shipping_address,
    shipping_zip_code,
    shipping_city,
    shipping_state,
    effective_date,
    expiry_date
)
VALUES
    (DEFAULT, 10, 'Bigger Customers', '7777 Ridge Rd.', '44102',
    'Cleveland', 'OH', '7777 Ridge Rd.', '44102', 'Cleveland',
    'OH', CURRENT_DATE, '9999-12-31'),
    (DEFAULT, 11, 'Smaller Stores', '8888 Jennings Fwy.', '44102',
    'Cleveland', 'OH', '8888 Jennings Fwy.', '44102', 'Cleveland',
    'OH', CURRENT_DATE, '9999-12-31'),
    (DEFAULT, 12, 'Small-Medium Retailers', '9999 Memphis Ave.', '44102',
    'Cleveland', 'OH', '9999 Memphis Ave.', '44102', 'Cleveland',
    'OH', CURRENT_DATE, '9999-12-31');
