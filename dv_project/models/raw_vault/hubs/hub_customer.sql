{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['hub', 'customer']
) -}}

{%- set source_model = "stg_customer" -%}
{%- set src_pk = "CUSTOMER_PK" -%}
{%- set src_nk = "C_CUSTKEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

