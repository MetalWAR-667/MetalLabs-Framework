ADR-003 — Source Records

Estado: Accepted

Objetivo

Separar la información legal del Asset físico.

Decisión

La información referente a:

tienda
licencia
factura
autor
atribución

no pertenece al Asset.

Pertenece a una Source.

Los Assets únicamente mantienen una referencia mediante:

source_uuid

Las Sources se almacenan en:

.metallabs/
    sources.json
Consecuencias

Una compra puede asociarse a cientos de assets sin duplicar información.