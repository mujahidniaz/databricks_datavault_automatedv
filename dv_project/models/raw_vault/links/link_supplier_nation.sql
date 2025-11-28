{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'link', 'supplier', 'nation']
) -}}

{%- set source_model = "stg_supplier" -%}
{%- set src_pk = "SUPPLIER_NATION_FK" -%}
{%- set src_fk = ["SUPPLIER_PK", "NATION_PK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}

