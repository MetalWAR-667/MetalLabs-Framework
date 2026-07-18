# 🧪 MetalLab AIS Framework
## El Presupuesto del Caos — v0.0777
*Marco experimental de mutación creativa controlada para agentes de IA*

> *"La innovación sin disciplina se convierte en caos. La disciplina sin experimentación se convierte en estancamiento. El Presupuesto del Caos existe en algún punto intermedio."*

---

### Ley 0 — MetalLab existe para servir a Lands of Folklore, nunca para sustituirlo.
> *"MetalLab es un laboratorio de aprendizaje, investigación y experimentación. Su misión es mejorar los procesos, herramientas y conocimientos aplicables a Lands of Folklore y a futuros proyectos. El laboratorio nunca debe convertirse en un fin en sí mismo ni desplazar el desarrollo del proyecto principal."*

Un laboratorio serio que no se toma demasiado en serio a sí mismo.

Tres agentes entran. Solo uno la abandona con el *pull request* aprobado.

Antes de que nadie saque conclusiones precipitadas, una aclaración:  
Esto no pretende demostrar qué IA es mejor.  
Pretende comprobar qué ocurre cuando distintas IA trabajan bajo las mismas reglas, con el mismo presupuesto de cambio y el mismo criterio de revisión.

Si mañana desaparecen estos modelos y aparecen otros nuevos, el experimento debería seguir siendo válido.  
**Los modelos son reemplazables. El proceso no debería serlo.**

Si dentro de tres años desaparecen Gemini, Claude, Codex o Jules, y aparecen otros cuatro agentes completamente distintos, el protocolo debería seguir funcionando exactamente igual.  
Si eso ocurre, el *framework* habrá demostrado que estaba abstraído del proveedor tecnológico.

---

## 📖 1. Resumen ejecutivo

El Presupuesto del Caos es un marco experimental de ingeniería de software diseñado para investigar si distintos agentes de IA pueden detectar, proponer e implementar mejoras valiosas, inesperadas y técnicamente sólidas cuando trabajan dentro de un entorno estrictamente restringido.

El banco de pruebas será **The METAL_IAS — Absurdly Oversized Installer**, un proyecto pequeño, funcional, deliberadamente sobredimensionado y suficientemente prescindible como para permitir experimentos sin poner en peligro un desarrollo crítico.

El objetivo no es descubrir qué IA escribe más código.  
Tampoco demostrar que un agente puede sustituir al desarrollador.  
El objetivo es estudiar:

- Qué considera valioso cada agente.
- Cómo selecciona los problemas.
- Cuánto contexto necesita.
- Cómo responde a restricciones estrictas.
- Qué calidad ofrece su implementación.
- Cuánto trabajo humano exige verificarla.
- En qué tipo de tareas resulta más eficiente cada modelo.
- Cuando un modelo rápido es suficiente y cuándo merece la pena recurrir a uno avanzado.

El propósito final no es la automatización pura.  
Es la emergencia controlada y la construcción de un flujo de trabajo asistido por IA que resulte útil, verificable y sostenible.

---

## 🎯 2. El Verdadero Objetivo del Experimento

Este experimento no pretende descubrir qué agente de IA es "el mejor".  
No trata sobre Jules.  
No trata sobre DeepSeek.  
Ni sobre Codex.  
Ni sobre Gemini.  
Ni sobre Claude.

El verdadero objeto de estudio es **el Presupuesto del Caos**.  
Es decir, el marco de trabajo que define cómo distintos agentes pueden colaborar dentro de un proceso de ingeniería donde la creatividad está permitida, pero el alcance permanece estrictamente controlado.

La prueba de que el marco tiene sentido es muy sencilla: Si mañana todos los modelos actuales desaparecieran y fueran sustituidos por otros completamente distintos, el experimento seguiría siendo válido. Bastaría con reemplazar los agentes actuales por otros y aplicar exactamente las mismas reglas.

Si las conclusiones continúan siendo útiles independientemente del nombre del modelo, significa que el valor del experimento no reside en comparar una tecnología concreta, sino en diseñar un proceso reproducible para colaborar con agentes de inteligencia artificial.

**Los modelos cambiarán. El marco permanecerá.** Y ese es, precisamente, el verdadero objetivo de MetalLab.

---

## 🎯 3. Hipótesis central

Un proyecto de software puede reservar de forma segura un pequeño **Presupuesto del Caos** donde diferentes agentes exploren ideas no convencionales sin comprometer:

- La estabilidad.
- La arquitectura.
- El alcance.
- La mantenibilidad.
- La visión a largo plazo.
- La rama principal del proyecto.

La creatividad se convierte en un experimento. La arquitectura continúa siendo determinista. La innovación se vuelve probabilística.

---

## ⚠️ 4. Hipótesis previas y limitaciones

