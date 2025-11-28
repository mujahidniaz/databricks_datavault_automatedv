{{- config(
    materialized='incremental',
    schema='bronze_psa',
    tags=['bronze', 'psa', 'lineitem'],
    unique_key='LINEITEM_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: lineitem
derived_columns:
  RECORD_SOURCE: "'TPCH_LINEITEM'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  LINEITEM_PK:
    - "L_ORDERKEY"
    - "L_LINENUMBER"
  ORDER_PK: "L_ORDERKEY"
  PART_PK: "L_PARTKEY"
  SUPPLIER_PK: "L_SUPPKEY"
  ORDER_LINEITEM_FK:
    - "L_ORDERKEY"
    - "L_LINENUMBER"
  ORDER_PART_SUPPLIER_FK:
    - "L_ORDERKEY"
    - "L_PARTKEY"
    - "L_SUPPKEY"
  LINEITEM_HASHDIFF:
    is_hashdiff: true
    columns:
      - "L_QUANTITY"
      - "L_EXTENDEDPRICE"
      - "L_DISCOUNT"
      - "L_TAX"
      - "L_RETURNFLAG"
      - "L_LINESTATUS"
      - "L_SHIPDATE"
      - "L_COMMITDATE"
      - "L_RECEIPTDATE"
      - "L_SHIPINSTRUCT"
      - "L_SHIPMODE"
      - "L_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

