# Persistent Staging Area (PSA) Design

## What is a PSA?

A **Persistent Staging Area (PSA)** is a data warehouse layer that:
- Stores raw/staged data **permanently** (not computed on-the-fly)
- Acts as a **system of record** for all source data
- Enables **reprocessing** without re-extracting from source
- Provides **audit trail** of all data loads
- Supports **data lineage** and troubleshooting

## PSA vs Views

| Aspect | Views (Old) | PSA Tables (New) |
|--------|-------------|------------------|
| **Storage** | ❌ No storage | ✅ Persistent storage |
| **Performance** | ❌ Recomputed each time | ✅ Pre-computed, fast |
| **Audit Trail** | ❌ No history | ✅ Full load history |
| **Reprocessing** | ❌ Must re-extract | ✅ Reprocess from PSA |
| **Source Independence** | ❌ Depends on source | ✅ Independent copy |
| **Cost** | 💰 Compute on read | 💰 Storage cost |

## Our PSA Implementation

### Configuration

```yaml
# dbt_project.yml
staging:
  +schema: staging
  +materialized: incremental
  +on_schema_change: 'append_new_columns'
  +unique_key: ['LOAD_DATE']
  +tags: ['staging', 'psa']
```

### Key Features

1. **Incremental Loading**
   - Only new data is added
   - Existing data remains unchanged
   - Efficient for large datasets

2. **Schema Evolution**
   - Automatically adds new columns
   - Non-breaking changes handled gracefully

3. **Load Tracking**
   - Every record has `LOAD_DATE` timestamp
   - Full audit trail of when data arrived

4. **Hash Keys**
   - Pre-computed hash keys for Raw Vault
   - Performance optimization for downstream processing

## PSA Data Flow

```
┌─────────────┐
│   Source    │
│  (TPC-H)    │
└──────┬──────┘
       │
       │ Extract
       ▼
┌─────────────────┐
│  PSA (Staging)  │ ← Persistent Tables
│  ─────────────  │
│  • Raw data     │
│  • Hash keys    │
│  • Load metadata│
│  • Incremental  │
└──────┬──────────┘
       │
       │ Transform
       ▼
┌─────────────────┐
│   Raw Vault     │
│  ─────────────  │
│  • Hubs         │
│  • Links        │
│  • Satellites   │
└─────────────────┘
```

## Benefits of PSA

### 1. **Source System Independence**
```sql
-- Raw Vault loads from PSA, not source
-- Source can be offline, PSA is always available
SELECT * FROM staging.stg_customer  -- ✅ Always available
-- vs
SELECT * FROM samples.tpch.customer -- ❌ Depends on source
```

### 2. **Time Travel & Audit**
```sql
-- See what data looked like at any point in time
SELECT * FROM staging.stg_customer 
WHERE LOAD_DATE = '2024-01-15'

-- Audit: How many times was customer X loaded?
SELECT LOAD_DATE, COUNT(*) 
FROM staging.stg_customer
WHERE C_CUSTKEY = 12345
GROUP BY LOAD_DATE
```

### 3. **Reprocessing Without Re-extraction**
```bash
# Rebuild Raw Vault from PSA without touching source
dbt run --select raw_vault+ --full-refresh

# The PSA data is still there - no need to re-extract!
```

### 4. **Data Quality Checks**
```sql
-- Run quality checks on PSA before loading to Raw Vault
SELECT 
    LOAD_DATE,
    COUNT(*) as record_count,
    COUNT(DISTINCT CUSTOMER_PK) as unique_customers,
    SUM(CASE WHEN CUSTOMER_PK IS NULL THEN 1 ELSE 0 END) as null_keys
FROM staging.stg_customer
GROUP BY LOAD_DATE
```

## PSA vs Raw Vault

### PSA (Staging)
- **Purpose**: Exact copy of source with hash keys
- **Updates**: Append-only, keeps all loads
- **Schema**: Source schema + hash keys + metadata
- **Retention**: Configurable (keep N days/loads)

### Raw Vault
- **Purpose**: Enterprise data warehouse
- **Updates**: Merge/update based on hash diffs
- **Schema**: Normalized (Hubs, Links, Satellites)
- **Retention**: Infinite (full history)

## Loading Patterns

### Full Load (Initial)
```bash
# First load: Load all historical data
dbt run --select staging --full-refresh
dbt run --select raw_vault --full-refresh
```

### Incremental Load (Daily)
```bash
# Subsequent loads: Only new data
dbt run --select staging+
# This automatically loads new data to staging and propagates to Raw Vault
```

