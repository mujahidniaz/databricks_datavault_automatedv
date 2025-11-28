-- ========================================
-- Sample Queries for Data Vault Demo
-- ========================================

-- Use the correct catalog
USE CATALOG mujahid_data_vault_demo;

-- ========================================
-- STAGING LAYER QUERIES
-- ========================================

-- View staged customer data with hash keys
SELECT *
FROM staging.stg_customer
LIMIT 10;

-- View staged orders with all hash keys
SELECT 
    O_ORDERKEY,
    ORDER_PK,
    CUSTOMER_PK,
    CUSTOMER_ORDER_FK,
    O_ORDERDATE,
    O_TOTALPRICE
FROM staging.stg_orders
LIMIT 10;

-- ========================================
-- RAW VAULT QUERIES
-- ========================================

-- Count records in each hub
SELECT 'Customers' AS entity, COUNT(*) AS count FROM raw_vault.hub_customer
UNION ALL
SELECT 'Orders' AS entity, COUNT(*) AS count FROM raw_vault.hub_order
UNION ALL
SELECT 'Parts' AS entity, COUNT(*) AS count FROM raw_vault.hub_part
UNION ALL
SELECT 'Suppliers' AS entity, COUNT(*) AS count FROM raw_vault.hub_supplier
UNION ALL
SELECT 'Nations' AS entity, COUNT(*) AS count FROM raw_vault.hub_nation
UNION ALL
SELECT 'Regions' AS entity, COUNT(*) AS count FROM raw_vault.hub_region;

-- Customer satellite data (descriptive attributes)
SELECT 
    h.C_CUSTKEY,
    s.C_NAME,
    s.C_MKTSEGMENT,
    s.C_ACCTBAL,
    s.EFFECTIVE_FROM
FROM raw_vault.hub_customer h
JOIN raw_vault.sat_customer s ON h.CUSTOMER_PK = s.CUSTOMER_PK
LIMIT 20;

-- Link between customers and orders
SELECT 
    ch.C_CUSTKEY,
    oh.O_ORDERKEY,
    col.LOAD_DATE
FROM raw_vault.link_customer_order col
JOIN raw_vault.hub_customer ch ON col.CUSTOMER_PK = ch.CUSTOMER_PK
JOIN raw_vault.hub_order oh ON col.ORDER_PK = oh.ORDER_PK
LIMIT 20;

-- ========================================
-- BUSINESS VAULT QUERIES
-- ========================================

-- Customer details with geography
SELECT 
    C_CUSTKEY AS customer_id,
    C_NAME AS customer_name,
    C_MKTSEGMENT AS market_segment,
    C_ACCTBAL AS account_balance,
    NATION_NAME,
    REGION_NAME
FROM business_vault.bv_customer_details
ORDER BY C_ACCTBAL DESC
LIMIT 20;

-- Order details with customer information
SELECT 
    O_ORDERKEY AS order_id,
    O_ORDERDATE AS order_date,
    O_TOTALPRICE AS total_price,
    O_ORDERSTATUS AS status,
    CUSTOMER_NAME,
    CUSTOMER_SEGMENT
FROM business_vault.bv_order_details
ORDER BY O_ORDERDATE DESC
LIMIT 20;

-- Supplier details with geography
SELECT 
    S_SUPPKEY AS supplier_id,
    S_NAME AS supplier_name,
    S_ACCTBAL AS account_balance,
    NATION_NAME,
    REGION_NAME
FROM business_vault.bv_supplier_details
ORDER BY S_ACCTBAL DESC
LIMIT 20;

-- ========================================
-- INFORMATION MARTS - DIMENSIONS
-- ========================================

-- Customer dimension
SELECT 
    customer_id,
    customer_name,
    customer_market_segment,
    customer_account_balance,
    NATION_NAME,
    REGION_NAME
FROM information_marts.dim_customer
ORDER BY customer_account_balance DESC
LIMIT 20;

