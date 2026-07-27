# 06_resources.md

# Resources

## Estado

**Especificación conceptual de datos**

Este documento define los Resources necesarios para expresar el contenido del microjuego en Godot 4.

No contiene código ni fija todavía nombres de propiedades, tipos concretos de GDScript o detalles de serialización.

Su propósito es:

- establecer la responsabilidad de cada Resource;
- separar contenido inmutable y estado mutable;
- definir las relaciones entre cartas, opciones, amenazas, personajes, dados, objetos, consecuencias y audio;
- impedir que las excepciones narrativas se conviertan en scripts específicos;
- ofrecer un contrato suficientemente claro para implementar el primer corte vertical.

Las reglas vigentes proceden de `03_core_rules.md`.

Cuando otro documento conserve una formulación anterior incompatible, prevalece `03_core_rules.md`.

En particular:

- no existen Dados de Amenaza;
- una Amenaza declara un símbolo objetivo, una cantidad base y daño por ronda fallida;
- Atención, Fuerza y Cordura son símbolos de los dados, no atributos numéricos persistentes;
- Salud es el único recurso general de desgaste y derrota.

---

# 1. Principios

## 1.1 Contenido declarativo

Los Resources describen contenido.

Pueden:

- almacenar valores editoriales;
- referenciar otros Resources;
- declarar condiciones y consecuencias dentro del vocabulario permitido;
- proporcionar identificadores lógicos;
- contener referencias a assets de presentación.

No pueden:

- acceder o modificar `GameState`;
- decidir por sí mismos el flujo de partida;
- ejecutar consecuencias;
- realizar tiradas;
- reproducir animaciones o audio;
- depender de nodos, escenas o controles de interfaz;
- contener llamadas arbitrarias;
- introducir reglas exclusivas para una carta.

Una carta debe poder funcionar mediante los mismos resolutores y ejecutores que las demás.

---

## 1.2 Definición frente a estado

Los Resources de contenido representan definiciones inmutables durante una partida.

Ejemplos:

- la distribución de un dado;
- el texto de una carta;
- el objetivo de una Amenaza;
- el efecto declarado de un objeto;
- la identidad de un aliado.

El estado mutable pertenece a `GameState` y a su representación de guardado.

Ejemplos:

- Salud actual;
- aliado actual;
- objetos poseídos;
- variables narrativas;
- estado actual del sueño;
- identificador de la carta actual.

Nunca se modificará un Resource compartido para representar el progreso de una partida.

---

## 1.3 Identificadores lógicos

Todo contenido que pueda ser referenciado desde una carta o desde una partida guardada tendrá un identificador lógico estable.

El identificador:

- será único dentro de su categoría;
- no dependerá del nombre visible;
- no dependerá de la ruta física del archivo;
- no cambiará después de publicar una build salvo migración deliberada;
- utilizará una convención uniforme y legible.

Las referencias internas entre Resources podrán ser directas cuando resulte cómodo para la edición.

El guardado conservará identificadores lógicos, no copias completas de los Resources ni rutas de nodos.

---

## 1.4 Vocabulario cerrado

Los datos estructurados utilizarán un vocabulario pequeño y cerrado.

Los valores conceptuales iniciales son:

### Símbolos de resolución

- Atención;
- Fuerza;
- Cordura.

### Resultado de una Amenaza

- éxito;
- ronda fallida;
- derrota, cuando corresponda.

### Estados del sueño

El conjunto definitivo se concretará en dirección narrativa y visual.

Como base podrán utilizarse:

- vacío;
- calma;
- inquietud;
- peligro;
- recuerdo;
- presencia.

No se crearán cadenas libres para representar conceptos que deban ser comparados por la lógica.

---

# 2. Mapa de Resources

El contenido se divide en los siguientes Resources principales:

| Resource | Responsabilidad |
|---|---|
| `CardResource` | Definir una escena completa |
| `CardOptionResource` | Definir una decisión disponible dentro de una carta |
| `ThreatResource` | Definir la Amenaza opcional asociada a una opción o resolución |
| `CharacterResource` | Definir al protagonista o a un aliado |
| `DiceResource` | Definir las seis caras del dado de un personaje |
| `DiceFaceResource` | Definir el resultado de una cara |
| `ItemResource` | Definir un objeto y su único efecto principal |
| `ConditionResource` | Declarar un requisito sencillo |
| `ConsequenceResource` | Declarar una modificación permitida del estado |
| `AudioCueResource` | Definir una intención sonora reutilizable |
| `SaveGameResource` | Representar una instantánea serializable del estado mutable |

