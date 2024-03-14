-- Accumulated Measures
CREATE TABLE month_end_balance_fact (
    month_sk INT,
    product_sk INT,
    month_end_amount_balance DECIMAL(10, 2),
    month_end_quantity_balance INT );
-- Initial Population

/* January */
INSERT INTO month_end_balance_fact
SELECT m.*
FROM
   month_end_sales_order_fact m
JOIN
   month_dim n ON m.month_order_sk = n.month_sk
WHERE
   n.month = 1;
/* February */

-- Menambahkan saldo akhir bulan Februari dengan saldo akhir bulan Januari
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 1
JOIN
  month_dim p ON p.month = 2 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk;

-- Menambahkan saldo akhir bulan Februari untuk produk yang belum memiliki saldo akhir bulan Januari
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 2
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 1 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL;

-- Menambahkan saldo akhir bulan Februari untuk produk yang tidak memiliki penjualan di bulan Januari
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 1
JOIN
  month_dim o ON o.month = 2 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 2 AND y.year = n.year);
/* March */

-- Menambahkan saldo akhir bulan Maret dengan saldo akhir bulan Februari
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 2
JOIN
  month_dim p ON p.month = 3 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year <= 2007;

-- Menambahkan saldo akhir bulan Maret untuk produk yang belum memiliki saldo akhir bulan Februari
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 3
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 2 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year <= 2007;

-- Menambahkan saldo akhir bulan Maret untuk produk yang tidak memiliki penjualan di bulan Februari
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 2
JOIN
  month_dim o ON o.month = 3 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 3 AND y.year = n.year
  )
  AND o.year <= 2007;
/* April */

-- Menambahkan saldo akhir bulan April dengan saldo akhir bulan Maret
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 3
JOIN
  month_dim p ON p.month = 4 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year <= 2007;

-- Menambahkan saldo akhir bulan April untuk produk yang belum memiliki saldo akhir bulan Maret
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 4
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 3 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year <= 2007;

-- Menambahkan saldo akhir bulan April untuk produk yang tidak memiliki penjualan di bulan Maret
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 3
JOIN
  month_dim o ON o.month = 4 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 4 AND y.year = n.year
  )
  AND o.year <= 2007;

/* May */

-- Menambahkan saldo akhir bulan Mei dengan saldo akhir bulan April
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 4
JOIN
  month_dim p ON p.month = 5 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan Mei untuk produk yang belum memiliki saldo akhir bulan April
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 5
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 4 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan Mei untuk produk yang tidak memiliki penjualan di bulan April
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 4
JOIN
  month_dim o ON o.month = 5 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 5 AND y.year = n.year
  )
  AND o.year < 2007;

/* June */

-- Menambahkan saldo akhir bulan Juni dengan saldo akhir bulan Mei
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 5
JOIN
  month_dim p ON p.month = 6 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan Juni untuk produk yang belum memiliki saldo akhir bulan Mei
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 6
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 5 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan Juni untuk produk yang tidak memiliki penjualan di bulan Mei
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 5
JOIN
  month_dim o ON o.month = 6 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 6 AND y.year = n.year
  )
  AND o.year < 2007;

/* July */

-- Menambahkan saldo akhir bulan Juli dengan saldo akhir bulan Juni
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 6
JOIN
  month_dim p ON p.month = 7 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan Juli untuk produk yang belum memiliki saldo akhir bulan Juni
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 7
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 6 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan Juli untuk produk yang tidak memiliki penjualan di bulan Juni
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 6
JOIN
  month_dim o ON o.month = 7 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 7 AND y.year = n.year
  )
  AND o.year < 2007;

/* September */

-- Menambahkan saldo akhir bulan September dengan saldo akhir bulan Agustus
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 8
JOIN
  month_dim p ON p.month = 9 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan September untuk produk yang belum memiliki saldo akhir bulan Agustus
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 9
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 8 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan September untuk produk yang tidak memiliki penjualan di bulan Agustus
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 8
JOIN
  month_dim o ON o.month = 9 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 9 AND y.year = n.year
  )
  AND o.year < 2007;

/* October */

-- Menambahkan saldo akhir bulan Oktober dengan saldo akhir bulan September
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 9
JOIN
  month_dim p ON p.month = 10 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan Oktober untuk produk yang belum memiliki saldo akhir bulan September
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 10
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 9 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan Oktober untuk produk yang tidak memiliki penjualan di bulan September
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 9
JOIN
  month_dim o ON o.month = 10 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 10 AND y.year = n.year
  )
  AND o.year < 2007;

/* November */