-- Supplier dimension
SELECT 
    supplier_id,
    supplier_name,
    supplier_account_balance,
    NATION_NAME,
    REGION_NAME
FROM information_marts.dim_supplier
ORDER BY supplier_account_balance DESC
LIMIT 20;

-- Part dimension
SELECT 
    part_id,
    part_name,
    manufacturer,
    brand,
    part_type,
    retail_price
FROM information_marts.dim_part
ORDER BY retail_price DESC
LIMIT 20;

-- ========================================
-- INFORMATION MARTS - FACTS
-- ========================================

-- Orders fact with dimensions
SELECT 
    order_id,
    order_date,
    customer_name,
    NATION_NAME,
    REGION_NAME,
    total_price,
    order_status,
    order_priority
FROM information_marts.fact_orders
ORDER BY total_price DESC
LIMIT 20;

-- Line items fact with all dimensions
SELECT 
    order_id,
    order_date,
    customer_name,
    part_name,
    supplier_name,
    quantity,
    extended_price,
    discount,
    total_price
FROM information_marts.fact_lineitem
ORDER BY total_price DESC
LIMIT 20;

-- ========================================
-- INFORMATION MARTS - ANALYTICAL QUERIES
-- ========================================

-- Top 10 customers by revenue
SELECT 
    customer_name,
    customer_nation,
    customer_region,
    SUM(total_revenue) AS total_revenue,
    SUM(total_orders) AS total_orders,
    SUM(total_line_items) AS total_items
FROM information_marts.mart_sales_summary
GROUP BY customer_name, customer_nation, customer_region
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by region
SELECT 
    customer_region,
    SUM(total_revenue) AS total_revenue,
    SUM(total_orders) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM information_marts.mart_sales_summary
GROUP BY customer_region
ORDER BY total_revenue DESC;

-- Revenue by nation
SELECT 
    customer_nation,
    customer_region,
    SUM(total_revenue) AS total_revenue,
    SUM(total_orders) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM information_marts.mart_sales_summary
GROUP BY customer_nation, customer_region
ORDER BY total_revenue DESC;

-- Top suppliers by performance
SELECT 
    supplier_name,
    supplier_nation,
    supplier_region,
    total_revenue,
    total_orders,
    total_line_items,
    avg_line_value,
    ROUND(return_rate_pct, 2) AS return_rate_pct
FROM information_marts.mart_supplier_performance
ORDER BY total_revenue DESC
LIMIT 20;

-- Suppliers with lowest return rates (min 100 items)
SELECT 
    supplier_name,
    supplier_nation,
    total_line_items,
    ROUND(return_rate_pct, 2) AS return_rate_pct,
    total_revenue
FROM information_marts.mart_supplier_performance
WHERE total_line_items >= 100
ORDER BY return_rate_pct ASC
LIMIT 20;

-- ========================================
-- ADVANCED ANALYTICAL QUERIES
-- ========================================

-- Monthly revenue trend
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(total_price) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM information_marts.fact_orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- Top parts by revenue
SELECT 
    part_name,
    manufacturer,
    brand,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_price) AS total_revenue,
    AVG(total_price / quantity) AS avg_price_per_unit
FROM information_marts.fact_lineitem
GROUP BY part_name, manufacturer, brand
ORDER BY total_revenue DESC
LIMIT 20;

-- Customer purchasing patterns
SELECT 
    customer_name,
    customer_nation,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_price) AS total_spent,
    AVG(total_price) AS avg_order_value,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM information_marts.fact_orders
GROUP BY customer_name, customer_nation
HAVING COUNT(DISTINCT order_id) >= 5
ORDER BY total_spent DESC
LIMIT 20;

-- Supplier concentration by region
SELECT 
    supplier_region,
    COUNT(DISTINCT supplier_id) AS num_suppliers,
    SUM(total_revenue) AS total_revenue,
    SUM(total_revenue) / COUNT(DISTINCT supplier_id) AS avg_revenue_per_supplier
FROM information_marts.mart_supplier_performance
GROUP BY supplier_region
ORDER BY total_revenue DESC;

