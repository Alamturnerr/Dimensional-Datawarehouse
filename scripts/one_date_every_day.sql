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
SELECT
    NULL,
    CURRENT_DATE,
    TO_CHAR(CURRENT_DATE, 'Month'),
    EXTRACT(MONTH FROM CURRENT_DATE),
    EXTRACT(QUARTER FROM CURRENT_DATE),
    EXTRACT(YEAR FROM CURRENT_DATE),
    '0000-00-00',
    '9999-12-31';
