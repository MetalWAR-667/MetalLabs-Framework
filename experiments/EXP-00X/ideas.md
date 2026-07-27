Final.

## Fade a negro como final

el final va a ser un fundido a negro XD

😂

Y cuanto más lo pienso...

más me gusta.

Porque sería tremendamente coherente.

El jugador lleva todo el juego intentando despertar.

Descubre reglas.

Hace sacrificios.

Acepta lo imposible.

Salta al vacío.

Olvida recuerdos.

Rompe pactos.

Encuentra puertas.

Aprende cómo piensa el sueño.

Y cuando por fin...

cree haber encontrado la salida...

La pantalla funde lentamente a negro.

Silencio.

Nada.

Durante unos segundos.

Y entonces...

Los créditos.

Sin explicación.

Sin "Has ganado".

Sin una escena donde despierta en una cama.

Sin revelar si todo era real.

Porque eso sería traicionar todo lo que has construido.

Hay una frase de diseño que me encanta para este proyecto.

El juego termina exactamente donde empiezan las respuestas.

Nunca las damos.

Y aquí vuelvo a Dunsany y Lovecraft.

Ambos entendían algo muy difícil.

El misterio deja de ser misterio en el instante en que lo explicas.

Así que...

¿Despertó?

No lo sabemos.

¿Murió?

No lo sabemos.

¿Escapó?

No lo sabemos.

¿Solo cambió de sueño?

No lo sabemos.

El fundido a negro es la única respuesta honesta.

Y, además, tiene otra ventaja muy MetalLab.

😂

Cuesta exactamente cero euros producirlo.

Pero, sobre todo, respeta el alcance. No necesitas una cinemática final, un epílogo ni una explicación cosmológica. Basta con que el último evento haya llevado al jugador hasta un punto donde él crea que ha encontrado la salida.

Entonces...

Fundido.

Negro.

Silencio.

Y una última frase, si decides poner una:

"...o eso creyó."

O incluso ninguna.

Solo negro.

Creo que sería un final muy fiel a todo lo que hemos hablado esta noche: no cerrar el misterio, sino dejar que el jugador salga del juego con la misma sensación con la que entró el protagonista... dudando de qué acaba de experimentar.


## # Semillas de presentación, música e interfaz

## Principio general

El proyecto utilizará una presentación minimalista.

La mayor parte de la pantalla estará ocupada por la carta activa: ilustración, texto y decisiones.

La interfaz no debe competir con la escena ni convertirse en un conjunto de paneles tradicionales. Cada elemento visible debe cumplir una función narrativa además de funcional.

La intención es que la presentación completa parezca un pequeño escenario donde la carta, el fondo, el sonido y los dados reaccionan al estado del sueño.

---

## La carta como espacio principal

Cada carta representa una situación, una pesadilla, un instante o un lugar.

La carta puede incluir:

* una ilustración;
* una descripción breve;
* una o varias decisiones;
* una prueba opcional;
* una consecuencia;
* cambios persistentes.

No es necesario construir escenarios explorables ni secuencias animadas complejas.

Una sola ilustración, acompañada por texto y sonido, debe ser suficiente para sostener la escena.

La primera carta podría representar el despertar del protagonista sobre una plataforma suspendida en el vacío.

La única opción disponible sería:

> **Saltar.**

Esta decisión introduce la primera ley del sueño:

> **Aceptar lo imposible permite avanzar.**

---

## Fondo dinámico mediante shaders

Detrás de la carta puede existir un fondo animado mediante shaders.

Este fondo no representa necesariamente un lugar físico.

Representa el estado del sueño.

El shader puede cambiar cuando:

* el protagonista atraviesa una transición;
* aparece una situación de peligro;
* se altera una ley del sueño;
* regresa un recuerdo;
* aumenta la inestabilidad;
* una presencia se aproxima;
* cambia el estado persistente del personaje.

Posibles estados visuales:

### Vacío

Movimiento lento, profundidad indefinida, tinta o niebla suspendida.

### Inquietud

Pequeñas distorsiones, pulsaciones o deformaciones apenas perceptibles.

### Peligro

Mayor velocidad, ruptura del ritmo, contraste o desplazamientos anómalos.

### Recuerdo

Aparición limitada de color o formas reconocibles.

### Presencia

Cambios de sombra, orientación o movimiento que sugieran que algo observa desde fuera de la carta.

El shader nunca debe distraer de la ilustración.

Debe sentirse como la respiración del sueño.

---

## La interfaz como estado del mundo

La UI no debe limitarse a informar mediante barras, porcentajes o paneles.

Siempre que sea posible, el estado debe percibirse directamente.

Ejemplos:

* la inestabilidad se representa mediante deformación;
* el peligro modifica el comportamiento del fondo;
* el recuerdo introduce color;
* la presencia altera sombras o movimiento;
* el deterioro vuelve menos fiable la propia interfaz.

Principio propuesto:

> **La interfaz no informa al jugador del estado del sueño. La interfaz es el propio sueño.**

---

## Uso narrativo del color