### Reprocessing Scenario
```bash
# Scenario: Bug found in Raw Vault transformation
# Fix the bug, then reprocess from PSA (no source re-extraction needed!)

# 1. Fix the transformation in dbt model
# 2. Clear Raw Vault
dbt run --select raw_vault --full-refresh

# 3. Reload from PSA (PSA stays intact!)
# Raw Vault rebuilds from existing PSA data
```

## Data Retention Strategy

### Option 1: Keep All PSA Data (Default)
```yaml
# dbt_project.yml
staging:
  +materialized: incremental  # Never delete
```

### Option 2: Sliding Window (Keep N Days)
```sql
-- Add to staging models
{{ config(
    materialized='incremental',
    post_hook=[
        "DELETE FROM {{ this }} WHERE LOAD_DATE < CURRENT_DATE - INTERVAL 90 DAYS"
    ]
) }}
```

### Option 3: Keep N Loads
```sql
-- Keep only last 10 loads
{{ config(
    post_hook=[
        """
        DELETE FROM {{ this }} 
        WHERE LOAD_DATE NOT IN (
            SELECT DISTINCT LOAD_DATE 
            FROM {{ this }}
            ORDER BY LOAD_DATE DESC 
            LIMIT 10
        )
        """
    ]
) }}
```

## Performance Considerations

### Pros
✅ Fast query performance (pre-computed)
✅ No source system impact
✅ Enables parallel processing
✅ Supports batch and streaming

### Cons
❌ Storage costs (duplicate data)
❌ Need to manage retention
❌ Potential for PSA/Source drift

## Best Practices

1. **✅ Always include LOAD_DATE**
   ```sql
   LOAD_DATE: "CURRENT_TIMESTAMP()"
   ```

2. **✅ Add source identifier**
   ```sql
   RECORD_SOURCE: "'TPCH_CUSTOMER'"
   ```

3. **✅ Pre-compute hash keys**
   ```sql
   CUSTOMER_PK: MD5(C_CUSTKEY)
   ```

4. **✅ Monitor PSA growth**
   ```sql
   SELECT 
       table_name,
       row_count,
       size_bytes / 1024 / 1024 / 1024 as size_gb
   FROM information_schema.tables
   WHERE table_schema = 'staging'
   ```

5. **✅ Implement data quality checks**
   ```yaml
   # models/staging/schema.yml
   - name: stg_customer
     tests:
       - dbt_utils.recency:
           field: LOAD_DATE
           datepart: day
           interval: 1
   ```

6. **✅ Document load patterns**
   ```yaml
   meta:
     load_frequency: "daily"
     load_time: "02:00 UTC"
     source_system: "TPC-H"
   ```

## Monitoring PSA

### Track Load Statistics
```sql
CREATE OR REPLACE VIEW staging.vw_load_stats AS
SELECT 
    'stg_customer' as table_name,
    LOAD_DATE,
    COUNT(*) as records,
    COUNT(DISTINCT CUSTOMER_PK) as unique_keys,
    MIN(C_CUSTKEY) as min_key,
    MAX(C_CUSTKEY) as max_key
FROM staging.stg_customer
GROUP BY LOAD_DATE

UNION ALL

SELECT 
    'stg_orders' as table_name,
    LOAD_DATE,
    COUNT(*) as records,
    COUNT(DISTINCT ORDER_PK) as unique_keys,
    MIN(O_ORDERKEY) as min_key,
    MAX(O_ORDERKEY) as max_key
FROM staging.stg_orders
GROUP BY LOAD_DATE;
```

### Alert on Anomalies
```sql
-- Detect significant changes in record counts
WITH load_counts AS (
    SELECT 
        LOAD_DATE,
        COUNT(*) as record_count,
        LAG(COUNT(*)) OVER (ORDER BY LOAD_DATE) as prev_count
    FROM staging.stg_customer
    GROUP BY LOAD_DATE
)
SELECT * 
FROM load_counts
WHERE ABS(record_count - prev_count) > prev_count * 0.2  -- 20% change
ORDER BY LOAD_DATE DESC;
```

## Summary

Your PSA is now configured as **incremental tables** providing:

✅ **Persistent storage** of all source data
✅ **Full audit trail** with LOAD_DATE tracking
✅ **Reprocessing capability** without source re-extraction
✅ **Performance** through pre-computed hash keys
✅ **Source independence** for Raw Vault processing
✅ **Data quality** validation layer

This is a **production-grade PSA** following Data Vault and data warehousing best practices!

