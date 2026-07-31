# EXP-00X — Awake the Monster

**Status: Vertical Slice Complete**

EXP-00X es un microjuego narrativo desarrollado en Godot 4.7.1 para validar un
proceso completo de producción asistida por IA dentro de MetalLab. Su propósito
no era construir un RPG extensible, sino cerrar un recorrido pequeño y aprender
qué decisiones técnicas, editoriales y artísticas merecen trasladarse a
Lands of Folklore.

## Qué contiene

- seis cartas narrativas;
- elección inicial entre tres objetos y un único slot equipado;
- pruebas de Atención, Cordura y Fuerza mediante dados personalizados;
- Amenazas persistentes entre rondas, daño y reintentos;
- un Fugitivo desbloqueable que puede participar o descansar;
- guardado local de un único slot y opción Continuar;
- pausa, Game Over y cierre automático de la partida;
- epílogo audiovisual después de Carta 06;
- carta con texto progresivo, scroll, slow zoom out y opciones contextuales;
- BackgroundFX con niebla geométrica, feedback y DreamGraph progresivo;
- música y efectos funcionales de menú, dados, éxito y fallo.

## Bucle jugable

```text
Splash → Main Menu → Nueva partida → Selección de objeto → HUD
      → Cartas 01–06 → Epílogo del Acto 1 → Final Vertical Slice
      → Main Menu

Main Menu → Continuar → HUD restaurado
Salud ≤ 0 → Game Over → Main Menu
```

Cada carta revela texto, presenta opciones y puede activar una Amenaza. Una
Amenaza exige símbolos; cada éxito reduce su cantidad pendiente y cada ronda
sin resolver aplica el daño declarado por la opción. La decisión queda
comprometida hasta cerrar la Amenaza.

## Cómo ejecutar

Abrir en Godot 4.7.1:

`exp-00x-awake-the-monster/project.godot`

La escena principal es `scenes/ui/menu/splash_screen.tscn`. El proyecto está
configurado a 1920×1080, Forward+ y D3D12 en Windows.

## Estructura

- `data/`: `ActorData`, `CardData`, `CardOptionData` e `ItemData` en `.tres`.
- `scenes/ui/`: menús, HUD y componentes visuales.
- `scripts/ui/hud.gd`: coordinación específica del vertical slice.
- `scripts/autoload/`: `SaveManager` y `MusicPlayer`.
- `shaders/`: fondos y marcos integrados.
- `experiments/vfx/`: laboratorio histórico y conclusiones visuales.

## Documentación

Empezar por [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md). Las reglas
vigentes están en [03_core_rules.md](03_core_rules.md) y la implementación real
en [05 Technical Foundations.md](05%20Technical%20Foundations.md).

## Limitaciones conocidas

- Solo la Escopeta ejecuta actualmente su efecto; Comida y Escudo siguen siendo
  selecciones editoriales con efecto runtime pendiente.
- El contenido está conectado explícitamente para seis cartas; no existe
  registro automático ni editor narrativo.
- El final posterior al epílogo es una pantalla provisional, no créditos.
- No se ha completado auditoría de assets, QA de publicación ni soporte web.
- DreamGraph permanece como integración experimental pendiente de juicio
  artístico final.

## Siguiente fase

El slice está cerrado. Cualquier ampliación debe comenzar por contenido y deuda
registrada en [FUTURE_EXPANSION.md](FUTURE_EXPANSION.md), sin convertir este
prototipo en una arquitectura general antes de necesitarla.

