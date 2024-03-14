-- Ragged Hierarchies
-- Kosongkan tabel 'campaign_session_stg'
TRUNCATE TABLE campaign_session_stg;

-- Memuat data dari file CSV ke tabel 'campaign_session_stg' menggunakan COPY
COPY campaign_session_stg (campaign_session, month, year)
FROM '/private/tmp/ragged_campaign_session_dataset.csv'
WITH CSV HEADER DELIMITER ',' QUOTE '"';
-- Perhatikan penggunaan QUOTE untuk menentukan karakter kutipan pada file CSV.

-- Memperbarui tabel 'month_dim' dengan nilai dari 'campaign_session_stg'
UPDATE month_dim a
SET campaign_session = b.campaign_session
FROM campaign_session_stg b
WHERE a.month = CAST(b.month AS INTEGER) -- Mengonversi 'month' dari 'campaign_session_stg' ke tipe data integer
AND a.year = b.year
AND b.campaign_session IS NOT NULL;


-- Memperbarui tabel 'month_dim' dengan nama bulan jika 'campaign_session_stg' memiliki nilai NULL
UPDATE month_dim a
SET campaign_session = a.month_name
FROM campaign_session_stg b
WHERE CAST(a.month AS VARCHAR) = b.month -- Mengonversi 'month' dari 'month_dim' ke tipe data karakter
AND a.year = b.year
AND b.campaign_session IS NULL;


UPDATE month_dim
SET campaign_session = NULL;
--

SELECT month_sk, month_name, year, campaign_session
FROM month_dim
WHERE year = 2006;

