{{- config(
    materialized='table',
    schema='business_vault',
    tags=['business_vault', 'customer']
) -}}

-- Customer details with nation and region information
WITH customer_hub AS (
    SELECT * FROM {{ ref('hub_customer') }}
),

customer_sat AS (
    SELECT * FROM {{ ref('sat_customer') }}
),

customer_nation_link AS (
    SELECT * FROM {{ ref('link_customer_nation') }}
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
    ch.CUSTOMER_PK,
    ch.C_CUSTKEY,
    cs.C_NAME,
    cs.C_ADDRESS,
    cs.C_PHONE,
    cs.C_ACCTBAL,
    cs.C_MKTSEGMENT,
    cs.C_COMMENT,
    nh.N_NATIONKEY,
    ns.N_NAME AS NATION_NAME,
    rh.R_REGIONKEY,
    rs.R_NAME AS REGION_NAME,
    ch.LOAD_DATE AS CUSTOMER_LOAD_DATE,
    cs.EFFECTIVE_FROM AS CUSTOMER_EFFECTIVE_FROM
FROM customer_hub ch
LEFT JOIN customer_sat cs ON ch.CUSTOMER_PK = cs.CUSTOMER_PK
LEFT JOIN customer_nation_link cnl ON ch.CUSTOMER_PK = cnl.CUSTOMER_PK
LEFT JOIN nation_hub nh ON cnl.NATION_PK = nh.NATION_PK
LEFT JOIN nation_sat ns ON nh.NATION_PK = ns.NATION_PK
LEFT JOIN nation_region_link nrl ON nh.NATION_PK = nrl.NATION_PK
LEFT JOIN region_hub rh ON nrl.REGION_PK = rh.REGION_PK
LEFT JOIN region_sat rs ON rh.REGION_PK = rs.REGION_PK

