{{- config(
    materialized='incremental',
    schema='bronze_psa',
    tags=['bronze', 'psa', 'part'],
    unique_key='PART_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: part
derived_columns:
  RECORD_SOURCE: "'TPCH_PART'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  PART_PK: "P_PARTKEY"
  PART_HASHDIFF:
    is_hashdiff: true
    columns:
      - "P_NAME"
      - "P_MFGR"
      - "P_BRAND"
      - "P_TYPE"
      - "P_SIZE"
      - "P_CONTAINER"
      - "P_RETAILPRICE"
      - "P_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

