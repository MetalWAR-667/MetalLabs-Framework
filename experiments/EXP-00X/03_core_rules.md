# 03_core_rules.md

# Core Rules

## Objetivo

Este documento define las reglas fundamentales del microjuego.

Todas las cartas, independientemente de que representen una criatura, un obstáculo, una conversación o una anomalía, utilizan el mismo sistema de resolución.

El juego no dispone de un subsistema independiente de combate.

Toda situación incierta se resuelve como una **Amenaza**.

---

# 1. Estado de los personajes

Los personajes utilizan tres capacidades:

- **Atención**
- **Fuerza**
- **Cordura**

Además, cada personaje dispone de **Salud**.

Las tres capacidades aparecen como símbolos en los dados y permiten resolver Amenazas.

La Salud no aparece como símbolo. Representa el desgaste del personaje y constituye el indicador de derrota.

---

## 1.1 Atención

Representa la capacidad para:

- observar;
- interpretar;
- anticipar;
- descubrir anomalías;
- comprender situaciones;
- actuar con astucia.

El término utilizado por el sistema será **Atención**.

Las referencias anteriores a *Astucia* se consideran parte del mismo concepto y deberán normalizarse durante la documentación.

---

## 1.2 Fuerza

Representa la capacidad para:

- resistir físicamente;
- ejercer fuerza;
- superar obstáculos;
- enfrentarse directamente a una amenaza;
- soportar situaciones de agotamiento.

---

## 1.3 Cordura

Representa la capacidad para:

- soportar situaciones imposibles;
- conservar el control;
- resistir el miedo;
- afrontar horrores;
- aceptar o comprender las leyes del sueño.

La Cordura es una capacidad de resolución, no una segunda barra de vida.

---

## 1.4 Salud

Representa el estado físico y el desgaste acumulado de cada personaje.

La Salud puede:

- reducirse como consecuencia de una carta;
- protegerse mediante el objeto Escudo u otros objetos permitidos;
- recuperarse mediante descanso;
- recuperarse mediante determinados objetos.

La Salud es el único recurso general cuya pérdida conduce a la derrota.

Los valores máximos iniciales y las condiciones exactas aplicables al aliado se determinarán durante el ajuste de equilibrio.

---

# 2. Personajes

## 2.1 Protagonista

El jugador comienza la partida controlando únicamente al protagonista.

El protagonista posee un dado personalizado de seis caras:

| Cara | Resultado |
|---:|---|
| 1 | Fuerza |
| 2 | Cordura |
| 3 | Atención |
| 4 | Cordura |
| 5 | Atención ×2 |
| 6 | Cordura |

Esta distribución define al protagonista como alguien más preparado para soportar y comprender el sueño que para imponerse mediante fuerza física.

---

## 2.2 Aliado

El jugador puede disponer de **un único aliado**.

Nunca existe una party de varios compañeros.

Cada aliado posee:

- su propio dado de seis caras;
- una distribución característica de los mismos símbolos;
- Salud propia;
- una identidad narrativa;
- una especialización sencilla.

El aliado amplía las posibilidades del jugador sin introducir un sistema de grupo complejo.

---

## 2.3 Incorporación de un aliado

Determinadas cartas pueden presentar un posible aliado.

La incorporación puede depender de:

- una decisión;
- una prueba;
- una consecuencia narrativa.

Si se cumplen las condiciones de la carta, el aliado pasa a acompañar al protagonista.

Si el jugador ya dispone de aliado, cualquier sustitución deberá resolverse de forma explícita y nunca permitirá conservar más de uno.

---

# 3. Dados de personaje

Cada personaje participante aporta un único dado:

- **1 dado**, si participa solo el protagonista;
- **2 dados**, si participan protagonista y aliado.

Los dados de personaje utilizan tres símbolos de capacidad:

- Fuerza;
- Cordura;
- Atención.

Algunas caras pueden producir más de una unidad del mismo símbolo.

Cada unidad obtenida neutraliza una unidad equivalente del objetivo de la carta.

No se añaden dados por nivel, progresión o estadísticas permanentes. Cualquier excepción debe proceder de un objeto sencillo y explícito.

---

## 3.1 Dados de aliado

Los aliados utilizan el mismo lenguaje de símbolos que el protagonista.

Su especialización se expresa únicamente mediante una distribución diferente de caras y resultados.

No necesitan habilidades, clases ni reglas de resolución propias.

La composición exacta de cada dado deberá validarse mediante pruebas de equilibrio.

---

# 4. Objetivo de la carta

Cada carta de Amenaza declara:

- un **símbolo objetivo**;
- una **cantidad requerida**;
- el **daño por ronda fallida**;
- cualquier consecuencia narrativa especial.

Ejemplo:

```text
Objetivo:
ATENCIÓN ×2

Daño:
2 Salud
```

El objetivo es fijo y conocido por el jugador antes de decidir quién participa.

No se lanzan Dados de Amenaza.

La dificultad procede de:

- el símbolo exigido;
- la cantidad requerida;
- la distribución de los dados de los personajes;
- el daño visible de la carta;
- las consecuencias especiales narradas por la propia carta.

