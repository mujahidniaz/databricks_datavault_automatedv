{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['hub', 'supplier']
) -}}

{%- set source_model = "stg_supplier" -%}
{%- set src_pk = "SUPPLIER_PK" -%}
{%- set src_nk = "S_SUPPKEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

