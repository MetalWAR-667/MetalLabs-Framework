# MetalSync 1.1

MetalSync copia el contenido de un proyecto a una carpeta de Drive/Git de forma
incremental y segura.

## Archivos

- `metalsync.py`: código fuente.
- `metalsync.json`: configuración.
- `build_onefile.bat`: genera `MetalSync.exe`.
- `dry_run.bat`: simulación detallada para la carpeta `dist`.

## Configuración

Edita `metalsync.json` y usa barras normales `/`:

```json
{
    "source": "D:/Proyectos/LandsOfFolklore",
    "destination": "G:/Mi unidad/Repos/LandsOfFolklore"
}
```

No uses barras invertidas simples dentro del JSON:

```text
D:\Proyectos\LandsOfFolklore
```

Eso produce un error de escape en JSON.

## Probar con Python

```bat
python metalsync.py --dry-run --verbose
```

Sincronización real:

```bat
python metalsync.py
```

## Generar el onefile

Ejecuta:

```bat
build_onefile.bat
```

El script instala PyInstaller si no está disponible y genera:

```text
dist/
    MetalSync.exe
    metalsync.json
    README.md
```

`MetalSync.exe` busca `metalsync.json` en su misma carpeta.

## Primera prueba del ejecutable

Abre una consola dentro de `dist` y ejecuta:

```bat
MetalSync.exe --dry-run --verbose
```

También puedes copiar `dry_run.bat` dentro de `dist` o ejecutarlo desde allí.

## Comportamiento

- Copia archivos nuevos o modificados.
- Conserva la estructura de carpetas.
- Compara primero tamaño y fecha.
- Si los metadatos difieren, compara SHA-256.
- No elimina archivos del destino.
- Omite carpetas generadas y temporales configurados.
- Los `.uid` se conservan por defecto.

## Seguridad

MetalSync rechaza:

- origen y destino iguales;
- destino dentro del origen;
- configuraciones JSON inválidas;
- rutas de origen inexistentes.
