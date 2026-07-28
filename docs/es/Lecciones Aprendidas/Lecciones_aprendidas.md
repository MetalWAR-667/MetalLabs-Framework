Manifiesto MetalLab

1. Escribe código con resistencia.

Cada línea nueva debe justificar su existencia.

2. Diseña para el problema presente.

El futuro todavía no existe.
La arquitectura sí debe permitir crecer.
La implementación no debe anticiparlo todo.

3. Integra despacio.

Experimenta todo lo que quieras.
Pero el repositorio principal solo recibe código comprendido, auditado y validado.

4. Specification Driven Vibe Coding

El verdadero Vibe Coding no consiste en pedirle a una IA que programe una idea. Consiste en dirigir a un ingeniero extremadamente rápido mediante especificaciones precisas.

5. Specification Driven Learning.

No aprender "matemáticas".

Aprender exactamente las matemáticas que necesita el problema que tienes delante.

Ejemplo.

No estudias Álgebra Lineal durante seis meses.

Estudias:

vectores;
producto escalar;
matrices de transformación;
espacios.

Porque hoy quieres construir una cámara.
Dentro de dos semanas necesitarás cuaterniones.
Entonces los estudias.

6. El verdadero límite

Durante años asumí que el principal obstáculo para construir proyectos complejos era la cantidad de conocimientos técnicos necesarios.

Tras meses trabajando con IA, arquitectura y desarrollo iterativo, he llegado a una conclusión diferente.

El verdadero límite rara vez es el lenguaje de programación.

Tampoco es la herramienta.

Ni siquiera la IA.

El verdadero límite suele ser mucho más sencillo de formular:

¿Estoy dispuesto a dedicar el tiempo necesario para comprender este problema?

Las IAs no eliminan la necesidad de aprender.

Lo que hacen es reducir enormemente el coste de ese aprendizaje.

Permiten preguntar, equivocarse, experimentar, auditar hipótesis y construir un modelo mental con una velocidad impensable hace unos años.

Pero siguen existiendo conceptos que deben ser comprendidos por quien diseña el sistema:

matemáticas;
geometría;
física;
teoría de algoritmos;
arquitectura de software.

La IA puede explicar estos modelos, responder preguntas, proponer experimentos y revisar razonamientos.

Sin embargo, no puede sustituir el momento en el que el desarrollador comprende realmente el problema.

Por eso, el límite deja de ser:

"No sé hacer esto."

Y pasa a ser:

"¿Quiero invertir el tiempo necesario para entenderlo?"

7. Pequeñas victorias

Los proyectos pequeños no sirven únicamente para validar ideas. Sirven para validar al ingeniero que las construye.

8. Documentación Viva

La documentación no es una fotografía del proyecto. Es parte del proyecto.

Cada sprint termina únicamente cuando:

el código refleja el comportamiento esperado;
la documentación describe exactamente ese comportamiento;
ambos pueden auditarse conjuntamente.

La deuda documental es deuda técnica.

Cuanto más tiempo permanezcan desincronizados el código y la documentación, mayor será el coste de recuperar la coherencia del proyecto.

9. Diseñar de dentro hacia fuera

Muchos proyectos fracasan porque comienzan diseñando profundidad antes de validar el núcleo jugable.

La estrategia utilizada en EXP-00X ha demostrado el enfoque contrario:

Construir el bucle mínimo completamente funcional.
Validar que resulta comprensible y divertido.
Incorporar una única mecánica nueva cada vez.
Repetir el proceso.

La profundidad no se diseña primero.

Se descubre ampliando un núcleo que ya funciona.

10. Semántica unificada (zopenco, unifica nombres y organizate)

Los agentes no interpretan la intención únicamente por contexto. También reconstruyen el sistema a partir de nombres de archivos, clases, nodos y documentación.

Cuando un mismo concepto recibe nombres distintos, aumenta:

el coste de búsqueda;
la ambigüedad;
el riesgo de duplicación;
la probabilidad de modificar la pieza equivocada;
el tiempo humano de revisión.

Por ello, cada componente debe poseer un nombre canónico compartido por:

documentación;
clase;
nodo raíz;
escena;
script;
referencias en prompts.

Las diferencias de formato son aceptables:

CardThreatBar
card_threat_bar.tscn
card_threat_bar.gd

Las diferencias semánticas no:

ThreatPanel
cardthreatbar.tscn
DangerWidget

Y la frase corta:

La arquitectura también se expresa mediante nombres. Si los nombres divergen, la arquitectura empieza a ocultarse.