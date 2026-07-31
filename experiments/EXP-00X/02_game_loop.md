# Game Loop

**Estado: Canónico para el vertical slice**

## Entrada

```text
SplashScreen
→ MainMenu
  → Nueva partida → ItemSelectionMenu → HUD / Carta 01
  → Continuar → HUD restaurado
```

Nueva partida elimina el guardado anterior. Continuar solo está disponible si
`SaveManager` valida el archivo local.

## Flujo de una carta

```text
Presentar ilustración y Amenaza contextual
→ revelar texto progresivamente
→ completar por tiempo, tecla o click
→ habilitar opciones
→ elegir una opción
→ comprobar condición editorial
→ resolver Amenaza, si existe
→ aplicar éxito automático y tiradas
→ reducir Amenaza o aplicar daño
→ actualizar estado runtime
→ autoguardar en un punto coherente
→ cargar la siguiente carta o repetir ronda
```

Las opciones se deshabilitan mientras se resuelve una tirada. Una opción que
inicia una Amenaza queda comprometida; no puede cambiarse entre reintentos.

## Resolución de Amenaza

1. La opción fija símbolo requerido, cantidad y daño.
2. El objeto equipado puede aportar éxitos automáticos compatibles una sola vez
   durante esa Amenaza.
3. Cada participante lanza su dado personalizado.
4. Cada cara que coincide aporta un éxito.
5. Los éxitos reducen `remaining_threat`.
6. Si llega a cero, avanza la historia.
7. Si queda Amenaza, se aplica daño y se habilita otro intento.

En Carta 06 Jack participa siempre. Si el Fugitivo fue incorporado, el jugador
elige continuar solo o pedir su ayuda. Si no participa y sobrevive el encuentro,
recupera un punto de Salud hasta su máximo.

## Objetos

La partida comienza eligiendo Comida, Escopeta o Escudo. El HUD muestra un solo
slot. Los usos restantes viven en runtime y en el guardado, nunca en el `.tres`.

En el slice actual solo la Escopeta resuelve efecto: garantiza un éxito de
Fuerza, consume su único uso y desaparece. Comida y Escudo todavía no ejecutan
las consecuencias descritas en sus recursos.

## Persistencia

El HUD autoguarda al cargar cartas y después de cambios coherentes relevantes,
incluidos reintentos fallidos. También conserva una Amenaza activa completa
cuando es seguro reanudarla.

## Derrota y cierre

```text
Salud de Jack ≤ 0
→ bloquear interacción
→ eliminar guardado
→ fundido a negro
→ Game Over
→ Main Menu
```

```text
Carta 06 superada
→ descanso del aliado, si procede
→ eliminar guardado
→ epílogo audiovisual
→ Final Vertical Slice
→ Main Menu
```

Completar o perder la partida deshabilita Continuar porque el archivo deja de
existir.

