# 11_ui_ux.md

# UI / UX

## Estado

**Especificación de interacción del corte vertical**

Este documento define cómo el jugador navega, lee y toma decisiones en EXP-00X.

Su alcance incluye:

- menú;
- selección de objeto inicial;
- presentación de cartas;
- opciones;
- Amenazas;
- selección de participantes;
- tiradas;
- daño;
- uso del Escudo;
- HUD e inventario;
- descanso;
- pausa;
- guardado;
- final y créditos.

La identidad visual se define en `09 Art Direction.md`.

El comportamiento sonoro se define en `10 Audio Direction.md`.

Las reglas proceden de `03_core_rules.md`.

La UI no interpreta ni modifica esas reglas.

---

# 1. Principio

El jugador debe poder comprender en todo momento:

1. qué está ocurriendo;
2. qué puede elegir;
3. qué riesgo acepta;
4. qué resultado se ha producido;
5. qué cambió después.

La experiencia gira alrededor de la lectura.

La interfaz debe desaparecer como obstáculo y permanecer como apoyo.

> **El sueño puede ser ambiguo; la decisión del jugador no.**

---

# 2. Pilares de experiencia

## 2.1 Lectura estable

Mientras el jugador lee:

- la carta permanece quieta;
- no aparecen elementos inesperados;
- el fondo reduce actividad;
- las opciones mantienen su posición;
- no existe límite de tiempo;
- el juego no avanza automáticamente.

## 2.2 Riesgo visible

Antes de confirmar una Amenaza deben mostrarse:

- símbolo objetivo;
- cantidad requerida;
- daño por ronda fallida;
- destinatarios del daño;
- participantes;
- objetos relevantes.

## 2.3 Una intención por acción

Cada interacción debe comunicar una sola intención:

- elegir;
- confirmar;
- lanzar;
- usar objeto;
- continuar;
- volver.

Se evitarán botones que ejecuten varias decisiones implícitas difíciles de anticipar.

## 2.4 Consecuencia comprensible

Después de una acción, la interfaz mostrará:

- resultado;
- daño evitado o recibido;
- Salud actualizada;
- objeto consumido, perdido o entregado;
- aliado incorporado;
- descanso aplicado;
- siguiente transición.

## 2.5 Control del ritmo

El jugador controla:

- cuándo termina de leer;
- cuándo elige;
- cuándo confirma participantes;
- cuándo inicia una tirada;
- cuándo continúa después de un resultado;
- cuándo avanza texto final y créditos.

Las animaciones no sustituyen esta capacidad.

---

# 3. Arquitectura de pantallas

El corte vertical necesita:

```text
MainMenu
├── NewGame
│   └── InitialItemSelection
├── Continue
└── Exit

GameScreen
├── DreamBackground
├── CardView
├── HUD
├── InventoryView
├── DiceTray
├── ParticipantSelection
├── ResultOverlay
├── PauseOverlay
└── TransitionLayer

EndingScreen
├── FinalText
├── Credits
└── BackToMenu
```

La estructura expresa responsabilidades conceptuales.

No obliga a crear una escena independiente para cada bloque.

---

# 4. Menú principal

## 4.1 Contenido

Orden recomendado:

```text
TÍTULO

CONTINUAR
NUEVA PARTIDA

PANTALLA COMPLETA

SALIR
```

## 4.2 Continuar

`CONTINUAR`:

- aparece habilitado cuando existe un guardado válido y no completado;
- aparece deshabilitado o no se muestra cuando no existe guardado;
- no aparece habilitado después de completar la partida;
- carga directamente la carta guardada.

No se necesita selector de partidas.

## 4.3 Nueva partida

Si no existe una partida en curso, conduce directamente a la selección de objeto.

Si existe una partida válida no completada:

- se muestra una confirmación breve;
- se explica que la nueva partida sustituirá el progreso actual;
- las acciones son `CANCELAR` y `NUEVA PARTIDA`.

La opción destructiva no debe activarse por una pulsación accidental.

## 4.4 Pantalla completa

El control alterna entre:

- ventana;
- pantalla completa.

El estado actual debe resultar visible.

No se abrirá una pantalla de opciones separada.

---

# 5. Selección de objeto inicial

## 5.1 Objetivo

Antes de la primera carta, el jugador elige uno de tres objetos.

La pantalla enseña el inventario mediante una decisión concreta, sin tutorial modal.

## 5.2 Presentación

