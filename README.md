# Data Vault 2.0 on Databricks - TPC-H Demo

This project demonstrates a complete Data Vault 2.0 implementation on Databricks using the AutomateDV framework with TPC-H benchmark data.

## 🎯 Project Overview

This Data Vault implementation includes:
- **Source Data**: TPC-H benchmark dataset from Databricks samples catalog
- **Target Catalog**: `mujahid_data_vault_demo`
- **Architecture Layers**:
  - `staging` - Staged and hashed source data
  - `raw_vault` - Core Data Vault structures (Hubs, Links, Satellites)
  - `business_vault` - Business-friendly denormalized views
  - `information_marts` - Dimensional models for analytics

## 📊 Data Vault Structure

### Hubs (Business Keys)
- `hub_customer` - Customer entities
- `hub_order` - Order entities
- `hub_part` - Part entities
- `hub_supplier` - Supplier entities
- `hub_nation` - Nation entities
- `hub_region` - Region entities

### Links (Relationships)
- `link_customer_order` - Customer-Order relationship
- `link_order_lineitem` - Order-LineItem relationship
- `link_order_part_supplier` - Order-Part-Supplier relationship
- `link_part_supplier` - Part-Supplier relationship
- `link_customer_nation` - Customer-Nation relationship
- `link_supplier_nation` - Supplier-Nation relationship
- `link_nation_region` - Nation-Region relationship

### Satellites (Descriptive Attributes)
- `sat_customer` - Customer attributes
- `sat_order` - Order attributes
- `sat_lineitem` - Line item attributes
- `sat_part` - Part attributes
- `sat_supplier` - Supplier attributes
- `sat_partsupp` - Part-Supplier attributes
- `sat_nation` - Nation attributes
- `sat_region` - Region attributes

### Business Vault
- `bv_customer_details` - Customer with nation/region info
- `bv_order_details` - Orders with customer info
- `bv_supplier_details` - Supplier with nation/region info

### Information Marts
- `dim_customer` - Customer dimension
- `dim_supplier` - Supplier dimension
- `dim_part` - Part dimension
- `dim_date` - Date dimension
- `fact_orders` - Orders fact table
- `fact_lineitem` - Line items fact table
- `mart_sales_summary` - Sales summary by customer and date
- `mart_supplier_performance` - Supplier performance metrics

## 🚀 Setup Instructions

### Prerequisites

1. **Databricks Workspace** with access to the `samples.tpch` catalog
2. **dbt installed** (version 1.0.0 or higher)
3. **dbt-databricks adapter** installed

### Installation Steps

#### 1. Install dbt and dbt-databricks

```bash
pip install dbt-core dbt-databricks
```

#### 2. Configure Environment Variables

Create a `.env` file or set these environment variables:

```bash
export DBT_DATABRICKS_HOST="your-databricks-workspace-url.cloud.databricks.com"
export DBT_DATABRICKS_HTTP_PATH="/sql/1.0/warehouses/your-warehouse-id"
export DBT_DATABRICKS_TOKEN="your-databricks-personal-access-token"
```

