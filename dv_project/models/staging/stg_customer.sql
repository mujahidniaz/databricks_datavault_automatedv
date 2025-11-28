{{- config(
    materialized='incremental',
    schema='bronze_psa',
    tags=['bronze', 'psa', 'customer'],
    unique_key='CUSTOMER_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: customer
derived_columns:
  RECORD_SOURCE: "'TPCH_CUSTOMER'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  CUSTOMER_PK: "C_CUSTKEY"
  NATION_PK: "C_NATIONKEY"
  CUSTOMER_NATION_FK:
    - "C_CUSTKEY"
    - "C_NATIONKEY"
  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - "C_NAME"
      - "C_ADDRESS"
      - "C_PHONE"
      - "C_ACCTBAL"
      - "C_MKTSEGMENT"
      - "C_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