-- Menambahkan saldo akhir bulan November dengan saldo akhir bulan Oktober
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 10
JOIN
  month_dim p ON p.month = 11 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan November untuk produk yang belum memiliki saldo akhir bulan Oktober
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 11
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 10 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan November untuk produk yang tidak memiliki penjualan di bulan Oktober
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 10
JOIN
  month_dim o ON o.month = 11 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 11 AND y.year = n.year
  )
  AND o.year < 2007;

/* December */

-- Menambahkan saldo akhir bulan Desember dengan saldo akhir bulan November
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, (n.month_order_amount + m.month_end_amount_balance), (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN
  month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN
  month_dim o ON o.month = 11
JOIN
  month_dim p ON p.month = 12 AND o.year = p.year
WHERE
  m.product_sk = n.product_sk
  AND p.year < 2007;

-- Menambahkan saldo akhir bulan Desember untuk produk yang belum memiliki saldo akhir bulan November
INSERT INTO month_end_balance_fact
SELECT n.month_order_sk, n.product_sk, n.month_order_amount, n.month_order_quantity
FROM
  month_end_sales_order_fact n
JOIN
  month_dim o ON o.month = 12
LEFT JOIN
  month_end_balance_fact m ON m.product_sk = n.product_sk
JOIN
  month_dim y ON y.month = 11 AND m.month_sk = y.month_sk
WHERE
  m.product_sk IS NULL
  AND y.year < 2007;

-- Menambahkan saldo akhir bulan Desember untuk produk yang tidak memiliki penjualan di bulan November
INSERT INTO month_end_balance_fact
SELECT o.month_sk, m.product_sk, m.month_end_amount_balance, m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN
  month_dim n ON n.month = 11
JOIN
  month_dim o ON o.month = 12 AND n.year = o.year
WHERE
  m.product_sk NOT IN (
    SELECT x.product_sk
    FROM  month_end_sales_order_fact x
    JOIN month_dim y ON x.month_order_sk = y.month_sk
    WHERE y.month = 12 AND y.year = n.year
  )
  AND o.year < 2007;
-- END INITIAL POPULATION
--
SELECT month_order_sk AS mosk, 
       product_sk AS psk,
       month_order_amount AS amt,
       month_order_quantity AS qty 
FROM month_end_sales_order_fact
ORDER BY month_order_sk, product_sk;
--
SELECT month_sk AS msk, 
       product_sk AS psk, 
       month_end_amount_balance AS amt,
       month_end_quantity_balance AS qty 
FROM month_end_balance_fact
ORDER BY month_sk, product_sk;
--
INSERT INTO month_end_balance_fact
SELECT m.*
FROM
  month_end_sales_order_fact m
JOIN month_dim n ON m.month_order_sk = n.month_sk
WHERE
    month = 1
AND EXTRACT(YEAR FROM TO_DATE(n.year::TEXT, 'YYYY')) = EXTRACT(YEAR FROM DATE '2007-03-27');
--
INSERT INTO month_end_balance_fact
SELECT
  n.month_order_sk,
  n.product_sk,
  (n.month_order_amount + m.month_end_amount_balance),
  (n.month_order_quantity + m.month_end_quantity_balance)
FROM
  month_end_balance_fact m
JOIN month_end_sales_order_fact n ON m.month_sk = n.month_order_sk
JOIN month_dim o ON m.month_sk = o.month_sk
JOIN month_dim p ON n.month_order_sk = p.month_sk
WHERE
  o.month = EXTRACT(MONTH FROM CURRENT_DATE) - 1
  AND p.month = EXTRACT(MONTH FROM CURRENT_DATE)
  AND o.year = p.year;

INSERT INTO month_end_balance_fact
SELECT
  m.*
FROM
  month_end_sales_order_fact m
JOIN month_dim n ON m.month_order_sk = n.month_sk
WHERE
  n.month = EXTRACT(MONTH FROM CURRENT_DATE)
  AND m.product_sk NOT IN (
    SELECT
      x.product_sk
    FROM
      month_end_balance_fact x
    JOIN month_dim y ON x.month_sk = y.month_sk
    WHERE
      y.month = EXTRACT(MONTH FROM CURRENT_DATE) - 1
      AND y.year = n.year
  );

INSERT INTO month_end_balance_fact
SELECT
  o.month_sk,
  m.product_sk,
  m.month_end_amount_balance,
  m.month_end_quantity_balance
FROM
  month_end_balance_fact m
JOIN month_dim n ON m.month_sk = n.month_sk
JOIN month_dim o ON n.month - 1 = o.month
WHERE
  n.month = EXTRACT(MONTH FROM CURRENT_DATE) - 1
  AND o.year = n.year;
--
SELECT
  b.year,
  b.month,
  SUM(a.month_end_amount_balance)
FROM
  month_end_balance_fact a
JOIN month_dim b ON a.month_sk = b.month_sk
GROUP BY b.year, b.month
ORDER BY b.year, b.month;














