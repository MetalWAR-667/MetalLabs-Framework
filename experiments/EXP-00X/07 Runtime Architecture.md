# 07_runtime_architecture.md

# Runtime Architecture

## Estado

**Especificación conceptual de ejecución**

Este documento define cómo colaboran en tiempo de ejecución los componentes descritos en `05 Technical Foundations.md` y los datos declarados en `06 Resources.md`.

No contiene código ni fija una jerarquía definitiva de nodos.

Su propósito es:

- establecer una única fuente de verdad para el estado de la partida;
- describir el flujo completo de una carta;
- separar coordinación, reglas, estado y presentación;
- definir el estado temporal de una Amenaza;
- evitar dependencias circulares;
- fijar los puntos seguros de autoguardado;
- limitar la arquitectura al alcance del experimento.

Las mecánicas proceden de `03_core_rules.md`.

Si este documento entra en conflicto con las reglas, prevalece `03_core_rules.md`.

---

# 1. Principio

La arquitectura se organiza alrededor de una única dirección de flujo:

```text
Intención del jugador
        ↓
GameController
        ↓
Servicios de lógica
        ↓
GameState
        ↓
Resultado descriptivo
        ↓
Presentación
```

La interfaz comunica intenciones.

El controlador coordina.

Los servicios calculan o aplican reglas.

`GameState` conserva el resultado persistente.

La presentación representa decisiones ya tomadas por la lógica.

Ningún componente visual modifica directamente el estado de partida.

---

# 2. Capas

## 2.1 Contenido

Contiene los Resources editoriales:

- cartas;
- opciones;
- Amenazas;
- personajes;
- dados;
- objetos;
- condiciones;
- consecuencias;
- intenciones de audio.

El contenido es declarativo e inmutable durante una partida.

---

## 2.2 Estado

Contiene:

- `GameState`;
- estado temporal de la carta;
- estado temporal de la Amenaza.

Esta capa diferencia con claridad:

- aquello que debe sobrevivir entre cartas;
- aquello que solo existe durante la resolución actual.

---

## 2.3 Lógica

Contiene los componentes que:

- consultan condiciones;
- realizan tiradas;
- neutralizan objetivos;
- producen resultados descriptivos;
- aplican consecuencias;
- validan invariantes.

La lógica no conoce animaciones, controles, shaders ni reproductores de audio.

---

## 2.4 Coordinación

`GameController` dirige el caso de uso completo.

Decide qué operación debe ocurrir a continuación, pero delega su ejecución.

No contiene las reglas internas de tiradas, inventario, daño o guardado.

---

## 2.5 Presentación

Contiene:

- menú principal;
- `GameScreen`;
- `CardView`;
- HUD;
- `DiceTray`;
- fondo del sueño;
- transiciones;
- presentación sonora.

Recibe modelos de vista o resultados descriptivos.

No recibe autoridad para alterar el juego.

---

## 2.6 Persistencia

`SaveService` convierte entre:

- `GameState`;
- `SaveGameResource`;
- archivo de autoguardado.

No decide cuándo avanzar ni qué consecuencias aplicar.

---

# 3. Componentes de ejecución

## 3.1 GameController

### Responsabilidad

Coordinar el ciclo de vida de la partida y mantener una fase de ejecución coherente.

### Puede

- iniciar o cargar una partida;
- solicitar contenido al repositorio;
- presentar la carta actual;
- recibir la opción elegida;
- solicitar participantes cuando exista una Amenaza;
- crear y conservar el estado temporal del encuentro;
- pedir una tirada al resolutor;
- esperar a que termine su representación;
- solicitar la aplicación de daño y consecuencias;
- aplicar descanso cuando corresponda;
- actualizar la carta actual;
- ordenar el autoguardado;
- iniciar la transición a la siguiente carta.

### No puede

- generar resultados aleatorios por sí mismo;
- neutralizar símbolos;
- interpretar efectos de objetos;
- modificar campos de `GameState` de manera dispersa;
- cargar Resources mediante rutas decididas por la UI;
- reproducir animaciones o audio directamente;
- guardar antes de que el estado sea coherente.

El controlador conoce el orden del proceso, no los detalles de cada regla.

