{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['satellite', 'order']
) -}}

{%- set source_model = "stg_orders" -%}
{%- set src_pk = "ORDER_PK" -%}
{%- set src_hashdiff = "ORDER_HASHDIFF" -%}
{%- set src_payload = ["O_ORDERSTATUS", "O_TOTALPRICE", "O_ORDERDATE", 
                       "O_ORDERPRIORITY", "O_CLERK", "O_SHIPPRIORITY", 
                       "O_COMMENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

