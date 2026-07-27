# 10_audio_direction.md

# Audio Direction

## Estado

**Dirección sonora del corte vertical**

Este documento define:

- música;
- ambientes;
- efectos sonoros;
- silencio;
- voz;
- transiciones;
- mezcla;
- producción y trazabilidad.

La dirección visual se define en `09 Art Direction.md`.

La arquitectura de reproducción permanece bajo `AudioController`, descrito en `05 Technical Foundations.md`.

---

# 1. Principio sonoro

El audio debe sugerir un espacio mayor que aquello que aparece en la carta.

No pretende llenar cada segundo.

Su función es:

- dar escala al vacío;
- anticipar presencias;
- separar estados del sueño;
- reforzar tiradas y consecuencias;
- introducir humanidad mediante momentos sonoros concretos;
- utilizar el silencio como recurso activo.

> **El sonido amplía el sueño; el silencio deja que el jugador lo imagine.**

---

# 2. Pilares

## 2.1 Contención

Se utilizará un conjunto pequeño de materiales reutilizables.

No habrá una composición musical exclusiva para cada carta.

## 2.2 Espacio imposible

El audio puede sugerir:

- distancias contradictorias;
- sonidos reproducidos al revés;
- reverberaciones sin espacio reconocible;
- frecuencias que parecen proceder de debajo o detrás;
- fuentes que desaparecen antes de resolverse.

## 2.3 Contraste

Los cambios importantes se comunican mediante contraste:

- ruido frente a silencio;
- grave frente a agudo;
- densidad frente a vacío;
- textura frente a melodía;
- proximidad frente a distancia.

## 2.4 Legibilidad

El sonido nunca debe:

- ocultar la voz;
- fatigar durante la lectura;
- competir con efectos funcionales;
- mantener picos constantes;
- convertir cada carta en un clímax.

---

# 3. Capas

La estructura mínima utiliza tres reproductores conceptuales:

## Música

Material tonal o musical de larga duración.

## Ambiente

Textura continua asociada al lugar o estado del sueño.

## Efectos

Eventos breves:

- opciones;
- carta;
- dados;
- daño;
- objetos;
- transiciones;
- criaturas.

La voz, si se utiliza, puede compartir una ruta sencilla o disponer de una cuarta ruta únicamente si mejora el control de mezcla.

No se construirá un sistema adaptativo complejo.

---

# 4. Música

## 4.1 Carácter

Características candidatas:

- ambientación lenta;
- drones discretos;
- piano preparado;
- notas aisladas;
- cuerdas contenidas;
- coros lejanos;
- campanas;
- reverberaciones amplias;
- silencios prolongados.

Se evitarán:

- percusión épica;
- melodías constantes;
- crescendos en cada Amenaza;
- terror basado en sobresaltos;
- armonías excesivamente sentimentales;
- cambios bruscos sin función narrativa.

## 4.2 Reutilización

Un material musical podrá compartirse entre varias cartas mediante:

- entrada y salida;
- volumen;
- filtrado sencillo;
- combinación con ambientes;
- fragmentos;
- silencio.

No se necesita una pista por carta.

## 4.3 Producción asistida

MetalSon & Has podrán definir partituras o ideas musicales originales.

Herramientas gestionadas como Suno u otras plataformas similares podrán utilizarse para producir o explorar versiones, siempre que:

- la dirección musical exista antes del prompt;
- la licencia permita el uso previsto;
- se conserve evidencia del origen;
- no se conviertan en una dependencia del runtime;
- el resultado pueda editarse y exportarse como un asset normal;
- el proceso ahorre tiempo respecto a construir un pipeline propio.

La herramienta concreta no forma parte de la arquitectura.

---

# 5. Ambientes

Los ambientes sostienen la mayor parte del recorrido.

Pueden incluir:

- viento procesado;
- drones;
- vibración;
- crujidos;
- respiración;
- ruido eléctrico;
- fricción;
- susurros no verbales;
- espacio casi silencioso.

Los loops deben:

- carecer de cortes perceptibles;
- evitar eventos demasiado reconocibles y repetitivos;
- admitir lectura prolongada;
- poder fundirse con otro estado.

---

# 6. Mapa sonoro del corte vertical

## Carta 1 — `cue_despertar`

