## Proyecto experimental

Las pruebas de MetalLab se realizarán sobre **MetalWar Instaler AIS**, un instalador personalizable escrito en Python y concebido como homenaje deliberadamente excesivo a la Demoscene de los años noventa.

Repositorio:

`https://github.com/MetalWAR-667/MetalWar-Installer

MetalWar Installer no es únicamente una utilidad para copiar archivos. El proyecto combina lógica de instalación, reproducción de audio, sincronización musical, efectos gráficos en tiempo real, interfaz, operaciones de sistema y generación de ejecutables mediante PyInstaller.

### ¿Por qué MetalWar Installer?

La elección responde a tres razones principales.

**1. Es un proyecto prescindible**

MetalWar Installer no forma parte de la arquitectura crítica de *Lands of Folklore*. Puede modificarse, romperse, restaurarse o incluso descartarse sin comprometer el proyecto principal.

Esto permite experimentar con agentes de IA dentro de un entorno real, pero sin poner en riesgo sistemas importantes.

**2. Está absurdamente sobredimensionado**

Su complejidad supera ampliamente la que necesitaría un instalador convencional.

Precisamente por ello resulta útil como laboratorio: contiene suficientes sistemas, dependencias y decisiones extravagantes como para provocar situaciones interesantes durante las pruebas de mantenimiento, refactorización, creatividad y control del alcance.

La exageración no es un defecto accidental del proyecto. Es parte de su identidad y una característica deliberadamente aprovechable por MetalLab.

**3. Contiene ámbitos técnicos claramente diferenciados**

El repositorio ofrece varias superficies de intervención independientes:

| Módulo              | Función dentro del chasis                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------- |
| `main.py`           | El cigüeñal. Bucle principal, sincronización con el reloj musical y máquina de estados.           |
| `config.py`         | El octanaje. Parámetros globales, colores neón y constantes matemáticas.                          |
| `audio.py`          | La admisión. Carga de módulos tracker, gestión de canales y voz robótica.                         |
| `effects.py`        | La inyección de nitro. Campo de estrellas, transformaciones 3D y efectos CRT.                     |
| `ui.py`             | La carrocería. Logotipo ASCII, HUD táctico y representación visual del sistema.                   |
| `installer.py`      | Los pistones. Copia de archivos, detección de rutas y ejecución mediante hilos.                   |
| `utils.py`          | La caja de herramientas. Rutas de recursos, utilidades comunes y generación procedural de fallos. |
| `Compiler_GUIV2.py` | La prensa hidráulica. Generación del ejecutable OneFile mediante PyInstaller.                     |

Esta separación permite diseñar pruebas sobre capacidades diferentes sin cambiar de proyecto:

* lógica y control de estados;
* concurrencia y operaciones de sistema;
* gráficos y matemáticas;
* audio y sincronización;
* interfaz de usuario;
* configuración;
* empaquetado y distribución;
* refactorización de código monolítico.

### Función dentro de MetalLab

MetalWar Installer actuará como **sujeto experimental común** para los agentes participantes.

Cada agente trabajará sobre una copia aislada del mismo estado inicial y bajo un protocolo equivalente. Las modificaciones se realizarán en ramas o entornos separados, evitando que un agente pueda conocer o heredar las soluciones generadas por los demás.

El objetivo no será mejorar indefinidamente el instalador.

Su función será proporcionar un entorno suficientemente real, variado y prescindible en el que observar:

* cómo interpreta cada agente una tarea;
* cuánto respeta el alcance;
* qué grado de mutación introduce;
* cómo protege o altera la arquitectura existente;
* qué calidad y coste de revisión produce;
* y qué capacidad de invención muestra cuando las restricciones se reducen.

MetalWar Installer no es el producto final de MetalLab.

Es la arena.