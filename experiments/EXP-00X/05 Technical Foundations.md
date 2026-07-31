# Technical Foundations

**Estado: Arquitectura integrada del vertical slice**

## Tecnología

- Godot 4.7.1.
- GDScript.
- Presentación 2D.
- Viewport de referencia 1920×1080 con `canvas_items` y aspecto expandible.
- Forward+; D3D12 en Windows.
- Escena inicial: `scenes/ui/menu/splash_screen.tscn`.

No se declara soporte web completado.

## Arquitectura real

```text
SplashScreen → MainMenu → ItemSelectionMenu → HUD
                                  ↓
                          CardView + actores + dados
                                  ↓
                        Game Over o Act1Epilogue
                                  ↓
                              MainMenu

Autoloads: MusicPlayer, SaveManager
Datos: ActorData, CardData, CardOptionData, ItemData
Fondo: BackgroundFX → AtmosphericLayer + MemoryLayer/DreamGraph
```

El slice no implementa los servicios generales propuestos durante
preproducción. No existen `GameController`, `GameState`, `CardRepository`,
`ThreatResolver`, `ConsequenceExecutor` ni `SaveService`.

## Responsabilidades

### `GameHUD`

Coordina las seis cartas, estado runtime, resolución, participantes, objetos,
autosave, derrota y salida al epílogo. Es código específico del slice. Esta
concentración fue aceptada para seis cartas; no debe extrapolarse sin revisar.

### Datos editoriales

- `ActorData`: presentación, caras y valores base.
- `CardData`: ilustración, texto y opciones.
- `CardOptionData`: prueba, daño y condición mínima.
- `ItemData`: presentación, símbolo, éxitos automáticos y usos iniciales.

Los `.tres` son inmutables en runtime. Salud, usos, flags y Amenaza viven en el
HUD y en el JSON de guardado.

### Presentación

- `CardView`: narrativa, skip, scroll, opciones, Amenaza y slow zoom out.
- `ActorPanel`: retrato, valores, Salud y shader de marco.
- `ActorDice`: presentación, resultado, audio, indicador y feedback.
- `EquipmentSlot`: icono y tooltip; no calcula efectos.
- `BackgroundFX`: composición atmosférica y transición visual por carta.
- `DreamGraph`: dibujo visual determinista, sin lógica narrativa.

La UI representa decisiones calculadas por `GameHUD`; el dado no decide
bonificaciones y el slot no ejecuta objetos.

## Persistencia

`SaveManager` escribe un único JSON en `user://exp_00x_save.json`. Valida tipos,
rutas y coherencia mínima. No hay Resources de guardado, slots, migraciones ni
versionado. `MainMenu` habilita Continuar solo con un archivo válido.

El HUD recibe un diccionario pendiente al continuar y restaura carta, actores,
objeto, usos, flags y Amenaza. El DreamGraph deriva su estado de la carta y se
aplica inmediatamente.

## Audio

`MusicPlayer` es un autoload con un único `AudioStreamPlayer` en `Master`.
Menús, dados y epílogo usan reproductores locales. No existe AudioManager ni
mezclador narrativo general.

## BackgroundFX

- Niebla geométrica paramétrica.
- Carta 01: composición fija tranquila.
- Carta 02: vórtice fijo.
- Cartas 03–06: variaciones aleatorias contenidas.
- Feedback independiente de éxito y fallo.
- DreamGraph de 18 nodos y 21 conexiones con progreso por carta.

El experimento Visual Lab permanece separado y no se modifica en runtime.

## Vídeo

El epílogo usa el soporte nativo Ogg Theora de Godot:

- `Assets/videos/act1-epilogue.ogv`, 1920×1080, 77,08 s;
- `Assets/music/act1-epilogue.mp3` como audio independiente.

El `VideoStreamPlayer` está silenciado. No quedan plugins de vídeo requeridos.

## Riesgos y límites

- Contenido conectado explícitamente mediante exports y comparaciones de
  Resources.
- `GameHUD` crecería demasiado si se añadieran muchas cartas.
- Comida y Escudo carecen de ejecución.
- El aliado no tiene derrota funcional.
- BackgroundFX y DreamGraph requieren QA visual y de rendimiento en hardware
  adicional.
- No se han validado exportación web, licencias completas ni publicación.

## Decisión arquitectónica

Para el vertical slice, simplicidad y trazabilidad tuvieron prioridad sobre una
arquitectura general. `06 Resources.md` y `07 Runtime Architecture.md` conservan
el diseño previo como material histórico, no como descripción de la build.

