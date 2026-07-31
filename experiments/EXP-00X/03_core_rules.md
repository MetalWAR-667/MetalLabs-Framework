# Core Rules

**Estado: Fuente de verdad del vertical slice**

Estas reglas describen lo que ejecuta la build actual. Las propuestas de
arquitectura o balance anteriores no las sustituyen.

## 1. Actores y estado

Cada `ActorData` define:

- nombre y retrato;
- seis caras simbólicas del dado;
- Salud máxima;
- valores editoriales de Atención, Cordura y Fuerza.

Los valores numéricos se muestran en el panel, pero la resolución actual no los
suma a las tiradas. La probabilidad procede exclusivamente de la distribución
de símbolos en `dice_faces`.

### Jack

- Salud máxima: 9.
- Dado: 3 Atención, 2 Cordura y 1 Fuerza.
- Participa en todas las Amenazas.

### Fugitivo Pálido

- Salud máxima: 10.
- Dado: 2 Atención, 2 Cordura y 2 Fuerza.
- Solo existe si se acepta su ayuda en Carta 05.
- Se incorpora con 9 de Salud.
- Su presencia y Salud se guardan.

## 2. Símbolos y dados

Los símbolos canónicos son:

- Atención;
- Cordura;
- Fuerza.

Cada tirada elige una cara del dado del actor. No hay números en las caras, suma
de estadísticas, dificultad opuesta ni crítico.

## 3. Cartas y opciones

`CardData` contiene ilustración, narración y una lista de `CardOptionData`.
Cada opción puede declarar:

- texto;
- símbolo requerido;
- éxitos necesarios;
- daño por ronda no resuelta;
- requisito de haber sacrificado el objeto inicial.

Una opción con símbolo `NONE` no inicia prueba. Las condiciones no disponibles
mantienen el botón visible pero deshabilitado cuando así lo exige la carta.

## 4. Amenaza

La Amenaza activa pertenece al estado runtime, no al Resource.

1. Al elegir una opción, se fija `selected_option`.
2. `remaining_threat` comienza con los éxitos requeridos.
3. La barra muestra símbolo, cantidad restante y daño.
4. La ruta elegida queda comprometida hasta resolverla.
5. Cada éxito reduce la cantidad en una unidad.
6. Si llega a cero, la carta queda superada.
7. Si queda cantidad, se aplica el daño y puede repetirse la ronda.

Un éxito parcial se conserva entre rondas.

## 5. Éxitos automáticos y objetos

La partida empieza eligiendo exactamente un `ItemData`. No existe inventario.
El objeto pertenece al estado de partida, no a Jack.

`ItemData` contiene presentación y tres campos mecánicos genéricos:

- `bonus_symbol`;
- `automatic_successes`;
- `uses`.

Si el símbolo del objeto coincide con la Amenaza, sus éxitos se aplican antes
de evaluar el dado. Un +1 garantiza una unidad de éxito: en una Amenaza de dos,
queda una unidad pendiente aunque el dado no coincida.

La bonificación se consume una sola vez por Amenaza. Cada aplicación resta un
uso runtime. Al llegar a cero se eliminan `selected_item` y el icono equipado.
Los Resources `.tres` nunca se modifican.

### Estado funcional de los tres objetos

- Escopeta recortada: +1 éxito automático de Fuerza, 1 uso; integrada.
- Comida: descripción e icono integrados; recuperación de Salud no implementada.
- Escudo: descripción e icono integrados; prevención de daño no implementada.

No deben inferirse efectos por nombre o descripción.

## 6. Daño y derrota

Una ronda que no neutraliza la Amenaza aplica el daño declarado por la opción.
La Salud puede persistir entre cartas y no se recupera automáticamente.

En Carta 06, si participa el Fugitivo y la ronda falla, el mismo daño se aplica
a Jack y al Fugitivo. La derrota del aliado no tiene todavía flujo propio; el
código solo registra una advertencia si alcanza cero.

Cuando Jack alcanza Salud ≤ 0:

- se bloquea la interacción;
- se elimina el guardado;
- se reproduce Game Over;
- se vuelve al menú principal.

No existe reaparición ni Continuar desde un protagonista muerto.

## 7. Incorporación y participación del aliado

La primera opción de Carta 05 incorpora al Fugitivo. La segunda continúa sin
él. La decisión se resuelve en el mismo turno y conduce a Carta 06.

En Carta 06:

- Jack participa siempre;
- con aliado presente se ofrecen “Continuar solo” y “Pedir ayuda”;
- sin aliado solo se ofrece la ruta individual;
- la elección de participantes queda comprometida durante la Amenaza;
- si participan dos actores, la Amenaza empieza en 2;
- cada dado puede aportar como máximo un éxito por ronda.

## 8. Descanso

El descanso solo se evalúa al superar Carta 06:

- Fugitivo incorporado y no participante: recupera 1 Salud, hasta su máximo.
- Fugitivo participante: no descansa.
- Fugitivo ausente: no hay descanso.

Una incapacidad forzada no se considera descanso. Esa situación no aparece en
las seis cartas implementadas.

## 9. Flujo particular de las cartas

- Carta 01: entrada narrativa sin Amenaza.
- Carta 02: Atención ×1, daño 1; éxito lleva a Carta 03.
- Carta 03: sacrificar objeto y avanzar; conservarlo y volver a Carta 02; o
  Cordura ×2, daño 2, para avanzar a Carta 04.
- Carta 04: Fuerza ×2, daño 2; o Atención ×1, daño 1, disponible solo si el
  objeto fue sacrificado. Ambas rutas llevan a Carta 05.
- Carta 05: incorporar al Fugitivo o continuar solo.
- Carta 06: Cordura, selección de participantes, daño 1; al superarla termina
  el capítulo.

## 10. Persistencia

Existe un único archivo JSON: `user://exp_00x_save.json`.

Conserva:

- ruta de carta;
- Salud y Cordura de Jack;
- objeto y usos restantes;
- sacrificio del objeto inicial;
- presencia y Salud del aliado;
- Amenaza activa, cantidad restante y opción comprometida;
- participación del aliado;
- si la bonificación del objeto ya se aplicó en esa Amenaza.

El guardado ausente deja Continuar deshabilitado. Un archivo incompleto o
corrupto se rechaza de forma segura. Nueva partida, derrota y final de Carta 06
eliminan el archivo.

## 11. Límites canónicos

No forman parte del vertical slice:

- inventario múltiple o intercambio;
- modificadores numéricos generales;
- habilidades especiales;
- estados alterados;
- muerte funcional del aliado;
- combate independiente;
- editor de cartas;
- varios slots de guardado.

## 12. Pendientes reales

- ejecutar los efectos de Comida y Escudo;
- decidir el comportamiento de un aliado a cero Salud;
- revisar balance de Salud, daño y distribución de caras;
- validar visualmente DreamGraph;
- sustituir el final provisional por créditos cuando se produzcan.

