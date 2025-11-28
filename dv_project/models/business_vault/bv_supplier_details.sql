{{- config(
    materialized='table',
    schema='silver_business_vault',
    tags=['silver', 'business_vault', 'supplier']
) -}}

-- Supplier details with nation and region information
WITH supplier_hub AS (
    SELECT * FROM {{ ref('hub_supplier') }}
),

supplier_sat AS (
    SELECT * FROM {{ ref('sat_supplier') }}
),

supplier_nation_link AS (
    SELECT * FROM {{ ref('link_supplier_nation') }}
),

nation_hub AS (
    SELECT * FROM {{ ref('hub_nation') }}
),

nation_sat AS (
    SELECT * FROM {{ ref('sat_nation') }}
),

nation_region_link AS (
    SELECT * FROM {{ ref('link_nation_region') }}
),

region_hub AS (
    SELECT * FROM {{ ref('hub_region') }}
),

region_sat AS (
    SELECT * FROM {{ ref('sat_region') }}
)

SELECT
    sh.SUPPLIER_PK,
    sh.S_SUPPKEY,
    ss.S_NAME,
    ss.S_ADDRESS,
    ss.S_PHONE,
    ss.S_ACCTBAL,
    ss.S_COMMENT,
    nh.N_NATIONKEY,
    ns.N_NAME AS NATION_NAME,
    rh.R_REGIONKEY,
    rs.R_NAME AS REGION_NAME,
    sh.LOAD_DATE AS SUPPLIER_LOAD_DATE,
    ss.EFFECTIVE_FROM AS SUPPLIER_EFFECTIVE_FROM
FROM supplier_hub sh
LEFT JOIN supplier_sat ss ON sh.SUPPLIER_PK = ss.SUPPLIER_PK
LEFT JOIN supplier_nation_link snl ON sh.SUPPLIER_PK = snl.SUPPLIER_PK
LEFT JOIN nation_hub nh ON snl.NATION_PK = nh.NATION_PK
LEFT JOIN nation_sat ns ON nh.NATION_PK = ns.NATION_PK
LEFT JOIN nation_region_link nrl ON nh.NATION_PK = nrl.NATION_PK
LEFT JOIN region_hub rh ON nrl.REGION_PK = rh.REGION_PK
LEFT JOIN region_sat rs ON rh.REGION_PK = rs.REGION_PK

