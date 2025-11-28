{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'dimension', 'part'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN part_key SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_part PRIMARY KEY(part_key)"
    ]
) -}}

-- Part dimension for analytical queries
WITH part_hub AS (
    SELECT * FROM {{ ref('hub_part') }}
),

part_sat AS (
    SELECT * FROM {{ ref('sat_part') }}
)

SELECT
    ph.PART_PK AS part_key,
    ph.P_PARTKEY AS part_id,
    ps.P_NAME AS part_name,
    ps.P_MFGR AS manufacturer,
    ps.P_BRAND AS brand,
    ps.P_TYPE AS part_type,
    ps.P_SIZE AS part_size,
    ps.P_CONTAINER AS container,
    ps.P_RETAILPRICE AS retail_price,
    ps.P_COMMENT AS part_comment,
    ph.LOAD_DATE AS load_date,
    ps.EFFECTIVE_FROM AS effective_from
FROM part_hub ph
LEFT JOIN part_sat ps ON ph.PART_PK = ps.PART_PK
WHERE ph.PART_PK IS NOT NULL

