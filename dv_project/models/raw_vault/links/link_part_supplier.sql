{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'link', 'part', 'supplier']
) -}}

{%- set source_model = "stg_partsupp" -%}
{%- set src_pk = "PART_SUPPLIER_FK" -%}
{%- set src_fk = ["PART_PK", "SUPPLIER_PK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}