Cada objeto muestra:

- icono;
- nombre;
- efecto en una frase;
- espacios ocupados;
- estado de selección.

Los tres objetos deben poder compararse simultáneamente.

## 5.3 Flujo

```text
Mostrar tres objetos
      ↓
Seleccionar uno
      ↓
Mostrar detalle y efecto
      ↓
Confirmar elección
      ↓
Crear partida
      ↓
Presentar carta 1
```

La selección inicial no incluye:

- estadísticas;
- clase;
- equipamiento;
- dificultad;
- creación de personaje.

## 5.4 Confirmación

Antes de confirmar:

- solo un objeto puede estar seleccionado;
- el botón de confirmación permanece deshabilitado sin selección;
- cambiar de objeto no requiere cerrar paneles;
- el Escudo se describe como consumible.

---

# 6. GameScreen

## 6.1 Jerarquía

Prioridad visual:

1. carta;
2. decisión activa;
3. información de Amenaza;
4. resultado de tirada;
5. Salud e inventario;
6. fondo.

La jerarquía puede cambiar temporalmente durante una tirada, pero la carta sigue siendo el contexto.

## 6.2 Estados

`GameScreen` representa las fases definidas en `07 Runtime Architecture.md`:

- presentando carta;
- esperando decisión;
- esperando participantes;
- resolviendo ronda;
- representando ronda;
- aplicando resultado;
- cerrando carta;
- guardando;
- transición;
- final.

Solo los controles correspondientes a la fase actual estarán activos.

---

# 7. CardView

## 7.1 Entrada

Secuencia:

1. aparece la carta;
2. se revela la ilustración;
3. aparece el texto;
4. aparecen las opciones;
5. se habilita la interacción.

La secuencia puede acelerarse mediante una acción del jugador.

Saltar la animación muestra el estado final de la carta.

No omite texto ni confirma opciones.

## 7.2 Texto

El texto narrativo:

- mantiene ancho de lectura contenido;
- utiliza alineación consistente;
- evita líneas excesivamente largas;
- permite desplazamiento solo cuando resulte imprescindible;
- no aparece sobre la ilustración;
- no utiliza efectos que dificulten leer.

La versión inicial puede mostrar el texto completo.

No necesita efecto de máquina de escribir.

## 7.3 Ilustración

La ilustración:

- dispone de una región estable;
- conserva proporción;
- no invade las opciones;
- puede atenuarse durante una tirada;
- no contiene información mecánica imprescindible.

---

# 8. Opciones

## 8.1 Presentación

Cada opción muestra:

- acción;
- texto breve;
- estado disponible o no disponible.

El jugador debe reconocer inmediatamente qué elementos son interactivos.

## 8.2 Opción no disponible

Una opción condicionada puede permanecer visible y deshabilitada cuando conocer su existencia aporta valor narrativo.

Debe indicar un motivo breve:

- `Requiere un objeto`;
- `El objeto ya no está disponible`;
- `Requiere al Fugitivo`.

No se expondrán nombres de variables internas.

Por ejemplo, la opción de entregar el objeto en el Umbral no mostrará `objeto_sacrificado_en_umbral`.

## 8.3 Confirmación

Una opción sin coste o riesgo irreversible puede ejecutarse directamente.

Una opción que:

- consume un objeto;
- inicia una Amenaza;
- sustituye un aliado;
- destruye progreso;

puede solicitar una confirmación contextual cuando las pruebas demuestren que evita errores.

No se añadirá un diálogo de confirmación a todas las opciones.

## 8.4 Bloqueo

Tras elegir:

- las opciones se bloquean;
- no se aceptan dobles pulsaciones;
- comienza la siguiente fase;
- la UI no permite cambiar la elección durante la transición.

---

# 9. Presentación de una Amenaza

## 9.1 Información

La Amenaza muestra:

- símbolo requerido;
- cantidad base;
- cantidad ajustada;
- progreso acumulado;
- daño por ronda fallida;
- reparto declarado por la carta;
- efectos especiales visibles cuando corresponda.

## 9.2 Lenguaje

La representación debe combinar:

- símbolo;
- nombre textual;
- cantidad;
- daño.

No se dependerá únicamente del color.

Ejemplo conceptual:

```text
CORDURA ×2
Progreso: 1 / 2

FALLO: 1 SALUD A CADA PARTICIPANTE
```

## 9.3 Momento

La información aparece antes de:

- seleccionar participantes;
- confirmar el uso de un aliado;
- lanzar los dados.

El jugador no descubre el daño después de aceptar el riesgo.

---

# 10. Selección de participantes

## 10.1 Disponibilidad

Esta fase solo aparece cuando:

- existe una Amenaza;
- el jugador dispone de aliado;
- la carta permite la participación habitual.

Sin aliado, el protagonista queda seleccionado automáticamente.

## 10.2 Comparación

La pantalla muestra dos configuraciones:

### Protagonista

- dado del protagonista;
- objetivo base;
- Salud actual;
- aliado descansará.

### Protagonista y aliado

- ambos dados;
- objetivo duplicado;
- Salud de ambos;
- ninguno descansará.

## 10.3 Confirmación

Antes de confirmar se actualizan:

- cantidad requerida;
- dados visibles;
- reparto de daño;
- indicación de descanso.

La selección queda bloqueada durante toda la Amenaza.

Una incapacitación posterior no cambia la elección ni activa descanso.

---

# 11. Tirada

## 11.1 Inicio

Cada ronda dispone de una acción explícita:

`LANZAR`

El botón solo se habilita cuando:

- los participantes están confirmados;
- no hay otra animación activa;
- no existe un resultado pendiente;
- la fase permite lanzar.

## 11.2 Representación

Secuencia:

1. se bloquea `LANZAR`;
2. aparecen o se activan los dados;
3. se reproduce la animación;
4. se muestra la cara calculada;
5. se resaltan símbolos útiles;
6. se actualiza el progreso;
7. se presenta éxito o ronda fallida.

Los símbolos que no coinciden pueden atenuarse.

No deben desaparecer antes de que el jugador comprenda el resultado.

## 11.3 Continuación

Después del resultado:

- una ronda superada conduce al desenlace;
- una ronda fallida normal habilita `CONTINUAR` o la siguiente acción `LANZAR`;
- una ronda fallida con finalización anticipada presenta su consecuencia y abandona la Amenaza.

La carta 3 y la carta 5 utilizan finalización anticipada por fallo.

---

# 12. Daño y Escudo

## 12.1 Previsualización

En una ronda fallida se muestra:

- daño total;
- destinatario o destinatarios;
- Salud antes de aplicarlo;
- protección disponible.

## 12.2 Uso del Escudo

Si el inventario contiene el Escudo y existe daño:

- se ofrece `USAR ESCUDO`;
- se explica que evita 1 punto;
- se recuerda que el objeto desaparecerá;
- puede elegirse `RECIBIR DAÑO`.

Si hay dos destinatarios, el jugador selecciona a quién protege antes de confirmar.

No se ofrece el Escudo cuando:

- no existe daño;
- ya fue consumido;
- la carta impide temporalmente usar objetos.

## 12.3 Aplicación

Secuencia:

1. confirmar protección o recibir daño;
2. mostrar 1 punto evitado, si corresponde;
3. retirar el Escudo del inventario;
4. actualizar Salud;
5. mostrar efectos especiales;
6. continuar o terminar el encuentro.

El daño declarado por la carta se aplica una sola vez.

No se mostrará una segunda consecuencia genérica de daño.

---

# 13. HUD

## 13.1 Protagonista

Muestra:

- identidad;
- Salud actual y máxima;
- estado temporal relevante, solo mientras exista.

## 13.2 Aliado

Solo aparece cuando existe un aliado.

Muestra:

- identidad;
- Salud actual y máxima;
- participación o descanso durante una Amenaza;
- incapacidad temporal, si existe.

## 13.3 Salud

La representación definitiva dependerá de los valores de balance.

Puede utilizar:

- valor numérico;
- marcas o puntos;
- combinación de ambos.

Debe permitir distinguir con precisión:

- Salud actual;
- Salud máxima;
- pérdida;
- recuperación;
- daño evitado.

No se utilizará únicamente una barra sin valores si impide conocer el riesgo exacto.

---

# 14. Inventario

## 14.1 Presentación

El inventario muestra:

- objetos actuales;
- espacios ocupados;
- efecto breve al enfocar;
- disponibilidad.

No necesita:

- ordenar;
- arrastrar;
- equipar;
- comparar rarezas;
- abrir una mochila separada.

## 14.2 Cambios

Cuando un objeto:

- se obtiene;
- se consume;
- se entrega;
- se roba;

