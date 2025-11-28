# Star Schema - Information Marts

## 📊 Schema Design

The information marts layer implements a **star schema** with proper Primary Key and Foreign Key relationships for optimal query performance and BI tool integration.

## 🔑 Primary Keys and Foreign Keys

### Dimensions (Primary Keys)

#### `dim_customer` 
**Primary Key:** `customer_key`
- Unique identifier for each customer
- Includes customer geography (nation, region)

#### `dim_supplier`
**Primary Key:** `supplier_key`
- Unique identifier for each supplier
- Includes supplier geography (nation, region)

#### `dim_part`
**Primary Key:** `part_key`
- Unique identifier for each part
- Includes part attributes (brand, type, manufacturer)

#### `dim_date`
**Primary Key:** `date_day`
- Unique date value
- Includes date attributes (year, month, quarter, etc.)

### Facts (Primary Keys + Foreign Keys)

#### `fact_orders`
**Primary Key:** `order_key`

**Foreign Keys:**
- `customer_key` → `dim_customer(customer_key)`
- `order_date` → `dim_date(date_day)`

#### `fact_lineitem`
**Primary Key:** `lineitem_key`

**Foreign Keys:**
- `order_key` → `fact_orders(order_key)`
- `customer_key` → `dim_customer(customer_key)`
- `part_key` → `dim_part(part_key)`
- `supplier_key` → `dim_supplier(supplier_key)`
- `order_date` → `dim_date(date_day)`

## 🎯 Star Schema Diagram

```
                    ┌─────────────┐
                    │  dim_date   │
                    │─────────────│
                    │ date_day PK │
                    │ year        │
                    │ quarter     │
                    │ month       │
                    └──────┬──────┘
                           │
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        │                  │                  │
┌───────▼────────┐  ┌──────▼──────────┐  ┌──▼────────────────┐
│ dim_customer   │  │  fact_orders    │  │  fact_lineitem    │
│────────────────│  │─────────────────│  │───────────────────│
│ customer_key PK│◄─┤ order_key PK    │◄─┤ lineitem_key PK   │
│ customer_id    │  │ customer_key FK │  │ order_key FK      │
│ customer_name  │  │ order_date FK   │  │ customer_key FK   │
│ nation_name    │  │ total_price     │  │ part_key FK       │
│ region_name    │  │ order_status    │  │ supplier_key FK   │
└────────────────┘  └─────────────────┘  │ order_date FK     │
                                         │ quantity          │
                                         │ extended_price    │
                    ┌────────────────┐   │ discount          │
                    │  dim_part      │   │ total_price       │
                    │────────────────│   └───────────────────┘
                    │ part_key PK    │◄──────────┘
                    │ part_id        │
                    │ part_name      │
                    │ manufacturer   │
                    │ brand          │
                    └────────────────┘
                    
                    ┌────────────────┐
                    │  dim_supplier  │
                    │────────────────│
                    │ supplier_key PK│◄──────────┘
                    │ supplier_id    │
                    │ supplier_name  │
                    │ nation_name    │
                    │ region_name    │
                    └────────────────┘
```

## 📝 Constraint Details

### Important Notes

1. **Informational Only**: In Databricks, constraints are **NOT ENFORCED** but serve as:
   - Metadata for query optimization
   - Documentation for developers
   - Hints for BI tools (Tableau, Power BI, Looker)

2. **Query Optimization**: Databricks SQL optimizer can use these constraints to:
   - Generate better execution plans
   - Optimize joins
   - Improve query performance

3. **BI Tool Integration**: BI tools can automatically:
   - Detect relationships
   - Build semantic models
   - Suggest joins
   - Create default visualizations

## 🔍 Querying with Relationships

### Example: Orders with Customer Details
```sql
SELECT 
    c.customer_name,
    c.region_name,
    o.order_date,
    o.total_price
FROM fact_orders o
JOIN dim_customer c ON o.customer_key = c.customer_key
JOIN dim_date d ON o.order_date = d.date_day
WHERE d.year = 1995;
```

### Example: Line Items with All Dimensions
```sql
SELECT 
    c.customer_name,
    p.part_name,
    s.supplier_name,
    d.year,
    d.month_name,
    li.quantity,
    li.total_price
FROM fact_lineitem li
JOIN dim_customer c ON li.customer_key = c.customer_key
JOIN dim_part p ON li.part_key = p.part_key
JOIN dim_supplier s ON li.supplier_key = s.supplier_key
JOIN dim_date d ON li.order_date = d.date_day;
```

## 🚀 Benefits of This Design

### 1. **Performance**
- Star schema is optimized for analytical queries
- Denormalized dimensions reduce joins
- Databricks optimizer uses constraint metadata

### 2. **Simplicity**
- Easy to understand structure
- Straightforward join paths
- Clear business meaning

### 3. **Flexibility**
- Easy to add new dimensions
- Simple to extend facts
- Support for complex queries

### 4. **BI Tool Integration**
- Auto-discovery of relationships
- Semantic layer generation
- Drag-and-drop analytics

## 📊 Cardinality

| Relationship | Type | Cardinality |
|--------------|------|-------------|
| dim_customer → fact_orders | One-to-Many | 1:N |
| dim_date → fact_orders | One-to-Many | 1:N |
| fact_orders → fact_lineitem | One-to-Many | 1:N |
| dim_customer → fact_lineitem | One-to-Many | 1:N |
| dim_part → fact_lineitem | One-to-Many | 1:N |
| dim_supplier → fact_lineitem | One-to-Many | 1:N |
| dim_date → fact_lineitem | One-to-Many | 1:N |

## 🔧 Rebuilding with Constraints

To rebuild the information marts with constraints:

```bash
# Drop and recreate information marts
dbt run --select information_marts --full-refresh

# Or rebuild specific models
dbt run --select dim_customer dim_supplier dim_part dim_date
dbt run --select fact_orders fact_lineitem
```

## ✅ Verifying Constraints

Check constraints in Databricks:

```sql
-- Show table constraints
DESCRIBE EXTENDED mujahid_data_vault_demo.information_marts.dim_customer;

-- Show all constraints for a table
SHOW TBLPROPERTIES mujahid_data_vault_demo.information_marts.fact_lineitem;

-- Query information schema
SELECT 
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'information_marts';
```

## 🎓 Best Practices

1. **Always define PKs on dimensions**
2. **Define FKs from facts to dimensions**
3. **Use surrogate keys (not natural keys) for PKs**
4. **Keep dimension keys immutable**
5. **Use consistent naming conventions**
6. **Document relationships in schema.yml**

---

This star schema design provides a solid foundation for analytics and BI reporting! 🎉

