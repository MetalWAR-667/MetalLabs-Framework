#!/usr/bin/env python3
"""
MetalSync v1.1
==============

Sincroniza un proyecto de trabajo con una copia destinada a Git/Drive.

Características:
- Copia todo salvo exclusiones explícitas.
- Conserva la estructura relativa de carpetas.
- Comparación rápida por tamaño y fecha.
- Segundo control por SHA-256 cuando los metadatos no coinciden.
- No elimina archivos del destino.
- Muestra primero el plan de sincronización y pide confirmación.
- Soporta modo simulación (--dry-run).
- Soporta salida detallada (--verbose).
- Busca metalsync.json junto al script o junto al .exe generado por PyInstaller.
- Usa únicamente la librería estándar de Python.

Uso:
    MetalSync.exe
    MetalSync.exe --dry-run
    MetalSync.exe --verbose
    MetalSync.exe --config otra_config.json
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


APP_NAME = "MetalSync"
APP_VERSION = "1.2"
DEFAULT_CONFIG_NAME = "metalsync.json"
HASH_CHUNK_SIZE = 1024 * 1024
MTIME_TOLERANCE_SECONDS = 1.0


@dataclass
class SyncStats:
    scanned: int = 0
    copied: int = 0
    skipped: int = 0
    excluded: int = 0
    errors: int = 0
    bytes_copied: int = 0


@dataclass(frozen=True)
class SyncConfig:
    source: Path
    destination: Path
    exclude_directories: frozenset[str]
    exclude_extensions: frozenset[str]
    exclude_files: frozenset[str]
    exclude_globs: tuple[str, ...]


def application_directory() -> Path:
    """
    Devuelve la carpeta del script o del ejecutable onefile.

    En PyInstaller, sys.executable apunta al .exe lanzado por el usuario.
    En ejecución normal, usamos la carpeta de este archivo .py.
    """
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parent


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sincroniza un proyecto con una copia Git/Drive sin borrar archivos."
    )
    parser.add_argument(
        "--config",
        default=None,
        help=(
            "Ruta al archivo de configuración. "
            f"Por defecto: {DEFAULT_CONFIG_NAME} junto al script o ejecutable."
        ),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Muestra qué copiaría sin modificar el destino.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Muestra también archivos omitidos y excluidos.",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"{APP_NAME} {APP_VERSION}",
    )
    return parser.parse_args()


def resolve_config_path(config_argument: str | None) -> Path:
    if config_argument:
        return Path(config_argument).expanduser().resolve()
    return application_directory() / DEFAULT_CONFIG_NAME


def friendly_json_error(error: json.JSONDecodeError, config_path: Path) -> str:
    return (
        f"Error al leer {config_path.name}.\n\n"
        f"Detalle: {error.msg}, línea {error.lineno}, columna {error.colno}.\n\n"
        "En JSON, las rutas de Windows deben escribirse con barras normales:\n"
        '  "source": "D:/Proyectos/LandsOfFolklore"\n'
        '  "destination": "G:/Mi unidad/Repos/LandsOfFolklore"\n\n'
        "También serían válidas las barras invertidas dobles, pero se recomienda usar '/'."
    )


def normalize_user_path(value: str) -> Path:
    """
    Normaliza rutas ya válidas procedentes del JSON.

    Nota: un JSON con barras invertidas simples no puede llegar hasta aquí,
    porque el propio parser JSON lo rechaza antes.
    """
    normalized = value.strip().replace("\\", "/")
    return Path(normalized).expanduser().resolve()


def load_config(config_path: Path) -> SyncConfig:
    if not config_path.is_file():
        raise FileNotFoundError(
            f"No se encontró el archivo de configuración:\n{config_path}\n\n"
            f"Coloca {DEFAULT_CONFIG_NAME} junto a {APP_NAME}.exe "
            "o usa --config RUTA."
        )

    try:
        with config_path.open("r", encoding="utf-8") as file:
            raw = json.load(file)
    except json.JSONDecodeError as error:
        raise ValueError(friendly_json_error(error, config_path)) from error

    try:
        source_value = raw["source"]
        destination_value = raw["destination"]
    except KeyError as error:
        raise ValueError(
            f"Falta la propiedad obligatoria {error!s} en {config_path.name}."
        ) from error

    if not isinstance(source_value, str) or not isinstance(destination_value, str):
        raise ValueError("'source' y 'destination' deben ser cadenas de texto.")

    source = normalize_user_path(source_value)
    destination = normalize_user_path(destination_value)

    exclude_directories = frozenset(
        str(item).casefold() for item in raw.get("exclude_directories", [])
    )
    exclude_extensions = frozenset(
        normalize_extension(str(item))
        for item in raw.get("exclude_extensions", [])
    )
    exclude_files = frozenset(
        str(item).casefold() for item in raw.get("exclude_files", [])
    )
    exclude_globs = tuple(str(item) for item in raw.get("exclude_globs", []))

    return SyncConfig(
        source=source,
        destination=destination,
        exclude_directories=exclude_directories,
        exclude_extensions=exclude_extensions,
        exclude_files=exclude_files,
        exclude_globs=exclude_globs,
    )


def normalize_extension(extension: str) -> str:
    extension = extension.strip().casefold()
    if extension and not extension.startswith("."):
        extension = "." + extension
    return extension


def validate_paths(config: SyncConfig) -> None:
    source = config.source
    destination = config.destination

    if not source.is_dir():
        raise NotADirectoryError(
            f"El origen no existe o no es una carpeta:\n{source}"
        )

    if source == destination:
        raise ValueError("Origen y destino no pueden ser la misma carpeta.")

    if is_relative_to(destination, source):
        raise ValueError(
            "El destino no puede estar dentro del origen: "
            "provocaría una copia recursiva."
        )


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def path_matches_any_glob(relative_path: Path, patterns: Iterable[str]) -> bool:
    posix_path = relative_path.as_posix()
    return any(
        relative_path.match(pattern) or Path(posix_path).match(pattern)
        for pattern in patterns
    )


def should_exclude_file(
    source_file: Path,
    relative_path: Path,
    config: SyncConfig,
) -> bool:
    if source_file.name.casefold() in config.exclude_files:
        return True

    if source_file.suffix.casefold() in config.exclude_extensions:
        return True

    return path_matches_any_glob(relative_path, config.exclude_globs)


def iter_source_files(config: SyncConfig, verbose: bool, stats: SyncStats):
    source = config.source

    for current_root, directories, files in os.walk(source):
        root_path = Path(current_root)

        retained_directories: list[str] = []
        for directory in directories:
            relative_directory = (root_path / directory).relative_to(source)
            excluded = (
                directory.casefold() in config.exclude_directories
                or path_matches_any_glob(relative_directory, config.exclude_globs)
            )

            if excluded:
                stats.excluded += 1
                if verbose:
                    print(f"[EXCL] {relative_directory.as_posix()}/")
            else:
                retained_directories.append(directory)

        directories[:] = retained_directories

        for filename in files:
            source_file = root_path / filename
            relative_path = source_file.relative_to(source)
            stats.scanned += 1

            if should_exclude_file(source_file, relative_path, config):
                stats.excluded += 1
                if verbose:
                    print(f"[EXCL] {relative_path.as_posix()}")
                continue

            yield source_file, relative_path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as file:
        while chunk := file.read(HASH_CHUNK_SIZE):
            digest.update(chunk)

    return digest.hexdigest()


def files_are_equal(source_file: Path, destination_file: Path) -> bool:
    if not destination_file.is_file():
        return False

    source_stat = source_file.stat()
    destination_stat = destination_file.stat()

    if source_stat.st_size != destination_stat.st_size:
        return False

    time_difference = abs(source_stat.st_mtime - destination_stat.st_mtime)
    if time_difference <= MTIME_TOLERANCE_SECONDS:
        return True

    # Segundo control: evita copiar cuando solo cambió el timestamp.
    return sha256(source_file) == sha256(destination_file)


def human_size(size_bytes: int) -> str:
    value = float(size_bytes)
    units = ("B", "KiB", "MiB", "GiB", "TiB")

    for unit in units:
        if value < 1024 or unit == units[-1]:
            return f"{value:.2f} {unit}"
        value /= 1024

    return f"{size_bytes} B"


def build_sync_plan(
    config: SyncConfig,
    verbose: bool,
) -> tuple[SyncStats, list[tuple[Path, Path, Path, int]]]:
    """
    Analiza el origen y devuelve:
    - estadísticas preliminares;
    - lista de archivos que necesitan copiarse.
    """
    stats = SyncStats()
    plan: list[tuple[Path, Path, Path, int]] = []

    for source_file, relative_path in iter_source_files(config, verbose, stats):
        destination_file = config.destination / relative_path

        try:
            if files_are_equal(source_file, destination_file):
                stats.skipped += 1
                if verbose:
                    print(f"[SKIP] {relative_path.as_posix()}")
                continue

            file_size = source_file.stat().st_size
            plan.append((source_file, destination_file, relative_path, file_size))

        except OSError as error:
            stats.errors += 1
            print(f"[ERROR] {relative_path.as_posix()}: {error}", file=sys.stderr)

    return stats, plan


def print_sync_plan(
    plan: list[tuple[Path, Path, Path, int]],
    stats: SyncStats,
) -> None:
    print()
    print("Archivos pendientes de sincronización:")
    print("─" * 60)

    if not plan:
        print("No hay archivos nuevos o modificados.")
    else:
        for _, _, relative_path, file_size in plan:
            print(f"[COPY] {relative_path.as_posix()} ({human_size(file_size)})")

    print("─" * 60)
    print(f"Pendientes : {len(plan)}")
    print(f"Datos      : {human_size(sum(item[3] for item in plan))}")
    print(f"Omitidos   : {stats.skipped}")
    print(f"Excluidos  : {stats.excluded}")
    print(f"Errores    : {stats.errors}")


def confirm_sync() -> bool:
    while True:
        answer = input("\n¿Deseas proceder con la sincronización? [s/N]: ").strip().casefold()

        if answer in {"s", "si", "sí", "y", "yes"}:
            return True

        if answer in {"", "n", "no"}:
            return False

        print("Respuesta no válida. Escribe 's' para continuar o 'n' para cancelar.")


def execute_sync_plan(
    config: SyncConfig,
    plan: list[tuple[Path, Path, Path, int]],
) -> SyncStats:
    stats = SyncStats()
    config.destination.mkdir(parents=True, exist_ok=True)

    for source_file, destination_file, relative_path, file_size in plan:
        try:
            destination_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_file, destination_file)

            print(f"[COPY] {relative_path.as_posix()}")

            stats.copied += 1
            stats.bytes_copied += file_size

        except OSError as error:
            stats.errors += 1
            print(f"[ERROR] {relative_path.as_posix()}: {error}", file=sys.stderr)

    return stats


def print_summary(
    config: SyncConfig,
    stats: SyncStats,
    elapsed_seconds: float,
    dry_run: bool,
) -> None:
    mode = "SIMULACIÓN" if dry_run else "SINCRONIZACIÓN"

    print()
    print("─" * 60)
    print(f" {APP_NAME} {APP_VERSION} — {mode}")
    print("─" * 60)
    print(f" Origen     : {config.source}")
    print(f" Destino    : {config.destination}")
    print()
    print(f" Escaneados : {stats.scanned}")
    print(f" Copiados   : {stats.copied}")
    print(f" Omitidos   : {stats.skipped}")
    print(f" Excluidos  : {stats.excluded}")
    print(f" Errores    : {stats.errors}")
    print(f" Datos      : {human_size(stats.bytes_copied)}")
    print(f" Tiempo     : {elapsed_seconds:.2f} s")
    print("─" * 60)

    if stats.errors:
        print("Finalizado con errores.")
    elif dry_run:
        print("Simulación finalizada. No se modificó ningún archivo.")
    else:
        print("Sincronización finalizada.")


def pause_if_frozen() -> None:
    """
    Evita que la consola del .exe se cierre instantáneamente al hacer doble clic.
    No pausa cuando se ejecuta como script de Python.
    """
    if getattr(sys, "frozen", False):
        try:
            input("\nPulsa Enter para cerrar...")
        except EOFError:
            pass


def main() -> int:
    args = parse_args()
    start_time = time.perf_counter()

    try:
        config_path = resolve_config_path(args.config)
        config = load_config(config_path)
        validate_paths(config)

        analysis_stats, plan = build_sync_plan(
            config=config,
            verbose=args.verbose,
        )

        print_sync_plan(plan, analysis_stats)

        if args.dry_run:
            final_stats = analysis_stats
            final_stats.copied = len(plan)
            final_stats.bytes_copied = sum(item[3] for item in plan)

        elif not plan:
            final_stats = analysis_stats

        elif not confirm_sync():
            print("\nSincronización cancelada por el usuario.")
            final_stats = analysis_stats

        else:
            copy_stats = execute_sync_plan(config, plan)

            final_stats = analysis_stats
            final_stats.copied = copy_stats.copied
            final_stats.bytes_copied = copy_stats.bytes_copied
            final_stats.errors += copy_stats.errors

        elapsed = time.perf_counter() - start_time
        print_summary(config, final_stats, elapsed, args.dry_run)
        exit_code = 1 if final_stats.errors else 0

    except (ValueError, OSError) as error:
        print(f"\n[FATAL]\n{error}", file=sys.stderr)
        exit_code = 2

    pause_if_frozen()
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