la interfaz muestra una transición breve y actualiza el inventario una sola vez.

Cuando un intento de robo encuentra el inventario vacío:

- se muestra que no se ha robado nada;
- no aparece una selección vacía;
- no se simula una consecuencia alternativa.

---

# 15. Descanso

El descanso se comunica al cerrar la carta.

Si el aliado fue excluido voluntariamente:

1. se muestra `DESCANSO`;
2. aparece `+1 SALUD`;
3. se actualiza el HUD;
4. continúa el cierre.

Si el aliado está a Salud máxima:

- puede mostrarse `SALUD COMPLETA`;
- no se reproduce una curación ficticia.

Si el aliado participó o fue incapacitado:

- no aparece feedback de descanso;
- no recupera Salud.

La carta 6 es la primera demostración del descanso en el corte vertical.

---

# 16. Consecuencias persistentes

Los cambios importantes reciben feedback breve:

- objeto entregado;
- objeto perdido;
- variable narrativa reflejada en la siguiente carta;
- aliado incorporado;
- Salud modificada;
- partida completada.

No se mostrarán nombres técnicos ni listas de variables.

La persistencia se entiende por sus efectos en el mundo.

Ejemplo:

- entregar el objeto en la carta 3 habilita una descripción y una opción diferentes en la carta 4.

---

# 17. Autoguardado

El autoguardado ocurre entre cartas.

La experiencia debe:

- evitar interrupciones;
- no pedir nombre;
- no abrir selector;
- no detener la lectura.

Puede mostrarse un indicador pequeño durante un instante.

El indicador:

- no bloquea;
- no requiere confirmación;
- desaparece al completar el guardado;
- comunica un error solo cuando sea relevante.

No se prometerá que la partida está guardada antes de recibir confirmación del servicio.

---

# 18. Pausa

`Escape` abre un overlay mínimo:

- `CONTINUAR`;
- `VOLVER AL MENÚ`;
- `SALIR`.

Volver al menú:

- no modifica el estado de la carta;
- no fuerza un guardado en mitad de una Amenaza;
- puede pedir confirmación si existe progreso temporal no guardado.

El juego basado en lectura no necesita detener simulaciones complejas.

La pausa existe principalmente como navegación segura.

---

# 19. Final y créditos

## 19.1 Entrada

Después de superar la carta 6:

- se bloquea la interacción;
- se marca la partida como completada;
- se realiza el último guardado;
- comienza el fundido.

## 19.2 Texto final

El jugador puede avanzar mediante una única acción.

No se muestra una opción narrativa nueva.

## 19.3 Créditos

Los créditos:

- permiten lectura;
- muestran atribuciones obligatorias;
- pueden acelerarse;
- conducen a `VOLVER AL MENÚ`.

`CONTINUAR` queda deshabilitado para la partida completada.

`NUEVA PARTIDA` vuelve a la selección de objeto.

---

# 20. Entradas

## 20.1 Ratón

Debe permitir completar todo el recorrido.

## 20.2 Teclado

Controles mínimos:

- flechas o navegación de foco;
- `Enter` o `Espacio` para confirmar;
- `Escape` para pausa o retroceso seguro.

## 20.3 Foco

Todo control interactivo debe:

- recibir foco visible;
- mantener orden lógico;
- recuperar un foco válido al cerrar overlays;
- evitar que el foco quede detrás de una capa modal.

No se diseñará inicialmente:

- remapeo completo;
- soporte táctil específico;
- mando avanzado;
- combinaciones complejas.

El soporte de mando podrá evaluarse después de validar teclado y ratón.

---

# 21. Accesibilidad mínima

El corte vertical debe cumplir:

- contraste suficiente;
- texto escalado para 1920 × 1080;
- símbolos acompañados por nombres;
- información no dependiente solo del color;
- foco visible;
- botones con estados distinguibles;
- animaciones breves;
- ausencia de parpadeos intensos;
- tiempo de lectura ilimitado;
- posibilidad de acelerar entradas y transiciones.

Se evitarán:

- texto pequeño sobre fondos animados;
- flashes frecuentes;
- opciones comunicadas solo mediante color;
- audio imprescindible sin equivalente visual;
- movimiento continuo cerca del texto.

No se construirá todavía un sistema completo de accesibilidad o personalización.

Primero se garantizará una base legible y operable.

---

# 22. Feedback y errores

## Feedback inmediato

