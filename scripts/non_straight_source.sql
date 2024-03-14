-- Non Straight Source
CREATE TABLE non_straight_campaign_stg (
  campaign_session CHAR(30),
  start_month CHAR(9),
  start_year INT,
  end_month CHAR(9),
  end_year INT );
--
UPDATE month_dim
SET campaign_session = NULL;

--
TRUNCATE TABLE non_straight_campaign_stg; -- Kosongkan tabel sebelum memuat data

COPY non_straight_campaign_stg (
  campaign_session,
  start_month,
  start_year,
  end_month,
  end_year )
FROM '/private/tmp/non_straight_campaign_dataset.csv'
WITH (FORMAT CSV, DELIMITER ',', NULL '', HEADER TRUE );
--
UPDATE month_dim AS p
SET campaign_session = q.campaign_session
FROM (
    SELECT
        a.month,
        a.year,
        b.campaign_session
    FROM
        month_dim a
    LEFT OUTER JOIN (
        SELECT
            campaign_session,
            start_month::integer AS month,
            start_year::integer AS year
        FROM
            non_straight_campaign_stg
        UNION ALL
        SELECT
            campaign_session,
            end_month::integer AS month,
            end_year::integer AS year
        FROM
            non_straight_campaign_stg
    ) AS b ON a.year = b.year AND a.month = b.month
    ORDER BY
        year,
        month
) AS q
WHERE
    q.campaign_session IS NOT NULL
    AND p.month = q.month
    AND p.year = q.year;
--
UPDATE month_dim AS p
SET campaign_session = r.campaign_session
FROM (
    SELECT
        MIN(a.month) AS minmo,
        MIN(a.year) AS minyear,
        a.campaign_session AS campaign_session,
        MAX(b.month) AS maxmo,
        MAX(b.year) AS maxyear
    FROM
        month_dim a
    JOIN month_dim b ON a.month = b.month AND a.year = b.year
    WHERE
        a.campaign_session IS NOT NULL
        AND b.campaign_session IS NOT NULL
    GROUP BY
        a.campaign_session,
        b.campaign_session
) AS r
WHERE
    p.month > r.minmo
    AND p.year = r.minyear
    AND p.month < r.maxmo
    AND p.year = r.maxyear;
--
SELECT
    month_sk AS m_sk,
    month_name,
    month AS m,
    campaign_session,
    quarter AS q,
    year
FROM month_dim
WHERE year = 2006;





