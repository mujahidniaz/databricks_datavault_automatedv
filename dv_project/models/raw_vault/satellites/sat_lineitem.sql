{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'satellite', 'lineitem']
) -}}

{%- set source_model = "stg_lineitem" -%}
{%- set src_pk = "LINEITEM_PK" -%}
{%- set src_hashdiff = "LINEITEM_HASHDIFF" -%}
{%- set src_payload = ["L_QUANTITY", "L_EXTENDEDPRICE", "L_DISCOUNT", "L_TAX", 
                       "L_RETURNFLAG", "L_LINESTATUS", "L_SHIPDATE", "L_COMMITDATE", 
                       "L_RECEIPTDATE", "L_SHIPINSTRUCT", "L_SHIPMODE", "L_COMMENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