---

## 3.2 GameState

### Responsabilidad

Ser la única fuente de verdad del estado mutable que debe sobrevivir entre cartas.

### Contenido

- identificador de la carta actual;
- identificador del protagonista;
- Salud actual del protagonista;
- identificador del aliado actual, si existe;
- Salud actual del aliado;
- inventario;
- variables narrativas imprescindibles;
- estado narrativo o visual del sueño;
- semilla aleatoria, únicamente si se adopta una política reproducible.

### Invariantes

- la Salud se mantiene dentro de sus límites válidos;
- solo existe un aliado activo;
- el inventario respeta su capacidad cuando esta se concrete;
- todos los identificadores referencian contenido existente;
- Atención, Fuerza y Cordura no aparecen como valores persistentes;
- no contiene nodos, controles ni estado de animación;
- no conserva tiradas ni progreso de una Amenaza entre cartas.

Las modificaciones persistentes se realizan mediante operaciones controladas, principalmente a través de `ConsequenceExecutor`.

---

## 3.3 CardRepository

### Responsabilidad

Resolver un identificador lógico y devolver el `CardResource` correspondiente.

### Puede

- mantener un catálogo sencillo;
- comprobar identificadores duplicados;
- informar de una carta inexistente;
- devolver definiciones inmutables.

### No puede

- seleccionar la siguiente carta;
- evaluar condiciones;
- aplicar consecuencias;
- mantener progreso de la partida;
- ordenar cartas por una secuencia implícita de archivos.

---

## 3.4 ConditionEvaluator

### Responsabilidad

Evaluar `ConditionResource` contra una lectura de `GameState`.

### Resultado

Devuelve únicamente:

- condición cumplida;
- condición no cumplida;
- motivo descriptivo opcional para presentación o diagnóstico.

### Límites

- no modifica estado;
- no ejecuta consecuencias;
- no contiene un lenguaje general de expresiones;
- no decide qué opción debe elegir el jugador.

Este componente puede comenzar como una pieza pequeña del flujo y separarse físicamente solo si la implementación lo justifica.

---

## 3.5 ThreatResolver

### Responsabilidad

Resolver una ronda de Amenaza mediante datos de entrada explícitos.

### Recibe

- símbolo objetivo;
- cantidad pendiente;
- dados de los participantes;
- modificadores simples permitidos;
- efectos aplicables de objetos;
- restricciones temporales de la ronda.

### Produce

Un resultado descriptivo que puede incluir:

- cara obtenida por cada dado;
- unidades del símbolo requerido obtenidas;
- unidades neutralizadas;
- cantidad pendiente;
- éxito completo;
- ronda fallida;
- finalización anticipada y destino, cuando la carta lo declara;
- efectos relevantes.

### No puede

- lanzar Dados de Amenaza;
- modificar `GameState`;
- reducir Salud;
- aplicar consecuencias;
- seleccionar la siguiente carta;
- reproducir dados;
- guardar.

El resultado lógico se calcula antes de comenzar la animación visual.

---

## 3.6 EncounterState

### Responsabilidad

Conservar únicamente el estado temporal necesario mientras se resuelve la carta actual.

### Contenido posible

- opción elegida;
- participantes confirmados;
- objetivo original;
- cantidad pendiente;
- número de ronda;
- restricciones temporales;
- uso temporal de objetos;
- resultado lógico pendiente de representación.

### Reglas

- se crea al comenzar la resolución;
- no sustituye a `GameState`;
- no se serializa en el flujo normal;
- se elimina al concluir la carta;
- las restricciones temporales desaparecen cuando deja de ser relevante la situación;
- no se convierte en un sistema general de estados alterados.

Una carta sin Amenaza puede utilizar un contexto mínimo de resolución sin crear estado de rondas.

---

## 3.7 ConsequenceExecutor

### Responsabilidad

Aplicar consecuencias estructuradas sobre `GameState` en un orden conocido.

### Recibe

- lista ordenada de `ConsequenceResource`;
- destinatario declarado;
- estado actual;
- contexto mínimo del desenlace.

### Puede

