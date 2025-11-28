{{- config(
    materialized='table',
    schema='information_marts',
    tags=['mart', 'supplier', 'performance']
) -}}

-- Supplier performance mart
SELECT
    supplier_id,
    supplier_name,
    supplier_nation,
    supplier_region,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_line_items,
    SUM(quantity) AS total_quantity_supplied,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_line_value,
    SUM(CASE WHEN return_flag = 'R' THEN 1 ELSE 0 END) AS returned_items,
    SUM(CASE WHEN return_flag = 'R' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS return_rate_pct
FROM {{ ref('fact_lineitem') }}
GROUP BY
    supplier_id,
    supplier_name,
    supplier_nation,
    supplier_region

