# Postmortem

## 1. Objetivo inicial

EXP-00X nació para demostrar que un proyecto pequeño podía recorrer todas las
fases de producción y validar un núcleo narrativo útil para MetalLab y, como
aprendizaje, para Lands of Folklore. El reto era cerrar el bucle, no construir
un motor narrativo universal.

## 2. Resultado

El vertical slice funcional se alcanzó. Contiene seis cartas, selección de
objeto, pruebas simbólicas, un aliado opcional, persistencia, derrota, epílogo,
presentación audiovisual y retorno al menú. El alcance real creció en pulido y
dirección visual, pero el contenido permaneció contenido.

## 3. Qué funcionó

- Congelar el contenido en seis cartas permitió terminar.
- Sprints pequeños hicieron visibles dependencias antes de generalizarlas.
- La revisión humana corrigió lectura, composición y decisiones mecánicas.
- Los Resources separaron contenido editorial y estado runtime.
- UI, dados, slot y fondo representan decisiones sin asumir todos sus cálculos.
- Visual Lab permitió aceptar resultados negativos sin contaminar producción.
- La IA funcionó mejor como equipo de taller con auditoría y criterios de cierre
  que como generador autónomo de sistemas.

## 4. Qué no funcionó

- Ink Exploration nunca dejó de parecer humo, incluso con estructura y torsión.
- Atmospheric Profiles produjo intensidades, no atmósferas diferenciadas.
- Fog, Ink y partículas juntos compitieron por atención.
- La primera integración de vídeo expuso el pobre compromiso de OGV; WebM y MP4
  mediante plugins añadieron incompatibilidades. Finalmente se aceptó Theora
  nativo con una compresión corregida.
- La arquitectura conceptual de `06` y `07` resultó mayor que el problema real.
- Comida y Escudo quedaron representados pero no ejecutados: la descripción
  editorial se adelantó a la mecánica.

## 5. Decisiones importantes

- Un slot y un objeto, no inventario.
- Usos en runtime, nunca modificando `.tres`.
- Éxito automático ligado a símbolo, no suma de estadística.
- Un aliado opcional y una sola carta con selección de participantes.
- No construir editor, router, GameState general ni framework de consecuencias.
- Aceptar límites técnicos del vídeo y cerrar con una solución nativa.
- Preservar experimentos negativos como evidencia, no intentar salvarlos con
  más capas.

## 6. Reutilización

Pueden inspirar LoF la separación entre definiciones y runtime, las opciones
editoriales por Resource, la disciplina de sprints y el laboratorio aislado.
CardView, dados y BackgroundFX son prototipos útiles, pero deben migrarse solo
si el problema de LoF coincide. Ink y perfiles atmosféricos quedan como
aprendizaje perceptivo, no como código candidato.

## 7. Estimación

El vertical slice funcional se alcanzó en aproximadamente 6–7 días de trabajo
concentrado. El rango inicial de 30–45 días seguía siendo razonable para añadir
contenido, pulir, auditar, ejecutar QA y publicar. La estimación estructural no
falló; el slice se detuvo antes de convertir esas fases en alcance implícito.

## 8. Conclusión

Sí, el proceso quedó validado: una especificación pequeña, propagación de
decisiones, implementación incremental y juicio humano produjeron un recorrido
cerrado. Sí, el bucle se cerró: se puede entrar, jugar, perder, completar y
volver al menú. Merece ampliarse únicamente si el nuevo contenido confirma que
la estructura actual empieza a quedarse corta; no antes.

