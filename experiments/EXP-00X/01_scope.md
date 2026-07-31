# Scope

**Estado: Vertical Slice Complete**

## Objetivo

Validar en un proyecto pequeño el ciclo completo de una experiencia narrativa:
preproducción, implementación, arte, audio, persistencia, cierre, prueba humana
y documentación. EXP-00X sirve como banco de aprendizaje para MetalLab y LoF;
no como base obligatoria de su arquitectura futura.

## Vertical Slice Scope

Entró en el corte:

- una experiencia 2D de escritorio a 1920×1080;
- seis cartas y un epílogo audiovisual;
- Jack y un único aliado opcional, el Fugitivo Pálido;
- tres objetos iniciales y exactamente un slot equipado;
- tres símbolos: Atención, Cordura y Fuerza;
- Amenazas, daño, reintentos y selección de participantes en Carta 06;
- descanso del aliado cuando no participa;
- persistencia mínima de un slot;
- pausa, Game Over, final provisional y retorno al menú;
- presentación completa de carta, dados, audio y BackgroundFX.

El límite de un objeto fue deliberado: el problema real era conservar y
consultar una referencia con usos runtime, no construir un inventario.

## Contenido efectivo

- 6 cartas.
- 2 actores.
- 3 objetos seleccionables.
- 1 efecto de objeto operativo: Escopeta, +1 éxito automático de Fuerza, un uso.
- 1 epílogo Ogg Theora con música externa.
- Duración variable según lectura y reintentos; el capítulo es deliberadamente
  breve y no pretende alcanzar una duración comercial.

## Future Expansion

- nuevas cartas y eventos;
- efectos funcionales de Comida y Escudo;
- registro automático de contenido;
- créditos definitivos;
- DreamGraph reactivo si supera evaluación visual;
- soporte web tras una investigación específica.

El detalle está acotado en `FUTURE_EXPANSION.md`.

## Explicitly Out of Scope

- inventario múltiple, economía, equipo complejo o loot;
- combate táctico separado;
- varios aliados simultáneos;
- editor narrativo y framework genérico;
- múltiples slots de guardado, migraciones o nube;
- soporte web declarado sin validación;
- publicación, auditoría completa de assets y QA final.

## Tiempo

El vertical slice funcional se alcanzó en aproximadamente 6–7 días de trabajo
concentrado. La estimación inicial de 30–45 días sigue siendo razonable para
contenido adicional, pulido, QA, licencias y publicación.

## Regla de cierre

El slice demuestra el bucle. La ampliación debe añadir contenido antes que
infraestructura hipotética.

