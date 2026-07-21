# EXP-002 — Asset Trace Utility

## Estado

```text
STATUS

PASSED
```

## Objetivo

Validar la capacidad de un equipo de agentes IA para desarrollar una herramienta de escritorio pequeña, autocontenida y orientada a un problema real, siguiendo un proceso de ingeniería asistido y manteniendo un alcance estrictamente controlado.

El resultado esperado no era únicamente obtener una utilidad funcional, sino validar el propio flujo de trabajo de MetalLabs.

---

# Resultado

**PASSED**

Asset Trace Utility alcanza un nivel de madurez suficiente para incorporarse al flujo de trabajo habitual de **Lands of Folklore**.

La herramienta permite:

* Catalogar Assets del proyecto.
* Mantener trazabilidad completa.
* Gestionar Sources compartidas.
* Asociar documentación de compra.
* Detectar Assets nuevos, modificados y desaparecidos.
* Mantener estados editoriales.
* Identificar Assets mediante Preview.
* Trabajar con un flujo de catalogación coherente y estable.

Tras varias iteraciones de validación manual, Quick Wins y Roadmap V2, la utilidad se considera **Production Ready**.

---

# Metodología validada

Durante EXP-002 quedó validado el siguiente flujo de trabajo:

```text
Arquitectura
        ↓
Implementación
        ↓
Validación Manual
        ↓
Auditoría Técnica
        ↓
Correcciones
        ↓
Production Ready
```

La experiencia demuestra que la calidad final no depende únicamente del agente implementador, sino del proceso completo de revisión.

---

# Participantes

## Metal

**Director del proyecto**

Responsabilidades:

* Definición funcional.
* Dirección técnica.
* Arquitectura de producto.
* Validación manual.
* Integración.
* Roadmap.
* Decisión final de aceptación.

**Valoración**

La validación manual continua permitió detectar pequeñas fricciones de uso que difícilmente aparecen durante la implementación aislada, mejorando significativamente la calidad final de la herramienta.

---

## Lumen

**Arquitecto técnico**

Responsabilidades:

* Diseño arquitectónico.
* Definición del flujo de trabajo.
* Revisión funcional.
* Diseño de Quick Wins.
* Diseño del Roadmap evolutivo.
* Revisión de UX.
* Definición de criterios de Production Ready.

**Valoración**

Actuó principalmente como arquitecto y facilitador del proceso, ayudando a mantener el alcance controlado y priorizando mejoras basadas en el uso real frente a nuevas funcionalidades.

---

## Jules

**Implementación inicial**

Responsabilidades:

* Desarrollo del MVP.
* Workspace MetalLabs.
* Persistencia inicial.
* Gestión de Sources.
* Sistema de escaneo.
* Base de la arquitectura.
* Implementación de Sprint 1.

### Fortalezas

* Excelente disciplina arquitectónica.
* Respeta el alcance cuando está bien definido.
* Código limpio y modular.
* Muy buena capacidad para implementar bloques funcionales completos.
* Buena respuesta a revisiones técnicas.

### Aspectos observados

* Tiende a considerar terminadas tareas parcialmente implementadas.
* Necesita criterios de aceptación muy concretos.
* Menor sensibilidad hacia UX y pequeños detalles de interacción.
* Requiere validación manual antes del merge.
* Latencia elevada para tareas pequeñas e iterativas.

### Valoración

Jules resulta especialmente adecuado para implementaciones de tamaño medio o grande con especificaciones cerradas.

No es la mejor opción para ciclos rápidos de prueba, UX o pequeños ajustes consecutivos.

---

## Butch

**Auditor técnico e implementación de consolidación**

Responsabilidades:

* Revisión crítica del MVP.
* Eliminación de fricción.
* Implementación de Quick Wins.
* Desarrollo del Roadmap V2.
* Consolidación del flujo de catalogación.
* Preparación para Production Ready.

### Fortalezas

* Excelente capacidad de análisis previo.
* Propone alternativas antes de modificar código.
* Muy buen criterio para separar problemas funcionales de problemas de UX.
* Mantiene el alcance con disciplina.
* Identifica responsabilidades correctamente antes de implementar.

### Aspectos observados

* Estilo de comunicación muy directo y técnico.
* Tiende a detenerse para confirmar decisiones importantes en lugar de asumirlas.

### Valoración

Butch destaca especialmente en fases de consolidación, auditoría técnica, refactorizaciones controladas y eliminación de fricción.

Su forma de trabajar encaja especialmente bien tras un MVP ya funcional.

---

# Lecciones aprendidas

Durante EXP-002 se confirmaron varias conclusiones relevantes:

* Una especificación clara reduce significativamente las iteraciones.
* Las mejoras de UX aparecen durante el uso real, no durante la implementación.
* Dividir el trabajo en iteraciones pequeñas produce mejores resultados que intentar resolver un Sprint completo de una sola vez.
* La validación manual continúa siendo una parte esencial del proceso.
* No toda buena idea debe implementarse inmediatamente; muchas pertenecen al Roadmap o a Future Seeds.

---

# Veredicto final

EXP-002 valida tanto la utilidad desarrollada como la metodología utilizada para construirla.

Asset Trace Utility pasa a formar parte del conjunto de herramientas internas de MetalLabs y entra oficialmente en fase de uso dentro del desarrollo de **Lands of Folklore**.

Las futuras mejoras deberán surgir exclusivamente del uso real de la herramienta y no de hipótesis de diseño.
