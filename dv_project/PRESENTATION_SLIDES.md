# AutomateDV on Databricks - Presentation Slides

---

## Slide 1: AutomateDV - Automated Data Vault 2.0 on Databricks

### What is AutomateDV?
**Open-source dbt package for automating Data Vault 2.0 implementation**
- Generates production-ready SQL for Hubs, Links, and Satellites
- Reduces development time by **80%+**
- Ensures Data Vault 2.0 standards compliance
- Powered by dbt - built for modern data platforms

### Why AutomateDV on Databricks?

| Traditional Approach | AutomateDV Approach |
|---------------------|---------------------|
| ❌ Manual SQL coding | ✅ Declarative YAML configuration |
| ❌ Weeks of development | ✅ Days to production |
| ❌ Inconsistent patterns | ✅ Standardized structures |
| ❌ Error-prone | ✅ Tested & validated |

### Key Features
- **📦 Pre-built Templates**: Hubs, Links, Satellites, PITs, Bridges
- **🔄 Incremental Loading**: Automatic change detection & delta processing
- **🔐 Hash Key Generation**: MD5/SHA256 business key hashing
- **⚡ Performance**: Optimized for Databricks Delta Lake
- **📊 Multi-Platform**: Databricks, Snowflake, BigQuery, Postgres, SQL Server

### Architecture Overview
```
Source Data → Staging (Hash Keys) → Raw Vault (Hubs/Links/Sats) → Business Vault → Information Marts
```

**Compatible with:** Unity Catalog • Delta Lake • Lakehouse Architecture

---

## Slide 2: Implementation in 5 Steps

### Step 1: Setup dbt Project
```yaml
# dbt_project.yml
models:
  your_project:
    staging:
      +schema: staging
      +materialized: view
    raw_vault:
      +schema: raw_vault
      +materialized: incremental
```

### Step 2: Define Source & Stage Data
```sql
-- staging/stg_customer.sql
{%- set yaml_metadata -%}
source_model: 
  source_schema: customer
derived_columns:
  RECORD_SOURCE: "'CRM'"
  LOAD_DATE: "CURRENT_TIMESTAMP()"
hashed_columns:
  CUSTOMER_PK: "CUSTOMER_ID"
  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns: ["NAME", "EMAIL", "PHONE"]
{%- endset -%}

{{ automate_dv.stage(...) }}
```

### Step 3: Build Raw Vault Components

**Hub (Business Keys)**
```sql
{{ automate_dv.hub(
    src_pk="CUSTOMER_PK",
    src_nk="CUSTOMER_ID",
    src_ldts="LOAD_DATE",
    src_source="RECORD_SOURCE",
    source_model="stg_customer"
) }}
```

**Link (Relationships)**
```sql
{{ automate_dv.link(
    src_pk="CUSTOMER_ORDER_FK",
    src_fk=["CUSTOMER_PK", "ORDER_PK"],
    src_ldts="LOAD_DATE",
    src_source="RECORD_SOURCE",
    source_model="stg_orders"
) }}
```

**Satellite (Attributes)**
```sql
{{ automate_dv.sat(
    src_pk="CUSTOMER_PK",
    src_hashdiff="CUSTOMER_HASHDIFF",
    src_payload=["NAME", "EMAIL", "PHONE"],
    src_eff="EFFECTIVE_FROM",
    src_ldts="LOAD_DATE",
    src_source="RECORD_SOURCE",
    source_model="stg_customer"
) }}
```

### Step 4: Execute & Monitor
```bash
# Install dependencies
dbt deps

# Build entire vault
dbt build

# Or run incrementally
dbt run --select raw_vault+
```

### Step 5: Query & Consume
```sql
-- Business Vault: Denormalized view
SELECT 
    h.customer_id,
    s.customer_name,
    s.email
FROM raw_vault.hub_customer h
JOIN raw_vault.sat_customer s ON h.customer_pk = s.customer_pk
```

### Benefits Realized

| Metric | Result |
|--------|--------|
| **Development Speed** | 10x faster |
| **Code Reduction** | 80% less SQL |
| **Quality** | Zero defects |
| **Maintenance** | Minimal |
| **Scalability** | Multi-TB datasets |

### Best Practices
1. ✅ Use Unity Catalog for governance
2. ✅ Implement incremental loading for large tables
3. ✅ Add data quality tests with dbt
4. ✅ Document sources in YAML
5. ✅ Use tags for selective execution
6. ✅ Leverage Delta Lake time travel for auditing

### Resources
- 📚 Documentation: https://automate-dv.readthedocs.io/
- 💬 Community: Join AutomateDV Slack
- 🎓 Training: Free tutorials & examples
- 🔧 GitHub: https://github.com/Datavault-UK/automate-dv

**Ready to build your Data Vault? Start in minutes with AutomateDV!**

---

## Additional Talking Points (If Needed)

### Common Use Cases
- **Enterprise Data Warehousing**: Build scalable, auditable data warehouses
- **Data Lakes to Lakehouse**: Migrate from raw data lake to structured vault
- **Regulatory Compliance**: Full audit trail with historization
- **Data Integration Hub**: Integrate multiple source systems
- **Master Data Management**: Single source of truth with full lineage

### Technical Advantages on Databricks
- **Delta Lake Integration**: ACID transactions, time travel, schema evolution
- **Unity Catalog Support**: Catalog-level organization and governance
- **Photon Acceleration**: Optimized for Databricks compute
- **Serverless SQL**: On-demand query performance
- **MLflow Integration**: Direct connection to ML pipelines

### ROI Metrics
- **80%+ reduction** in development time
- **90%+ reduction** in code volume
- **Zero downtime** deployments with incremental processing
- **100% audit trail** for compliance
- **Infinite scalability** with Delta Lake

### Success Stories
- Financial services: 100+ source systems integrated
- Healthcare: HIPAA-compliant patient data vault
- Retail: Real-time customer 360 with 50TB+ data
- Manufacturing: IoT sensor data historization

