# EXP-VFX-005C — Flow Deformation

## Hypothesis

Una torsión local coherente puede transformar masas celulares en pliegues y
lenguas continuas, aportando un lenguaje cinemático más próximo a la tinta.

## Baseline

Fuente celular, composición, umbral, contraste, borde, núcleo, halo, expansión
regional y color permanecen idénticos a EXP-VFX-005B.

## Deformation Model

Una rotación local alrededor de un centro desviado disminuye suavemente hasta
desaparecer fuera del radio. Su intensidad cambia muy lentamente para plegar la
estructura sin hacer girar toda la pantalla.

## Observations

Técnicamente debe comprobarse continuidad, estabilidad y ausencia de parpadeo.
La conclusión perceptiva queda pendiente de validación visual.

## Performance

El compuesto conserva tres lecturas de textura. La deformación añade distancia,
`smoothstep()` y una rotación trigonométrica por fragmento. `Base Source` realiza
una lectura adicional únicamente durante ese modo de depuración.

## Open Questions

- ¿Aparecen lenguas y pliegues o solamente un vórtice?
- ¿Las células dejan de dominar la lectura?
- ¿La torsión cambia la categoría perceptiva del material?
