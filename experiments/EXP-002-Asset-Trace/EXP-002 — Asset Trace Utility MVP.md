EXP-002 — Asset Trace Utility MVP
Objetivo del experimento

Validar si un agente IA puede implementar una utilidad Python pequeña, autocontenida y de alcance estrictamente limitado a partir de una especificación detallada, respetando el contrato funcional y sin sobrearquitecturar la solución.

Resultado
✅ EXPERIMENTO APROBADO

No es un aprobado por cortesía.

Es un aprobado técnico.

La hipótesis queda validada.

Valoración
Área	Valoración
Respeto del alcance	⭐⭐⭐⭐⭐
Arquitectura	⭐⭐⭐⭐☆
Legibilidad	⭐⭐⭐⭐⭐
UI	⭐⭐⭐⭐☆
JSON	⭐⭐⭐⭐⭐
Portabilidad	⭐⭐⭐⭐☆
Robustez	⭐⭐⭐☆☆
Necesidad de correcciones	Baja
Lo que ha hecho muy bien
Alcance

No ha intentado reinventar nada.

No hay:

base de datos
ORM
plugins
framework web
dependencias absurdas

Eso ya es una victoria.

Código

El proyecto se entiende.

La separación es limpia:

main
UI
Scanner
Catalog
Persistence
Models

Muy apropiado para un MVP.

JSON

Muy cercano al contrato solicitado.

Legible.

Sencillo.

UI

Sorprendentemente usable.

No parece una demo de consola.

Permite trabajar.

Portabilidad

Mover el proyecto a:

experiments/
    EXP-002/

no rompió nada.

El único fallo fue nuestro.

😂

Observaciones encontradas

Ninguna invalida el experimento.

Son refinamientos propios de una primera versión.

OBS-001

El scanner incorpora archivos internos de Godot.

Ejemplo:

.import
.uid

Debe existir una política de exclusión.

OBS-002

Los estados NEW/MODIFIED necesitan revisarse.

Actualmente el hash de referencia se actualiza demasiado pronto.

Debe compararse contra el último catálogo persistido.

OBS-003

No existe preview de imágenes.

No es un fallo.

Simplemente mejora UX.

Queda fuera del MVP.

OBS-004

Persistencia mejorable.

No existe escritura atómica.

No existe recuperación ante JSON corrupto.

No bloquea el MVP.

Conclusión técnica

El resultado demuestra que, con una especificación suficientemente precisa, el agente es capaz de producir una herramienta pequeña, funcional y mantenible respetando el alcance solicitado.

Las incidencias encontradas pertenecen al dominio del problema (Godot, política de escaneo, UX y persistencia) y no evidencian problemas estructurales de arquitectura.

No se detecta sobreingeniería ni desviaciones importantes respecto al objetivo inicial.

EXP-002 — Asset Trace Utility
STATUS
PASSED
Objetivo

Validar la capacidad de un agente de implementación para desarrollar una utilidad de trazabilidad de Assets de alcance reducido siguiendo un proceso de ingeniería asistido por IA.

Resultado

PASSED

La utilidad alcanza un nivel funcional suficiente para incorporarse al flujo de trabajo de Lands of Folklore.

Implementa correctamente:

Workspace .metallabs
Catálogo persistente de Assets
Gestión de Sources
Gestión de recibos
Hashing y detección de cambios
Estados editoriales
Whitelist de Assets
Preview de imágenes
Arquitectura modular
Suite básica de tests
Observaciones

Durante el desarrollo se detectaron diversas mejoras mediante validación manual:

refinamiento del flujo del Inspector;
integración más natural de Sources;
mejoras de UX;
pequeños defectos de sincronización UI;
oportunidades de ampliación del sistema de previews.

Estas observaciones no invalidan el resultado del experimento y pasan a formar parte del roadmap normal de la utilidad.

Evaluación del Agente (Jules)
Fortalezas
Excelente disciplina arquitectónica.
Respeta el alcance solicitado.
Implementación limpia y modular.
Muy buena respuesta al feedback.
Alta productividad en tareas bien definidas.
Debilidades observadas
Tiende a cerrar requisitos parcialmente implementados.
Necesita criterios de aceptación muy concretos.
Presenta menor precisión en tareas de UX y flujos de usuario.
Requiere revisión manual antes del merge.
Lecciones aprendidas

Las tareas de implementación complejas deben dividirse en cortes pequeños, con criterios de aceptación verificables y una fase explícita de validación manual antes del cierre.

El proceso MetalLabs:

Arquitectura
    ↓
Implementación
    ↓
Validación Manual
    ↓
Revisión Técnica
    ↓
Corrección
    ↓
Merge

ha demostrado ser eficaz para aumentar la calidad del resultado final.

Veredicto
EXP-002

STATUS

PASSED

Observación

El tiempo de ejecución de Jules para tareas de implementación resulta elevado para un flujo de trabajo iterativo.

Durante EXP-002, varias tareas de alcance reducido requirieron esperas de decenas de minutos e incluso horas, lo que dificulta mantener un ciclo rápido de:

Implementar
↓
Probar
↓
Corregir
↓
Repetir

En tareas donde la validación manual descubre pequeños ajustes, la latencia entre iteraciones se convierte en el principal cuello de botella.

Impacto
Reduce significativamente la velocidad del ciclo de desarrollo.
Penaliza la resolución de incidencias pequeñas.
Favorece acumular demasiados cambios en una sola entrega.
Recomendación

Utilizar Jules únicamente para:

implementaciones relativamente grandes y bien definidas;
tareas que puedan ejecutarse en segundo plano mientras el desarrollador continúa trabajando.

No utilizar Jules para:

correcciones pequeñas;
ajustes de UX;
ciclos rápidos de prueba-error;
cambios que requieran varias iteraciones consecutivas.


Malo para Jules
"Rehacer el Inspector."

Porque mezcla:

UI
UX
modelo
persistencia
preview
eventos
Bueno para Jules
Implementar whitelist.

No tocar nada más.

Criterios:

...

Tests:

...

Eso son 300 líneas.


Otro ejemplo.

Malo
"Haz Sprint 4."
Bueno
Implementa CatalogScanner.

No modifiques UI.

No modifiques modelos.

No modifiques persistencia.

Entrega tests.

