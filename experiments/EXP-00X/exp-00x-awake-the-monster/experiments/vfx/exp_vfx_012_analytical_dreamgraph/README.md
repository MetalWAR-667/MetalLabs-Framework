# EXP-VFX-012 — Analytical DreamGraph (la canica cósmica)

**Status: In progress / Isolated experiment.**

## Pregunta

¿Puede una red matemática de luz comportarse como una estructura mental viva
sin depender de texturas, partículas, geometría rasterizada ni bloom?

## Hipótesis

Un grafo data-driven dibujado mediante distancias analíticas, acumulación
luminosa y respiración desincronizada puede conservar la claridad estructural de
EXP-VFX-011 y adquirir una presencia orgánica propia. Una lente esférica
opcional permitirá comprobar si contener el grafo refuerza su lectura o se
convierte en el efecto dominante.

## Procedencia

Continúa directamente la línea EXP-VFX-009 → EXP-VFX-010 → EXP-VFX-011: mismo
principio de "un nodo por carta jugada, glow analítico per-píxel", sin código
compartido con ninguno de los tres. La lente esférica ("canica cósmica") es
una idea nueva de este experimento, no una adaptación de un shader anterior.

## Implementación

- Un único shader `canvas_item` fullscreen (`analytical_dreamgraph.gdshader`),
  sin `SubViewport` ni pasada de bloom — igual que EXP-VFX-011.
- Nodos como distancias radiales (`smoothstep` + `1/(epsilon+d²)`) y conexiones
  mediante `sd_segment()` (distancia punto-a-segmento), en vez de los círculos
  CPU de EXP-VFX-010.
- Glow estabilizado con caída inversa al cuadrado y compresión exponencial
  final (`1 - exp(-light)`) en vez del tonemap Reinhard de EXP-VFX-011 — evita
  tanto el blanqueo por canales saturados como los infinitos en el centro del
  nodo.
- Respiración independiente por elemento: cada nodo/conexión deriva una fase
  estable pseudo-aleatoria (`fposmod(sin(index*91.345)*47453.5453, 1.0)`), no
  sincronizada globalmente — busca que el "latido" del grafo no se vea
  mecánico.
- Arrays runtime de hasta 32 nodos y 64 conexiones (`experiment.gd`), mismo
  patrón de `Array[Vector4]` empujado como uniform que EXP-VFX-011.
- Crecimiento manual vía `Add Node` (conecta cada nodo nuevo al más cercano
  existente, más una conexión secundaria a `index-3` para dar redundancia
  estructural), con revelado coordinado de nodo y conexiones durante
  0.8 segundos. `Reset Graph` restaura 18 nodos en espiral áurea.
- Lente esférica aplicada a las coordenadas *antes* de evaluar cualquier
  distancia (deforma el espacio de muestreo, no la imagen ya renderizada).

## Cinco palancas de la canica cósmica

- `Enable Cosmic Lens` — interruptor A/B, mismos datos/color/animación con y
  sin lente.
- `Lens Radius` — tamaño de la esfera de contención.
- `Lens Strength` — cuánto se nota la curvatura/máscara.
- `Lens Edge` — brillo del borde/rim de la esfera.
- `Lens Refraction` — cuánta distorsión aplica la curvatura al espacio interior.

## Parámetros expuestos

Nodo (`node_size`, `node_glow`), línea (`line_width`, `line_glow`),
respiración (`breath_amount`, `breath_speed`), `exposure`, y las cinco
palancas de la lente. Todo cableado por `PARAMETER_CONTROLS` en
`experiment.gd`, mismo patrón que EXP-VFX-009/010/011.

## Restricciones

No existe integración narrativa, editor, serialización, generación infinita,
texturas, partículas ni postprocesado. El experimento no modifica EXP-VFX-010,
EXP-VFX-011 ni el `BackgroundFX` de producción — sigue siendo una isla
aislada.

## Riesgos técnicos

- Mismo límite que EXP-VFX-011: el costo por píxel escala con
  `node_count + connection_count` reales (sin partición espacial). Con el
  tope de 32/64 es más barato aún que el -011, pero el techo es más bajo si
  algún día se necesitaran más nodos simultáneos que cartas jugables en una
  partida real.
- La lente deforma el espacio de muestreo con una división (`p /= warp`);
  `warp` está protegido con `max(warp, 0.15)` para evitar división por cero
  o valores degenerados en `lens_refraction` extremo.
- Cargó y corrió sin errores en las pruebas headless de este proyecto, pero
  falta validación visual real (ver "Evaluación pendiente").

| Aspecto | Primera lectura | Coste | Integración | Observaciones |
|---|---|---|---|---|
| Glow por caída inversa al cuadrado | Pendiente | Bajo (32/64 elementos) | No conectado | Comparar contra el sparkle `1/dist^1.5` de EXP-VFX-011 |
| Respiración desincronizada por fase | Pendiente | Nulo | No conectado | Validar si de verdad lee "orgánico" vs. EXP-VFX-011 |
| Lente esférica ("canica cósmica") | Pendiente | Bajo | No conectado | Comparación A/B disponible en vivo con `Enable Cosmic Lens` |

## Evaluación pendiente

1. ¿El grafo parece una estructura mental viva o un diagrama luminoso?
2. ¿Las intersecciones acumulan luz sin perder legibilidad?
3. ¿La respiración es orgánica o demasiado coordinada?
4. ¿La canica cósmica aporta contención y profundidad?
5. ¿La lente mejora el DreamGraph o roba todo el espectáculo?