-- Order status distribution
SELECT 
    order_status,
    COUNT(*) AS num_orders,
    SUM(total_price) AS total_value,
    AVG(total_price) AS avg_order_value
FROM information_marts.fact_orders
GROUP BY order_status
ORDER BY num_orders DESC;

-- Shipping mode analysis
SELECT 
    ship_mode,
    COUNT(*) AS num_shipments,
    SUM(quantity) AS total_quantity,
    SUM(total_price) AS total_revenue,
    AVG(discount) AS avg_discount,
    SUM(CASE WHEN return_flag = 'R' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS return_rate_pct
FROM information_marts.fact_lineitem
GROUP BY ship_mode
ORDER BY total_revenue DESC;

-- ========================================
-- DATA QUALITY CHECKS
-- ========================================

-- Check for orphan records (orders without customers)
SELECT COUNT(*) AS orphan_orders
FROM information_marts.fact_orders
WHERE customer_key IS NULL;

-- Check for missing dimensions
SELECT 
    COUNT(*) AS total_lineitems,
    SUM(CASE WHEN order_key IS NULL THEN 1 ELSE 0 END) AS missing_order,
    SUM(CASE WHEN part_key IS NULL THEN 1 ELSE 0 END) AS missing_part,
    SUM(CASE WHEN supplier_key IS NULL THEN 1 ELSE 0 END) AS missing_supplier
FROM information_marts.fact_lineitem;

-- ========================================
-- SAMPLE BUSINESS QUESTIONS
-- ========================================

-- Q1: Which customers in the ASIA region have the highest account balances?
SELECT 
    customer_name,
    NATION_NAME,
    customer_account_balance
FROM information_marts.dim_customer
WHERE REGION_NAME = 'ASIA'
ORDER BY customer_account_balance DESC
LIMIT 10;

-- Q2: What is the total revenue by market segment?
SELECT 
    customer_market_segment,
    COUNT(DISTINCT f.customer_id) AS num_customers,
    SUM(f.total_price) AS total_revenue,
    AVG(f.total_price) AS avg_order_value
FROM information_marts.fact_orders f
JOIN information_marts.dim_customer c ON f.customer_key = c.customer_key
GROUP BY customer_market_segment
ORDER BY total_revenue DESC;

-- Q3: Which suppliers provide the most competitive pricing?
SELECT 
    fl.supplier_name,
    fl.supplier_nation,
    COUNT(DISTINCT fl.part_id) AS unique_parts_supplied,
    AVG(fl.total_price / fl.quantity) AS avg_price_per_unit,
    SUM(fl.total_price) AS total_revenue
FROM information_marts.fact_lineitem fl
GROUP BY fl.supplier_name, fl.supplier_nation
HAVING COUNT(DISTINCT fl.part_id) >= 10
ORDER BY avg_price_per_unit ASC
LIMIT 20;

-- Q4: What is the order fulfillment time distribution?
SELECT 
    AVG(DATEDIFF(receipt_date, ship_date)) AS avg_fulfillment_days,
    MIN(DATEDIFF(receipt_date, ship_date)) AS min_fulfillment_days,
    MAX(DATEDIFF(receipt_date, ship_date)) AS max_fulfillment_days,
    STDDEV(DATEDIFF(receipt_date, ship_date)) AS stddev_fulfillment_days
FROM information_marts.fact_lineitem
WHERE receipt_date IS NOT NULL 
  AND ship_date IS NOT NULL;

-- Q5: Which brands are most popular by region?
SELECT 
    fo.REGION_NAME,
    fl.brand,
    COUNT(*) AS num_orders,
    SUM(fl.quantity) AS total_quantity,
    SUM(fl.total_price) AS total_revenue
FROM information_marts.fact_lineitem fl
JOIN information_marts.fact_orders fo ON fl.order_id = fo.order_id
GROUP BY fo.REGION_NAME, fl.brand
ORDER BY fo.REGION_NAME, total_revenue DESC;

