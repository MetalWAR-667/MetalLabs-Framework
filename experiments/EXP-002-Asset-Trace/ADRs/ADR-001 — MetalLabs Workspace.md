ADR-001 — MetalLabs Workspace

Estado: Accepted

Objetivo

Definir dónde almacenan las herramientas de MetalLabs los metadatos asociados a un proyecto.

Decisión

Todas las herramientas de MetalLabs almacenarán sus datos dentro de una carpeta oculta situada en la raíz del proyecto inspeccionado.

<project_root>/
│
├── assets/
├── raw-textures/
│
└── .metallabs/

La utilidad nunca almacenará información dentro de su propia instalación.

Consecuencias

Ventajas:

El proyecto es autocontenido.
Los metadatos viajan con el proyecto.
Compatible con Git.
Permite futuras herramientas.