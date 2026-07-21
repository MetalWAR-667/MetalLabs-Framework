ADR-005 — Scan Policy

Estado: Accepted

Objetivo

Definir qué constituye un Asset escaneable.

Decisión

El escáner únicamente procesa los directorios configurados.

Inicialmente:

assets/
raw-textures/

Quedan excluidos:

.git/
.godot/
.import/
__pycache__/

*.import
*.uid

Así como cualquier otro patrón definido por la configuración del proyecto.

Consecuencias

El catálogo refleja únicamente recursos relevantes.

Se evita registrar archivos generados automáticamente por herramientas externas.