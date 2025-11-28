{{- config(
    materialized='table',
    schema='information_marts',
    tags=['dimension', 'customer'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN customer_key SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_customer PRIMARY KEY(customer_key)"
    ]
) -}}

-- Customer dimension for analytical queries
SELECT
    CUSTOMER_PK AS customer_key,
    C_CUSTKEY AS customer_id,
    C_NAME AS customer_name,
    C_ADDRESS AS customer_address,
    C_PHONE AS customer_phone,
    C_ACCTBAL AS customer_account_balance,
    C_MKTSEGMENT AS customer_market_segment,
    C_COMMENT AS customer_comment,
    N_NATIONKEY AS nation_id,
    NATION_NAME,
    R_REGIONKEY AS region_id,
    REGION_NAME,
    CUSTOMER_LOAD_DATE AS load_date,
    CUSTOMER_EFFECTIVE_FROM AS effective_from
FROM {{ ref('bv_customer_details') }}
WHERE CUSTOMER_PK IS NOT NULL

