

## 1. SOBRE LA UI DE GODOT

Primer diagnóstico (en caliente):

> "La UI de Godot está diseñada por un masoquista."

Diagnóstico tras comprender su filosofía:

> "La UI de Godot está explicada por psicópatas."

😂

### Lección aprendida

Las escenas de Godot **no representan pantallas**.

Representan **componentes con una única responsabilidad**.

Cuando una interfaz comienza a crecer, deja de pensar en una gran escena llena de controles.

Empieza a pensar en un conjunto de pequeñas escenas reutilizables que posteriormente se ensamblan en una escena principal.

La composición deja de ser un problema de coordenadas y pasa a ser un problema de arquitectura.

### Regla práctica

Cuando necesites una UI compleja o responsive:

- Agrupa los elementos por responsabilidad y comportamiento.
- Convierte cada bloque funcional en una escena independiente (`CardThreatBar`, `CardIllustration`, `CardDescription`, etc.).
- Instancia esas escenas desde una escena principal (`CardView`, `HUD`, etc.).
- Posiciona cada componente desde la escena raíz.
- Deja que cada componente gestione internamente su propio layout mediante `HBoxContainer`, `VBoxContainer`, `MarginContainer`, etc.

De esta forma los `Container` organizan únicamente el contenido de cada componente, mientras que la escena principal conserva libertad total para componer la interfaz.

### Descubrimiento clave

El momento en que comprendí esta filosofía fue al utilizar **Editable Children** sobre escenas instanciadas.

Fue entonces cuando la UI dejó de sentirse como una limitación y empezó a parecer un sistema de composición de componentes.