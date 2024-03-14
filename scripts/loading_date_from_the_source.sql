INSERT INTO source.sales_order VALUES
  (21, 1, 3, '2007-02-07', '2007-02-07', 1000),
  (22, 2, 3, '2007-02-08', '2007-02-08', 1000),
  (23, 3, 3, '2007-02-09', '2007-02-09', 4000),
  (24, 4, 3, '2007-02-10', '2007-02-10', 4000);

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
SELECT DISTINCT
    NULL,
    order_date,
    TO_CHAR(order_date, 'Month'),
    EXTRACT(MONTH FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(YEAR FROM order_date),
    '0000-00-00',
    '9999-12-31'
FROM
    source.sales_order
WHERE
    order_date NOT IN (SELECT date FROM date_dim);
