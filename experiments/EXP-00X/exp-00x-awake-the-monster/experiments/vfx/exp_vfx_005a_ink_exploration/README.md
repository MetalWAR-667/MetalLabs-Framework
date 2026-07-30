# EXP-VFX-005A — Ink Exploration

## Hypothesis

Una única fuente orgánica puede producir identidad de tinta si se transforma en
masas compactas con núcleo, borde y halo, y si su evolución modifica la ocupación
en lugar de limitarse a desplazar la textura.

## Implementation

Prototipo mínimo con una textura, tres lecturas, deformación UV lenta y máscara
con `smoothstep()`. Incluye cuerpo, núcleo oscuro y halo de difusión.

## Observations

Pendientes de validación visual. La pregunta activa es si la materia parece tinta
o todavía se interpreta como humo negro.

## Performance

Una pasada fullscreen y tres lecturas de la misma textura.

## Open Questions

- ¿El umbral produce invasión o una pulsación demasiado evidente?
- ¿El borde conserva suficiente estabilidad?
- ¿La separación entre núcleo y halo resulta legible?
