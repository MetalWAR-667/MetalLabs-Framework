# MetalLABS Development Workflow

Status: Living Document
Version: 1.1
Language: English (Canonical)

> “Aceptémoslo: la arquitectura es la mínima cantidad de papeleo y disciplina obligatoria que necesitas para que tu proyecto siga siendo mantenible, comprensible y, sobre todo, para que el próximo que toque el código no vaya a buscarte a tu casa con un bate de béisbol.”

---

# Objetivo

Este documento define el flujo habitual de desarrollo utilizado durante la construcción de **Lands of Folklore**.

El objetivo del workflow no es automatizar el desarrollo, sino distribuir correctamente las responsabilidades entre el desarrollador y las distintas herramientas de IA, manteniendo el control arquitectónico, reduciendo la deuda técnica y garantizando que todas las decisiones importantes permanezcan bajo criterio humano.

Este documento describe un proceso de trabajo, no una dependencia tecnológica.

El workflow se revisará cuando la práctica demuestre que alguna fase puede simplificarse, corregirse o mejorarse.


> “Los agentes nunca ejecutan una idea. Ejecutan una decisión aprobada.”

---

# Ley 0

> **El workflow existe para servir al proyecto. Nunca para sustituir el criterio del desarrollador.**

Las herramientas pueden cambiar.

Los agentes pueden cambiar.

El proceso debe permanecer.

---

# Filosofía

Todo cambio sigue este orden general:

```text
Pensar
    ↓
Diseñar
    ↓
Auditar el estado existente
    ↓
Implementar
    ↓
Auditar la arquitectura
    ↓
Validar el funcionamiento
    ↓
Sincronizar la documentación
    ↓
Integrar
```

La implementación nunca precede al diseño.

La documentación nunca intenta justificar retrospectivamente una implementación improvisada.

El código funcional no se considera automáticamente código correcto.

Una implementación debe funcionar y, además, respetar el plano aprobado.

---

# Roles del equipo

Los agentes se asignan por responsabilidad, no por marca o modelo.

El objetivo es que el workflow permanezca estable aunque las herramientas evolucionen o sean sustituidas.

---

## 🕶️ Director Técnico — Metal

### Responsabilidades

* Buscarles problemas al equipo de forma creativa.
* Traducir conceptos complejos a un lenguaje comprensible antes de aprobarlos.
* Mantener la visión general de Lands of Folklore.
* Diseñar sistemas junto al Arquitecto.
* Priorizar el roadmap.
* Congelar y proteger el alcance de cada Latido.
* Tomar las decisiones finales.
* Aceptar, revisar, aplazar o rechazar propuestas.
* Validar manualmente el comportamiento del proyecto.
* Ser el responsable último del código, los commits y la documentación.
* Autorizar la integración en la rama principal.

### Autoridad de veto

Metal puede detener o rechazar cualquier propuesta, aunque ya se haya invertido trabajo en ella.

El trabajo invertido no crea derecho de adopción.

Toda propuesta rechazada tendrá uno de estos destinos:

```text
Aceptar
→ entra en el proyecto

Solicitar revisión
→ vuelve a Diseño con observaciones concretas

Aplazar
→ pasa a Semillas Futuras con un disparador de revisión

Rechazar
→ se registra brevemente el motivo y se cierra
```

---

## 📐 Arquitecto — Lumen / GPT

### Responsabilidades

* Diseñar arquitectura conceptual.
* Revisar responsabilidades entre sistemas.
* Definir contratos entre componentes.
* Redactar propuestas de ADR.
* Contrastar propuestas con las Leyes del Chasis y la arquitectura vigente.
* Detectar inconsistencias conceptuales.
* Identificar riesgos arquitectónicos.
* Diseñar la evolución estructural del Editor, Compiler y Runtime.
* Revisar decisiones técnicas antes de su consolidación.

### No es responsable de

* Mantener la documentación sincronizada con el código real.
* Auditar de forma periódica el árbol documental.
* Localizar archivos duplicados.
* Realizar cambios mecánicos en múltiples documentos.
* Implementar características por iniciativa propia.
* Aprobar decisiones en nombre del Director Técnico.

---

## 📦 Archivista — Jules Winnfield

### Responsabilidades

