{{- config(
    materialized='table',
    schema='gold_information_marts',
    tags=['gold', 'mart', 'sales', 'summary']
) -}}

-- Sales summary mart aggregating line items by customer, date, and region
SELECT
    customer_id,
    CUSTOMER_NAME AS customer_name,
    customer_nation,
    customer_region,
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_line_items,
    SUM(quantity) AS total_quantity,
    SUM(extended_price) AS total_extended_price,
    SUM(discounted_price) AS total_discounted_price,
    SUM(total_price) AS total_revenue,
    AVG(discount) AS avg_discount,
    AVG(tax) AS avg_tax
FROM {{ ref('fact_lineitem') }}
GROUP BY
    customer_id,
    CUSTOMER_NAME,
    customer_nation,
    customer_region,
    order_date