- modificar Salud;
- añadir o eliminar objetos;
- asignar, sustituir o retirar aliado;
- cambiar variables narrativas;
- cambiar el estado del sueño;
- establecer el identificador de la siguiente carta;
- registrar marcas narrativas;
- resolver el intento de robo sin modificar el estado cuando no existen objetos.

### No puede

- interpretar texto narrativo;
- modificar Cordura como recurso;
- alterar Resources de contenido;
- reproducir presentación;
- inventar una consecuencia no declarada;
- ejecutar scripts incluidos en una carta.

Las consecuencias temporales propias de una ronda se aplican sobre `EncounterState`, no sobre el estado persistente.

---

## 3.8 RestResolver

### Responsabilidad

Aplicar la regla única de descanso al finalizar una Amenaza.

### Reglas

- solo se evalúa cuando existe un aliado;
- el aliado descansa si no fue seleccionado como participante;
- recupera 1 punto de Salud;
- nunca supera su Salud máxima;
- se aplica una vez por encuentro, no por ronda;
- el aliado que participa no descansa;
- una incapacidad temporal no retira al aliado de la lista de participantes;
- un aliado incapacitado no descansa ni recupera Salud por descanso;
- el aliado que descansa no recibe beneficios reservados a participantes.

Puede implementarse como una operación pequeña coordinada por `GameController`.

No necesita convertirse en un sistema independiente si ello no aporta claridad.

---

## 3.9 SaveService

### Responsabilidad

Guardar y cargar una única partida automática.

### Guardado

- recibe un `GameState` coherente;
- construye su representación serializable;
- conserva identificadores lógicos;
- registra la versión del formato;
- escribe la instantánea de forma segura.

### Carga

- detecta si existe autoguardado;
- lee la versión;
- valida referencias y valores esenciales;
- reconstruye `GameState`;
- informa de un fallo recuperable si los datos no son válidos.

Una partida marcada como completada no habilita `CONTINUAR`.

### Límites

- no guarda en mitad de una ronda;
- no serializa `EncounterState`;
- no duplica Resources de contenido;
- no decide la carta siguiente;
- no ofrece múltiples ranuras ni guardado manual.

---

## 3.10 PresentationCoordinator

### Responsabilidad

Traducir órdenes descriptivas del flujo en acciones de presentación.

Puede coordinar:

- `CardView`;
- `DiceTray`;
- HUD;
- `DreamBackground`;
- `TransitionLayer`;
- `AudioController`.

No calcula resultados ni aplica reglas.

Puede residir inicialmente en una colaboración sencilla entre `GameScreen` y sus componentes.

No se creará una capa adicional si la escena principal puede mantener esta responsabilidad sin mezclar lógica.

---

# 4. Fases de ejecución

El flujo utiliza un conjunto pequeño de fases conceptuales.

| Fase | Significado |
|---|---|
| Inicio | Preparación o carga de partida |
| Presentando carta | Entrada, texto y opciones |
| Esperando decisión | El jugador puede elegir una opción |
| Esperando participantes | Debe decidirse si interviene el aliado |
| Resolviendo ronda | La lógica calcula una tirada |
| Representando ronda | Los dados muestran el resultado calculado |
| Aplicando resultado | Se aplican daño, efectos o desenlace |
| Cerrando carta | Se aplican descanso y consecuencias finales |
| Guardando | Se persiste un estado coherente |
| Transición | Se abandona la carta y se presenta la siguiente |
| Final | Se ha alcanzado un desenlace |

Solo una fase puede estar activa.

Las entradas del jugador que no correspondan a la fase actual se ignoran o permanecen deshabilitadas.

No se necesita una máquina de estados genérica.

Una enumeración de fases y transiciones explícitas será suficiente.

Al entrar en la fase Final:

- se marca la partida como completada;
- se guarda el estado final;
- se deshabilita `CONTINUAR`;
- la presentación ejecuta el desenlace y los créditos;
- volver al menú no reinicia automáticamente una nueva partida.

---

# 5. Inicio de partida

## 5.1 Nueva partida