**To get these values:**
- **Host**: Your Databricks workspace URL (without https://)
- **HTTP Path**: Go to SQL Warehouses → Select your warehouse → Connection Details → HTTP Path
- **Token**: User Settings → Access Tokens → Generate New Token

#### 3. Create the Target Catalog (if not exists)

Run this in Databricks SQL:

```sql
CREATE CATALOG IF NOT EXISTS mujahid_data_vault_demo;
```

#### 4. Install dbt Dependencies

```bash
cd dv_project
dbt deps
```

This will install the AutomateDV package from the parent directory.

#### 5. Test Connection

```bash
dbt debug
```

This should show all green checkmarks if your connection is configured correctly.

## 📦 Running the Project

### Full Build

To build the entire Data Vault from scratch:

```bash
# Build all models
dbt build

# Or run models only
dbt run
```

### Incremental Build

For subsequent runs (incremental loading):

```bash
dbt run --select raw_vault
```

### Build by Layer

```bash
# Staging layer only
dbt run --select staging

# Raw Vault only
dbt run --select raw_vault

# Business Vault only
dbt run --select business_vault

# Information Marts only
dbt run --select information_marts
```

### Build by Tag

```bash
# Build all hubs
dbt run --select tag:hub

# Build all links
dbt run --select tag:link

# Build all satellites
dbt run --select tag:satellite

# Build all marts
dbt run --select tag:mart
```

### Build Specific Models

```bash
# Build a specific hub and its dependencies
dbt run --select hub_customer+

# Build a specific mart and its upstream dependencies
dbt run --select +fact_lineitem
```

## 📈 Testing

Run data quality tests:

```bash
dbt test
```

## 📚 Documentation

Generate and serve documentation:

```bash
# Generate documentation
dbt docs generate

# Serve documentation (opens in browser)
dbt docs serve
```

## 🔍 Querying the Data Vault

### Example Queries

#### Query Customer Details from Business Vault

```sql
SELECT *
FROM mujahid_data_vault_demo.business_vault.bv_customer_details
LIMIT 10;
```

#### Query Sales Summary Mart

```sql
SELECT
    customer_name,
    customer_nation,
    customer_region,
    SUM(total_revenue) AS total_revenue,
    SUM(total_orders) AS total_orders
FROM mujahid_data_vault_demo.information_marts.mart_sales_summary
GROUP BY customer_name, customer_nation, customer_region
ORDER BY total_revenue DESC
LIMIT 20;
```

#### Query Supplier Performance

```sql
SELECT
    supplier_name,
    supplier_nation,
    total_revenue,
    total_orders,
    return_rate_pct
FROM mujahid_data_vault_demo.information_marts.mart_supplier_performance
ORDER BY total_revenue DESC
LIMIT 20;
```

#### Query Line Items with All Dimensions

```sql
SELECT
    order_date,
    customer_name,
    part_name,
    supplier_name,
    quantity,
    total_price
FROM mujahid_data_vault_demo.information_marts.fact_lineitem
WHERE order_date >= '1995-01-01'
LIMIT 100;
```

## 🏗️ Project Structure

```
dv_project/
├── dbt_project.yml          # Project configuration
├── packages.yml             # Package dependencies (AutomateDV)
├── profiles.yml             # Connection profiles
├── README.md               # This file
└── models/
    ├── sources.yml         # Source definitions
    ├── staging/           # Staging models
    │   ├── stg_customer.sql
    │   ├── stg_orders.sql
    │   ├── stg_lineitem.sql
    │   ├── stg_part.sql
    │   ├── stg_supplier.sql
    │   ├── stg_partsupp.sql
    │   ├── stg_nation.sql
    │   └── stg_region.sql
    ├── raw_vault/         # Raw Vault models
    │   ├── hubs/         # Hub tables
    │   ├── links/        # Link tables
    │   └── satellites/   # Satellite tables
    ├── business_vault/    # Business Vault models
    │   ├── bv_customer_details.sql
    │   ├── bv_order_details.sql
    │   └── bv_supplier_details.sql
    └── information_marts/ # Information Marts
        ├── dim_customer.sql
        ├── dim_supplier.sql
        ├── dim_part.sql
        ├── dim_date.sql
        ├── fact_orders.sql
        ├── fact_lineitem.sql
        ├── mart_sales_summary.sql
        └── mart_supplier_performance.sql
```

## ⚙️ Configuration

### Variables

You can override variables in `dbt_project.yml` or via command line:

```bash
# Change load date
dbt run --vars '{"load_date": "1995-01-01"}'

# Change hash algorithm
dbt run --vars '{"hash": "SHA256"}'
```

### Materialization Strategy

- **Staging**: Views (no storage, computed on-the-fly)
- **Raw Vault**: Incremental tables (append-only)
- **Business Vault**: Tables (full refresh)
- **Information Marts**: Tables (full refresh)

## 🔧 Troubleshooting

### Connection Issues

If `dbt debug` fails:
1. Check your environment variables are set correctly
2. Verify your Databricks token is valid
3. Ensure your SQL warehouse is running
4. Check network connectivity to Databricks

### Permission Issues

Ensure your user has:
- `USE CATALOG` on `mujahid_data_vault_demo`
- `CREATE SCHEMA` on the catalog
- `SELECT` on `samples.tpch` tables

### Package Installation Issues

If `dbt deps` fails:
1. Check that the parent directory contains the AutomateDV package
2. Verify `packages.yml` is configured correctly
3. Try deleting `dbt_packages/` and running `dbt deps` again

## 📖 Learn More

- [AutomateDV Documentation](https://automate-dv.readthedocs.io/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Data Vault 2.0](https://www.data-vault.com/)
- [Databricks Documentation](https://docs.databricks.com/)

## 🤝 Contributing

This is a demo project. Feel free to extend it with:
- Additional business vault models
- More sophisticated information marts
- Data quality tests
- Custom macros
- Point-in-Time (PIT) tables
- Bridge tables for query optimization

## 📝 License

This project uses the AutomateDV package which is licensed under Apache 2.0.

