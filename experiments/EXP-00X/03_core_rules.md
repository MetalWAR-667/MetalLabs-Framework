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
| 5 | Atención |
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

Cada actor posee un dado personalizado de seis caras.

Cada cara representa una única estadística:

- Fuerza;
- Cordura;
- Atención.

Las caras no contienen valores numéricos ni multiplicadores. Una cara produce exactamente un símbolo de la estadística que representa.

La distribución de las seis caras pertenece a los datos del actor y se define mediante su propio `ActorData`.

El dado expresa así las aptitudes del actor sin convertir sus caras en modificadores numéricos.

---

# 4. Opciones y pruebas de la carta

Una carta contiene una o varias opciones.

Cada opción constituye una unidad editorial independiente y define su propia acción y consecuencia.

Cuando una opción requiere una prueba, declara:

- la **estadística requerida**;
- la **cantidad inicial de unidades de Amenaza**;
- el **daño por ronda no resuelta**.

Dos opciones de una misma carta pueden plantear pruebas diferentes. La prueba pertenece a la opción elegida, no al conjunto de la carta.

Por tanto, una carta puede contener varias Amenazas potenciales, pero solo la opción elegida origina la **Amenaza activa**.

Cuando una carta presenta varias opciones, la barra de Amenaza permanece oculta hasta que el jugador selecciona una. En ese momento se revela la estadística y la cantidad correspondientes a la opción elegida.

Una vez iniciada la Amenaza, la decisión queda comprometida hasta resolverla. El jugador puede repetir rondas, pero no cambiar a otra opción de la carta durante la resolución.

Ejemplo:

```text
Estadística:
ATENCIÓN ×1

Daño por ronda no resuelta:
1 Salud
```

La prueba de cada opción es fija. Cuando una carta contiene una única opción con Amenaza, se muestra al presentar la carta; cuando contiene varias opciones, la Amenaza se revela después de seleccionar una.

No se lanzan Dados de Amenaza.

La dificultad procede de:

- la estadística requerida;
- la cantidad inicial de Amenaza;
- la distribución del dado del actor;
- el daño por ronda no resuelta visible al revelar la Amenaza.

La dificultad no se incrementará añadiendo subsistemas o reglas propias para cada prueba.

---

# 5. Resolución de una Amenaza

## 5.1 Preparación

Cuando una opción inicia una prueba:

1. La opción muestra la estadística requerida, la cantidad inicial de Amenaza y el daño por ronda no resuelta.
2. El jugador selecciona la opción.
3. La Amenaza restante se inicializa con la cantidad declarada por la opción elegida.
4. Se lanza el dado del actor participante.

La cantidad restante pertenece al estado runtime del encuentro. No modifica el recurso editorial de la carta.

---

## 5.2 Comprobación

Cada símbolo obtenido que coincida con la estadística requerida elimina una unidad de la Amenaza restante.

Un símbolo que no coincida no reduce la Amenaza.

Las unidades eliminadas se conservan entre rondas mientras permanezca activo el mismo encuentro.

Ejemplo:

```text
Amenaza restante:
ATENCIÓN ×2

Resultado:
ATENCIÓN

Nueva Amenaza restante:
ATENCIÓN ×1
```

En este ejemplo existe progreso, pero la Amenaza todavía no ha sido neutralizada.

---

## 5.3 Amenaza neutralizada

Si la tirada elimina la última unidad y la Amenaza restante llega a cero, la carta queda superada.

La ronda final que neutraliza la Amenaza no aplica daño.

---

## 5.4 Ronda no resuelta

Si después de la tirada todavía queda Amenaza:

1. se conserva cualquier unidad eliminada durante esa tirada;
2. se aplica el daño por ronda no resuelta;
3. la Amenaza permanece activa con su cantidad restante;
4. el jugador puede iniciar otra ronda.

El daño se aplica incluso cuando la tirada eliminó parcialmente una unidad. Solo neutralizar la última unidad evita el daño de esa ronda.

---

## 5.5 Abandono del encuentro

Al abandonar una carta o acceder a otra por una ruta diferente:

- la Amenaza activa termina;
- su cantidad restante se descarta;
- cualquier encuentro posterior con esa carta comienza nuevamente con la cantidad inicial completa.

El progreso se conserva entre rondas del mismo encuentro, pero nunca entre encuentros distintos.

---

# 6. Daño y consecuencias

## 6.1 Daño

El daño de cada carta reduce exclusivamente la **Salud**.

La cantidad de daño por fallo se muestra de forma visible en la esquina inferior derecha de la carta.

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

# 9. Objeto inicial

Al comenzar una nueva partida, el jugador elige exactamente uno de estos tres objetos:

- Comida;
- Escopeta recortada;
- Escudo.

Jack porta únicamente el objeto seleccionado durante la sesión.

El objeto elegido forma parte del estado runtime de la partida. No pertenece a `ActorData` y no modifica la definición de Jack.

La Carta 03, **El Umbral**, será la primera carta que consulte esta referencia.

En el estado actual del proyecto no existe un inventario.

---

# 11. Estado persistente

Entre cartas se conservan únicamente:

- Salud del protagonista;
- aliado actual;
- Salud del aliado;
- objeto inicial seleccionado;
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
- pruebas fijas declaradas por las cartas;
- progreso de Amenaza conservado entre rondas del mismo encuentro;
- daño visible y definido por cada carta;
- un único objeto inicial conservado como estado runtime;
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

> **La profundidad debe proceder de elegir una opción, comprender su riesgo y decidir si volver a intentarlo; nunca de añadir sistemas nuevos.**

El jugador debe poder responder de inmediato a tres preguntas:

1. ¿Qué estadística exige la prueba?
2. ¿Cuántos éxitos necesito?
3. ¿Cuánto daño recibiré si fallo?

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
