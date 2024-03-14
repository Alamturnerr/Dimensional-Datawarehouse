--
ALTER TABLE date_dim
ADD COLUMN promo_ind CHAR(1);
-- Create Staging Promo 
CREATE TABLE promo_schedule_stg (
  promo_code CHAR(2),
  promo_name CHAR(30),
  promo_start_date DATE,
  promo_last_date DATE);
-- Clear data
TRUNCATE TABLE promo_schedule_stg;

-- Load Data
COPY promo_schedule_stg (promo_code, promo_name, promo_start_date, promo_last_date)
FROM '/private/tmp/on_demand_population_dataset.csv' DELIMITER ',' CSV HEADER;

-- Update Data
UPDATE date_dim AS a
SET promo_ind = 'Y'
FROM promo_schedule_stg AS b
WHERE a.date BETWEEN b.promo_start_date AND b.promo_last_date;

--
SELECT * FROM date_dim 
WHERE date >= '2007-04-01' AND date <= '2007-04-10';

-- END






