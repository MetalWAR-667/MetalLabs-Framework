📖 Framework

Es el laboratorio.

Aquí viven las reglas permanentes.

No contiene experimentos.

Contiene la metodología.

Cuando cambia el Framework, cambia el laboratorio entero.

🚗 Vehicles

Son los vehículos experimentales.

Cada carpeta es una copia completamente aislada del mismo proyecto base.

Todos los agentes comienzan exactamente desde el mismo estado inicial.

Los vehículos son desechables.

Si un experimento destruye completamente uno de ellos, simplemente se elimina y se genera una nueva copia limpia.

Los vehículos nunca contienen documentación experimental.

Solo contienen código.

🗃️ Agent Dossiers

Es el historial permanente de cada participante.

Cada agente dispone de su propio expediente.

En él se registran:

prompts utilizados;
registros experimentales;
informes de resultados;
observaciones;
fortalezas detectadas;
debilidades observadas;
conclusiones acumuladas.

El dossier permanece incluso cuando el vehículo utilizado durante la prueba ha sido eliminado.

🔬 Results

Contiene únicamente el resultado final del laboratorio.

Aquí no hay opiniones.

Solo evidencia.

Por ejemplo:

EXP-001

Ganador:
Codex

Motivo:
Menor coste de revisión.

Observaciones:
Claude propuso una arquitectura interesante.
Gemini produjo una solución creativa.
Codex presentó la implementación más integrable.



La metodología queda muy clara
📖 Framework
        │
        ▼
Se define el protocolo
        │
        ▼
🚗 Vehicle limpio
        │
        ▼
🤖 Agente trabaja
        │
        ▼
🗃️ Se documenta todo
        │
        ▼
🔬 Se evalúan resultados
        │
        ▼
Framework mejora (si procede)

🧪 MetalLab Framework
│
├── 📖 Framework
│   ├── MetalLab Framework.md
│   ├── Escenario 01 - MetalWar Installer.md
│   └── (Futuros escenarios)
│
├── 🚗 Vehicles
│   ├── Claude
│   ├── Codex
│   ├── GeminiChat
│   └── Jules - Repositorio GitHub
│
├── 🗃️ Agent Dossiers
│   │
│   ├── Claude
│   │   ├── Prompts
│   │   ├── Experiment Logs
│   │   ├── Reports
│   │   └── Notes
│   │
│   ├── Codex
│   │   ├── Prompts
│   │   ├── Experiment Logs
│   │   ├── Reports
│   │   └── Notes
│   │
│   ├── Gemini
│   │   ├── Prompts
│   │   ├── Experiment Logs
│   │   ├── Reports
│   │   └── Notes
│   │
│   ├── DeepSeek
│   │   └── ...
│   │
│   └── Jules
│       └── ...
│
└── 🔬 Results
    ├── Accepted
    ├── Rejected
    └── Conclusions
	
	
Regla de acceso al repositorio

Jules será el único agente autorizado a trabajar directamente sobre el repositorio remoto de GitHub.
Esta excepción existe porque Jules está diseñado para integrarse de forma nativa con GitHub y forma parte del objeto de estudio del laboratorio.

Su capacidad para interactuar con ramas, commits y pull requests reales constituye una característica propia del agente y, por tanto, forma parte del experimento.
El resto de agentes trabajarán exclusivamente sobre vehículos locales completamente aislados.

Esta organización responde al entorno disponible durante las primeras pruebas.
Si en el futuro otros agentes disponen de integración nativa equivalente con GitHub,
el protocolo podrá ampliarse sin modificar el Framework.


De esta forma:

el entorno experimental permanece reproducible;
se evita la contaminación entre agentes;
todos parten del mismo estado inicial;
únicamente Jules ejerce el papel de agente conectado al repositorio oficial.