`ThreatResource`, `DiceFaceResource` y `ConditionResource` se añaden a la lista preliminar de `05 Technical Foundations.md` porque permiten mantener separadas responsabilidades que no pertenecen a la carta, al dado o a la consecuencia.

Esta separación no implica construir un framework genérico.

Si durante la implementación alguno de estos tipos auxiliares puede expresarse de forma más sencilla sin mezclar responsabilidades, podrá integrarse en su Resource propietario.

---

# 3. CardResource

## 3.1 Responsabilidad

`CardResource` define una escena narrativa completa.

Debe contener todo lo necesario para presentar la carta y conocer las decisiones que ofrece, pero no debe resolverlas.

## 3.2 Datos conceptuales

- identificador lógico;
- título opcional;
- texto narrativo;
- ilustración principal;
- lista ordenada de opciones;
- señales de presentación opcionales;
- intención sonora opcional;
- estado del sueño sugerido durante la carta;
- etiquetas editoriales opcionales.

Las etiquetas editoriales sirven para organización y validación.

No conceden reglas en tiempo de ejecución.

## 3.3 Reglas

- Toda carta tendrá al menos una opción.
- Una carta con una única acción seguirá utilizando una opción explícita.
- La carta no contendrá Salud, inventario ni progreso mutable.
- La categoría narrativa de una carta no cambiará su forma de resolución.
- El tipo de transición visual será una instrucción de presentación, no una regla.
- La siguiente carta no se deducirá del nombre o del orden físico de los archivos.

---

# 4. CardOptionResource

## 4.1 Responsabilidad

`CardOptionResource` define una acción que el jugador puede elegir.

La opción conecta la decisión narrativa con:

- sus condiciones de disponibilidad;
- una Amenaza opcional;
- sus consecuencias;
- el siguiente paso del recorrido.

## 4.2 Datos conceptuales

- identificador local o lógico;
- texto visible de la acción;
- condiciones de disponibilidad;
- texto opcional cuando la opción no está disponible;
- Amenaza opcional;
- consecuencias de resolución;
- señales de presentación o audio opcionales.

## 4.3 Reglas

- Una opción sin incertidumbre no necesita `ThreatResource`.
- Una opción con Amenaza utiliza siempre las reglas comunes de `03_core_rules.md`.
- Las condiciones deciden disponibilidad, no ejecutan efectos.
- Las consecuencias se declaran como datos estructurados.
- El acceso a la siguiente carta se declara como una consecuencia estructurada.
- No se incrustarán expresiones, scripts ni un lenguaje de diálogo.

---

# 5. ThreatResource

## 5.1 Responsabilidad

`ThreatResource` declara la información visible y fija necesaria para resolver una Amenaza.

## 5.2 Datos conceptuales

- símbolo objetivo;
- cantidad base requerida para un participante;
- daño de Salud por ronda fallida;
- regla general o declaración de reparto del daño, si fuera necesaria;
- consecuencias especiales de ronda fallida;
- destino opcional cuando una ronda fallida termina el encuentro;
- texto breve de apoyo opcional;
- presentación o audio asociados a la resolución.

## 5.3 Reglas

- El objetivo utiliza exactamente uno de los tres símbolos vigentes.
- La cantidad base es positiva.
- Si participa el aliado, la cantidad requerida se duplica.
- El progreso neutralizado se conserva entre rondas.
- El daño afecta exclusivamente a Salud.
- El Resource no contiene Dados de Amenaza.
- El Resource no define enemigos con estadísticas, turnos, iniciativa o habilidades.
- Los valores pendientes de balance se parametrizan dentro de estas reglas; no crean mecánicas nuevas.

Si la carta declara que una ronda fallida termina el encuentro:

- el daño se aplica una sola vez;
- el progreso acumulado se descarta;
- no se inicia otra ronda;
- se utiliza el destino declarado.

La asignación de daño con dos participantes permanece pendiente de balance conforme a `03_core_rules.md`.

El modelo debe poder expresar la decisión definitiva sin alterar la estructura básica del Resource.

---

# 6. CharacterResource

## 6.1 Responsabilidad

`CharacterResource` define la identidad inmutable de un personaje controlable.

## 6.2 Datos conceptuales