- control enfocado;
- control presionado;
- opción confirmada;
- acción bloqueada;
- objeto consumido;
- daño aplicado;
- Salud recuperada;
- guardado completado.

## Errores recuperables

Mensajes breves para:

- guardado inválido;
- fallo al guardar;
- contenido no disponible;
- opción que dejó de cumplir su condición.

Los mensajes:

- describen el problema en lenguaje de jugador;
- no muestran rutas, IDs o trazas;
- ofrecen una única salida segura cuando sea posible.

Los detalles técnicos pertenecen al diagnóstico de desarrollo.

---

# 23. Prevención de errores

La UI debe impedir:

- confirmar una opción dos veces;
- lanzar durante una animación;
- cambiar participantes entre rondas;
- usar un objeto inexistente;
- curar por encima de la Salud máxima;
- activar descanso por incapacitación;
- continuar una partida completada;
- iniciar una nueva partida accidentalmente;
- cerrar atribuciones obligatorias antes de mostrarlas.

La prevención debe proceder primero del estado de interacción.

No de mensajes posteriores que reprendan al jugador.

---

# 24. Onboarding del corte vertical

Las seis cartas enseñan mediante uso:

| Paso | Aprendizaje |
|---|---|
| Selección inicial | Elegir y conservar un objeto |
| Carta 1 | Leer y elegir |
| Carta 2 | Resolver una Amenaza |
| Carta 3 | Entregar un objeto y aceptar una salida por fallo |
| Carta 4 | Riesgo, objeto y rutas condicionadas |
| Carta 5 | Incorporación condicional de aliado |
| Carta 6 | Participantes, escalado y descanso |
| Final | Cierre y retorno al menú |

No se necesitan:

- ventanas de tutorial;
- páginas de manual;
- explicaciones extensas antes de jugar;
- resaltados que bloqueen la pantalla.

Cuando una mecánica aparece por primera vez, una frase contextual y una presentación clara deben ser suficientes.

---

# 25. Pruebas de UX

El corte vertical debe observarse con jugadores sin explicación previa.

Preguntas:

- ¿Encuentran `NUEVA PARTIDA`?
- ¿Entienden que deben elegir un objeto?
- ¿Distinguen texto y opciones?
- ¿Ven objetivo y daño antes de lanzar?
- ¿Comprenden el progreso entre rondas?
- ¿Detectan que el Escudo se consume?
- ¿Entienden por qué una opción está deshabilitada?
- ¿Comprenden el efecto de incorporar al Fugitivo?
- ¿Distinguen participación e incapacidad?
- ¿Perciben la recuperación por descanso?
- ¿Saben cómo volver al menú?

Se registrarán confusiones reales.

No se añadirán ayudas para problemas que todavía no se hayan observado.

---

# 26. Fuera del alcance

No se implementará inicialmente:

- editor de interfaz;
- personalización de HUD;
- remapeo completo;
- soporte táctil específico;
- múltiples perfiles;
- selector de guardados;
- diario;
- códice;
- mapa;
- registro de combate;
- tooltips complejos;
- árbol de tutoriales;
- inventario por arrastre;
- pantalla avanzada de opciones;
- localización completa;
- interfaz adaptada a muchas proporciones;
- sistema general de accesibilidad configurable.

---

# 27. Criterio de aceptación

La UI/UX del corte vertical se considerará validada cuando el jugador pueda:

- iniciar una partida;
- elegir uno de tres objetos;
- leer una carta sin distracciones;
- distinguir opciones disponibles;
- comprender por qué una opción está bloqueada;
- conocer objetivo y daño antes de una Amenaza;
- seleccionar participantes cuando exista aliado;
- lanzar uno o dos dados;
- entender progreso, éxito y fallo;
- utilizar y consumir el Escudo;
- identificar daño y destinatarios;
- observar cambios de Salud;
- comprender incorporación e incapacidad;
- reconocer el descanso voluntario;
- ver el autoguardado sin interrupción;
- pausar y volver al menú;
- completar el final y los créditos;
- comenzar una nueva partida.

Todo ello debe funcionar:

- con ratón;
- con teclado;
- sin lógica dentro de la UI;
- sin información dependiente solo del color;
- sin tutorial externo;
- sin ampliar el sistema de juego.

---

# 28. Principio final

> **Mostrar el riesgo antes de decidir, mostrar el resultado antes de continuar y no pedir al jugador que interprete la interfaz como si fuera otra pesadilla.**
