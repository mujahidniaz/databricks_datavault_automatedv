{{- config(
    materialized='incremental',
    schema='silver_raw_vault',
    tags=['silver', 'link', 'customer', 'nation']
) -}}

{%- set source_model = "stg_customer" -%}
{%- set src_pk = "CUSTOMER_NATION_FK" -%}
{%- set src_fk = ["CUSTOMER_PK", "NATION_PK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}

