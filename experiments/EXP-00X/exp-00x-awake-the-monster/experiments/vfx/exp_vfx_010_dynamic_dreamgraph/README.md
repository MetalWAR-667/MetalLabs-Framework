# EXP-VFX-010 — Dynamic DreamGraph

**Status: In progress / Isolated experiment.** Explora una evolución del
DreamGraph de producción (`scripts/ui/dream_graph.gd`, 18 nodos fijos con
revelado por `progress`) hacia un grafo que crece nodo a nodo en tiempo real,
con glow real en vez del halo dibujado a mano.

## Pregunta

¿Se puede lograr el lenguaje visual sugerido por EXP-VFX-009 (nodos, líneas,
brillo, parpadeo) con un grafo *data-driven* (un nodo por carta jugada) en vez
del grid procedural infinito de aquel experimento, y sin pagar su coste por
píxel?

## Enfoque

- `dynamic_graph_view.gd`: `Control` con `_draw()` puro (sin shader), igual de
  barato que la versión de producción. Mantiene un array dinámico de nodos
  (`add_node()`), cada uno con posición, intensidad, momento de nacimiento y
  revelado propio (fade-in individual, no global). Las conexiones son curvas
  bezier cuadráticas, igual que en producción.
- `bloom_composite.gdshader`: a diferencia del halo-círculo de producción,
  este experimento renderiza el grafo en un `SubViewport` aparte y compone el
  resultado con un shader de **bloom de una sola pasada** (muestreo en anillo
  con umbral de brillo) sobre un `TextureRect`. No es un bloom multi-pasada
  real, pero da glow verdadero (ilumina alrededor del punto) en vez de un
  círculo semitransparente fijo.
- `experiment.gd`: panel de control. Botón "Add Node" simula que se jugó una
  carta (posición en espiral áurea, `GOLDEN_ANGLE`); "Auto Play" añade nodos
  solo para poder observar el crecimiento sin clickear cada vez; modo de
  conexión Chain (cadena narrativa lineal) vs Hub (todo conecta al nodo 0,
  para probar la idea original de "X"/constelación con centro).

## Procedencia

Arquitectura de nodos inspirada en la propuesta de grafo dinámico compartida
por el usuario (script de referencia con `NodeData`/`connections` y sugerencia
de `SubViewport` + shader de bloom). El bloom de una sola pasada reutiliza la
misma técnica de muestreo en anillo que ya usan `logo_main_menu.gdshader` y
`vortex_umbral.gdshader` del menú principal, no código de EXP-VFX-009.

## Parámetros expuestos

Bloom en doble anillo (`bloom_threshold`, `bloom_intensity`/`bloom_radius`
"caliente" y `bloom_intensity_wide`/`bloom_radius_wide` "amplio",
`bloom_falloff` para la caída), parpadeo de nodo (`flicker_speed`,
`flicker_amount`), `sparkle_intensity` (núcleo sobre-brillante RGB > 1 que
alimenta al bloom, requiere `use_hdr_2d` en el SubViewport), `line_glow`,
color por nodo (`color_variation`, `color_cycle_speed` vía `Color.from_hsv`),
movimiento (`drift_amount`/`drift_speed` por nodo, `zoom_amount`/`zoom_speed`
global), grosor de línea, tamaño de nodo, modo de conexión (Chain / Hub /
Nearest-web con k=3 vecinos).

## Riesgos técnicos

- El `SubViewport` añade un render pass extra por frame (coste no medido aún
  en el driver D3D12 experimental que usa el proyecto).
- El bloom de una sola pasada es una aproximación (muestreo en anillo, no
  blur gaussiano real); con pocos nodos brillantes funciona bien, podría
  degradarse con muchos nodos muy juntos.
- No está conectado a `background_fx.gd`/`hud.gd` — es una isla deliberada
  para validar el look antes de integrar.

| Aspecto | Primera lectura | Coste | Integración | Observaciones |
|---|---|---|---|---|
| Bloom 1-pasada | Pendiente | Pendiente | No conectado | Comparar contra halo actual de producción |
| Crecimiento por nodo | Pendiente | Bajo (`_draw()`) | No conectado | Layout en espiral áurea, no la "X" original |
| Modo Hub vs Chain | Pendiente | — | No conectado | Probar cuál lee mejor como "mapa del sueño" |
