ADR-002 — Asset Catalog Persistence

Estado: Accepted

Objetivo

Definir la persistencia del catálogo de assets.

Decisión

El catálogo se almacenará en:

.metallabs/
    asset_catalog.json

Cada entrada representa un Asset conocido por el proyecto.

El catálogo constituye la referencia persistente contra la que se comparan futuros escaneos.

Nunca debe generarse fuera del proyecto.

Consecuencias
El catálogo pertenece al proyecto.
La utilidad es completamente stateless.
Permite trabajar sobre múltiples proyectos.