Las primeras ilustraciones pueden utilizar un estilo monocromático inspirado en grabados, ilustraciones clásicas y antiguos módulos de aventuras.

El blanco y negro representa el estado natural del sueño.

El color aparecerá de manera gradual y deliberada.

No debe utilizarse como decoración, sino como acontecimiento narrativo.

Una única zona de color puede representar:

* una anomalía;
* un recuerdo;
* una grieta;
* una verdad;
* la influencia de una entidad;
* una alteración de las leyes del sueño.

La aparición del color debe ser escasa para conservar su fuerza.

---

## Dados y pruebas

Los dados solo aparecerán cuando exista incertidumbre real.

No permanecerán visibles de forma constante.

Secuencia posible:

1. El jugador elige una opción.
2. La carta permanece en pantalla.
3. El fondo se detiene o modifica su ritmo.
4. Aparecen los dados.
5. Se resuelve la prueba.
6. Los dados desaparecen.
7. La consecuencia transforma la carta o conduce a la siguiente.

La tirada debe sentirse como un acontecimiento, no como una operación rutinaria.

Los dados representan la intervención del azar o del propio sueño.

---

## Inventario mínimo

El inventario, si existe, debe ser extremadamente reducido.

No se plantea una mochila tradicional.

El protagonista podría conservar un número muy limitado de elementos, por ejemplo tres espacios.

Estos elementos no tienen por qué ser objetos convencionales.

Pueden ser:

* recuerdos;
* símbolos;
* fragmentos;
* conocimientos;
* promesas;
* marcas;
* pequeñas anomalías.

Ejemplos visuales:

* una llave;
* un hilo rojo;
* una pluma;
* una máscara;
* una lágrima;
* una moneda sin rostro;
* el nombre de alguien.

El inventario no representa lo que el protagonista transporta.

Representa lo que el sueño todavía no ha conseguido quitarle.

---

## Música generada mediante IA

La música podrá producirse mediante herramientas gestionadas como Suno u otras plataformas similares.

No se pretende construir un pipeline técnico propio ni mantener infraestructuras complejas.

La herramienta debe ahorrar tiempo y mantener el proceso divertido.

Principio:

> **Utilizar herramientas sencillas cuando construir el proceso no aporte aprendizaje relevante al experimento.**

La dirección musical se definirá antes que los prompts.

Características candidatas:

* ambientación lenta;
* drones discretos;
* piano preparado o notas aisladas;
* cuerdas contenidas;
* coros lejanos;
* campanas;
* reverberaciones amplias;
* silencios prolongados;
* ausencia de percusión épica;
* ausencia de terror basado en sobresaltos.

No será necesario producir una pista distinta para cada carta.

Un pequeño conjunto de ambientes podrá reutilizarse según el estado del sueño.

Posibles categorías:

* despertar;
* contemplación;
* vacío;
* inquietud;
* presencia;
* recuerdo;
* aceptación;
* final.

---

## El silencio

El silencio debe considerarse parte de la banda sonora.

No todas las cartas necesitan música.

Una carta puede funcionar únicamente con:

* viento;
* respiración;
* ruido lejano;
* vibraciones;
* silencio absoluto.

La aparición de una melodía después de varias cartas silenciosas puede tener más fuerza que una banda sonora constante.

---

## Voz

La voz del propio desarrollador podría utilizarse de manera limitada.

No sería necesario narrar todas las cartas.

La voz podría aparecer únicamente en:

* pensamientos breves;
* recuerdos;
* momentos de ruptura;
* frases especialmente importantes;
* cartas concretas.

Herramientas como ElevenLabs podrían emplearse para procesar la grabación, mantener consistencia o realizar ajustes moderados de tono y textura.

La intención sería conservar la interpretación original, no sustituirla por una voz genérica.

La grabación deberá conservarse siempre limpia antes de añadir:

* reverberación;
* eco;
* distorsión;
* compresión;
* modificación de pitch;
* tratamiento ambiental.

La voz puede evolucionar ligeramente a medida que avanza el juego, siempre de forma sutil.

---

## Economía de producción

Cada elemento debe cumplir varias funciones.

* La carta representa la escena.
* La ilustración construye el lugar.
* El texto transmite percepción y pensamiento.
* El shader comunica el estado del sueño.
* El color comunica anomalías.
* Los dados representan incertidumbre.
* Los símbolos conservan memoria.
* La música construye atmósfera.
* El silencio genera tensión.
* La voz introduce presencia humana.

Esta combinación permite construir una identidad reconocible sin ampliar el alcance mediante mapas, cinemáticas, combate, animaciones complejas o una interfaz extensa.

---

## Regla de alcance

La presentación debe mantenerse compatible con el presupuesto temporal de cuatro semanas y un máximo previsto de seis.

Si una idea visual o sonora requiere:

* construir herramientas complejas;
* mantener pipelines externos;
* producir animaciones extensas;
* crear una pista por carta;
* narrar todo el contenido;
* desarrollar un inventario completo;
* convertir los shaders en un subsistema enorme;

deberá simplificarse o descartarse.

La intención artística debe reforzar el microjuego.

Nunca convertirlo en otro proyecto de largo recorrido.