```text
Menú principal
      ↓
Solicitar nueva partida
      ↓
Crear GameState inicial
      ↓
Asignar protagonista
      ↓
Mostrar tres objetos iniciales
      ↓
El jugador elige uno
      ↓
Añadir el objeto elegido al inventario
      ↓
Establecer carta inicial
      ↓
Guardar estado inicial
      ↓
Presentar primera carta
```

El objeto inicial se elige entre tres opciones declaradas.

La selección no implica clases, equipamiento ni configuración previa del personaje.

---

## 5.2 Continuar

```text
Menú principal
      ↓
Comprobar autoguardado
      ↓
Cargar y validar SaveGameResource
      ↓
Reconstruir GameState
      ↓
Resolver la carta actual
      ↓
Presentar la carta
```

`CONTINUAR` solo está disponible cuando existe un guardado válido y no completado.

---

# 6. Presentación de una carta

```text
GameController solicita el identificador actual
      ↓
CardRepository devuelve CardResource
      ↓
Se evalúan las condiciones de sus opciones
      ↓
Se prepara el modelo de presentación
      ↓
Se actualizan fondo, HUD y audio
      ↓
CardView reproduce la entrada
      ↓
Se habilitan las opciones disponibles
```

La carta permanece estable mientras el jugador lee.

Las animaciones expresivas se concentran en entradas, salidas y resultados.

---

# 7. Elección de opción

Al elegir una opción:

1. la UI emite la intención con el identificador de la opción;
2. `GameController` confirma que la fase permite elegir;
3. comprueba de nuevo sus condiciones;
4. bloquea nuevas entradas;
5. determina si la opción contiene una Amenaza.

Si no existe Amenaza:

```text
Aplicar consecuencias de resolución
      ↓
Determinar la siguiente carta
      ↓
Cerrar carta
```

Si existe Amenaza:

```text
Mostrar objetivo y daño
      ↓
Solicitar participantes
      ↓
Crear EncounterState
      ↓
Comenzar primera ronda
```

---

# 8. Selección de participantes

Las opciones válidas son:

- protagonista;
- protagonista y aliado.

La segunda solo existe si hay un aliado activo.

La elección:

- se realiza antes de la primera ronda;
- se mantiene hasta terminar la Amenaza;
- define los dados participantes;
- duplica la cantidad requerida cuando participa el aliado;
- determina si el aliado podrá descansar;
- no puede alterarse entre rondas.

Una consecuencia que impide actuar durante una ronda no altera esta elección.

El personaje incapacitado continúa siendo participante y no puede recibir descanso.

La UI muestra el riesgo antes de confirmar:

- símbolo objetivo;
- cantidad ajustada;
- daño por ronda fallida;
- participantes;
- Salud disponible.

---

# 9. Resolución de una ronda

```text
Leer cantidad pendiente
      ↓
Obtener dados y modificadores permitidos
      ↓
ThreatResolver calcula resultados
      ↓
Actualizar progreso temporal
      ↓
Entregar resultado a DiceTray
      ↓
Representar la tirada
      ↓
Confirmar fin de animación
      ↓
Aplicar resultado de la ronda
```

La animación nunca decide la cara obtenida.

Mientras se representa la ronda:

- no puede solicitarse otra tirada;
- no pueden cambiarse los participantes;
- no se aplican dos veces las consecuencias;
- el resultado lógico permanece disponible hasta ser consumido por el flujo.

---

# 10. Ronda superada

Si la cantidad pendiente alcanza cero:

1. la Amenaza termina inmediatamente;
2. no se aplica daño de ronda fallida;
3. se descartan las restricciones temporales;
4. se aplican las consecuencias de resolución de la opción;
5. se aplican los beneficios a sus destinatarios declarados;
6. se aplica descanso al aliado no participante, si existe;
7. se determina la siguiente carta;
8. se valida `GameState`;
9. se ejecuta el autoguardado;
10. se inicia la transición.

---

# 11. Ronda fallida

Si quedan unidades pendientes:

1. se conserva el progreso neutralizado;
2. se calcula el daño visible de la carta;
3. si el jugador utiliza un objeto Escudo, se evita una unidad de daño y el objeto se elimina del inventario;
4. se asigna el daño restante según la declaración de la carta;
5. se aplican los efectos especiales de la ronda;
6. se comprueban las condiciones de derrota;
7. si la carta declara finalización anticipada por fallo, se descarta el progreso y se establece su destino;
8. en caso contrario, si la partida continúa, comienza una nueva ronda.

