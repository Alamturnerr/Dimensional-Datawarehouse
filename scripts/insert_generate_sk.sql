INSERT INTO customer_dim
( customer_sk
, customer_number
, customer_name
, customer_street_address
, customer_zip_code
, customer_city
, customer_state
, effective_date
, expiry_date )
VALUES
  (DEFAULT, 1, 'Big Customers', '7500 Louise Dr.', '17050',
       'Mechanicsburg', 'PA', CURRENT_DATE, '9999-12-31'),
  (DEFAULT, 2, 'Small Stores', '2500 Woodland St.', '17055',
       'Pittsburgh', 'PA', CURRENT_DATE, '9999-12-31'),
  (DEFAULT, 3, 'Medium Retailers', '1111 Ritter Rd.', '17055',
       'Pittsburgh', 'PA', CURRENT_DATE, '9999-12-31'),
  (DEFAULT, 4, 'Good Companies', '9500 Scott St.', '17050',
       'Mechanicsburg', 'PA', CURRENT_DATE, '9999-12-31'),
  (DEFAULT, 5, 'Wonderful Shops', '3333 Rossmoyne Rd.', '17050',
       'Mechanicsburg', 'PA', CURRENT_DATE, '9999-12-31'),
  (DEFAULT, 6, 'Loyal Clients', '7070 Ritter Rd.', '17055',
       'Pittsburgh', 'PA', CURRENT_DATE, '9999-12-31');

SELECT * FROM customer_dim
