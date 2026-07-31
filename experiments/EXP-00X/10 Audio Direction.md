# Audio Direction

**Estado: Integrada para el vertical slice**

## Principio

El audio acompaña lectura, materialidad y tensión. Debe sugerir un espacio
incorrecto sin convertir cada carta en una demostración sonora. El silencio
sigue siendo una opción válida.

## Música integrada

- Menú: `Assets/music/Awake the monster_final.mp3`.
- Selección de objeto y partida: `Assets/music/Stone Above the Void.mp3`.
- Epílogo: `Assets/music/act1-epilogue.mp3`.

`MusicPlayer` conserva una única pista global. El epílogo detiene ese reproductor
y utiliza uno local para sincronizar su música con el vídeo mediante un desfase
fijo de 0,12 s.

No existen cues musicales diferentes por carta, mezcla dinámica, sincronización
por beats ni música específica de Game Over.

## Efectos integrados

### Menú principal

- Hover: `Quiz_And_Puzzle_Musical_SFX  (289).wav`.
- Click confirmado: `Quiz_And_Puzzle_Musical_SFX  (290).wav`.

Un único reproductor local evita duplicación.

### Dados

- cuatro sonidos aleatorios `shuffle_open` antes de lanzar;
- cuatro impactos aleatorios `d6_floor` durante la tirada;
- señal sonora de éxito;
- señal sonora de fallo.

El audio acompaña entrada, animación, resultado y salida del dado. Jack y el
Fugitivo reutilizan el mismo componente.

## Capas no implementadas

- ambientes específicos por carta;
- sonidos de criaturas;
- voz;
- efectos propios de Comida o Escudo;
- transiciones musicales narrativas;
- controles y buses independientes de volumen;
- audio de créditos definitivos.

Las secciones antiguas que proponían seis cues distintos se consideran
dirección previa, no estado de la build.

## Mezcla

Todos los reproductores utilizan actualmente el bus `Master`. No existe un
AudioManager. La prioridad del slice fue claridad funcional; mezcla, loudness y
opciones de volumen pertenecen a QA futuro.

## Criterio

Cada sonido debe confirmar una acción o reforzar una transición. Añadir capas
sin una función reconocible queda fuera del cierre.