Las expectativas sobre Jules, Gemini, Codex o Claude representan únicamente hipótesis previas basadas en experiencias anteriores. No constituyen resultados ni conclusiones.

Estas predicciones deben conservarse sin modificaciones antes de comenzar el experimento para poder comparar posteriormente qué comportamientos fueron inesperados y qué juicios estaban condicionados por experiencias previas.

### 4.1 Limitación de contexto
Las primeras pruebas pueden realizarse sin proporcionar al agente el contexto completo del proyecto:
- ADRs.
- Contratos arquitectónicos.
- Decisiones históricas.
- Filosofía de diseño.
- Documentación técnica exhaustiva.

Por tanto, un resultado deficiente no debe atribuirse automáticamente a una limitación del modelo. Puede proceder de falta de contexto, mala división del problema o ambigüedad en la misión.

### 4.2 Observación previa
Todos los modelos probados hasta el momento han demostrado que pueden trabajar de forma sorprendentemente eficiente cuando reciben:
- Contexto suficiente.
- Un problema dividido en pulsos pequeños y coherentes.
- Misiones con un alcance limitado y bien definido.

Por ello, MetalLab no pretende responder *"¿Cuál es la mejor IA?"*, sino observar cómo cambia el comportamiento de cada una cuando comparten las mismas condiciones.

---

## 🛡️ 5. Reglas fundamentales

### 5.1 La regla de oro
Todo experimento debe ser completamente desechable.
Si eliminar la rama experimental perjudica al proyecto, el aislamiento ha fallado y el experimento queda invalidado.

### 5.2 El núcleo protegido — ADN inmutable
Los siguientes elementos definen la identidad del proyecto y **no pueden modificarse**:
- Punto de entrada principal (`main.py`).
- Arquitectura documentada.
- Contratos de API pública.
- Filosofía del proyecto.
- Estándares de codificación.
- Flujo estable de instalación.

Los agentes pueden leerlos, analizarlos y criticarlos en su informe, pero no pueden modificarlos porque una noche se hayan sentido especialmente inspirados.

### 5.3 Presupuesto máximo de mutación
Cada ciclo permite como máximo:

| Recurso | Límite |
|---------|--------|
| Nueva funcionalidad | 1 |
| Archivos fuente modificados | 2 |
| Recursos o archivos de datos nuevos | 1 |
| Cambios arquitectónicos | 0 |
| Tests rotos | 0 |
| Excusas creativas | 0 |

El presupuesto es un límite máximo, no un objetivo obligatorio. Una solución de ocho líneas puede ser mejor que otra de trescientas.

### 5.4 Reglas de supervivencia
Cualquiera de las siguientes condiciones implica el rechazo automático de la mutación:
- Error de sintaxis o compilación.
- Tests automatizados rotos.
- Reducción injustificada de cobertura.
- Violación de contratos arquitectónicos.
- Regresión de rendimiento significativa.
- Efectos secundarios ocultos.

### 5.5 Opción legítima de inacción
El agente puede concluir que ninguna modificación merece consumir el Presupuesto del Caos. En ese caso debe explicar qué alternativas evaluó, por qué las descartó y qué aprendió sobre el sistema actual.

No modificar nada puede demostrar comprensión del sistema, contención, madurez y capacidad de priorización.

---

## 🏗️ 6. Diseño experimental

Todos los agentes comienzan desde un mismo punto congelado: **`chaos-base-001`**. Los agentes no se comunican entre ellos y no conocen las propuestas de sus competidores.

### 6.1 Fase A — Mutación libre
Todos los agentes reciben el repositorio completo, el Presupuesto del Caos, las reglas del laboratorio y **ninguna orientación** sobre qué módulo deben tocar.

- **Pregunta experimental:** ¿Qué ve cada modelo cuando observa el proyecto sin que nadie le diga qué buscar?
- **Qué se evalúa:** Iniciativa, selección del problema, comprensión global, capacidad de contención y capacidad de no actuar.

### 6.2 Fase B — Misión dirigida
Todos los agentes reciben el mismo archivo o subsistema, la misma tarea, las mismas restricciones y el mismo *commit* base limpio.

- **Pregunta experimental:** ¿Cómo resuelve cada modelo el mismo problema técnico cuando todos parten exactamente del mismo punto?
- **Ronda B1 (`effects.py`):** Evalúa creatividad algorítmica, rendimiento y compatibilidad con NumPy.
- **Ronda B2 (`audio.py`):** Evalúa fallbacks, sincronización y errores de dispositivos.
- **Ronda B3 (`installer.py`):** Evalúa ingeniería defensiva, operaciones de entrada y salida, manejo de rutas y recuperación ante fallos.
- **Ronda B4 (`Compiler_GUIV2.py`):** Evalúa integración, *pipeline* de compilación y respeto estricto por el alcance.

