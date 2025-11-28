{{- config(
    materialized='incremental',
    schema='bronze_psa',
    tags=['bronze', 'psa', 'supplier'],
    unique_key='SUPPLIER_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: supplier
derived_columns:
  RECORD_SOURCE: "'TPCH_SUPPLIER'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  SUPPLIER_PK: "S_SUPPKEY"
  NATION_PK: "S_NATIONKEY"
  SUPPLIER_NATION_FK:
    - "S_SUPPKEY"
    - "S_NATIONKEY"
  SUPPLIER_HASHDIFF:
    is_hashdiff: true
    columns:
      - "S_NAME"
      - "S_ADDRESS"
      - "S_PHONE"
      - "S_ACCTBAL"
      - "S_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

