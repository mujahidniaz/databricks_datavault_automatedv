# Data Vault Architecture Overview

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      SOURCE LAYER                                │
│                   samples.tpch (Databricks)                      │
│  ┌──────────┬─────────┬──────────┬──────┬──────────┬────────┐  │
│  │ customer │ orders  │ lineitem │ part │ supplier │ nation │  │
│  │          │         │          │      │          │ region │  │
│  └──────────┴─────────┴──────────┴──────┴──────────┴────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    STAGING LAYER (Views)                         │
│           mujahid_data_vault_demo.staging                        │
│  ┌───────────────┬────────────┬──────────────┬─────────────┐   │
│  │ stg_customer  │ stg_orders │ stg_lineitem │ stg_part    │   │
│  │ stg_supplier  │ stg_nation │ stg_region   │ stg_partsupp│   │
│  └───────────────┴────────────┴──────────────┴─────────────┘   │
│         • Hash Keys (MD5)                                        │
│         • Load Metadata                                          │
│         • Business Keys                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│               RAW VAULT LAYER (Incremental Tables)               │
│           mujahid_data_vault_demo.raw_vault                      │
│                                                                   │
│  ┌──────────────── HUBS (Business Keys) ─────────────────┐     │
│  │  hub_customer │ hub_order │ hub_part │ hub_supplier   │     │
│  │  hub_nation   │ hub_region                            │     │
│  └────────────────────────────────────────────────────────┘     │
│                              ↓                                   │
│  ┌────────────── LINKS (Relationships) ──────────────────┐     │
│  │  link_customer_order    │ link_order_lineitem         │     │
│  │  link_order_part_supplier │ link_part_supplier        │     │
│  │  link_customer_nation   │ link_supplier_nation        │     │
│  │  link_nation_region                                   │     │
│  └────────────────────────────────────────────────────────┘     │
│                              ↓                                   │
│  ┌──────────── SATELLITES (Attributes & History) ────────┐     │
│  │  sat_customer │ sat_order   │ sat_lineitem │ sat_part│     │
│  │  sat_supplier │ sat_partsupp│ sat_nation   │ sat_region    │
│  └────────────────────────────────────────────────────────┘     │
│         • Append-Only                                            │
│         • Full History                                           │
│         • Hash Diff for Change Detection                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              BUSINESS VAULT LAYER (Tables)                       │
│         mujahid_data_vault_demo.business_vault                   │
│  ┌─────────────────┬──────────────────┬─────────────────────┐  │
│  │ bv_customer_    │ bv_order_        │ bv_supplier_        │  │
│  │    details      │    details       │    details          │  │
│  └─────────────────┴──────────────────┴─────────────────────┘  │
│         • Denormalized Views                                     │
│         • Business-Friendly                                      │
│         • Pre-Joined Data                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│           INFORMATION MARTS LAYER (Tables)                       │
│       mujahid_data_vault_demo.information_marts                  │
│                                                                   │
│  ┌────────────── DIMENSIONS ──────────────────────────┐         │
│  │  dim_customer │ dim_supplier │ dim_part │ dim_date │         │
│  └──────────────────────────────────────────────────────┘        │
│                              ↓                                   │
│  ┌─────────────────── FACTS ──────────────────────────┐         │
│  │  fact_orders   │   fact_lineitem                   │         │
│  └──────────────────────────────────────────────────────┘        │
│                              ↓                                   │
│  ┌────────────── AGGREGATED MARTS ────────────────────┐         │
│  │  mart_sales_summary   │   mart_supplier_performance│         │
│  └──────────────────────────────────────────────────────┘        │
│         • Star Schema                                            │
│         • Ready for BI Tools                                     │
│         • Optimized for Analytics                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    CONSUMPTION LAYER                             │
│         Tableau │ Power BI │ Databricks SQL │ APIs              │
└─────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

### 1. Source → Staging
- Extract from `samples.tpch`
- Generate hash keys (MD5)
- Add load metadata
- Create as views (no storage)

### 2. Staging → Raw Vault
- **Hubs**: Extract unique business keys
- **Links**: Capture relationships
- **Satellites**: Store descriptive attributes
- Incremental load (insert-only)

### 3. Raw Vault → Business Vault
- Join Hubs + Links + Satellites
- Create denormalized views
- Add business context
- Current state snapshots

### 4. Business Vault → Information Marts
- **Dimensions**: Entity attributes
- **Facts**: Metrics and measures
- **Marts**: Pre-aggregated analytics
- Star schema design

## 🔄 Loading Pattern