* Auditar la carpeta `docs/`.
* Comprobar el estado documental antes de iniciar una nueva fase de diseño.
* Detectar documentos relacionados.
* Localizar duplicidades y contradicciones.
* Mantener índices, tablas de contenido y Wiki de GitHub.
* Sincronizar referencias cruzadas.
* Aplicar cambios documentales previamente aprobados.
* Detectar contratos obsoletos y deuda documental.
* Comprobar que los nombres, estados y numeración de ADRs sean coherentes.
* Preparar cambios documentales acotados para revisión.

### Momentos de intervención

El Archivista actúa:

* antes de iniciar una Foundation o fase mayor;
* antes de crear un ADR;
* al cerrar una fase;
* cuando una decisión afecta a varios documentos;
* cuando se reorganiza `docs/`;
* cuando lo solicita el Director Técnico.

No es necesaria una auditoría documental completa antes de cada Latido menor.

### No es responsable de

* Diseñar arquitectura.
* Tomar decisiones técnicas.
* Crear nuevos modelos conceptuales.
* Modificar contratos sin aprobación.
* Convertir documentación provisional en normativa por iniciativa propia.

---

## 🔍 Auditor — Butch C. Claude

### Responsabilidades

* Contrastar hipótesis contra el código fuente existente en el `HEAD`.
* Buscar inconsistencias entre documentación y código.
* Auditar implementaciones y decisiones técnicas usando evidencia real.
* Revisar responsabilidades, acoplamiento y rutas de ejecución.
* Identificar riesgos arquitectónicos y de rendimiento.
* Revisar diffs y Pull Requests antes de su consolidación.
* Distinguir entre errores funcionales y desviaciones arquitectónicas.

### Requisito de evidencia

Toda conclusión relevante debe incluir, siempre que sea posible:

* archivo;
* clase o función;
* línea o bloque concreto;
* comportamiento observable;
* impacto sobre el plano propuesto.

Si no existe evidencia suficiente, la afirmación debe marcarse como:

```text
Hipótesis
```

y nunca como una conclusión confirmada.

### No es responsable de

* Diseñar la arquitectura desde cero.
* Mantener documentación de forma proactiva.
* Implementar correcciones sin autorización.
* Modificar el alcance de un Latido.

---

## 🔧 Implementador IA

El Implementador es un rol operativo.

Puede ser asumido por distintos agentes según la tarea.

### Responsabilidades

* Analizar el código existente antes de modificarlo.
* Comprobar hipótesis mediante evidencia.
* Implementar únicamente el plano aprobado.
* Detectar dependencias reales durante la implementación.
* Informar cuando el plano no cubra una situación encontrada.
* Mantener el cambio acotado.
* Revisar el diff antes de entregar el trabajo.

### No es responsable de

* Redefinir la arquitectura.
* Ampliar el alcance.
* Introducir mejoras no solicitadas.
* Resolver silenciosamente decisiones nuevas.
* Aprobar su propia implementación como correcta.

---

## 🚚 Explorador — Jack Burton / Gemini

### Responsabilidades

* Investigación técnica.
* Brainstorming.
* Búsqueda de alternativas.
* Recopilación de referencias externas.
* Consulta de documentación oficial.
* Comparación de enfoques existentes.
* Alimentar la base de Semillas Futuras.
* Proponer preguntas que ayuden a tensionar el diseño.

### No es responsable de

* Validar la arquitectura final.
* Consolidar documentación oficial.
* Convertir una posibilidad en una decisión.
* Introducir semillas futuras dentro del sprint actual.
* Sustituir la auditoría del código real.

---

### 🐺 El junior aplicado - Winston W.

El agente utilitario, la navaja suiza del equipo.
No tiene una responsabilidad fija, sino un conjunto de habilidades que se aplican bajo demanda.

Responsabilidades

* Traducción y localización: Adaptar textos técnicos o divulgativos entre idiomas, preservando tono, intención y contexto.
* Ordenación y estructuración: Tomar notas, borradores o ideas dispersas y convertirlas en documentos coherentes.
* Formateo y presentación: Preparar documentos en Markdown, organizar tablas, limpiar formato, etc.
* Resolución de dudas puntuales: Responder preguntas concretas sobre sintaxis, herramientas, flujos o conceptos.
* Preparación de contexto: Ayudar a Metal a preparar prompts, resúmenes o documentación para otros agentes.

* Soporte general: Cualquier tarea que no encaje claramente en Lumen, Jules o Butch, pero que deba hacerse.

