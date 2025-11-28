{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'dimension', 'supplier'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN supplier_key SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_supplier PRIMARY KEY(supplier_key)"
    ]
) -}}

-- Supplier dimension for analytical queries
SELECT
    SUPPLIER_PK AS supplier_key,
    S_SUPPKEY AS supplier_id,
    S_NAME AS supplier_name,
    S_ADDRESS AS supplier_address,
    S_PHONE AS supplier_phone,
    S_ACCTBAL AS supplier_account_balance,
    S_COMMENT AS supplier_comment,
    N_NATIONKEY AS nation_id,
    NATION_NAME,
    R_REGIONKEY AS region_id,
    REGION_NAME,
    SUPPLIER_LOAD_DATE AS load_date,
    SUPPLIER_EFFECTIVE_FROM AS effective_from
FROM {{ ref('bv_supplier_details') }}
WHERE SUPPLIER_PK IS NOT NULL

