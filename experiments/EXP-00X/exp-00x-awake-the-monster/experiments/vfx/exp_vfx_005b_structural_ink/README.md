# EXP-VFX-005B — Structural Ink

**Status: Closed / Negative result.** La estructura celular mejoró la materia,
pero no cambió de forma convincente su identidad de humo.

## Hipótesis

La identidad de la tinta depende principalmente de la estructura espacial de la
materia. Un pipeline sencillo puede resultar convincente si recibe masas
celulares compactas en vez de una fuente formada como niebla.

## ¿Por qué puede importar más la estructura?

`smoothstep`, núcleo y halo solo clasifican y componen la información disponible.
No pueden crear frentes tensos o regiones compactas cuando la fuente contiene
gradientes nubosos continuos.

## Cambios respecto a 005A

- `Noise 1.png` se sustituye por una única `NoiseTexture2D` celular.
- La expansión global se sustituye por fases espaciales diferentes por región.
- Una perturbación pequeña del umbral rompe la uniformidad del borde.
- Controles, composición y número de lecturas permanecen equivalentes.

## Observaciones

Las masas celulares aportan regiones más compactas e invasión desigual, pero la
lectura dominante continúa siendo humo endurecido. La estructura mejora; la
categoría perceptiva no cambia.
