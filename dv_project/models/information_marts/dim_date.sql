{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'dimension', 'date'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN date_day SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_date PRIMARY KEY(date_day)"
    ]
) -}}

-- Date dimension built from order dates
WITH date_spine AS (
    SELECT DISTINCT
        O_ORDERDATE AS date_day
    FROM {{ source('tpch', 'orders') }}
)

SELECT
    date_day,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    DAYOFMONTH(date_day) AS day_of_month,
    DAYOFWEEK(date_day) AS day_of_week,
    WEEKOFYEAR(date_day) AS week_of_year,
    DATE_FORMAT(date_day, 'MMMM') AS month_name,
    DATE_FORMAT(date_day, 'EEEE') AS day_name,
    CASE 
        WHEN DAYOFWEEK(date_day) IN (1, 7) THEN true 
        ELSE false 
      END AS is_weekend
FROM date_spine
WHERE date_day IS NOT NULL
ORDER BY date_day

