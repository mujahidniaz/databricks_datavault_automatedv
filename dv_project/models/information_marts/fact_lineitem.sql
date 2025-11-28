{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'fact', 'lineitem'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN lineitem_key SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_fact_lineitem PRIMARY KEY(lineitem_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_lineitem_order FOREIGN KEY(order_key) REFERENCES {{ ref('fact_orders') }}(order_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_lineitem_customer FOREIGN KEY(customer_key) REFERENCES {{ ref('dim_customer') }}(customer_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_lineitem_part FOREIGN KEY(part_key) REFERENCES {{ ref('dim_part') }}(part_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_lineitem_supplier FOREIGN KEY(supplier_key) REFERENCES {{ ref('dim_supplier') }}(supplier_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_lineitem_date FOREIGN KEY(order_date) REFERENCES {{ ref('dim_date') }}(date_day)"
    ]
) -}}

-- Line item fact table with all dimensions
WITH stg_lineitem AS (
    SELECT * FROM {{ ref('stg_lineitem') }}
),

order_details AS (
    SELECT * FROM {{ ref('bv_order_details') }}
),

customer_dim AS (
    SELECT * FROM {{ ref('dim_customer') }}
),

part_dim AS (
    SELECT * FROM {{ ref('dim_part') }}
),

supplier_dim AS (
    SELECT * FROM {{ ref('dim_supplier') }}
)

SELECT
    li.LINEITEM_PK AS lineitem_key,
    li.ORDER_PK AS order_key,
    od.O_ORDERKEY AS order_id,
    od.O_ORDERDATE AS order_date,
    od.CUSTOMER_PK AS customer_key,
    od.C_CUSTKEY AS customer_id,
    od.CUSTOMER_NAME,
    cd.NATION_NAME AS customer_nation,
    cd.REGION_NAME AS customer_region,
    li.PART_PK AS part_key,
    pd.part_id,
    pd.part_name,
    pd.manufacturer,
    pd.brand,
    pd.part_type,
    li.SUPPLIER_PK AS supplier_key,
    sd.supplier_id,
    sd.supplier_name,
    sd.NATION_NAME AS supplier_nation,
    sd.REGION_NAME AS supplier_region,
    li.L_QUANTITY AS quantity,
    li.L_EXTENDEDPRICE AS extended_price,
    li.L_DISCOUNT AS discount,
    li.L_TAX AS tax,
    li.L_EXTENDEDPRICE * (1 - li.L_DISCOUNT) AS discounted_price,
    li.L_EXTENDEDPRICE * (1 - li.L_DISCOUNT) * (1 + li.L_TAX) AS total_price,
    li.L_RETURNFLAG AS return_flag,
    li.L_LINESTATUS AS line_status,
    li.L_SHIPDATE AS ship_date,
    li.L_COMMITDATE AS commit_date,
    li.L_RECEIPTDATE AS receipt_date,
    li.L_SHIPINSTRUCT AS ship_instructions,
    li.L_SHIPMODE AS ship_mode,
    li.L_COMMENT AS line_comment,
    li.LOAD_DATE AS load_date
FROM stg_lineitem li
LEFT JOIN order_details od ON li.ORDER_PK = od.ORDER_PK
LEFT JOIN customer_dim cd ON od.CUSTOMER_PK = cd.customer_key
LEFT JOIN part_dim pd ON li.PART_PK = pd.part_key
LEFT JOIN supplier_dim sd ON li.SUPPLIER_PK = sd.supplier_key
WHERE li.LINEITEM_PK IS NOT NULL