### No es responsable de

* No toma decisiones arquitectónicas.
* No audita código (eso es cosa de Butch).
* No diseña sistemas (eso es cosa de Lumen).
* No consolida documentación oficial (eso es cosa de Jules).

---

# Flujo habitual de un Latido

## 1. Diseño

Metal y el Arquitecto definen:

* objetivo;
* alcance;
* responsabilidades;
* sistemas afectados;
* riesgos;
* restricciones;
* fuera de alcance;
* criterio de éxito;
* criterio de parada.

Resultado:

```text
Implementation Plan
```

Mientras el plano no esté aprobado, no comienza la implementación.

---

## 2. Auditoría previa del código existente

Antes de modificar nada, el Implementador revisa el código real.

Debe responder:

* ¿Existe ya esta responsabilidad?
* ¿Existe una implementación parcial?
* ¿Hay duplicación?
* ¿Qué sistemas dependen del código afectado?
* ¿Hay acoplamiento que complique el cambio?
* ¿Existen signals, estados o caches relacionados?
* ¿Hay efectos secundarios?
* ¿El plano cubre todas las dependencias reales?
* ¿Existe código legacy o congelado que deba ignorarse?

Las respuestas deben aportar evidencia concreta:

```text
Archivo
Función o clase
Línea o comportamiento observable
Impacto sobre el plano
```

Si el análisis revela una decisión arquitectónica no contemplada, el Latido vuelve a Diseño.

---

## 3. Preparación de la implementación

Antes de modificar:

* confirmar la rama activa;
* sincronizar con el remoto;
* verificar que los archivos corresponden al `HEAD` actual;
* comprobar el estado del working tree;
* revisar contratos y ADRs relacionados;
* evitar reemplazar archivos completos sin revisar previamente el diff;
* confirmar que el alcance sigue siendo válido.

---

## 4. Implementación

El Implementador desarrolla el cambio siguiendo el plano aprobado.

Durante esta fase:

* no amplía el alcance;
* no introduce mejoras no solicitadas;
* no cambia responsabilidades entre sistemas;
* no crea nuevas abstracciones sin necesidad demostrada;
* no modifica ADRs para justificar el código;
* no oculta decisiones nuevas dentro de la implementación.

Si aparece una decisión nueva:

```text
Detener implementación
    ↓
Registrar hallazgo
    ↓
Volver a Diseño
```

---

## 5. Auditoría arquitectónica

Antes de la validación funcional, el Auditor revisa:

* cumplimiento del plano;
* separación de responsabilidades;
* ownership;
* dependencias;
* acoplamiento;
* contracts;
* signals;
* estados compartidos;
* código muerto;
* duplicación;
* modificaciones fuera de alcance;
* coherencia con ADRs y Leyes del Chasis.

El objetivo no es comprobar si la función “parece funcionar”.

El objetivo es comprobar que el código cuenta la misma historia que el plano.

---

# Criterio de parada arquitectónica

Si la auditoría detecta un problema, se clasifica por impacto.

## Riesgo crítico

Ejemplos:

* Viola una Ley del Chasis.
* Introduce ownership duplicado.
* Rompe identidad estable.
* Contamina Editor con estructuras Runtime.
* Puede corromper datos persistidos.
* Contradice un ADR aceptado.
* Requiere rediseñar el contrato principal.

Acción:

```text
Parar
    ↓
Registrar el hallazgo
    ↓
Volver a Diseño
    ↓
Revisar el plano o ADR
    ↓
Reimplementar
```

El Latido no puede continuar.

---

## Riesgo medio

El problema no invalida el modelo general, pero debe corregirse antes del cierre.

Acción:

```text
Corrección controlada
```

La corrección debe registrar:

* problema detectado;
* impacto;
* cambio autorizado;
* motivo por el que no altera el diseño;
* evidencia de resolución.

---

## Riesgo bajo

No impide cerrar el Latido.

Se registra como deuda técnica incluyendo:

* ubicación;
* impacto;
* razón para no corregirlo ahora;
* disparador de revisión;
* fase futura probable.

Una deuda sin disparador de revisión no se considera correctamente documentada.

---

## 6. Validación funcional

Después de superar la auditoría arquitectónica, Metal verifica manualmente:

