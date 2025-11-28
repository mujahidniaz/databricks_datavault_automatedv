{{- config(
    materialized='incremental',
    schema='staging',
    tags=['staging', 'psa'],
    unique_key='ORDER_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: orders
derived_columns:
  RECORD_SOURCE: "'TPCH_ORDERS'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  ORDER_PK: "O_ORDERKEY"
  CUSTOMER_PK: "O_CUSTKEY"
  CUSTOMER_ORDER_FK:
    - "O_CUSTKEY"
    - "O_ORDERKEY"
  ORDER_HASHDIFF:
    is_hashdiff: true
    columns:
      - "O_ORDERSTATUS"
      - "O_TOTALPRICE"
      - "O_ORDERDATE"
      - "O_ORDERPRIORITY"
      - "O_CLERK"
      - "O_SHIPPRIORITY"
      - "O_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

