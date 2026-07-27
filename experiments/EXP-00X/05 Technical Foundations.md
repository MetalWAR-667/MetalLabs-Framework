# 05_technical_foundations.md

# Technical Foundations

## Estado

**Preproducción técnica**

Este documento define los fundamentos técnicos mínimos necesarios para construir el microjuego en Godot.

No constituye una especificación detallada de implementación.

Su objetivo es establecer:

* las restricciones tecnológicas;
* las piezas principales del proyecto;
* sus responsabilidades;
* las fronteras entre lógica, datos y presentación;
* el primer corte vertical que deberá validarse.

Las decisiones descritas deberán mantenerse compatibles con el alcance temporal definido en `01_scope.md`.

---

# 1. Principio técnico

El proyecto debe construirse utilizando la solución más sencilla capaz de sostener el juego diseñado.

No se pretende crear:

* un motor narrativo genérico;
* un framework independiente;
* un editor de cartas;
* una arquitectura comparable a la de Lands of Folklore;
* una infraestructura preparada para necesidades hipotéticas.

La prioridad es completar un juego pequeño, estable y publicable.

> **La arquitectura debe proteger el alcance, no anticipar un proyecto mayor.**

---

# 2. Tecnología

## 2.1 Motor

El proyecto se desarrollará en **Godot 4** mediante GDScript.

Se utilizarán las herramientas nativas del motor siempre que resulten suficientes.

No se incorporarán plugins salvo necesidad técnica demostrable.

---

## 2.2 Presentación exclusivamente 2D

Todo el proyecto utilizará el sistema 2D de Godot.

No se emplearán:

* nodos 3D;
* cámaras 3D;
* luces 3D;
* meshes;
* materiales espaciales;
* físicas 3D;
* entornos tridimensionales.

La presentación se construirá principalmente mediante:

* nodos `Control`;
* contenedores de interfaz;
* `TextureRect`;
* `RichTextLabel`;
* botones;
* `AnimatedSprite2D`;
* `AnimationPlayer`;
* `Tween`;
* shaders `canvas_item`.

El aprendizaje de Godot 3D queda fuera del alcance de este experimento.

---

## 2.3 Resolución

La resolución de diseño será:

**1920 × 1080 píxeles**

La interfaz se diseñará inicialmente para formato horizontal 16:9.

Se utilizarán anchors y containers para conservar una composición estable al cambiar entre ventana y pantalla completa.

No se desarrollará inicialmente una interfaz independiente para múltiples proporciones de pantalla.

---

## 2.4 Plataformas

La plataforma principal será escritorio.

Objetivos iniciales:

* Windows;
* posible exportación Linux.

La exportación Web para itch.io se evaluará al final del desarrollo.

No condicionará la arquitectura ni la dirección visual inicial.

Si una limitación específica de la exportación Web obliga a degradar significativamente shaders, audio o presentación, la versión Web podrá descartarse sin considerar incumplido el experimento.

---

# 3. Modelo de datos

El contenido del juego se definirá mediante **Resources de Godot**.

No se utilizará JSON como formato editorial principal durante esta versión.

Resources previstos:

* `CardResource`;
* `CardOptionResource`;
* `CharacterResource`;
* `DiceResource`;
* `ItemResource`;
* `ConsequenceResource`;
* `AudioCueResource`;
* `SaveGameResource`.

Los nombres definitivos podrán ajustarse durante la implementación, pero sus responsabilidades deberán mantenerse separadas.

---

## 3.1 Principios de los Resources

Los Resources:

* describen datos;
* pueden referenciar otros Resources;
* no dependen de nodos de interfaz;
* no controlan el flujo de partida;
* no ejecutan animaciones;
* no reproducen audio;
* no modifican directamente el estado global.

Una carta no debe necesitar un script específico para funcionar.

Las 30–40 cartas deberán expresarse reutilizando las mismas estructuras de datos y el mismo sistema de resolución.

---

# 4. Estado de partida

Toda la información persistente de la partida residirá en una única estructura lógica denominada provisionalmente:

`GameState`

Debe contener únicamente el estado mutable necesario para continuar la partida.

Contenido previsto:

* identificador de la carta actual;
* estado del protagonista;
* identificador y estado del aliado;
* inventario;
* variables narrativas;
* estado del sueño;
* semilla aleatoria, si se decide conservar resultados reproducibles.

Atención, Fuerza y Cordura son símbolos de resolución definidos por los dados.