* compilación;
* ejecución;
* comportamiento esperado;
* ausencia de regresiones;
* integración con el resto del sistema;
* Undo/Redo, cuando corresponda;
* persistencia, cuando corresponda;
* experiencia de uso, cuando corresponda.

Una implementación puede ser funcional y arquitectónicamente incorrecta.

También puede ser arquitectónicamente correcta y funcionalmente defectuosa.

Ambas validaciones son obligatorias.

---

## 7. Revisión final

Después de corregir problemas funcionales, se realiza una comprobación final breve.

Su objetivo es confirmar que las correcciones no hayan introducido:

* atajos arquitectónicos;
* mutaciones directas no previstas;
* dependencias nuevas;
* cambios fuera de alcance;
* documentación incoherente.

---

## 8. Integración mediante Git

Todo cambio significativo sigue este flujo:

```text
main
    ↓
Nueva rama
    ↓
Implementación
    ↓
Commit
    ↓
Push
    ↓
Pull Request
    ↓
Review
    ↓
Squash & Merge
    ↓
Eliminar rama
```

La rama principal debe permanecer estable.

Cada commit debe representar un cambio comprensible y acotado.

El historial de Git forma parte de la documentación técnica del proyecto.

---

## 9. Auditoría documental

Una vez validado el resultado, el Archivista determina:

* qué documentos deben modificarse;
* qué documentos deben crearse;
* qué referencias han quedado obsoletas;
* qué índices deben actualizarse;
* si existe duplicidad;
* si un ADR debe mantenerse, revisarse o sustituirse;
* si el cambio debe registrarse como deuda o semilla futura.

La documentación describe el resultado final consolidado.

Nunca un estado intermedio de implementación.

---

## 10. Cierre por el Director Técnico

Metal decide uno de estos resultados:

```text
Aceptar
Revisar
Aplazar
Rechazar
```

Solo un resultado aceptado puede considerarse integrado y cerrado.

---

# Puertas de control del Latido

Todo Latido debe atravesar estas puertas:

```text
1. Plano aprobado
2. Auditoría previa del código
3. Implementación acotada
4. Auditoría arquitectónica
5. Correcciones controladas
6. Validación funcional
7. Revisión final
8. Auditoría documental
9. Integración
10. Cierre por el Director Técnico
```

---

# Principios

## El plano manda

La implementación ejecuta y valida el diseño.

Nunca ocurre al revés.

---

## El código es evidencia

Las decisiones se apoyan en el comportamiento observable del proyecto.

No en recuerdos.

No en intuiciones.

No en documentación desactualizada.

---

## Una hipótesis no es una conclusión

Cuando no existe evidencia suficiente, debe indicarse explícitamente.

La incertidumbre visible es preferible a una certeza inventada.

---

## Cada herramienta aporta donde más valor tiene

No todas las IA hacen el mismo trabajo.

El objetivo no es que una herramienta haga todo.

El objetivo es que cada una se encargue de la responsabilidad donde aporta mayor calidad.

---

## Separación entre creación y certificación

El agente que implementa puede revisar su trabajo.

Pero la certificación arquitectónica debe proceder de una revisión independiente siempre que el alcance lo justifique.

---

## Las responsabilidades son explícitas

Las decisiones arquitectónicas pertenecen al Director Técnico.

Las implementaciones pertenecen al código.

Las auditorías pertenecen al proceso.

La documentación pertenece al proyecto.

---

## Git es parte del diseño

El historial de commits forma parte de la historia técnica de Lands of Folklore.

Cada commit debe describir claramente el cambio realizado.

---

## La documentación no sigue al código a ciegas

Si una implementación contradice la documentación vigente, primero debe determinarse cuál de las dos está equivocada.

El código existente no convierte automáticamente una decisión en correcta.

---

# Criterios para cerrar un Latido

Un Latido solo puede darse por terminado cuando:

* cumple el objetivo definido;
* respeta el alcance aprobado;
* se ha contrastado contra el código real;
* supera la auditoría arquitectónica;
* supera la validación funcional;
* no contiene riesgos críticos abiertos;
* las correcciones medias han sido resueltas;
* las deudas bajas están documentadas con disparador;
* se integra correctamente mediante Git;
* la documentación queda sincronizada;
* Metal acepta expresamente el resultado.

---

# Adaptabilidad

Este workflow no depende de ninguna IA concreta.

