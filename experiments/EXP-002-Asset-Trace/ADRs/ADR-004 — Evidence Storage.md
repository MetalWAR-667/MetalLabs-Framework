ADR-004 — Evidence Storage

Estado: Accepted

Objetivo

Centralizar la evidencia documental.

Decisión

Toda evidencia asociada a una Source se almacena dentro de:

.metallabs/
    receipts/

Inicialmente se soportan:

PDF
imágenes de recibos

El catálogo almacena únicamente rutas relativas.

Nunca rutas absolutas.

Consecuencias

La trazabilidad permanece portable.