No forman parte del estado persistente.

El autoguardado se realizará entre cartas, por lo que no será necesario conservar tiradas ni progreso neutralizado de una Amenaza.

`GameState` no será una interfaz gráfica.

Tampoco contendrá referencias a botones, labels, sprites, shaders ni reproductores de audio.

---

# 5. Separación entre lógica y presentación

La interfaz no contendrá reglas de juego.

Los elementos visuales podrán:

* mostrar información;
* reproducir animaciones;
* recibir interacción del jugador;
* emitir señales;
* representar resultados calculados previamente.

No podrán:

* resolver amenazas;
* decidir consecuencias;
* modificar directamente el inventario;
* alterar Salud;
* seleccionar la siguiente carta;
* guardar la partida por iniciativa propia.

> **La UI recibe datos, los representa y comunica la intención del jugador.**

---

# 6. Componentes principales

## 6.1 GameController

Responsabilidad:

Coordinar el flujo general de la partida.

Funciones conceptuales:

* iniciar una nueva partida;
* cargar una partida existente;
* solicitar la carta actual;
* presentar la carta;
* recibir la opción elegida;
* solicitar la selección de participantes;
* iniciar la resolución;
* aplicar consecuencias;
* aplicar descanso;
* actualizar el estado;
* ejecutar el autoguardado;
* avanzar a la siguiente carta.

No deberá:

* calcular directamente las tiradas;
* dibujar dados;
* animar cartas;
* implementar efectos visuales;
* almacenar definiciones de contenido;
* convertirse en una clase que contenga todas las reglas.

El controlador coordina.

No sustituye a los componentes especializados.

La participación se fija al comenzar la Amenaza.

Una incapacidad temporal no retira al personaje de la lista de participantes y nunca activa el descanso.

---

## 6.2 GameState

Responsabilidad:

Mantener el estado mutable y coherente de la partida.

Debe ser la fuente de verdad para:

* Salud;
* aliado;
* Salud del aliado;
* inventario;
* variables narrativas;
* estado del sueño;
* carta actual.

La UI podrá consultar una representación del estado, pero no modificarla directamente.

---

## 6.3 CardRepository

Responsabilidad:

Localizar y devolver las definiciones de cartas.

Entrada conceptual:

* identificador lógico de carta.

Salida:

* `CardResource`.

No decidirá qué carta debe mostrarse.

Solo resolverá referencias de contenido.

Inicialmente puede ser una implementación muy sencilla basada en Resources precargados o en una carpeta conocida.

No se construirá un sistema complejo de base de datos.

---

## 6.4 ThreatResolver

Responsabilidad:

Resolver una Amenaza mediante el objetivo fijo declarado por la carta y los dados de los personajes participantes.

Recibe:

* dados participantes;
* símbolo objetivo;
* cantidad requerida ajustada al número de participantes;
* progreso neutralizado en rondas anteriores;
* modificadores simples permitidos;
* efectos aplicables de objetos.

Devuelve un resultado descriptivo.

No deberá:

* aplicar daño;
* modificar el `GameState`;
* seleccionar cartas;
* reproducir animaciones;
* reproducir sonidos;
* guardar la partida.

El resultado conceptual podrá contener:

* caras obtenidas;
* símbolos neutralizados;
* símbolos pendientes;
* éxito completo;
* ronda fallida;
* efectos especiales relevantes.

No se lanzan Dados de Amenaza.

Una restricción que impide actuar durante una ronda es temporal.

No cambia la selección de participantes ni concede recuperación de Salud por descanso.

Una ronda fallida puede devolver un resultado de finalización anticipada y un destino declarado por la carta.

Esta excepción aplica el daño visible una sola vez y no inicia otra ronda.

---

## 6.5 ConsequenceExecutor

Responsabilidad:

Aplicar sobre `GameState` las consecuencias declaradas por una carta.

Consecuencias previstas:

* modificar Salud;
* añadir o eliminar objetos;
* asignar o retirar aliado;
* modificar variables narrativas;
* cambiar el estado del sueño;
* determinar la siguiente carta;
* aplicar efectos simples permitidos.

No deberá interpretar texto narrativo ni controlar animaciones.

Las consecuencias deben estar declaradas mediante datos estructurados, no mediante llamadas arbitrarias incrustadas en cada carta.

---

## 6.6 SaveService

Responsabilidad:

Guardar y cargar el estado de partida.

El sistema utilizará una única partida automática.

