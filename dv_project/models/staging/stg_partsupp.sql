{{- config(
    materialized='incremental',
    schema='staging',
    tags=['staging', 'psa'],
    unique_key='PARTSUPP_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: partsupp
derived_columns:
  RECORD_SOURCE: "'TPCH_PARTSUPP'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  PARTSUPP_PK:
    - "PS_PARTKEY"
    - "PS_SUPPKEY"
  PART_PK: "PS_PARTKEY"
  SUPPLIER_PK: "PS_SUPPKEY"
  PART_SUPPLIER_FK:
    - "PS_PARTKEY"
    - "PS_SUPPKEY"
  PARTSUPP_HASHDIFF:
    is_hashdiff: true
    columns:
      - "PS_AVAILQTY"
      - "PS_SUPPLYCOST"
      - "PS_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

