# 08 Cards

**Estado: Fuente narrativa e historial editorial.**

La prosa y función narrativa de las seis cartas siguen vigentes. Los Resources
runtime canónicos son `data/cards/card_01_awaken.tres` hasta
`card_06_icnophage.tres`. Las IDs `card_001_*`, llamadas `set_next_card`,
referencias a inventario, uso del Escudo y créditos que aparecen en las notas
inferiores pertenecen al diseño previo y no describen literalmente la build.

Mapa funcional aceptado:

- Carta 01 presenta el mundo y avanza a Carta 02.
- Carta 02 introduce Atención ×1 y daño 1.
- Carta 03 permite sacrificar el objeto, volver a Carta 02 o superar Cordura ×2.
- Carta 04 ofrece Fuerza ×2 o Atención ×1 condicionada al sacrificio.
- Carta 05 incorpora o rechaza al Fugitivo.
- Carta 06 selecciona participantes, resuelve Cordura y abre el epílogo.

El epílogo audiovisual y `EndScreen` sustituyen la antigua secuencia descrita de
texto final y créditos. Comida y Escudo no ejecutan todavía sus efectos.

---

## Archivo editorial histórico

Las notas siguientes se preservan para trazabilidad narrativa. Cuando difieran
de `03_core_rules.md` o de los `.tres`, deben interpretarse como decisiones
anteriores, no como reglas actuales.

08_cards.md (Fragmento)

Configuración previa a la primera carta:

Al comenzar una nueva partida, el jugador elige uno de tres objetos iniciales disponibles.

El objeto elegido se añade al inventario antes de mostrar `card_001_despertar`.

01. El Despertar

ID: card_001_despertar
Título: Despertar

## Descripción:

El despertar no fue un tránsito. Fue una fractura.
La conciencia regresó como un cristal astillado —y cuando abrió los ojos, ya estaba allí.
En pie.

Suspendido sobre una plataforma inerte, hecha de un material tan extraño como irreconocible, que parecía recordar haber sido otra cosa, en otro tiempo, bajo otra mano.
Bajo la plataforma no había suelo.
Solo un vacío tan inmenso que la palabra caída perdía todo su significado.

El aire — si es que aquel hálito estancado de eones merecía ese nombre— se respiraba como quien intenta recordar un color olvidado.
No estaba soñando.

Era el intruso de una arquitectura onírica que jamás fue diseñada para ser contemplada por ojos humanos.
Configuración Visual y Sonora

## Configuración Visual y Sonora

Estado del Sueño (Shader): vortex_vacio  
Descripción visual: Un remolino de bruma monocromática que se succiona perpetuamente hacia un punto central infinito detrás de la carta. Color principal: Índigo violáceo muy profundo #1A1528 Acompañado 
por:Azul óleo #0F1C26. Movimiento muy lento. Como si el vacío respirase.
Referencia Técnica: Implementar mediante coordenadas polares en un CanvasItem shader. Mezclar una textura de ruido (FastNoiseLite) con un desplazamiento basado en TIME sobre el radio y el ángulo para generar el efecto de espiral y succión hacia el centro.

Intención Sonora (Audio): cue_despertar
Descripción: Un sonido seco de cristal rompiéndose (agudo), seguido de un zumbido de baja frecuencia (drone) que sugiere un espacio inmenso.
Ilustración: Silueta blanca sobre losa grisácea. Fondo negro absoluto con el shader de bruma en gris muy oscuro.

## Opciones

Opcion A: El Salto

Texto de la acción: "Arrojarse al vacío."
Condiciones: Ninguna.
Amenaza: Ninguna.
Consecuencias:
set_next_card: card_002_caida
Nota de diseño: Actúa como tutorial de entrada. El jugador debe aceptar la pérdida de control para iniciar el bucle de juego.
Notas de Auditoría (v0.1)
Fuente de Verdad (03): Sin Amenaza. Sin uso de símbolos. No hay desgaste de Salud.
Consistencia Técnica (05): El shader propuesto evita ray marching, cumpliendo con la restricción de rendimiento para 1920x1080.
Filosofía Narrativa: Se establece la "arquitectura imposible" y la "regla extraña de la realidad" (el aire como recuerdo) definida en la Visión.

02. El Descenso

ID: card_002_caida
Título: El Descenso

## Descripción:

No hay aceleración, solo una suspensión perpetua en el abismo. La gravedad aquí no es una ley física, sino una voluntad que te arrastra hacia una profundidad sin nombre.
A tu alrededor, el remolino de bruma se ha vuelto frenético. Las sombras se estiran y se contraen, adoptando formas que rozan el borde de tus recuerdos: rostros que nunca conociste, ciudades que se deshacen como ceniza, geometrías que hieren la vista.

El silencio ha sido sustituido por un siseo constante, miles de susurros solapados que intentan decirte algo antes de que el vacío te devore por completo. Si no logras fijar la mirada, si no separas la verdad de la ilusión, te perderás en la bruma mucho antes de llegar al fondo.

## Configuración Visual y Sonora

Estado del Sueño (Shader): vortex_inquietud
Descripción visual: El remolino anterior aumenta su velocidad. Se introducen "flashes" ocasionales de un color complementario (Empiezan a aparecer anomalías Azul gris tormenta #243443) que representan los destellos de las visiones Índigo #1A1528.
Intención Sonora (Audio): cue_viento_imposible
Descripción: Un sonido de viento que no es aire, sino una frecuencia eléctrica modulada, mezclada con susurros ininteligibles (procesados con mucho reverb).

## Opciones

Opcion A: Observar la bruma
Texto de la acción: "Discernir una ruta entre las sombras."
Amenaza:
Símbolo objetivo: ATENCIÓN
Cantidad base: 1 (Dificultad baja, tutorial).
Daño por ronda fallida: 1 Salud (El esfuerzo mental de filtrar la irrealidad agota el cuerpo).
Consecuencias (Éxito):
set_next_card: card_003_umbral
Nota narrativa: Logras divisar una estructura sólida que emerge del caos.
Consecuencias (Ronda fallida):
Texto: "Las visiones te confunden. El siseo se vuelve un grito en tus oídos."
(El jugador pierde 1 de Salud y vuelve a tirar hasta neutralizar el 1 de Atención).
Auditoría según 03_core_rules
Uso de Atención: Se alinea con la definición: "capacidad para observar, interpretar y descubrir anomalías".

## Mecánica de Dados:
El Protagonista tiene 2 caras con Atención (Caras 3 y 5).
Tiene un 33% de probabilidad de éxito por ronda.
Como el objetivo es solo 1, estadísticamente debería superarlo en 1-3 rondas, perdiendo quizás 1 o 2 puntos de Salud. Es un "desgaste" perfecto para empezar.
Escudo: No aparece en las caras del dado. Si fue el objeto inicial elegido y el jugador decide utilizarlo tras una ronda fallida, evita 1 punto de daño y desaparece del inventario.
No hay Aliado: Por lo tanto, el objetivo no se duplica. Se mantiene en 1.

03. El Umbral

ID: card_003_umbral
Título: El Umbral

Descripción:

La bruma se rasga. Por un instante, el caos se detiene.
Ante ti, una estructura emerge del vacío. No es una construcción hecha por manos humanas. Sus líneas no siguen la geometría que conoces, pero hay algo en su forma que sugiere un propósito: una entrada, un paso, un límite.

El siseo se apaga. Los susurros se retiran, como si aquel lugar les infundiera un respeto que no muestran ante ti.
Frente al umbral, aguarda una inscripción. No está grabada en piedra ni metal, sino en la sustancia misma de la arquitectura onírica. Cuando la miras, las palabras no se leen: se recuerdan.
"Quien cruce este umbral deberá abandonar algo de sí mismo."
No hay amenaza visible. No hay susurros. Solo la certeza de que aquella puerta no se abre con llaves, sino con pérdidas.
Sientes el peso del objeto que llevas contigo. No sabes si lo necesitarás más adelante. Pero sabes que, si lo guardas, este umbral no se abrirá.

## Configuración Visual y Sonora

Estado del Sueño (Shader): umbral_quietud
Descripción visual: El remolino se detiene casi por completo. Ahora el mundo empieza a mirar al jugador. Verde gris enfermizo #28352B/ Índigo #1A1528
Intención Sonora (Audio): cue_umbral
Descripción: Silencio presurizado. Una nota de diapasón grave y sostenida. Un latido rítmico muy tenue.

## Opciones

Opción A: Abandonar el objeto
Texto de la acción: "Dejar el objeto en el umbral y cruzar."
Condiciones: Poseer al menos 1 objeto.
Consecuencias:
remove_item: objeto_inicial_conservado
set_narrative_flag: objeto_sacrificado_en_umbral
set_next_card: card_004_acechador
Nota: El jugador elige el camino de la menor resistencia a cambio de recursos.
Si el objeto inicial ya fue consumido o perdido, esta opción permanece desactivada.

Opción B: Guardar el objeto
Texto de la acción: "Aferrarse a lo propio y retroceder."
Consecuencias:
set_next_card: card_002_caida
Nota de diseño: Crea un bucle narrativo. El jugador no avanza si no está dispuesto a sacrificar.
Opción C: Forzar el paso
Texto de la acción: "Imponer la propia voluntad sobre el umbral."

## Amenaza:

Símbolo objetivo: CORDURA (Representa la resistencia mental al rechazo del umbral).
Cantidad base: 2
Daño por ronda fallida: 2 Salud
Consecuencias (Éxito):
set_next_card: card_004_acechador
Texto: "Logras abrirte paso conservando tus pertenencias, pero el umbral se ha resentido. Sientes un frío nuevo en los huesos."
Consecuencias (Ronda fallida):
end_encounter: true
set_next_card: card_002_caida
Texto: "El umbral te rechaza con una fuerza ciega. La bruma te engulle de nuevo, más hambrienta que antes."
Auditoría según 03_core_rules
Símbolos: Se ha cambiado "Voluntad" por Cordura. El protagonista tiene 3 caras de Cordura en su dado (Caras 2, 4 y 6), lo que le da un 50% de probabilidad de éxito por dado. Pedir 2 unidades de Cordura hace que sea un reto real pero justo.
Daño: El daño de 2 Salud es significativo (probablemente el 20-33% de su vida total inicial), lo que valida la importancia de la decisión.
Objetos: Utiliza la mecánica de inventario de forma orgánica.
Bucle: La opción de volver a la card_002 es brillante para un juego de corta duración, ya que castiga la indecisión sin terminar la partida (Game Over), pero desgastando la salud si el jugador falla la Amenaza de la carta 02 al reintentarlo.

04. El Acechador de los Restos
ID: card_004_acechador
Título: El Acechador de los Restos

## Descripción:

Tras el umbral, la arquitectura se vuelve obscena. Las paredes de piedra parecen palpitar con una vida lenta y enferma, y el aire huele a cobre y a encierro milenario. No has caminado mucho cuando lo ves: una silueta que se desprende de las sombras, compuesta por una amalgama de extremidades residuales y fragmentos de cosas que alguna vez tuvieron forma.
Es el Acechador, el parásito de los que cruzan. Se alimenta de lo que los viajeros traen del mundo despierto.
[SI `objeto_sacrificado_en_umbral`]: La entidad está encorvada sobre el altar del umbral, devorando con ruidos húmedos el objeto que abandonaste. Sus ojos, múltiples y desordenados, apenas te registran mientras pasas. Tienes una oportunidad, pero el camino es estrecho.
[SI NO `objeto_sacrificado_en_umbral`]: La criatura emite un chillido que no nace de una garganta, sino de la fricción de sus partes muertas. Siente la vibración de lo que guardas. Para ella, ese objeto es un faro de realidad en este mundo de sombras, y no permitirá que lo lleves más lejos.
Configuración Visual y Sonora
Estado del Sueño (Shader): presencia_amenaza
Descripción visual: El fondo se tiñe de un rojo visceral muy oscuro. El remolino se vuelve errático, como si la bruma estuviera asustada. Índigo profundo #1A1528 Negro azulado #090B10 El shader casi parece un cielo vivo.
Intención Sonora (Audio): cue_acechador
Descripción: Un sonido de arrastre pesado sobre piedra, mezclado con crujidos óseos. La música sube de tono, volviéndose opresiva.

## Opciones

Opción A: Enfrentamiento Directo
Texto de la acción: "Hacer frente a la aberración."

## Amenaza:

Símbolo objetivo: FUERZA
Cantidad base: 2
Daño por ronda fallida: 2 Salud
Modificador de Objeto: La Escopeta garantiza un éxito automático de Fuerza al comenzar la Amenaza. La bonificación se aplica una sola vez durante el encuentro.
Consecuencias (Éxito):
set_next_card: card_005_refugio
Texto: "La entidad se deshace en un charco de brea y olvido. Has prevalecido, pero tu cuerpo registra cada golpe de esa danza macabra."
Consecuencias (Ronda fallida):
Texto: "Sus garras de materia imposible desgarran tu carne. El dolor es demasiado real para ser un sueño."

## Opción B: Intentar pasar desapercibido
Texto de la acción: "Deslizarse por la sombra mientras la bestia se alimenta."
Condiciones: `objeto_sacrificado_en_umbral` debe estar activa.

## Amenaza:

Símbolo objetivo: ATENCIÓN
Cantidad base: 1
Daño por ronda fallida: 1 Salud (El Acechador te nota y te lanza un zarpazo antes de que escapes).
Consecuencias (Éxito):
set_next_card: card_005_refugio
Texto: "Cruzas el pasillo conteniendo el aliento. El sacrificio ha cumplido su propósito: eres invisible para el hambre de la bestia."
Auditoría según 03_core_rules (Tutorial de Combate)
Dificultad de Fuerza: El protagonista solo tiene 1 cara de Fuerza (Cara 1). Pedir 2 éxitos de Fuerza es una amenaza muy alta para él solo.
Lección: El jugador aprenderá aquí que el combate físico es extremadamente peligroso y que debería haber buscado otra vía o necesitará un aliado de Fuerza pronto.
Uso de Salud: Con un daño de 2, el jugador sentirá que el combate no es algo que pueda hacer a la ligera. Es una carrera de desgaste.
Valor del Objeto:
Si sacrificó: Tiene acceso a la Opción B, que es mucho más fácil (Atención). Siente que su pérdida valió la pena.
Si conservó: Se ve obligado a la Opción A. Si el objeto era un arma, siente su utilidad. Si el objeto era inútil para el combate, siente el peso de su codicia.
Escudo: No aparece en los dados. Si el jugador eligió el Escudo como objeto inicial y aún lo conserva, puede consumirlo para evitar 1 punto de daño de una ronda fallida.

¿Con este "bautismo de fuego"?, el jugador ya ha aprendido:

A tomar decisiones difíciles (Umbral).
A gestionar su salud en un combate desigual (Acechador).
A valorar sus recursos.

05. El Refugio de las Sombras Largas
ID: card_005_refugio
Título: El Refugio de las Sombras Largas

## Descripción:

El pasillo de carne y piedra desemboca en una estancia que desafía la lógica del tormento previo. Aquí, las paredes no palpitan; están cubiertas por una biblioteca de volúmenes cuyas páginas son de aire y cuyos lomos están cosidos con hilos de memoria. En el centro, una pequeña hoguera de llamas azules consume sombras en lugar de madera.
Junto al fuego, una figura se ovilla con una quietud de siglos. Es un hombre, o el envoltorio de uno, cuya piel tiene la textura del pergamino viejo y cuya mirada parece haber visto el envés de la realidad durante demasiado tiempo.

—No eres el primero en caer —dice, y su voz suena como el roce de hojas secas—. Pero podrías ser el primero en no disolverse. Este lugar es un error en la trama del sueño. Un refugio. Pero el sueño no tolera los vacíos por mucho tiempo. Algo está tratando de filtrarse por las grietas del techo.

El Fugitivo Pálido se incorpora con una lentitud geológica y te ofrece una mano temblorosa. No es un guerrero, sino un testigo. Si lo aceptas, cargará con tu miedo, pero tu presencia en el sueño se volverá el doble de pesada.

## Configuración Visual y Sonora

Estado del Sueño (Shader): calma_azul
Descripción visual: El remolino de fondo es casi imperceptible. Una luz azul suave emana del centro de la pantalla. Partículas blancas (como ceniza o nieve) caen lentamente.
Intención Sonora (Audio): cue_refugio
Descripción: Una melodía de piano minimalista y melancólica, muy lejana, envuelta en el crepitar de la hoguera azul.

## Opciones

Opción A: Tender la mano al Fugitivo
Texto de la acción: "Aceptar su ayuda antes de abandonar el refugio."
Resolución:
- No contiene Amenaza.
- No se lanzan dados.
- El Fugitivo se incorpora siempre.
add_ally: fugitivo_palido
set_ally_current_health: max_health - 1
set_next_card: card_006_icnofago

Opción B: Rechazar su ayuda
Texto de la acción: "Apartarse del fuego y continuar solo."
Resolución:
- No contiene Amenaza.
- No se lanzan dados.
- El Fugitivo no se incorpora.
set_next_card: card_006_icnofago

La escarcha permanece como parte de la atmósfera del refugio, pero no constituye una Amenaza mecánica.
La selección de participantes y el descanso se explicarán en cartas posteriores, cuando el jugador ya disponga de un aliado.
Ficha Técnica del Aliado: El Fugitivo Pálido
Dado del Fugitivo:
Cara 1: Fuerza
Cara 2: Cordura
Cara 3: Cordura
Cara 4: Cordura
Cara 5: Atención
Cara 6: Cordura
Auditoría de Mecánicas
Incorporación de aliado: Depende exclusivamente de la decisión explícita del jugador.
Rechazo: Permite continuar sin incorporar al Fugitivo.
Alcance tutorial: Esta carta presenta una decisión binaria y prepara el estado runtime del aliado. No explica todavía selección de participantes ni descanso.
Sin Amenaza: La primera utilización mecánica del aliado se reserva para la Carta 06.

06. El Icnófago de Nácar
ID: card_006_icnofago
Título: El Icnófago de Nácar

## Descripción:

Más allá del refugio, el corredor desemboca en una llanura de sal negra bajo un cielo demasiado cercano. No hay estrellas. En su lugar, miles de huellas luminosas cruzan la bóveda celeste, como si generaciones de viajeros hubieran caminado alguna vez por la cara interior de la noche.
Una de aquellas huellas se detiene.

Después, desciende.

La criatura que toca la llanura posee seis patas largas y transparentes, articuladas como los dedos de una mano ahogada. Su cuerpo está cubierto por placas de nácar que reflejan lugares donde nunca has estado. No tiene ojos ni boca. En el lugar de la cabeza gira lentamente una cavidad oscura llena de pequeños senderos blancos.

El Fugitivo, si todavía te acompaña, retrocede al reconocerla.

—No devora cuerpos —susurra—. Devora los caminos que conducen fuera de aquí.

El Icnófago inclina su cavidad hacia ti. Las huellas que has dejado atrás comienzan a desprenderse del suelo y vuelan hacia su interior. Si consume la última, olvidarás que alguna vez existió un lugar al que regresar.

## Configuración Visual y Sonora

Estado del Sueño (Shader): llanura_nacar
Descripción visual: Superficie negra y mate atravesada por líneas blancas semejantes a huellas. La criatura refleja fragmentos invertidos de cartas anteriores sobre sus placas. El fondo permanece casi inmóvil mientras las huellas ascienden lentamente hacia su cabeza.
Intención Sonora (Audio): cue_icnofago
Descripción: Chasquidos delicados de porcelana, pasos reproducidos al revés y un coro muy grave que parece escucharse desde debajo del suelo.
Ilustración: Criatura hexápoda de extremidades transparentes y cuerpo de nácar. En lugar de rostro, una cavidad circular contiene una espiral de senderos luminosos.

## Opciones

Opción A: Recordar el camino
Texto de la acción: "Aferrarse al recuerdo del mundo despierto."

Amenaza:
Símbolo objetivo: CORDURA
Cantidad base: 1
Daño por ronda fallida:
- Protagonista solo: 1 Salud al protagonista.
- Protagonista y Fugitivo: 1 Salud a cada participante.
Protección:
El objeto Escudo puede evitar 1 punto de daño a uno de los destinatarios y desaparece después de utilizarse.
Selección de participantes:
- Si el Fugitivo no se incorporó en `card_005_refugio`, participa únicamente el protagonista.
- Si el Fugitivo está presente, el jugador elige entre protagonista solo o protagonista y aliado.
- Si participa el Fugitivo, el objetivo aumenta de CORDURA ×1 a CORDURA ×2.
- La elección se mantiene durante toda la Amenaza.
Consecuencias (Éxito):
set_next_screen: ending_vertical_slice
Texto con aliado: "El Fugitivo pronuncia tu nombre cuando tú estás a punto de olvidarlo. Las huellas regresan al suelo. El Icnófago se pliega sobre sí mismo hasta convertirse en una pequeña concha vacía."
Texto sin aliado: "Repites tu nombre hasta que deja de parecer una palabra. Es suficiente. Las huellas regresan al suelo y el Icnófago se pliega sobre sí mismo hasta convertirse en una pequeña concha vacía."
Descanso:
- Si el Fugitivo existe y el jugador decidió que no participase, recupera 1 punto de Salud al finalizar la carta.
- Si fue seleccionado, no descansa aunque una consecuencia pudiera impedirle actuar.
- Si no existe aliado, no se evalúa descanso.
Transición final:
La ilustración pierde progresivamente el color.
Las huellas luminosas se apagan una tras otra.
Fundido a negro.
Se muestra un breve texto de cierre.
Comienzan los créditos.
Auditoría de Mecánicas
Selección: La carta funciona con protagonista solo y habilita la elección de aliado únicamente cuando el Fugitivo está presente.
Escalado: La cantidad requerida se duplica con dos participantes conforme a 03_core_rules.
Especialización: El dado de Cordura del Fugitivo resulta valioso, pero participar expone su Salud.
Descanso: El Fugitivo se incorpora herido. Excluirlo voluntariamente permite mostrar una recuperación real de 1 Salud.
Daño: La propia carta declara de forma visible quién recibe daño en cada configuración.
Escudo: Continúa siendo un objeto consumible y protege solo contra 1 punto de daño.
Final: Ambas rutas conducen a la pantalla negra y a los créditos del corte vertical.
Nota de inspiración:
Criatura original inspirada en la fantasía onírica y el horror cósmico de la weird fiction. No adapta una criatura concreta de otro relato.

## Final del corte vertical
ID de pantalla: ending_vertical_slice
Tipo: Desenlace de presentación. No es una carta ni contiene una Amenaza.

Activación:

Se muestra después de superar `card_006_icnofago`.
Estado de partida:

- Se registra la partida como completada.
- Se ejecuta un último autoguardado.
- Una partida completada no habilita la opción CONTINUAR en el menú principal.
- Elegir NUEVA PARTIDA sustituye el autoguardado anterior mediante el flujo normal.

Secuencia:

1. Se bloquea la interacción de la carta 6.
2. Las huellas luminosas y la ilustración se desvanecen.
3. El audio realiza un fundido lento hasta dejar únicamente un ambiente grave.
4. La pantalla queda completamente negra.
5. Tras una pausa breve aparece el texto final.
6. El texto desaparece mediante fundido.
7. Se muestran los créditos sobre fondo negro.
8. Al terminar aparece la opción VOLVER AL MENÚ.

Texto final:

"No recordabas el camino.
Pero todavía recordabas que existía un lugar al que regresar."

Presentación:

- Fondo negro.
- Texto centrado en blanco o gris muy claro.
- Sin ilustraciones adicionales.
- Sin cinemática.
- Sin shader activo durante los créditos.
- Movimiento mínimo y lectura estable.

Audio:

- El ambiente de la carta 6 se desvanece durante el fundido.
- Puede mantenerse un drone casi imperceptible durante el texto final.
- Los créditos utilizan silencio o una única pista breve reutilizable.

Créditos mínimos:

- Título del juego.
- Diseño y desarrollo.
- Escritura.
- Arte e ilustraciones.
- Música y sonido.
- Fuentes, shaders y assets de terceros.
- Herramientas utilizadas cuando corresponda.
- Licencias y atribuciones obligatorias.
- Agradecimientos.

Interacción:

- El jugador puede avanzar del texto final a los créditos mediante una única acción.
- Los créditos pueden acelerarse o cerrarse después de mostrar las atribuciones obligatorias.
- VOLVER AL MENÚ es la única navegación necesaria al finalizar.

Criterio de aceptación:

- La carta 6 conduce siempre a `ending_vertical_slice` tras superarse.
- El final funciona tanto si el Fugitivo se incorporó como si no.
- El texto resulta legible en 1920 × 1080.
- Todas las atribuciones requeridas aparecen antes de permitir cerrar los créditos.
- Al volver al menú, CONTINUAR permanece deshabilitado para la partida completada.
- NUEVA PARTIDA permite comenzar de nuevo desde la selección de objeto inicial.

Principio:

El final debe confirmar que el corte vertical ha concluido sin prometer una resolución completa del sueño.