No existirán inicialmente:

* múltiples ranuras;
* nombres de partida;
* selector de guardados;
* guardado manual;
* checkpoints elegibles;
* sincronización en la nube.

El guardado se realizará en un punto seguro del flujo:

```text
Resolver encuentro
        ↓
Aplicar consecuencias
        ↓
Aplicar descanso
        ↓
Determinar siguiente carta
        ↓
Actualizar GameState
        ↓
Guardar
        ↓
Mostrar siguiente carta
```

El jugador percibirá un guardado continuo entre cartas.

La partida guardada deberá conservar solo estado mutable y referencias lógicas.

No deberá serializar copias completas de los Resources de contenido.

---

## 6.7 AudioController

Responsabilidad:

Gestionar la reproducción de:

* música;
* ambiente;
* efectos sonoros.

Estructura mínima prevista:

* reproductor de música;
* reproductor de ambiente;
* reproductor de efectos.

Funciones permitidas:

* reproducir una pista;
* cambiar de pista;
* realizar fundidos;
* detener audio;
* reproducir un efecto;
* aplicar volumen global o silencio.

No se construirá un sistema de mezcla adaptativa complejo.

El silencio es un estado válido y deliberado.

---

# 7. Componentes de presentación

## 7.1 GameScreen

Responsabilidad:

Contener y organizar la presentación principal del juego.

Estructura conceptual:

```text
GameScreen
├── DreamBackground
├── CardLayer
│   └── CardView
├── HUD
│   ├── ProtagonistStatus
│   ├── AllyStatus
│   └── InventoryView
├── DiceLayer
│   └── DiceTray
└── TransitionLayer
```

La jerarquía final podrá variar durante el montaje de la escena, pero las responsabilidades deberán conservarse.

---

## 7.2 CardView

Responsabilidad:

Representar visualmente una carta.

Debe poder mostrar:

* ilustración;
* título, si existe;
* texto narrativo;
* opciones;
* información visual de amenaza;
* estados temporales de interacción.

Debe poder reproducir un conjunto reducido de transiciones reutilizables.

Presets conceptuales:

* aparición normal;
* fundido;
* caída;
* ruptura;
* presencia.

La carta puede:

* desplazarse;
* escalar;
* rotar ligeramente;
* aparecer mediante fade;
* salir de la pantalla;
* revelar texto y opciones de forma secuencial.

No utilizará simulación física ni perspectiva 3D.

La animación se resolverá mediante `Tween`, `AnimationPlayer` o una combinación sencilla de ambos.

---

## 7.3 DiceTray

Responsabilidad:

Presentar visualmente las tiradas.

No calcula resultados.

Recibe del sistema lógico:

* número de dados;
* propietario o categoría;
* color;
* cara final;
* efectos especiales.

Después:

* instancia los dados necesarios;
* reproduce la animación;
* muestra el resultado;
* comunica cuándo ha terminado la representación.

---

## 7.4 Dado 2D

Se utilizará un asset animado 2D adquirido previamente.

El dado deberá envolverse en una escena reutilizable.

Responsabilidades:

* reproducir la animación de lanzamiento;
* mostrar la cara final indicada;
* aplicar el color correspondiente;
* representar símbolos;
* emitir una señal al finalizar.

El shader del asset podrá diferenciar visualmente:

* protagonista;
* aliado;
* amenaza.

La lógica calculará el resultado antes de que la animación termine.

No se utilizarán físicas para determinar el resultado.

---

## 7.5 DreamBackground

Responsabilidad:

Representar visualmente el estado del sueño detrás de la carta.

Implementación inicial:

* `ColorRect` a pantalla completa;
* `ShaderMaterial`;
* shader `canvas_item`.

El fondo podrá representar estados como:

* vacío;
* calma;
* inquietud;
* peligro;
* recuerdo;
* presencia.

El primer estado visual previsto será un remolino suave de nubes, niebla o humo.

La carta aparecerá desde el fondo y se colocará frente al jugador mientras el remolino continúa moviéndose lentamente.

---

## 7.6 Restricción de rendimiento del shader

El shader de fondo deberá ser visualmente expresivo, pero técnicamente contenido.

Se priorizarán:

* texturas de ruido;
* deformación UV;
* pocas capas;
* animación mediante `TIME`;
* parámetros reutilizables;
* interpolaciones entre estados.

Se evitarán:

