{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['hub', 'nation']
) -}}

{%- set source_model = "stg_nation" -%}
{%- set src_pk = "NATION_PK" -%}
{%- set src_nk = "N_NATIONKEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