Función:

- presentar la fractura inicial;
- establecer escala;
- introducir el vacío.

Material:

- cristal seco y agudo;
- drone grave;
- cola amplia;
- ausencia posterior de actividad excesiva.

## Carta 2 — `cue_viento_imposible`

Función:

- comunicar caída sin gravedad convencional;
- aumentar inquietud.

Material:

- frecuencia eléctrica modulada;
- viento no natural;
- susurros ininteligibles;
- movimiento estéreo lento.

## Carta 3 — `cue_umbral`

Función:

- detener el impulso anterior;
- dar solemnidad a la decisión.

Material:

- silencio presurizado;
- diapasón grave;
- latido muy tenue;
- espacio amplio.

## Carta 4 — `cue_acechador`

Función:

- introducir presencia física;
- aumentar peligro sin recurrir a un sobresalto.

Material:

- arrastre sobre piedra;
- crujidos orgánicos;
- drone más tenso;
- incremento controlado de densidad.

## Carta 5 — `cue_refugio`

Función:

- ofrecer contraste;
- introducir humanidad y memoria.

Material:

- piano minimalista lejano;
- hoguera azul;
- espacio cálido pero extraño;
- silencios entre notas.

## Carta 6 — `cue_icnofago`

Función:

- presentar una criatura ajena a la lógica física;
- preparar el final.

Material:

- porcelana o nácar;
- pasos invertidos;
- coro muy grave;
- sonido procedente de debajo del suelo;
- reducción gradual antes del fundido final.

## Final

Función:

- cerrar el corte vertical;
- dejar una resonancia, no un clímax.

Material:

- fundido del ambiente de la carta 6;
- drone casi imperceptible durante el texto;
- silencio o una pista breve durante créditos.

---

# 7. Efectos funcionales

El corte vertical necesita un conjunto reducido:

## Carta

- aparición;
- desaparición;
- opción confirmada;
- opción no disponible;
- transición.

## Dados

- aparición;
- lanzamiento;
- impacto o asentamiento;
- revelado;
- símbolo neutralizado;
- objetivo completado.

## Estado

- daño recibido;
- curación;
- objeto obtenido;
- objeto consumido;
- objeto entregado;
- aliado incorporado;
- autoguardado discreto, solo si resulta útil.

## Criaturas y escena

- cristal inicial;
- viento imposible;
- umbral;
- Acechador;
- hoguera;
- escarcha;
- Icnófago;
- huellas.

Un mismo efecto procesado o combinado puede cubrir varios eventos.

No se necesita una muestra única para cada acción.

---

# 8. Dados

La animación sonora acompaña un resultado ya calculado.

El audio no determina:

- duración lógica de la tirada;
- cara obtenida;
- éxito;
- daño.

El lanzamiento debe:

- tener un inicio reconocible;
- evitar una duración excesiva;
- diferenciar aparición, movimiento y asentamiento;
- permitir que el resultado final sea legible;
- admitir uno o dos dados sin saturar.

Los símbolos no necesitan voces ni sonidos largos.

Una confirmación breve será suficiente.

---

# 9. Objetos

Los objetos necesitan feedback sonoro mínimo:

- selección inicial;
- uso;
- consumo;
- entrega;
- pérdida.

El Escudo debe comunicar dos cosas:

1. se ha evitado 1 punto de daño;
2. el objeto ha desaparecido.

Puede resolverse mediante una única secuencia breve de protección y ruptura.

No requiere una capa persistente ni un sonido de armadura.

---

# 10. Silencio

El silencio es una decisión de mezcla, no la ausencia accidental de assets.

Puede utilizarse:

- después del cristal del despertar;
- antes de presentar el Umbral;
- durante una frase importante;
- antes de revelar una criatura;
- al comenzar el fundido final;
- entre texto y créditos.

El silencio no tiene que ser digitalmente absoluto.

Un ruido de fondo casi imperceptible puede conservar continuidad cuando resulte necesario.

---

# 11. Voz

La voz es opcional y limitada.

No se narrarán las cartas completas.

Usos permitidos:

- una frase del protagonista;
- una frase del Fugitivo;
- un recuerdo;
- una ruptura;
- el texto final, solo si mejora la escena.

La interpretación original debe conservarse.

