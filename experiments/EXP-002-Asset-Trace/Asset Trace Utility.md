# Asset Trace Utility

**Status:** Production Ready

**Project:** MetalLabs Framework
**Primary Consumer:** Lands of Folklore

---

# Descripción

Asset Trace Utility es una herramienta de escritorio diseñada para mantener la trazabilidad completa de los recursos utilizados durante el desarrollo de videojuegos.

Su objetivo es proporcionar un catálogo único de Assets donde cada recurso pueda identificarse, auditarse y relacionarse con su origen, evitando pérdidas de información sobre licencias, compras, estados editoriales y modificaciones realizadas durante el desarrollo.

La herramienta nace como una necesidad práctica durante el desarrollo de *Lands of Folklore* y forma parte del conjunto de utilidades internas de MetalLabs.

---

# Objetivos

* Catalogar Assets de un proyecto.
* Mantener la trazabilidad de cada recurso.
* Registrar la procedencia de los Assets.
* Asociar compras y recibos.
* Facilitar auditorías legales y técnicas.
* Detectar Assets nuevos, modificados o desaparecidos.
* Reducir el riesgo de utilizar recursos sin identificar.

---

# Funcionalidades principales

## Escaneo del proyecto

* Exploración recursiva del proyecto.
* Descubrimiento automático de Assets compatibles.
* Lista blanca centralizada de extensiones soportadas.
* Detección de:

  * NEW
  * MODIFIED
  * MISSING
  * OK

---

## Catálogo persistente

* Workspace propio de MetalLabs.
* Persistencia mediante JSON.
* Hash SHA-256.
* Tamaño del archivo.
* Estado editorial.
* Tags.
* Notas.

---

## Gestión de Sources

Cada Asset puede asociarse a una Source común que representa su origen.

Una Source puede almacenar:

* producto
* tienda
* autor
* licencia
* URL
* observaciones
* recibos asociados

---

## Gestión de recibos

Las compras pueden almacenar documentación asociada.

Ejemplos:

* PDF
* imágenes
* facturas
* comprobantes

Los recibos permanecen vinculados a la Source y no a cada Asset individual.

---

## Preview integrado

Identificación rápida del Asset mediante:

* vista previa de imágenes
* reproducción de audio

El Preview forma parte del flujo natural de catalogación.

---

## Estados editoriales

Cada Asset puede clasificarse como:

* PLACEHOLDER
* DORMANT
* PRODUCTION

Facilitando posteriores auditorías y limpieza del proyecto.

---

## Flujo de catalogación

El flujo de trabajo recomendado es:

```text
Scan
    ↓
Seleccionar Asset
    ↓
Identificar mediante Preview
    ↓
Asignar o crear Source
    ↓
Revisar estado editorial
    ↓
Añadir notas si procede
    ↓
Guardar catálogo
```

---

# Filosofía

Asset Trace Utility no pretende ser un gestor documental genérico.

Su única responsabilidad es mantener la trazabilidad de los recursos utilizados por un proyecto de desarrollo.

Las funcionalidades futuras deberán responder siempre a necesidades detectadas durante el uso real de la herramienta.

---

# Equipo del Taller

## Metal

**Dirección del proyecto**

* Diseño funcional
* Arquitectura
* Validación manual
* Integración
* Roadmap
* UX final

---

## Lumen

**Arquitectura técnica**

* Diseño de flujo de trabajo
* Revisión arquitectónica
* Definición de Quick Wins
* Roadmap evolutivo
* Validación funcional
* Criterios de Production Ready

---

## Butch

**Ingeniería y auditoría técnica**

* Implementación incremental
* Revisión de UX
* Eliminación de fricción
* Consolidación del flujo de catalogación
* Implementación de Roadmap V2

---

## Jules

**Implementación inicial**

* Desarrollo del MVP
* Workspace MetalLabs
* Persistencia inicial
* Sistema de Sources
* Base de la herramienta

---

# Estado

```text
Asset Trace Utility

STATUS

PRODUCTION READY
```

A partir de este punto la herramienta entra en fase de uso dentro de *Lands of Folklore*.

Las mejoras futuras deberán surgir del uso real y se registrarán como **Future Seeds** hasta demostrar su utilidad.
