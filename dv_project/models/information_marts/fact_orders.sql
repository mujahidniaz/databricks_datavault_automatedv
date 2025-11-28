{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'fact', 'orders'],
    post_hook=[
        "ALTER TABLE {{ this }} ALTER COLUMN order_key SET NOT NULL",
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_fact_orders PRIMARY KEY(order_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_orders_customer FOREIGN KEY(customer_key) REFERENCES {{ ref('dim_customer') }}(customer_key)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_orders_date FOREIGN KEY(order_date) REFERENCES {{ ref('dim_date') }}(date_day)"
    ]
) -}}

-- Orders fact table
WITH order_details AS (
    SELECT * FROM {{ ref('bv_order_details') }}
),

customer_dim AS (
    SELECT * FROM {{ ref('dim_customer') }}
)

SELECT
    od.ORDER_PK AS order_key,
    od.O_ORDERKEY AS order_id,
    cd.customer_key,
    cd.customer_id,
    cd.customer_name,
    cd.nation_id,
    cd.NATION_NAME,
    cd.region_id,
    cd.REGION_NAME,
    od.O_ORDERDATE AS order_date,
    od.O_ORDERSTATUS AS order_status,
    od.O_TOTALPRICE AS total_price,
    od.O_ORDERPRIORITY AS order_priority,
    od.O_CLERK AS clerk,
    od.O_SHIPPRIORITY AS ship_priority,
    od.O_COMMENT AS order_comment,
    od.ORDER_LOAD_DATE AS load_date
FROM order_details od
LEFT JOIN customer_dim cd ON od.CUSTOMER_PK = cd.customer_key
WHERE od.ORDER_PK IS NOT NULL

