# 02_game_loop.md

# Game Loop

## Objetivo

El jugador atraviesa una sucesión de escenas independientes dentro de un sueño que no obedece las reglas de la realidad.

Cada escena se presenta mediante una carta que describe una situación, plantea una decisión y, cuando existe incertidumbre, resuelve el resultado mediante un sistema único de dados.

No existe separación entre exploración, eventos y combate.

Todo se considera un **encuentro**.

---

# Filosofía

Cada carta representa un instante del viaje.

Puede tratarse de:

- una criatura;
- una conversación;
- una puerta imposible;
- una pesadilla;
- un recuerdo;
- una decisión moral;
- un lugar.

Todas utilizan exactamente el mismo sistema de resolución.

La diferencia entre unas y otras es únicamente narrativa.

---

# Bucle principal

```text
Nueva carta
      ↓
Leer la situación
      ↓
Elegir una decisión
      ↓
Si existe una Amenaza:
seleccionar participantes
      ↓
Resolver la Amenaza, si existe
      ↓
Aplicar consecuencias
      ↓
Aplicar descanso, si corresponde
      ↓
Actualizar estado persistente
      ↓
Siguiente carta
```

Este ciclo constituye la totalidad de la experiencia jugable.

---

# Flujo de una carta

## 1. Presentación

Se muestra una ilustración acompañada por un texto que describe la situación actual.

La carta representa una escena completa.

No existen mapas ni exploración espacial entre encuentros.

---

## 2. Decisión

El jugador elige cómo afrontar la situación.

Ejemplos:

- Saltar.
- Hablar.
- Observar.
- Abrir.
- Esperar.
- Alejarse.

No todas las cartas necesitan varias opciones.

En ocasiones únicamente existirá una acción posible.

---

## 3. Selección de participantes

Cuando una carta contiene una Amenaza, el jugador decide quién interviene antes de comenzar su resolución.

Opciones posibles:

- únicamente el protagonista;
- protagonista y aliado.

El aliado nunca participa automáticamente.

Su utilización forma parte de la decisión táctica del jugador.

---

## 4. Resolución

Si la carta presenta incertidumbre, declara:

- un símbolo objetivo;
- una cantidad base requerida;
- el daño por ronda fallida;
- cualquier consecuencia narrativa especial.

El objetivo es fijo y conocido antes de seleccionar participantes.

Si participa también el aliado, la cantidad requerida se duplica.

Cada participante lanza su único dado de personaje.

Cada unidad obtenida del símbolo requerido neutraliza una unidad del objetivo.

El progreso neutralizado se conserva entre rondas.

Si quedan unidades pendientes:

- la carta aplica su daño;
- resuelve los efectos especiales indicados;
- comienza una nueva ronda con el objetivo restante.

Una carta puede declarar como consecuencia especial que una ronda fallida termine el encuentro y conduzca a otra carta.

Cuando esto sucede, el daño se aplica una sola vez, se descarta el progreso de la Amenaza y no comienza otra ronda.

No se lanzan Dados de Amenaza.

La resolución utiliza siempre el mismo sistema, independientemente de que la amenaza represente:

- una criatura;
- un obstáculo;
- una conversación;
- un fenómeno imposible;
- una situación psicológica.

---

## 5. Descanso

Cuando existe un aliado y el jugador decide que no participe en una Amenaza:

- descansa durante todo el encuentro;
- no recibe beneficios derivados de la resolución;
- recupera **1 punto de Salud** al finalizar la carta.

El descanso se resuelve una vez por encuentro, no una vez por ronda.

Solo existe descanso cuando el jugador excluye voluntariamente al aliado durante la selección de participantes.

Si el aliado fue seleccionado y una consecuencia le impide actuar durante una ronda, continúa siendo participante:

- no descansa;
- no recupera Salud por descanso.

Esto introduce una decisión permanente entre:

- aumentar las probabilidades de éxito;
- conservar recursos para encuentros posteriores.

---

## 6. Consecuencias

La carta aplica el resultado obtenido.

Las consecuencias pueden incluir:

- pérdida o recuperación de Salud;
- obtención o pérdida de objetos;
- incorporación de un aliado;
- modificación de variables narrativas;
- desbloqueo de nuevas cartas;
- cambios en el estado del sueño.

Cada encuentro deja una huella persistente sobre la partida.

---

## 7. Persistencia

Al finalizar una carta únicamente permanece aquello que resulta relevante para el resto de la aventura.

Entre encuentros se conservan:

- Salud del protagonista;
- aliado actual;
- Salud del aliado;
- inventario;
- variables narrativas imprescindibles;
- estado visual o narrativo del sueño.

Atención, Fuerza y Cordura son símbolos de los dados, no valores numéricos persistentes.

La propia carta desaparece.

El viaje continúa sobre el nuevo estado generado.

---

# Principios de diseño

- Un único sistema resuelve cualquier situación.
- Las cartas representan escenas, no niveles.
- Las decisiones siempre producen consecuencias.
- El jugador administra riesgos, no acciones complejas.
- El aliado amplía posibilidades sin aumentar la complejidad del sistema.
- El estado del mundo evoluciona carta tras carta.

---

# Resumen

El juego completo puede resumirse en una única frase:

> **Leer una situación, tomar una decisión, afrontar la amenaza y vivir sus consecuencias antes de continuar el viaje por el sueño.**