La dificultad no se incrementará añadiendo subsistemas o reglas propias para cada Amenaza.

---

## 4.1 Escalado por participación

La carta define el objetivo base para un personaje.

Si participa también el aliado, la cantidad requerida se duplica.

Ejemplo:

```text
Objetivo base:
ATENCIÓN ×1

Protagonista solo:
ATENCIÓN ×1

Protagonista y aliado:
ATENCIÓN ×2
```

El aliado aporta un segundo dado, pero la Amenaza también aumenta su exigencia.

La decisión no consiste únicamente en lanzar más dados, sino en valorar:

- las distribuciones de ambos personajes;
- el daño que puede producir la carta;
- la Salud disponible;
- el beneficio del encuentro;
- la posibilidad de que el aliado descanse.

---

# 5. Resolución de una Amenaza

## 5.1 Preparación

Cuando una carta contiene una Amenaza:

1. La carta muestra su objetivo y el daño por fallo.
2. El jugador decide si participa solo el protagonista o también el aliado.
3. Se ajusta la cantidad del objetivo al número de participantes.
4. Los personajes participantes lanzan sus dados.

La elección de participantes se mantiene durante todo el encuentro.

---

## 5.2 Neutralización

Cada unidad del símbolo requerido obtenida por los personajes neutraliza una unidad equivalente del objetivo.

Los símbolos neutralizados se conservan entre rondas.

Los resultados que no coincidan con el objetivo no generan progreso.

Ejemplo:

```text
Objetivo:
ATENCIÓN ×2

Primera ronda:
ATENCIÓN ×1

Objetivo restante:
ATENCIÓN ×1
```

---

## 5.3 Ronda superada

Si los personajes neutralizan todas las unidades requeridas, la Amenaza concluye inmediatamente.

La carta aplica su resultado de éxito y los participantes obtienen los beneficios que correspondan.

---

## 5.4 Ronda fallida

Si al terminar la tirada permanecen unidades sin resolver:

1. se conserva el progreso obtenido;
2. la carta aplica su daño;
3. se resuelve cualquier efecto especial indicado;
4. comienza una nueva ronda con el objetivo restante.

La Amenaza funciona así como una carrera de desgaste, no como una única comprobación binaria.

Como excepción explícita, una carta puede indicar que una ronda fallida termina el encuentro y conduce a otra carta.

En ese caso:

- el daño por ronda fallida se aplica una sola vez;
- se descarta el progreso acumulado de la Amenaza;
- no comienza una nueva ronda;
- se establece la carta de destino declarada.

---

# 6. Daño y consecuencias

## 6.1 Daño

El daño de cada carta reduce exclusivamente la **Salud**.

La cantidad de daño por ronda fallida se muestra de forma visible en la esquina inferior derecha de la carta.

El jugador conoce el riesgo antes de decidir si incorpora al aliado o permite que descanse.

La asignación del daño entre los participantes debe ser sencilla, visible y definida de forma explícita por la carta o por una única regla general pendiente de balance.

---

## 6.2 Consecuencias especiales

Una carta puede narrar una consecuencia distinta o adicional al daño, por ejemplo:

- perder un objeto porque una criatura lo roba;
- impedir que un personaje actúe durante la siguiente ronda;
- impedir temporalmente el uso de objetos;
- modificar una variable narrativa;
- acceder a otra carta;
- cambiar el estado del sueño.

Estas consecuencias pertenecen a la carta.

No crean barras de recursos, estados alterados ni subsistemas generales nuevos.

Cuando la consecuencia deja de ser relevante para esa situación, desaparece.

Impedir que un personaje actúe durante una ronda no modifica la elección de participantes realizada al comenzar la Amenaza.

Un personaje incapacitado continúa siendo participante y no se considera que esté descansando.

---

## 6.3 Beneficios

Al superar una Amenaza, la carta puede conceder:

- recuperación de Salud;
- obtención de un objeto;
- incorporación de un aliado;
- modificación de una variable narrativa;
- acceso a otra carta;
- cambio del estado del sueño.

No todas las cartas necesitan ofrecer un beneficio material.

---

# 7. Escudo y protección

**Escudo** es un objeto consumible.

Cuando el jugador decide utilizarlo, evita una unidad de daño de una ronda fallida.

El Escudo:

- ocupa espacio en el inventario;
- se elimina del inventario después de proteger contra una unidad de daño;
- no aparece en las caras de los dados;
- no modifica el objetivo ni los símbolos obtenidos;
- no introduce armaduras, resistencias ni cálculos adicionales.

Cuando participan dos personajes, el Escudo protege al destinatario del daño elegido conforme a la asignación declarada por la carta.

---

# 8. Participación y descanso

La elección de participantes se realiza al comenzar la Amenaza y se mantiene hasta que la carta termina.

## 8.1 Protagonista solo

El protagonista aporta su dado.

Si existe un aliado y no participa:

- descansa durante todo el encuentro;
- no recibe beneficios derivados de la resolución;
- recupera **1 punto de Salud** al finalizar la carta.

El descanso solo se produce cuando el jugador decide voluntariamente no incluir al aliado al seleccionar participantes.

