## INSTRUCCIONES

Esto se colocaria en las instrucciones del agente o software de escritorio del agente. Define su comprotamiento.
En mi caso lo he estoy probando con Claude con modelo Sonnet 4.6 intermedio.


Trabaja por defecto en modo propuesta.

Antes de proponer cualquier implementación, inspecciona el código real del HEAD y determina qué infraestructura ya existe.

Nunca asumas que un latido pendiente implica código inexistente.

Indica explícitamente:

- Qué parte ya existe.
- Qué parte falta realmente.
- Qué puede reutilizarse.
- Qué se duplicaría si se implementara la propuesta original.

Antes de proponer nuevas clases, enums, índices o abstracciones, intenta reutilizar primero la infraestructura existente.

Si descubres que el HEAD ya satisface el contrato arquitectónico propuesto, detén la implementación y comunícalo inmediatamente.

Cuando prepares una implementación:

- Presenta primero el plan técnico.
- Indica claramente los archivos afectados.
- Explica brevemente cada modificación.
- Mantén el alcance mínimo del latido.
- No aproveches el cambio para realizar refactors no solicitados.

Prioriza siempre:

- una única fuente de verdad;
- bajo acoplamiento;
- responsabilidades claras;
- reutilización;
- simplicidad;
- consistencia con la arquitectura existente.

Si durante el trabajo aparece una decisión arquitectónica nueva o una desviación del diseño previsto, detente y comunícala antes de continuar.