La arquitectura no fija todavía:

- la asignación definitiva del daño con dos participantes;
- las condiciones exactas de derrota o retirada del aliado.

Esas decisiones permanecen bajo la autoridad de `03_core_rules.md`.

## 11.1 Intento de robo sin objetos

Cuando una consecuencia de robo comprueba que el inventario está vacío:

1. no elimina ningún objeto;
2. no busca ni aplica una consecuencia sustitutiva;
3. solicita a la presentación un mensaje indicando que no se ha robado nada;
4. concluye el encuentro;
5. continúa el cierre normal de la carta.

---

# 12. Cierre y autoguardado

El punto seguro de guardado es posterior a todas las modificaciones de la carta y anterior a presentar la siguiente.

```text
Concluir resolución
      ↓
Aplicar daño y efectos finales
      ↓
Aplicar consecuencias
      ↓
Aplicar descanso
      ↓
Establecer siguiente carta
      ↓
Validar GameState
      ↓
Guardar
      ↓
Eliminar EncounterState
      ↓
Transición
      ↓
Presentar siguiente carta
```

Si el guardado falla:

- el flujo no debe corromper el estado en memoria;
- se informa de forma discreta;
- no se intenta guardar repetidamente dentro del mismo frame o transición;
- la política exacta de reintento se mantendrá sencilla.

---

# 13. Comunicación con la presentación

La comunicación seguirá dos direcciones limitadas.

## De la UI al controlador

Solo intenciones:

- nueva partida;
- continuar;
- elegir opción;
- confirmar participantes;
- solicitar tirada o continuar resolución;
- volver al menú;
- salir.

## Del flujo a la UI

Solo datos y órdenes descriptivas:

- presentar carta;
- mostrar opciones disponibles;
- mostrar objetivo y daño;
- actualizar HUD;
- representar tirada;
- mostrar progreso restante;
- reproducir transición;
- cambiar estado visual del sueño;
- reproducir una intención sonora;
- bloquear o habilitar interacción.

Las señales no transportarán nodos como sustituto de datos de juego.

---

# 14. Aleatoriedad

Toda aleatoriedad lógica se concentra fuera de la presentación.

Incluye:

- resultado de dados;
- cualquier selección aleatoria permitida por una carta.

La arquitectura permitirá proporcionar una fuente aleatoria controlable para pruebas.

Conservar una semilla en `GameState` es opcional.

Solo se adoptará si la reproducibilidad aporta valor real al diagnóstico o al guardado.

---

# 15. Validación y errores

Los fallos de contenido deben detectarse lo antes posible.

## Errores recuperables

- autoguardado inexistente;
- opción temporalmente no disponible;
- asset visual o sonoro opcional ausente;
- guardado inválido que puede descartarse.

## Errores de contenido

- identificador duplicado;
- carta inexistente;
- opción sin desenlace resoluble;
- dado que no contiene seis caras;
- símbolo no permitido;
- consecuencia sin destinatario cuando lo necesita;
- referencia a objeto o personaje inexistente.

Durante desarrollo, estos errores deben producir información clara.

En una build publicada, el juego debe evitar bloquearse cuando exista una salida segura, pero no ocultar silenciosamente un estado incoherente durante las pruebas.

---

# 16. Dependencias permitidas

```text
GameController
├── GameState
├── CardRepository
├── ConditionEvaluator
├── ThreatResolver
├── ConsequenceExecutor
├── SaveService
└── PresentationCoordinator

PresentationCoordinator
├── CardView
├── HUD
├── DiceTray
├── DreamBackground
├── TransitionLayer
└── AudioController
```

Reglas de dependencia:

- la presentación no depende de `SaveService`;
- `ThreatResolver` no depende de `GameState`;
- `CardRepository` no depende del controlador;
- `ConsequenceExecutor` no depende de la UI;
- `SaveService` no depende de Resources visuales;
- los Resources no dependen de componentes de ejecución;
- `GameState` no depende de la presentación.

