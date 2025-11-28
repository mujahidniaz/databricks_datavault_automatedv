{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['satellite', 'supplier']
) -}}

{%- set source_model = "stg_supplier" -%}
{%- set src_pk = "SUPPLIER_PK" -%}
{%- set src_hashdiff = "SUPPLIER_HASHDIFF" -%}
{%- set src_payload = ["S_NAME", "S_ADDRESS", "S_PHONE", 
                       "S_ACCTBAL", "S_COMMENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

