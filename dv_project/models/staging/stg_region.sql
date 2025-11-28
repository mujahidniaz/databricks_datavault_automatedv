{{- config(
    materialized='incremental',
    schema='bronze_psa',
    tags=['bronze', 'psa', 'region'],
    unique_key='REGION_PK'
) -}}

{%- set yaml_metadata -%}
source_model: 
  tpch: region
derived_columns:
  RECORD_SOURCE: "'TPCH_REGION'"
  LOAD_DATE: "'{{ var('load_date') }}'"
  EFFECTIVE_FROM: "LOAD_DATE"
hashed_columns:
  REGION_PK: "R_REGIONKEY"
  REGION_HASHDIFF:
    is_hashdiff: true
    columns:
      - "R_NAME"
      - "R_COMMENT"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