---

# 17. Ciclo de vida

## Alcance de aplicación

Persisten mientras el juego está abierto:

- catálogo de cartas;
- configuración general;
- controlador de audio;
- acceso al guardado.

## Alcance de partida

Persisten desde nueva partida o carga hasta volver al menú:

- `GameController`;
- `GameState`;
- pantalla principal de juego.

## Alcance de carta

Se reemplazan o reinician al cambiar de carta:

- modelo presentado;
- opciones disponibles;
- contexto de resolución.

## Alcance de ronda

Se reinician tras cada tirada:

- caras obtenidas;
- resultado pendiente de animación;
- efectos limitados a la ronda.

---

# 18. Pruebas previstas

La separación de responsabilidades debe permitir comprobar la lógica sin depender de animaciones.

Casos mínimos:

- cargar una carta por identificador;
- evaluar opciones disponibles;
- resolver una cara simple;
- resolver una cara con símbolo doble;
- utilizar y consumir el objeto Escudo;
- conservar progreso entre rondas;
- duplicar el objetivo con aliado;
- impedir cambiar participantes;
- aplicar daño de ronda fallida;
- aplicar una lista ordenada de consecuencias;
- respetar el destinatario;
- aplicar descanso una sola vez;
- rechazar un segundo aliado;
- guardar y reconstruir `GameState`;
- continuar desde la carta guardada;
- descartar el estado temporal al cerrar la carta.

No es necesario construir primero una infraestructura de pruebas extensa.

Las fronteras deben permitir añadir pruebas pequeñas donde reduzcan riesgo real.

---

# 19. Riesgos

## GameController excesivo

Mitigación:

Mantener en él el orden del flujo y delegar cálculos, mutaciones especializadas, guardado y presentación.

## Estado temporal filtrado a GameState

Mitigación:

Separar explícitamente `EncounterState` y destruirlo al cerrar la carta.

## Doble aplicación de resultados

Mitigación:

Cada resultado lógico se consume una sola vez y la interacción permanece bloqueada durante su representación.

## UI con reglas

Mitigación:

La UI recibe información ya calculada y emite únicamente intenciones.

## Arquitectura sobredimensionada

Mitigación:

Los componentes conceptuales pequeños pueden comenzar como operaciones internas bien delimitadas. Solo se separarán físicamente cuando aporten claridad o capacidad de prueba.

## Guardado incoherente

Mitigación:

Guardar únicamente después de cerrar la carta y validar el estado.

---

# 20. Fuera del alcance

La arquitectura de ejecución no incluirá:

- gestor genérico de misiones;
- árbol narrativo visual;
- bus global de eventos para toda interacción;
- contenedor de inyección de dependencias;
- máquina de estados genérica reutilizable;
- sistema de comandos con deshacer;
- event sourcing;
- base de datos;
- servidor;
- telemetría;
- multijugador;
- scripting de cartas;
- guardado durante una ronda;
- múltiples partidas;
- simulación física de dados;
- inteligencia artificial de enemigos.

---

# 21. Criterio de aceptación

La arquitectura será suficiente cuando permita completar esta secuencia:

```text
Iniciar o cargar partida
      ↓
Resolver CardResource por identificador
      ↓
Presentar carta y opciones válidas
      ↓
Elegir una opción
      ↓
Si existe una Amenaza:
seleccionar participantes
      ↓
Resolver una o varias rondas, si corresponde
      ↓
Representar los resultados calculados
      ↓
Aplicar consecuencias y, si corresponde, daño y descanso
      ↓
Actualizar y validar GameState
      ↓
Autoguardar
      ↓
Presentar la siguiente carta
```

La secuencia debe funcionar:

- sin lógica de juego en la UI;
- sin modificar Resources compartidos;
- sin Dados de Amenaza;
- sin Cordura persistente;
- sin guardar estado temporal;
- sin scripts exclusivos por carta;
- sin ampliar los sistemas definidos.

---

# 22. Principio final

> **El flujo coordina, la lógica resuelve, el estado conserva y la presentación comunica. Ninguna capa debe asumir la responsabilidad de otra.**
