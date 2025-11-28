{{- config(
    materialized='view',
    schema='staging',
    tags=['staging']
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: nation
derived_columns:
  RECORD_SOURCE: "'TPCH_NATION'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  NATION_PK: "N_NATIONKEY"
  REGION_PK: "N_REGIONKEY"
  NATION_REGION_FK:
    - "N_NATIONKEY"
    - "N_REGIONKEY"
  NATION_HASHDIFF:
    is_hashdiff: true
    columns:
      - "N_NAME"
      - "N_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

