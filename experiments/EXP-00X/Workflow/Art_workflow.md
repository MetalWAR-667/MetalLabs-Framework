09 Art Direction
        ↓
Moodboard
        ↓
Prompt Maestro
        ↓
5 imágenes piloto
        ↓
Elegir estilo definitivo
        ↓
Template de carta
        ↓
Implementar CardView en Godot
        ↓
Generar ilustraciones
        ↓
Montarlas dentro del juego


8. Orden práctico
Diseñar una carta vacía completa como referencia visual.
Aprobar proporciones, materialidad y jerarquía.
Descomponerla en elementos reutilizables.
Importar esos elementos en Godot.
Construir CardView.tscn.
Rellenarlo con contenido provisional.
Probar texto corto, largo, una opción y varias.
Solo entonces fijar la proporción de las ilustraciones.
Generar las cinco imágenes piloto en esa proporción.

Esta última parte es importante: no fijaría todavía el formato de las ilustraciones hasta saber cuánto espacio real ocuparán dentro de la carta en 1920 × 1080.

La plantilla vacía será la referencia artística. CardView será la carta real. La primera nos permite definir el aspecto; la segunda conserva flexibilidad y contiene toda la interacción. Así tendremos algo bonito sin convertir cada carta en una imagen rígida imposible de corregir.