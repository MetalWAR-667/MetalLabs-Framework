# UI / UX

**Estado: Integrada para el vertical slice**

## Principio

La interfaz mantiene estable la lectura aunque el sueño sea extraño. Cada
acción debe tener una intención clara, mostrar su riesgo y bloquearse mientras
se resuelve.

## Pantallas

```text
SplashScreen
MainMenu
ItemSelectionMenu
HUD + PauseMenu
GameOver / Act1Epilogue
EndScreen
```

## MainMenu

- Nueva partida elimina el guardado y abre selección de objeto.
- Continuar se habilita solo con guardado válido.
- Pantalla completa alterna modo de ventana.
- Salir cierra la aplicación.
- Los botones tienen foco, hover visual y sonidos de entrada/click.

## Selección inicial

Muestra exactamente Comida, Escopeta y Escudo con ilustración, nombre,
descripción y botón Elegir. La elección comienza la música de gameplay y pasa
una única referencia de objeto al HUD.

## HUD

- Carta principal a la izquierda.
- Panel de Jack y slot equipado a la derecha.
- Panel del Fugitivo oculto hasta su incorporación; al desbloquearse entra con
  fade, escala y desplazamiento suaves.
- Dados ocultos en reposo y visibles solo durante tiradas.
- Pausa con Escape, reanudación y confirmación para volver al menú.

El espacio del aliado permanece vacío antes de desbloquearlo; no se redistribuye
la composición.

## CardView

La escena activa es `card_view_responsive.tscn`.

- texto a 40 caracteres por segundo con pausas de puntuación;
- tecla de aceptar o click sobre el texto completa el reveal;
- opciones aparecen después mediante fade;
- RichTextLabel conserva scroll automático y rueda manual;
- la barra vertical existe pero es visualmente transparente;
- hover desplaza ligeramente el texto y muestra un fondo suave;
- la ilustración usa una máscara fija y slow zoom out de 202% a 100% durante
  8 segundos;
- la barra de Amenaza muestra símbolo, cantidad y daño;
- los marcos de carta y actor comparten lenguaje shader.

## Opciones y Amenazas

Las opciones no disponibles siguen visibles pero deshabilitadas. Al seleccionar
una ruta se bloquean las demás hasta completar la Amenaza. No hay diálogo de
confirmación para decisiones narrativas.

## Dados

Cada tirada presenta:

1. sonido de preparación;
2. fade y escala de entrada;
3. animación e impacto;
4. símbolo resultante;
5. feedback de éxito o fallo;
6. salida y ocultación.

Un éxito automático aparece como `+N` sobre el dado. El Fugitivo usa gradiente
verde y permanece colocado sobre su propio panel.

## Objeto equipado

Existe un único slot siempre visible. Muestra icono y tooltip, pero no calcula
efectos. Al agotarse el objeto, el icono desaparece y el hueco permanece.

No existe interfaz para activar Comida o Escudo; sus efectos no están
implementados.

## Derrota, epílogo y final

Game Over no ofrece botones: revela la imagen, espera y vuelve al menú. El
epílogo permite mantener `ui_accept` durante 1,5 s para omitirlo. La pantalla
final tiene un único botón de retorno. Los créditos definitivos siguen
pendientes.

## Accesibilidad y límites

- ratón y foco de teclado están presentes en menús;
- la rueda permite releer narración;
- no hay remapeo, lector de pantalla, escalado tipográfico ni ajustes de color;
- no se ha realizado validación completa a resoluciones distintas de la base.

## Criterio

El jugador debe poder entrar, leer, decidir, comprender una Amenaza, continuar,
perder y terminar sin necesitar documentación externa.

