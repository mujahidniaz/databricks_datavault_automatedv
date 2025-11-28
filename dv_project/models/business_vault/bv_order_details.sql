{{- config(
    materialized='table',
    schema='business_vault',
    tags=['business_vault', 'order']
) -}}

-- Order details with customer information
WITH order_hub AS (
    SELECT * FROM {{ ref('hub_order') }}
),

order_sat AS (
    SELECT * FROM {{ ref('sat_order') }}
),

customer_order_link AS (
    SELECT * FROM {{ ref('link_customer_order') }}
),

customer_hub AS (
    SELECT * FROM {{ ref('hub_customer') }}
),

customer_sat AS (
    SELECT * FROM {{ ref('sat_customer') }}
)

SELECT
    oh.ORDER_PK,
    oh.O_ORDERKEY,
    os.O_ORDERSTATUS,
    os.O_TOTALPRICE,
    os.O_ORDERDATE,
    os.O_ORDERPRIORITY,
    os.O_CLERK,
    os.O_SHIPPRIORITY,
    os.O_COMMENT,
    ch.CUSTOMER_PK,
    ch.C_CUSTKEY,
    cs.C_NAME AS CUSTOMER_NAME,
    cs.C_MKTSEGMENT AS CUSTOMER_SEGMENT,
    oh.LOAD_DATE AS ORDER_LOAD_DATE,
    os.EFFECTIVE_FROM AS ORDER_EFFECTIVE_FROM
FROM order_hub oh
LEFT JOIN order_sat os ON oh.ORDER_PK = os.ORDER_PK
LEFT JOIN customer_order_link col ON oh.ORDER_PK = col.ORDER_PK
LEFT JOIN customer_hub ch ON col.CUSTOMER_PK = ch.CUSTOMER_PK
LEFT JOIN customer_sat cs ON ch.CUSTOMER_PK = cs.CUSTOMER_PK