- identificador lógico;
- nombre visible;
- descripción breve;
- retrato o ilustración;
- dado asociado;
- Salud máxima;
- especialización narrativa breve;
- señales visuales o sonoras opcionales.

## 6.3 Reglas

- Cada personaje utiliza un único `DiceResource`.
- El protagonista y los aliados comparten la misma estructura.
- La especialización procede de la distribución del dado, no de clases o habilidades.
- El Resource no almacena Salud actual.
- Atención, Fuerza y Cordura no son estadísticas del personaje.
- Solo puede existir un aliado activo en `GameState`.
- El número máximo previsto de aliados de contenido es cinco.

La Salud máxima definitiva del protagonista y de los aliados queda pendiente de balance.

---

# 7. DiceResource y DiceFaceResource

## 7.1 Responsabilidad de DiceResource

`DiceResource` define la distribución completa del dado de seis caras de un personaje.

## 7.2 Datos conceptuales de DiceResource

- identificador lógico;
- seis caras ordenadas;
- color o identidad visual sugerida;
- referencia visual opcional para la presentación.

## 7.3 Responsabilidad de DiceFaceResource

`DiceFaceResource` define el resultado lógico de una cara.

## 7.4 Datos conceptuales de DiceFaceResource

- símbolo de resolución;
- cantidad producida.

## 7.5 Reglas

- Todo dado tiene exactamente seis caras.
- Toda cara produce un símbolo válido.
- Una cara puede producir más de una unidad del mismo símbolo.
- Una cara no produce varios símbolos diferentes.
- El dado no realiza la tirada ni conoce la Amenaza.
- La presentación recibe la cara final calculada; la animación no determina el resultado.

El dado inicial del protagonista respetará la distribución fijada en `03_core_rules.md`.

Las distribuciones de aliados se validarán mediante balance sin introducir resultados nuevos fuera de este vocabulario.

---

# 8. ItemResource

## 8.1 Responsabilidad

`ItemResource` define un objeto del inventario y su función principal.

## 8.2 Datos conceptuales

- identificador lógico;
- nombre visible;
- descripción;
- icono o ilustración;
- espacios ocupados;
- efecto estructurado;
- condición de uso opcional;
- consumible o persistente;
- texto narrativo opcional.

## 8.3 Reglas

- Cada objeto expresa su efecto principal en una sola frase.
- El tamaño es un entero positivo.
- El efecto pertenece al conjunto permitido por `03_core_rules.md`.
- El Resource no almacena cantidad poseída, posición en inventario ni estado de consumo.
- No existen rarezas, niveles, crafting, tiendas, mejoras ni equipo por ranuras.
- El catálogo completo se limita a 10–12 objetos.
- El jugador comienza eligiendo uno de tres objetos iniciales disponibles.
- Un objeto consumido, perdido o entregado desaparece del inventario.

## 8.4 Efectos permitidos

El vocabulario inicial debe poder expresar:

- recuperar Salud;
- evitar una unidad de daño;
- añadir un dado a una prueba concreta;
- modificar de forma sencilla una tirada;
- permitir una interacción específica con una carta.

Si un efecto necesita más de una frase para explicarse o exige un subsistema propio, queda fuera del alcance inicial.

El Escudo es un objeto consumible que evita una unidad de daño y desaparece después de utilizarse.

---

# 9. ConditionResource

## 9.1 Responsabilidad

`ConditionResource` declara un requisito sencillo que puede consultarse sin modificar el estado.

## 9.2 Condiciones permitidas

El conjunto inicial podrá comprobar:

- posesión o ausencia de un objeto;
- presencia o ausencia de aliado;
- identidad del aliado;
- valor de una variable narrativa;
- estado del sueño;
- umbral sencillo de Salud;
- cumplimiento previo de una marca narrativa imprescindible.

## 9.3 Reglas

- Una condición solo responde si se cumple o no.
- No ejecuta consecuencias.
- No contiene código ni expresiones arbitrarias.
- Las combinaciones se limitarán a listas simples de requisitos.
- No se construirá un lenguaje general de consultas.
- Solo se añadirán nuevos tipos cuando una carta aprobada del alcance congelado los necesite.

---

# 10. ConsequenceResource

## 10.1 Responsabilidad

`ConsequenceResource` declara una única modificación atómica que `ConsequenceExecutor` puede aplicar sobre `GameState`.

## 10.2 Consecuencias permitidas

El vocabulario inicial debe poder expresar:

- reducir o recuperar Salud;
- añadir o eliminar un objeto;
- asignar, sustituir o retirar al aliado;
- modificar una variable narrativa;
- cambiar el estado del sueño;
- establecer la siguiente carta;
- impedir que un personaje actúe durante la siguiente ronda;
- impedir temporalmente el uso de objetos durante la Amenaza actual;
- registrar una marca narrativa imprescindible.

Los modificadores de una tirada o la protección aportada por objetos podrán representarse mediante el mismo vocabulario de efectos o mediante un tipo auxiliar específico si así se mantiene una separación más clara.

## 10.3 Reglas

- Cada consecuencia realiza una sola modificación.
- Varias consecuencias se expresan mediante una lista ordenada.
- Toda consecuencia que afecte a personajes declara su destinatario de forma explícita.
- La consecuencia no decide cuándo ejecutarse.
- La consecuencia no contiene texto narrativo como sustituto de datos.
- No modifica Resources de contenido.
- Todo valor de Salud se limita al rango válido del personaje.
- La asignación de aliado nunca permite conservar más de uno.
- Añadir un objeto debe respetar la capacidad del inventario una vez se concrete durante el balance.
- El robo sigue siendo una consecuencia de carta, no un sistema independiente.
- Si una consecuencia de robo se resuelve sin objetos disponibles, no modifica el estado, solicita un mensaje de resultado y finaliza el encuentro.
- Los efectos de siguiente ronda o de Amenaza actual son transitorios y desaparecen cuando dejan de ser relevantes para esa situación.
- Los efectos transitorios no se convierten en estados alterados generales ni se conservan entre cartas.
- Impedir que un personaje actúe no altera la selección de participantes y no concede descanso.

Cordura no puede aumentar ni disminuir como estado persistente.

Las menciones anteriores a modificar Cordura deben considerarse obsoletas respecto a `03_core_rules.md`.

---

# 11. AudioCueResource

## 11.1 Responsabilidad

`AudioCueResource` describe una intención sonora reutilizable sin reproducirla.

## 11.2 Datos conceptuales

- identificador lógico;
- categoría: música, ambiente, efecto o voz;
- asset de audio;
- volumen base;
- fundido de entrada o salida opcional;
- bucle cuando corresponda;
- prioridad o política mínima de sustitución, si fuera necesaria;
- metadatos editoriales de procedencia.

## 11.3 Reglas

- El Resource no contiene un reproductor.
- No inicia ni detiene audio por sí mismo.
- Las cartas referencian intenciones reutilizables.
- El silencio se representa mediante ausencia de cue o una decisión explícita de presentación.
- No se diseñará música adaptativa compleja.
- La voz será limitada y no cubrirá todas las cartas.

---

# 12. SaveGameResource

## 12.1 Responsabilidad

`SaveGameResource` representa una instantánea serializable de `GameState`.

Es un Resource técnico, no contenido editorial.

## 12.2 Datos conceptuales

- versión del formato de guardado;
- identificador de la carta actual;
- identificador del protagonista y Salud actual;
- identificador del aliado actual y Salud actual, si existe;
- inventario mediante identificadores de objeto y estado mínimo necesario;
- variables narrativas imprescindibles;
- estado del sueño;
- partida completada;
- semilla aleatoria, únicamente si se decide conservar reproducibilidad;
- datos mínimos de una resolución en curso, solo si guardar entre cartas no resulta suficiente.

## 12.3 Reglas

- Existe una única partida automática.
- El guardado normal se realiza entre cartas, en un punto estable.
- Al alcanzar el final, la partida se marca como completada y deja de habilitar `CONTINUAR`.
- No serializa escenas, nodos ni elementos de UI.
- No duplica definiciones completas de cartas, personajes, dados u objetos.
- No almacena Atención, Fuerza o Cordura como valores.
- No almacena progreso histórico que no afecte a la continuación.
- Toda referencia a contenido se resuelve mediante identificador lógico.
- La versión permite detectar incompatibilidades y aplicar una migración mínima si fuera necesaria.

Mientras el autoguardado se mantenga entre cartas, no será necesario conservar tiradas ni progreso neutralizado de una Amenaza.

Añadir ese estado solo estará justificado si una necesidad real obliga a guardar durante una resolución.

---

# 13. Relaciones

La estructura conceptual principal es:

```text
CardResource
├── CardOptionResource[]
│   ├── ConditionResource[]
│   ├── ThreatResource?
│   │   └── ConsequenceResource[] — efectos especiales de ronda fallida
│   └── ConsequenceResource[] — desenlace de la opción
├── AudioCueResource?
└── assets de presentación

CharacterResource
└── DiceResource
    └── DiceFaceResource[6]

ItemResource
├── ConditionResource?
└── efecto estructurado

SaveGameResource
└── identificadores + estado mutable mínimo
```

Las dependencias deben avanzar desde el contenido compuesto hacia piezas pequeñas y reutilizables.

No se introducirán referencias circulares entre Resources.

---

# 14. Organización editorial

Los archivos podrán agruparse por categoría:

```text
resources/
├── cards/
├── characters/
├── dice/
├── items/
├── audio/
└── shared/
```

La estructura definitiva de carpetas se decidirá al crear el proyecto.

La organización debe favorecer:

- localizar contenido;
- detectar identificadores duplicados;
- revisar las 30–40 cartas;
- auditar referencias rotas;
- conservar la trazabilidad de assets.

No se construirá un editor propio.

Los inspectores y Resources nativos de Godot son la herramienta editorial inicial.

---

# 15. Validación

Antes de considerar válido el contenido, deberán comprobarse al menos las siguientes reglas:

## Cartas

- identificador único;
- texto y opción presentes;
- destinos resolubles;
- referencias válidas;
- Amenazas compatibles con las reglas vigentes.

## Amenazas

- símbolo válido;
- cantidad base positiva;
- daño no negativo;
- ausencia de Dados de Amenaza;
- destino válido cuando una ronda fallida termina el encuentro;
- consecuencias pertenecientes al vocabulario permitido.

## Personajes y dados

- identificadores únicos;
- Salud máxima válida;
- dado asociado;
- exactamente seis caras;
- resultados limitados a los tres símbolos.

## Objetos

- tamaño válido;
- efecto único y permitido;
- descripción comprensible en una frase;
- catálogo dentro del límite de 10–12.

## Guardado

- versión reconocida;
- carta actual existente;
- personajes y objetos resolubles;
- Salud dentro de límites;
- un aliado como máximo;
- ausencia de estado ajeno al alcance.

La primera validación puede ser manual.

Solo se automatizará cuando el volumen o los errores reales lo justifiquen.

---

# 16. Decisiones pendientes

Los Resources deben admitir sin rediseño las decisiones de balance todavía abiertas:

- Salud máxima del protagonista;
- Salud máxima de cada aliado;
- condición exacta de derrota o retirada del aliado;
- cantidad máxima práctica del objetivo;
- asignación del daño con dos participantes;
- distribuciones finales de dados de aliado;
- capacidad exacta del inventario;
- efectos finales de los objetos;
- condiciones exactas de derrota.

Estas decisiones concretarán valores o políticas dentro del modelo.

No autorizarán nuevos Resources de sistemas, nuevas barras ni nuevas mecánicas.

---

# 17. Fuera del alcance

El modelo de Resources no incluirá:

- Dados de Amenaza;
- estadísticas persistentes de Atención, Fuerza o Cordura;
- enemigos con fichas propias;
- habilidades, clases o niveles;
- estados alterados generales;
- árboles de diálogo;
- lenguaje de scripting;
- expresiones arbitrarias;
- base de datos;
- JSON como formato editorial principal;
- editor de cartas;
- sistema de mods;
- localización completa;
- inventario complejo;
- economía, crafting o tiendas;
- lógica de presentación;
- referencias directas a nodos.

---

# 18. Criterio de aceptación

La especificación de Resources será suficiente cuando permita expresar, sin código específico de carta:

- una carta narrativa con una única opción;
- una carta con varias opciones condicionadas;
- una Amenaza con objetivo fijo, rondas y daño;
- la participación del protagonista solo o con un aliado;
- un dado de personaje con símbolos simples o múltiples;
- consecuencias de éxito y de ronda fallida;
- descanso del aliado;
- incorporación o sustitución de aliado;
- obtención, uso y robo de objetos;
- cambios de variables narrativas y del estado del sueño;
- selección de la siguiente carta;
- intención visual y sonora;
- autoguardado entre cartas.

Si una de las 30–40 cartas exige un script propio, primero deberá revisarse la carta.

La solución preferida será adaptar su expresión al vocabulario existente antes de ampliar el modelo.

---

# 19. Principio final

> **Los Resources describen el sueño; el núcleo interpreta sus reglas; el estado conserva únicamente sus consecuencias.**
