CREATE OR REPLACE FUNCTION populate_date_dimension(start_date DATE, end_date DATE)
RETURNS VOID AS
$$
BEGIN
    WHILE start_date <= end_date LOOP
        INSERT INTO date_dim (date, day, month, quarter, year, day_of_week, effective_date, expiry_date)
        VALUES (start_date, EXTRACT(DAY FROM start_date), EXTRACT(MONTH FROM start_date), 
                EXTRACT(QUARTER FROM start_date), EXTRACT(YEAR FROM start_date), 
                EXTRACT(ISODOW FROM start_date), CURRENT_DATE, '9999-12-31');

        -- Populating month roll-up dimension if month not already in month_dim
        INSERT INTO month_dim (month_name, month, quarter, year, effective_date, expiry_date)
        SELECT DISTINCT 
            TO_CHAR(start_date, 'Month'),
            EXTRACT(MONTH FROM start_date),
            EXTRACT(QUARTER FROM start_date),
            EXTRACT(YEAR FROM start_date),
            CURRENT_DATE,
            '9999-12-31'
        WHERE NOT EXISTS (
            SELECT 1 FROM month_dim WHERE month = EXTRACT(MONTH FROM start_date) AND year = EXTRACT(YEAR FROM start_date)
        );

        start_date := start_date + INTERVAL '1 day';
    END LOOP;
END;
$$
LANGUAGE plpgsql;
