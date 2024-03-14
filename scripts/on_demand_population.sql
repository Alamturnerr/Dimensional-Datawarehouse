CREATE TABLE promo_schedule_stg (
  promo_code CHAR(2),
  promo_name CHAR(30),
  promo_start_date DATE,
  promo_last_date DATE
);


TRUNCATE promo_schedule_stg;

COPY promo_schedule_stg (
    promo_code,
    promo_name,
    promo_start_date,
    promo_last_date
) FROM '/path/to/promo_schedule.csv' DELIMITER ',' CSV HEADER;

UPDATE date_dim a
SET promo_ind = 'Y'
FROM promo_schedule_stg b
WHERE a.date >= b.promo_start_date
  AND a.date <= b.promo_last_date;

select * from date_dim where date >= '2007-04-01' and date <= '2007-04-10'