* ray marching;
* blur multipaso;
* lectura reiterada de pantalla;
* bucles largos;
* ruido procedural excesivamente complejo;
* un número innecesario de octavas;
* múltiples shaders simultáneos a pantalla completa.

Se podrá adaptar un shader existente de GDShaders siempre que:

* su licencia sea compatible;
* quede registrada su procedencia;
* sea revisado técnicamente;
* pueda simplificarse;
* supere una prueba de rendimiento en la resolución objetivo.

Jack o Butch podrán realizar una revisión específica del shader antes de consolidarlo.

---

## 7.7 HUD

Responsabilidad:

Mostrar únicamente información necesaria para tomar decisiones.

Contenido previsto:

* estado del protagonista;
* estado del aliado;
* inventario reducido;
* símbolos o valores esenciales.

La UI debe favorecer la lectura.

No deberá competir con la carta mediante:

* paneles grandes;
* animaciones constantes;
* exceso de iconos;
* barras redundantes;
* información no accionable.

Los dados solo estarán visibles durante una resolución.

---

## 7.8 TransitionLayer

Responsabilidad:

Controlar transiciones globales.

Funciones previstas:

* fundido a negro;
* oscurecimiento;
* pausa entre cartas;
* cobertura temporal durante cambios;
* transición al menú;
* transición al desenlace.

El final del juego utilizará un fundido a negro.

No se requiere una cinemática final.

---

# 8. Menú principal

El menú principal será deliberadamente minimalista.

Elementos previstos:

```text
TÍTULO

CONTINUAR
NUEVA PARTIDA

PANTALLA COMPLETA

SALIR
```

`CONTINUAR` solo aparecerá o estará habilitado cuando exista una partida guardada válida y no completada.

No existirá una escena independiente de opciones.

La alternancia entre ventana y pantalla completa se realizará desde el propio menú.

Podrá incluirse un control mínimo de audio únicamente si durante las pruebas resulta necesario.

---

# 9. Pausa

El juego no necesita una pausa tradicional debido a su naturaleza estática y basada en lectura.

La tecla de pausa o `Escape` podrá mostrar un overlay mínimo con:

* continuar;
* volver al menú principal;
* salir.

No se desarrollará una escena compleja de pausa.

---

# 10. Tipografía y legibilidad

La lectura constituye una parte central de la experiencia.

La selección tipográfica deberá priorizar:

* claridad;
* tamaño suficiente;
* contraste;
* espaciado;
* legibilidad en 1920 × 1080;
* licencias libres y verificables.

Podrán utilizarse dos familias:

* una fuente de interfaz muy legible;
* una fuente narrativa con personalidad moderada.

La estética nunca deberá reducir la comodidad de lectura.

Todas las fuentes deberán registrarse mediante el sistema de trazabilidad de assets.

---

# 11. Gestión de assets

Los assets externos o generados deberán documentarse.

Categorías previstas:

* ilustraciones generadas mediante IA;
* iconos;
* retratos;
* dado 2D adquirido;
* shaders de terceros;
* fuentes;
* música;
* ambientes;
* efectos sonoros;
* voz procesada;
* elementos promocionales.

Cada asset deberá conservar, cuando corresponda:

* nombre;
* tipo;
* origen;
* autor o herramienta;
* licencia;
* URL;
* fecha;
* evidencia;
* modificaciones;
* uso previsto;
* estado.

La utilidad de trazabilidad de assets podrá emplearse como parte práctica del experimento.

---

# 12. Audio y voz

El contenido sonoro deberá mantenerse reducido.

Se utilizarán:

* pocas pistas reutilizables;
* ambientes;
* efectos breves;
* silencio;
* voz opcional y limitada.

No se narrarán las 30–40 cartas.

La voz podrá reservarse para:

* frases concretas;
* pensamientos;
* aperturas;
* rupturas;
* momentos de especial importancia.

Las grabaciones originales deberán conservarse limpias antes de aplicar procesamiento.

---

# 13. Exportación y publicación

La arquitectura deberá permitir generar una build funcional para escritorio sin procesos externos complejos.

La publicación inicial se orientará a itch.io.

Steam podrá prepararse dentro del objetivo pedagógico del experimento, pero no debe obligar a ampliar el juego ni retrasar una primera publicación funcional.

La compatibilidad Web se comprobará al final.

---

# 14. Primer corte vertical

La primera implementación no deberá intentar construir el juego completo.

Debe validar el flujo mínimo.

## Corte A — Presentación