Si una herramienta deja de utilizarse, únicamente cambia el agente asignado a una responsabilidad.

El proceso permanece inalterado.

Los nombres de los compañeros forman parte del taller actual.

Los roles forman parte del método.

---

# Principio de soberanía

> **Los agentes no sustituyen el criterio del desarrollador. Cada uno aporta una perspectiva distinta al taller. Las decisiones arquitectónicas pertenecen a Lands of Folklore, no al agente que las propuso.**

---

# Objetivo final

Construir un proyecto mantenible.

No desarrollar más rápido.

No escribir menos código.

No delegar decisiones importantes.

La prioridad es conservar:

* una arquitectura comprensible;
* una historia técnica clara;
* documentación coherente;
* decisiones trazables;
* un proceso reproducible;
* control humano sobre el diseño.

El workflow habrá cumplido su función mientras permita que Lands of Folklore continúe evolucionando durante años sin perder el control del chasis.

Principio de Autoridad

Los agentes trabajan siempre bajo uno de estos estados:

1. Investigación

El agente:

observa;
analiza;
recopila evidencias;
no modifica nada.

Resultado:

Informe
2. Propuesta

El agente:

propone una solución;
identifica documentos afectados;
estima riesgos;
espera aprobación.

Resultado:

Plan de actuación
3. Aprobación

El Director Técnico decide.

Puede:

✔ Aprobar

✖ Rechazar

↺ Solicitar cambios

Solo aquí cambia el estado.

4. Ejecución

El agente implementa únicamente aquello que ha sido aprobado.

No amplía el alcance.

No añade mejoras.

No interpreta.

5. Revisión

El trabajo vuelve al Director Técnico.

Solo entonces puede integrarse.

## Lecciones aprendidas (Editor Foundations III)

Las siguientes reglas no nacen de teoría, sino de la experiencia obtenida durante el desarrollo de Editor Foundations III.

Se incorporan al workflow porque demostraron reducir errores, limitar el alcance y mejorar la trazabilidad del proyecto.

## Git pertenece al Director Técnico

Los agentes nunca modifican la historia del repositorio.

Por norma general:

no crean commits;
no realizan push;
no crean ni eliminan ramas;
no ejecutan merge, rebase o cherry-pick.

Los agentes trabajan únicamente sobre el working tree.

La integración mediante Git pertenece exclusivamente al Director Técnico.

## El alcance siempre es explícito

Antes de comenzar cualquier tarea debe quedar definido:

qué archivos pueden modificarse;
qué archivos están fuera del alcance;
qué decisiones pueden tomarse;
qué decisiones requieren volver a Diseño.

Una tarea sin límites claros tiende a expandirse innecesariamente.

Primero auditar, después escribir

Cuando una modificación afecta a arquitectura, documentación o varios sistemas relacionados, el flujo recomendado es:

Auditoría
    ↓
Informe
    ↓
Aprobación
    ↓
Implementación

No al revés.

La documentación se sincroniza

Los documentos describen el estado consolidado del proyecto.

No deben:

anticipar funcionalidades futuras;
describir implementaciones descartadas como vigentes;
utilizar nombres distintos a los existentes en el código.

El objetivo es que código, arquitectura y documentación describan exactamente la misma realidad.

## Cada agente trabaja donde aporta más valor

Las tareas deben asignarse según responsabilidad, no según disponibilidad.

Como referencia actual:

Rol	Agente recomendado
Arquitectura	Lumen
Auditoría	Butch
Documentación sincronizada	Jules (con alcance acotado)
Implementación	Agente de implementación
Investigación	Jack

Esta asignación podrá modificarse cuando aparezcan herramientas mejores.

## La historia Git también es documentación

Cada commit debe representar una unidad lógica de trabajo.

El historial forma parte del conocimiento del proyecto.

Por ello:

cambios de documentación y código deben separarse cuando tenga sentido;
los commits deben permanecer pequeños y comprensibles;
las etiquetas (tags) representan hitos de ingeniería, no únicamente versiones públicas.

## Los documentos también pasan QA

Antes de cerrar una Foundation o una fase importante, la documentación debe auditarse contra HEAD.

El objetivo no es mejorar la redacción.

Es comprobar que describe exactamente el comportamiento implementado.

"La implementación no marca el final de un trabajo. El trabajo termina cuando código, arquitectura, documentación y repositorio cuentan exactamente la misma historia."