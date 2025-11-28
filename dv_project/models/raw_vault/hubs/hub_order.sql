{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'hub', 'order']
) -}}

{%- set source_model = "stg_orders" -%}
{%- set src_pk = "ORDER_PK" -%}
{%- set src_nk = "O_ORDERKEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

