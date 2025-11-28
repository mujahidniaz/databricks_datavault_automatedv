{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'satellite', 'region']
) -}}

{%- set source_model = "stg_region" -%}
{%- set src_pk = "REGION_PK" -%}
{%- set src_hashdiff = "REGION_HASHDIFF" -%}
{%- set src_payload = ["R_NAME", "R_COMMENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