### 6.3 Fase C — Roles especializados
Esta fase es un ensayo del equipo real y solo se realizará después de observar las tendencias:
- **Jules:** Automatización y *pipelines*.
- **Gemini:** Matemáticas, efectos y exploración visual.
- **Codex:** Implementación, robustez y tests.
- **Claude:** Crítica, documentación y refactorización.

---

## ⚡ 7. Comparación entre modelos rápidos y avanzados

Cuando la plataforma lo permita, una misma prueba deberá ejecutarse utilizando un modelo rápido (Flash) y un modelo avanzado (Pro).

### Hipótesis Comparativas
- **H1 — Pulsos quirúrgicos:** En tareas pequeñas y cerradas, los modelos rápidos ofrecerán mejor relación coste/resultado.
- **H2 — Ambigüedad:** En tareas creativas o abiertas, los modelos avanzados mostrarán mayor capacidad de selección.
- **H3 — Sobrepensamiento:** Los modelos avanzados pueden introducir complejidad innecesaria sin un límite estricto.
- **H4 — Calidad del *prompt*:** Un *prompt* bien definido reducirá la diferencia entre modelos rápidos y avanzados.
- **H5 — Coste humano:** El factor decisivo será el tiempo humano requerido para revisar y verificar la propuesta.

---

## 🔬 8. Metodología de evaluación

### 8.1 Aislamiento efímero mediante Git
Cada agente evoluciona dentro de una rama aislada de Git y desechable (ej. `lab/free-001-codex`). Ningún experimento nace desde otra rama experimental.

### 8.2 *Prompt* congelado
El *prompt* se guarda en un archivo (ej. `metallab/prompts/free_mutation_v1.md`) y no se ajusta entre agentes durante una misma ronda para no contaminar la prueba.

### 8.3 Contrato de defensa
Cada propuesta debe responder obligatoriamente:
- ¿Qué problema real resuelve?
- ¿Por qué merecía gastar el Presupuesto del Caos?
- ¿Qué otras dos ideas consideraste y por qué fueron descartadas?
- ¿Qué riesgos introduce la propuesta?

### 8.4 Evaluación ciega
Las propuestas se exportan y evalúan de forma anónima (**Mutación A**, **Mutación B**, etc.) para reducir sesgos antes de revelar la autoría.

---

## 📊 9. Matriz de revisión quirúrgica

### Calidad de la decisión
| Vector | Pregunta |
|--------|----------|
| Selección del problema | ¿Eligió algo que realmente merecía ser cambiado? |
| Originalidad | ¿La propuesta aporta una idea no evidente? |
| Utilidad | ¿Mejora el proyecto o la experiencia de uso? |
| Contención | ¿Utilizó únicamente el caos necesario? |
| Capacidad de renuncia | ¿Habría sabido no modificar nada? |

### Calidad de la ejecución
| Vector | Pregunta |
|--------|----------|
| Mantenibilidad | ¿Se entenderá dentro de seis meses? |
| Validación | ¿Las pruebas demuestran realmente el comportamiento? |
| Riesgo | ¿Qué superficie de rotura introduce? |
| Honestidad | ¿Reconoce límites, supuestos y partes no verificadas? |

### Coste real
| Vector | Pregunta |
|--------|----------|
| Coste de revisión | ¿Cuánto trabajo humano exigió verificarlo? |
| Valor neto | ¿La utilidad compensa los costes técnicos y humanos? |

---

## ⚖️ 10. El Veredicto del Mecánico

No existen fusiones automáticas. El desarrollador humano inspecciona cada propuesta y puede decidir fusionar una mutación, fusionar varias, o no fusionar ninguna.

Un agente no gana por producir más código. Gana si su propuesta demuestra utilidad, contención y bajo riesgo. Eliminar todas las ramas se considera un resultado perfectamente exitoso.

---

## 📓 11. Registro de laboratorio

```markdown
## 🧪 Chaos Budget Log #001

### Identificación
- Fase:
- Ronda:
- Agente: [Jules / Gemini / Codex / Claude]
- Modelo: Flash / Pro / Auto
- Commit base:
- Rama:

### Presupuesto consumido
- Features: 0 / 1
- Archivos fuente modificados: 0 / 2
- Recursos nuevos: 0 / 1
- Cambios arquitectónicos: 0 / 0

### Verificación
- Sintaxis o compilación: PASS / FAIL
- Tests: PASS / FAIL
- Contratos respetados: SÍ / NO

### Propuesta
- Problema seleccionado:
- Mutación implementada:
- Ideas descartadas:
- Riesgos reconocidos:

### Veredicto del Mecánico
- MERGE / RECHAZADA / DESGUACE
- Lecciones Aprendidas:
(Adaptación estructural basada en)

🧬 12. Filosofía final
Git registra la evolución:

Cada rama es una mutación.

Cada Pull Request es una hipótesis.

Cada merge es supervivencia o selección artificial.

Cada rama eliminada es una especie extinta.

El mejor experimento no es el que sobrevive. Es el que enseña algo.