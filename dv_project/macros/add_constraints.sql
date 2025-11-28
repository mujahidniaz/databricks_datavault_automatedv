{% macro add_primary_key(table_name, column_name) %}
    ALTER TABLE {{ table_name }} 
    ADD CONSTRAINT pk_{{ table_name.identifier }}_{{ column_name }} 
    PRIMARY KEY({{ column_name }});
{% endmacro %}

{% macro add_foreign_key(table_name, column_name, ref_table, ref_column) %}
    ALTER TABLE {{ table_name }} 
    ADD CONSTRAINT fk_{{ table_name.identifier }}_{{ column_name }} 
    FOREIGN KEY({{ column_name }}) 
    REFERENCES {{ ref_table }}({{ ref_column }});
{% endmacro %}