Si el aliado fue seleccionado y una consecuencia le impide actuar durante una o varias rondas:

- continúa siendo participante;
- no descansa;
- no recupera Salud por descanso.

---

## 8.2 Protagonista y aliado

Ambos personajes aportan sus dados.

El objetivo de la carta duplica su cantidad.

Ninguno descansa y ambos pueden recibir los beneficios que determine la carta.

---

## 8.3 Descanso

El descanso se resuelve una vez por encuentro, no una vez por ronda.

El descanso:

- no consume turnos;
- no requiere una acción independiente;
- no genera una fase adicional;
- forma parte automática de la resolución de la carta.

La decisión principal es:

> Afrontar una Amenaza con ambos personajes para repartir el riesgo y aprovechar sus dados, o reservar al aliado para que recupere Salud.

---

# 9. Objetos

El juego contendrá un máximo de **10–12 objetos**.

Los objetos tendrán efectos sencillos y comprensibles de inmediato.

No existirán:

- rarezas;
- niveles;
- crafting;
- tiendas;
- mejoras permanentes;
- árboles de objetos;
- economía compleja.

---

## 9.1 Funciones permitidas

Los objetos pueden:

- añadir un dado a una prueba concreta;
- evitar una unidad de daño;
- recuperar Salud;
- modificar de forma sencilla una tirada;
- permitir una interacción específica con una carta.

Cada objeto debe expresar su efecto en una sola frase.

---

## 9.2 Inventario

El inventario será muy reducido.

Cada objeto ocupará uno o varios espacios según su importancia.

Ejemplos iniciales:

### Comida

- Ocupa 1 espacio.
- Recupera 1 punto de Salud.

### Escopeta recortada

- Ocupa 2 espacios.
- Proporciona una ventaja sencilla frente a determinadas Amenazas.

Los valores concretos deberán validarse, pero no se ampliará la complejidad funcional.

---

## 9.3 Objeto inicial

Al comenzar una nueva partida, el jugador elige **uno de tres objetos iniciales disponibles**.

El objeto elegido se añade al inventario antes de mostrar la primera carta.

Si el objeto se consume, se pierde o se entrega, deja de estar disponible para condiciones posteriores.

Esta elección introduce variación entre partidas sin añadir clases, creación de personaje ni equipamiento complejo.

---

# 10. Amenazas de robo

Algunas cartas pueden representar entidades que intentan robar al protagonista.

Si el jugador posee objetos:

- pierde un objeto según la regla indicada por la carta.

Si no posee objetos:

- no se roba ningún objeto;
- se muestra un mensaje indicando que el intento de robo no ha obtenido nada;
- el encuentro finaliza sin una consecuencia alternativa por falta de objetos.

El robo es una consecuencia narrativa de carta, no un subsistema independiente.

---

# 11. Estado persistente

Entre cartas se conservan únicamente:

- Salud del protagonista;
- aliado actual;
- Salud del aliado;
- inventario;
- variables narrativas imprescindibles;
- estado visual o narrativo del sueño.

Atención, Fuerza y Cordura son símbolos de los dados, no valores numéricos persistentes.

No se añadirán nuevos recursos o estados generales durante la producción inicial.

---

# 12. Límites del sistema

El sistema queda limitado a:

- un protagonista;
- un aliado máximo;
- tres símbolos de resolución;
- Salud como único recurso general de desgaste y derrota;
- un dado personalizado por personaje;
- objetivos fijos declarados por las cartas;
- progreso acumulado entre rondas;
- daño visible y definido por cada carta;
- inventario reducido;
- 10–12 objetos;
- consecuencias especiales contenidas en las cartas.

No forman parte del alcance:

- Dados de Amenaza;
- combate táctico independiente;
- iniciativa;
- posicionamiento;
- clases;
- niveles;
- experiencia;
- habilidades activas;
- barras de recursos adicionales;
- sistema general de estados alterados;
- enemigos con reglas propias;
- progresión compleja;
- equipo por ranuras;
- economía;
- crafting.

---

# 13. Principios de diseño

> **El sistema es pequeño. Las cartas son expresivas.**

> **La profundidad debe proceder de decidir quién participa, qué riesgo asumir y cuándo permitir que el aliado descanse; nunca de añadir sistemas nuevos.**

El jugador debe poder responder de inmediato a tres preguntas:

1. ¿Qué símbolo exige la carta?
2. ¿Cuánto daño recibiré si no completo el objetivo esta ronda?
3. ¿Afronto la Amenaza solo o con el aliado?

---

# 14. Elementos pendientes de balance

Los siguientes valores deberán decidirse mediante prototipado y pruebas:

- Salud máxima del protagonista;
- Salud máxima de los aliados;
- condición exacta de derrota o retirada del aliado;
- cantidad máxima práctica de símbolos requeridos;
- asignación del daño cuando participan dos personajes;
- distribuciones definitivas de los dados de aliado;
- tamaño exacto del inventario;
- efecto final de cada uno de los 10–12 objetos;
- condiciones exactas de derrota.

Estos ajustes no pueden introducir nuevas mecánicas.

Solo deben concretar números y comportamientos dentro del sistema definido.