```
Initial Load:
┌──────┐    ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌───────┐
│Source│ -> │ Staging │ -> │Raw Vault │ -> │Business  │ -> │ Marts │
│      │    │ (View)  │    │(Insert)  │    │  Vault   │    │       │
└──────┘    └─────────┘    └──────────┘    └──────────┘    └───────┘

Incremental Load:
┌──────┐    ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌───────┐
│Source│ -> │ Staging │ -> │Raw Vault │ -> │Business  │ -> │ Marts │
│(New) │    │ (View)  │    │(Append)  │    │(Refresh) │    │(Refresh)
└──────┘    └─────────┘    └──────────┘    └──────────┘    └───────┘
```

## 🗝️ Key Design Decisions

### Hash Keys
- **Algorithm**: MD5 (configurable to SHA256)
- **Purpose**: Platform-agnostic surrogate keys
- **Benefit**: No dependency on source system keys

### Satellites
- **Hash Diff**: Detects changes in attributes
- **Effective From**: Business effective date
- **Load Date**: Technical load timestamp
- **Append-Only**: Full history preservation

### Links
- **Composite Keys**: Multiple hub references
- **Load Date**: When relationship was captured
- **Source**: Origin of the relationship

### Materialization
- **Staging**: Views (computed on-the-fly)
- **Raw Vault**: Incremental (append-only)
- **Business Vault**: Tables (full refresh)
- **Marts**: Tables (full refresh)

## 🎯 Entity Relationships

```
                  ┌─────────┐
                  │ REGION  │
                  └────┬────┘
                       │
                  ┌────┴────┐
                  │ NATION  │
                  └────┬────┘
                       │
          ┌────────────┴────────────┐
          │                         │
     ┌────┴────┐              ┌─────┴─────┐
     │CUSTOMER │              │ SUPPLIER  │
     └────┬────┘              └─────┬─────┘
          │                         │
          │                    ┌────┴────┐
          │                    │  PART   │
          │                    └────┬────┘
          │                         │
     ┌────┴────┐              ┌─────┴─────┐
     │  ORDER  │──────────────│ PARTSUPP  │
     └────┬────┘              └───────────┘
          │
     ┌────┴────┐
     │LINEITEM │
     └─────────┘
```

## 📈 Model Dependencies

```
Staging Models (8)
    ↓
Hub Models (6)
    ↓
Link Models (7) ← depends on staging
    ↓
Satellite Models (8) ← depends on staging
    ↓
Business Vault Models (3) ← depends on hubs, links, satellites
    ↓
Dimension Models (4) ← depends on business vault
    ↓
Fact Models (2) ← depends on dimensions & business vault
    ↓
Mart Models (2) ← depends on facts & dimensions
```

## 🔍 Hash Key Strategy

### Primary Keys (PK)
- Single business key hashed
- Example: `MD5(CAST(C_CUSTKEY AS STRING))`
- Used in Hubs

### Foreign Keys (FK)
- Multiple business keys concatenated and hashed
- Example: `MD5(CONCAT(C_CUSTKEY, '||', O_ORDERKEY))`
- Used in Links

### Hash Diff
- All descriptive attributes concatenated and hashed
- Used for change detection in Satellites
- Only insert new row if hash diff changes

## 🚀 Performance Optimization

### Staging Layer
- **Views**: No storage, always fresh data
- **Pushed down**: Computation happens in Databricks

### Raw Vault
- **Incremental**: Only new records inserted
- **Partitioned**: By LOAD_DATE (configurable)
- **Delta Format**: ACID transactions, time travel

### Information Marts
- **Pre-aggregated**: Faster query performance
- **Denormalized**: Fewer joins needed
- **Star Schema**: Optimized for BI tools

## 🎓 Data Vault 2.0 Compliance

✅ **Hubs**: Business keys only
✅ **Links**: Relationships between hubs
✅ **Satellites**: Descriptive attributes + history
✅ **Hash Keys**: Platform-agnostic surrogate keys
✅ **Load Date**: Audit trail
✅ **Record Source**: Data lineage
✅ **Append-Only**: Immutable raw vault
✅ **Business Vault**: Simplified views
✅ **Information Marts**: Consumption layer

## 🔧 Extensibility Points

Want to extend this Data Vault? Easy additions:

1. **Add New Sources**: Create staging models
2. **Add PITs**: Point-in-Time tables for history
3. **Add Bridges**: Query performance optimization
4. **Add Business Rules**: Business vault calculations
5. **Add Custom Marts**: Domain-specific analytics
6. **Add Tests**: Data quality validations
7. **Add Snapshots**: Type 2 slowly changing dimensions

---

This architecture provides a solid foundation for a production Data Vault 2.0 implementation on Databricks! 🎉

