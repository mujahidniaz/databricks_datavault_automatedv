{{- config(
    materialized='incremental',
    schema='raw_vault',
    tags=['link', 'order', 'part', 'supplier']
) -}}

{%- set source_model = "stg_lineitem" -%}
{%- set src_pk = "ORDER_PART_SUPPLIER_FK" -%}
{%- set src_fk = ["ORDER_PK", "PART_PK", "SUPPLIER_PK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}

