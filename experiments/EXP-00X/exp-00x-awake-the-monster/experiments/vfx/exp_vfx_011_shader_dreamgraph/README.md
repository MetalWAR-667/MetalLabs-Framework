# EXP-VFX-011 — Shader DreamGraph

**Status: In progress / Isolated experiment.** Evolución directa de
EXP-VFX-010: mismo modelo de datos dinámico (un nodo por carta jugada,
conexiones explícitas a vecinos), pero el dibujo deja de ser geometría
CPU (`draw_circle`/`draw_polyline` + bloom de post-proceso) y pasa a ser
matemática analítica per-píxel en un único `canvas_item` shader — la misma
técnica de "sparkle" (`1/dist^1.5`) y líneas SDF de EXP-VFX-009, pero
alimentada por el array de GDScript en vez de una grilla procedural
infinita.

## Pregunta

¿Se puede lograr la finura y la intensidad de glow de EXP-VFX-009 (todo
calculado por píxel, sin geometría discreta) manteniendo el grafo
*data-driven* de EXP-VFX-010 (nodos reales, no ruido), sin pagar el costo
de un `SubViewport` + pasada de bloom aparte?

## Enfoque

- **Sin `SubViewport`, sin bloom de post-proceso.** Un solo `ColorRect` a
  pantalla completa con `dream_graph_glow.gdshader`. El brillo nace directo
  de la función `sparkle_radius / pow(dist, 1.5) * sparkle_intensity`
  evaluada en cada píxel — no hay geometría que rasterizar ni anillo de
  muestreo que aproxime un blur.
- **Datos empujados como arrays de uniform.** `experiment.gd` mantiene el
  mismo modelo que `dynamic_graph_view.gd` de EXP-VFX-010 (nodos con
  posición/intensidad/reveal/fase de color, conexiones a los `k` vecinos
  más cercanos), pero en vez de `_draw()` empaqueta todo en
  `uniform vec4 node_data[64]` / `uniform vec4 connection_data[128]` cada
  frame (`Array` de `Vector4`, tope 64 nodos / 128 conexiones — de sobra
  para el uso real de "un nodo por carta").
- **Drift y zoom calculados en el shader**, no en GDScript: cada nodo
  deriva su posición con `sin(time*drift_speed+fase)` per-píxel (misma
  fórmula que la versión CPU), y hay un zoom global que respira sobre todo
  el campo (`p /= zoom`), igual intención que el ciclo de profundidad de
  EXP-VFX-009 pero con una sola capa en vez de cinco.
- **Color por HSV** (`hue_to_rgb`) con fase propia por nodo + ciclo por
  tiempo, igual que EXP-VFX-010, pero mezclado de forma continua (aditivo
  por píxel) en vez de un color plano por círculo.
- **Tonemap Reinhard** (`color/(color+1)`) al final, para evitar el
  problema de líneas grises/blancas que apareció en EXP-VFX-010 cuando
  varios canales superaban 1.0 a la vez.

## Procedencia

Arquitectura de datos heredada de EXP-VFX-010 (a su vez inspirada en la
propuesta de grafo dinámico compartida por el usuario). Las fórmulas de
sparkle y línea SDF están adaptadas de `procedural_network.gdshader`
(EXP-VFX-009), reescritas para leer de un array dinámico de nodos en vez
de una grilla procedural con ruido.

## Parámetros expuestos

`sparkle_radius`/`sparkle_intensity`, `line_width`/`line_intensity`,
`saturation`, `color_cycle_speed`, `drift_amount`/`drift_speed`,
`zoom_amount`/`zoom_speed`, `exposure`. Panel con "Add Node" y "Auto Play"
para simular cartas jugándose.

## Riesgos técnicos

- El costo por píxel ahora escala con `node_count + connection_count`
  reales (sin partición espacial, a diferencia de la grilla de
  EXP-VFX-009 que solo mira 9 celdas vecinas). Con el tope de 64/128 es
  barato (~400M ALU ops/frame en 1080p), pero si el grafo real necesitara
  cientos de nodos habría que sumar partición espacial (grilla de celdas)
  para no pagar O(n) por píxel.
- La indexación dinámica de `node_data[index_a]` dentro del bucle de
  conexiones depende de soporte de indexado dinámico de arrays en el
  backend (Forward+/D3D12 en este proyecto) — cargó y corrió sin errores
  en las pruebas headless, pero falta validación visual real.
- No está conectado a `background_fx.gd`/`hud.gd` — sigue siendo una isla.

| Aspecto | Primera lectura | Coste | Integración | Observaciones |
|---|---|---|---|---|
| Sparkle analítico per-píxel | Pendiente | Medio (sin partición espacial) | No conectado | Comparar finura contra el halo de EXP-VFX-010 |
| Líneas SDF | Pendiente | Bajo | No conectado | Antialiasing per-píxel real |
| Drift/zoom en shader | Pendiente | Bajo | No conectado | Mismo lenguaje que EXP-VFX-010, sin coste extra en CPU |