Si se utilizan herramientas como ElevenLabs para procesar una grabación:

- se conservará el original limpio;
- el procesamiento será moderado;
- se documentará la herramienta;
- se verificará la licencia;
- no se sustituirá automáticamente la interpretación por una voz genérica.

Cadena posible:

- limpieza;
- compresión moderada;
- ecualización;
- reverberación;
- eco;
- modificación leve de tono;
- textura ambiental.

No todos estos procesos son necesarios.

---

# 12. Mezcla

Prioridad general:

1. información funcional inmediata;
2. voz, si existe;
3. efectos narrativos relevantes;
4. ambiente;
5. música.

Durante la lectura:

- música y ambiente permanecen contenidos;
- se evitan transitorios frecuentes;
- no se automatizan cambios constantes;
- la voz dispone de espacio.

Durante una tirada:

- el ambiente puede reducirse ligeramente;
- los dados ocupan el primer plano;
- el resultado se confirma;
- la mezcla vuelve al estado de lectura.

No se fijarán valores definitivos sin escuchar el juego en funcionamiento.

La optimización de niveles se realizará por evidencia, no por números elegidos de antemano.

---

# 13. Transiciones

Las cartas no deben cortar el audio de forma abrupta salvo intención narrativa.

Operaciones necesarias:

- iniciar cue;
- detener cue;
- fundir entrada;
- fundir salida;
- sustituir ambiente;
- reproducir efecto;
- entrar en silencio.

Los fundidos serán sencillos.

No se requiere sincronización musical por compases ni mezcla adaptativa avanzada.

---

# 14. Menú y pausa

El menú necesita:

- ambiente o música opcional;
- confirmación de botón;
- indicación discreta de opción no disponible;
- transición a partida;
- salida.

El overlay de pausa puede reutilizar los mismos sonidos de interfaz.

Se añadirá control de volumen o silencio solo si las pruebas muestran que es necesario.

---

# 15. Producción y trazabilidad

Cada asset sonoro debe registrar:

- nombre;
- categoría;
- origen;
- autor o herramienta;
- licencia;
- URL cuando corresponda;
- fecha;
- evidencia;
- modificaciones;
- uso previsto;
- estado;
- archivo fuente cuando exista.

Se conservarán:

- grabaciones originales limpias;
- proyectos editables cuando sean relevantes;
- stems útiles;
- exports finales;
- evidencia de licencias;
- prompts y parámetros cuando proceda.

No se integrará un asset cuya licencia o procedencia sea dudosa.

---

# 16. Presupuesto del corte vertical

Objetivo inicial:

- hasta seis cues principales, con reutilización cuando sea posible;
- uno o dos materiales musicales;
- ambientes combinables;
- conjunto reducido de efectos de carta;
- conjunto reducido de efectos de dados;
- efectos esenciales de objetos y daño;
- voz opcional;
- audio de menú y créditos reutilizado.

El número exacto puede reducirse.

La lista no obliga a producir un archivo independiente para cada cue si una misma base puede transformarse mediante edición o mezcla.

---

# 17. Fuera del alcance

No se construirá:

- música adaptativa por capas complejas;
- una pista por carta;
- narración completa;
- audio procedural;
- síntesis en tiempo real;
- mezcla por zonas;
- simulación acústica;
- sistema de diálogo;
- sincronización labial;
- servidor de generación;
- pipeline propio de IA;
- soporte surround específico;
- variaciones extensas de cada efecto.

---

# 18. Criterio de aceptación

La dirección sonora del corte vertical se considerará validada cuando:

- cada carta tenga una intención sonora reconocible;
- los cues formen una progresión coherente;
- el silencio se utilice deliberadamente;
- la lectura resulte cómoda;
- las tiradas sean claras sin prolongarse;
- daño, curación y objetos se distingan;
- el consumo del Escudo se entienda;
- la incorporación del aliado tenga feedback;
- las transiciones no produzcan cortes accidentales;
- el final funcione con audio mínimo;
- los créditos y atribuciones estén completos;
- todos los assets tengan procedencia y licencia registradas.

---

# 19. Principio final

> **Pocas fuentes, bien elegidas y bien situadas, deben hacer que el sueño parezca mucho mayor que la pantalla.**
