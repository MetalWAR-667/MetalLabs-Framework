# EXP-002: Asset Trace Utility

This is an MVP application designed to maintain a JSON-based catalog of game assets. It specifically follows the philosophy of "doing one thing and doing it well." It tracks new, modified, and missing assets based on SHA-256 hashes without relying on external dependencies or complex architectures.

## Requirements

- Python 3.12+
- `tkinter` support built into the Python installation.

## Usage

To start the utility:

```bash
python main.py
```

### Steps:
1. **Open Project**: Select the root folder of your project. The tool expects folders like `assets/` and `raw-textures/` to exist relative to this root. If this is a new project, it will start a new catalog. If an `asset_catalog.json` exists in the root, it will be loaded.
2. **Scan**: Searches through the `scan_roots` (e.g. `assets`, `raw-textures`) and evaluates the `scan_status` of the assets based on SHA-256 hashes.
    - `NEW`: File encountered for the first time.
    - `OK`: File hasn't changed.
    - `MODIFIED`: File changed.
    - `MISSING`: Tracked file is missing from disk.
3. **Save**: Persists changes manually made in the Inspector and the scan results back to `asset_catalog.json` in the project root.

## Testing

Run tests with standard `unittest`:

```bash
python -m unittest discover tests
```

## Design Decisions

- **Pure Python standard library**: The app only uses the built-in libraries (`tkinter` for UI, `json` for persistence, `hashlib` for hashing, `dataclasses` for models).
- **Separation of Concerns**: Split code cleanly into models, catalog (in-memory manager), scanner (I/O logic), persistence (JSON dumping/loading), and UI.
- **Resilient Models**: Manual inputs are preserved during scans. `asset_catalog.json` dictates the single source of truth.
- **Excluded Items**: `.git`, `.godot`, hidden files (`.*`), `__pycache__`, symlinks, and the `asset_catalog.json` file itself are intentionally bypassed to avoid recursive headaches and unnecessary tracing.

## Future Ideas (Out of Scope)

The following items were identified but explicitly rejected for this MVP:

- Configuration UI to manage and edit `scan_roots` and valid folders.
- Management of a robust `Sources` list (creating Source templates such as "Itch.io", "Humble Bundle") with specific licenses.
- Automated cleanup/archiving of `MISSING` assets.
- Thumbnails/preview panel inside the Inspector.
- Advanced filtering capabilities (e.g., filtering by Tag or Asset Type).
- Integration to move/rename tracked assets without generating duplicate logs.
