{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['satellite', 'part']
) -}}

{%- set source_model = "stg_part" -%}
{%- set src_pk = "PART_PK" -%}
{%- set src_hashdiff = "PART_HASHDIFF" -%}
{%- set src_payload = ["P_NAME", "P_MFGR", "P_BRAND", "P_TYPE", 
                       "P_SIZE", "P_CONTAINER", "P_RETAILPRICE", "P_COMMENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