```text
Abrir juego
    ↓
Menú principal
    ↓
Nueva partida
    ↓
Remolino de fondo
    ↓
Aparición animada de la primera carta
    ↓
Mostrar texto
    ↓
Mostrar opción «Saltar»
    ↓
Animar salida de la carta
    ↓
Cambiar estado del fondo
    ↓
Mostrar segunda carta
```

Este corte valida:

* bootstrap;
* menú;
* Resources de carta;
* `CardView`;
* transiciones;
* shader;
* audio básico;
* flujo entre cartas.

---

## Corte B — Resolución

La siguiente ampliación deberá añadir una carta con:

* una decisión;
* selección de participantes;
* un dado de personaje;
* un objetivo fijo declarado por la carta;
* animación 2D;
* neutralización y conservación de progreso entre rondas;
* daño por ronda fallida;
* uso de un objeto consumible de protección;
* consecuencia;
* modificación de Salud;
* descanso;
* autoguardado.

Este corte valida prácticamente todo el núcleo técnico.

---

# 15. Orden de implementación

Orden propuesto:

1. Crear proyecto y configuración 1920 × 1080.
2. Crear menú principal.
3. Crear `CardResource`.
4. Crear `CardView`.
5. Implementar transición entre dos cartas.
6. Integrar fondo con shader básico.
7. Crear `GameState`.
8. Crear `GameController`.
9. Integrar autoguardado.
10. Definir dados mediante Resources.
11. Integrar el dado animado 2D.
12. Implementar `ThreatResolver`.
13. Implementar `ConsequenceExecutor`.
14. Añadir HUD e inventario.
15. Añadir audio.
16. Completar contenido.
17. Pulir.
18. Exportar.
19. Publicar.

El orden podrá ajustarse durante la implementación, pero el primer corte vertical deberá mantenerse pequeño.

---

# 16. Elementos fuera del alcance técnico

No se implementarán:

* 3D;
* físicas de dados;
* editor de cartas;
* editor de nodos narrativos;
* scripting embebido en cartas;
* lenguaje de condiciones complejo;
* base de datos;
* servidor;
* multijugador;
* telemetría;
* sistema de mods;
* localización completa;
* múltiples perfiles;
* múltiples ranuras de guardado;
* opciones gráficas avanzadas;
* sistema de resolución adaptable por plataforma;
* herramientas procedurales de generación de contenido.

---

# 17. Riesgos técnicos

## Riesgo 1 — Sobrecargar los Resources

Mitigación:

Mantenerlos declarativos y sin lógica de presentación.

---

## Riesgo 2 — Convertir GameController en un objeto central excesivo

Mitigación:

Delegar resolución, consecuencias, guardado, audio y presentación.

---

## Riesgo 3 — Shader demasiado costoso

Mitigación:

Partir de una base sencilla, medir en 1920 × 1080 y reducir capas antes de añadir complejidad.

---

## Riesgo 4 — Animación que perjudique la lectura

Mitigación:

Movimiento expresivo durante entradas y salidas; estabilidad durante la lectura.

---

## Riesgo 5 — Crecimiento del contenido técnico

Mitigación:

No crear herramientas para producir 40 cartas si los Resources nativos permiten hacerlo directamente.

---

## Riesgo 6 — Compatibilidad Web

Mitigación:

Considerarla objetivo secundario y evaluarla después de disponer de una build de escritorio estable.

---

## Riesgo 7 — Arquitectura prematuramente reutilizable

Mitigación:

Construir primero el juego. Documentar el Narrative Core reutilizable únicamente después de validarlo.

---

# 18. Criterio de aceptación

Los fundamentos técnicos se considerarán validados cuando exista una secuencia jugable que permita:

* iniciar una partida;
* cargar una carta desde un Resource;
* mostrarla mediante una transición;
* elegir una opción;
* seleccionar participantes;
* realizar una tirada;
* representar la tirada mediante dados 2D;
* resolver la amenaza;
* aplicar una consecuencia;
* actualizar el estado;
* guardar;
* continuar con otra carta.

Si esta secuencia funciona sin lógica incrustada en la UI y sin sistemas adicionales, el chasis técnico será suficiente para continuar la producción.

---

# 19. Principio final

> **Una escena principal, un estado de partida, contenido definido mediante Resources, un resolutor de amenazas, un ejecutor de consecuencias y una presentación 2D cuidada deben ser suficientes para construir el juego completo.**
