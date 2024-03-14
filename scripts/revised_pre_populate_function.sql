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
