# Quick Start Guide

Follow these steps to get your Data Vault up and running on Databricks in minutes!

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Requirements

```bash
pip install dbt-core dbt-databricks
```

### Step 2: Configure Databricks Connection

Copy the environment template:
```bash
cp env_template.txt .env
```

Edit `.env` and fill in your Databricks credentials:
- `DBT_DATABRICKS_HOST`: Your workspace URL (e.g., `my-workspace.cloud.databricks.com`)
- `DBT_DATABRICKS_HTTP_PATH`: From your SQL Warehouse → Connection Details
- `DBT_DATABRICKS_TOKEN`: Generate from User Settings → Access Tokens

Load the environment variables:
```bash
source .env  # On Mac/Linux
# OR
set -a; source .env; set +a  # Alternative for Mac/Linux
```

### Step 3: Create Catalog in Databricks

Run in Databricks SQL Editor:
```sql
CREATE CATALOG IF NOT EXISTS mujahid_data_vault_demo;
```

### Step 4: Install Dependencies

```bash
cd /Users/mujahid.niaz/Downloads/automate-dv-0.11.3/dv_project
dbt deps
```

### Step 5: Test Connection

```bash
dbt debug
```

✅ You should see all green checkmarks!

### Step 6: Build Your Data Vault

```bash
# Build everything (first run may take a few minutes)
dbt build

# OR build step by step:
dbt run --select staging        # Step 1: Stage the data
dbt run --select raw_vault      # Step 2: Build Raw Vault
dbt run --select business_vault # Step 3: Build Business Vault
dbt run --select information_marts  # Step 4: Build Information Marts
```

## 🎉 You're Done!

Your Data Vault is now built. Query your data:

```sql
-- See customer sales summary
SELECT * 
FROM mujahid_data_vault_demo.information_marts.mart_sales_summary
LIMIT 10;

-- See supplier performance
SELECT * 
FROM mujahid_data_vault_demo.information_marts.mart_supplier_performance
ORDER BY total_revenue DESC
LIMIT 10;
```

## 📚 Next Steps

- Run `dbt docs generate && dbt docs serve` to view documentation
- Check out the [full README](README.md) for detailed information
- Explore the models in the `models/` directory
- Add your own custom marts!

## ⚡ Quick Reference

```bash
# Full rebuild
dbt build

# Incremental load
dbt run --select raw_vault

# Run tests
dbt test

# View documentation
dbt docs serve

# Build specific layer
dbt run --select staging
dbt run --select raw_vault
dbt run --select business_vault
dbt run --select information_marts

# Build by tag
dbt run --select tag:hub
dbt run --select tag:satellite
dbt run --select tag:mart
```

## 🆘 Troubleshooting

**Connection failed?**
- Verify your SQL Warehouse is running
- Check environment variables are loaded: `echo $DBT_DATABRICKS_HOST`
- Ensure your token hasn't expired

**Permission denied?**
- Make sure you have access to `samples.tpch`
- Verify you can create schemas in `mujahid_data_vault_demo`

**Package not found?**
- Run `dbt deps` to install AutomateDV
- Check that the parent directory contains the automate-dv package

For more help, see the [full README](README.md).

