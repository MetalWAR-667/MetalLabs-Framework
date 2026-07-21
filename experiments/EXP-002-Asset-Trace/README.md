# EXP-002: Asset Trace Utility

This is an MVP application designed to maintain a JSON-based catalog of game assets. It specifically follows the philosophy of "doing one thing and doing it well." It tracks new, modified, and missing assets based on SHA-256 hashes without relying on external dependencies or complex architectures.

## Requirements

- Python 3.12+
- `tkinter` support built into the Python installation.
- `Pillow` for image preview capabilities.
- `pygame` for audio playback.
- `PyMuPDF` for PDF receipt rendering.

## Usage

To start the utility, ensure requirements are installed:

```bash
pip install -r requirements.txt
python main.py
```

### Steps:
1. **Open Project**: Select the root folder of your project. The tool manages a hidden `.metallabs` folder. Data is persisted in `.metallabs/asset_catalog.json` and `.metallabs/sources.json`, and files attached as receipts are placed in `.metallabs/receipts/`.
2. **Scan**: Searches through configured `scan_roots` (e.g. `assets`, `raw-textures`). Only supported assets are indexed based on a strict whitelist of extensions (`png`, `jpg`, `jpeg`, `webp`, `gif`, `ogg`, `wav`, `mp3`, `ttf`, `otf`). Assets are marked as:
    - `NEW`: File encountered for the first time.
    - `OK`: File hasn't changed.
    - `MODIFIED`: File changed.
    - `MISSING`: Tracked file is missing from disk.
3. **Review & Organize**:
    - **Audit States**: Assets can be labeled as `PLACEHOLDER`, `DORMANT`, or `PRODUCTION`.
    - **Sources**: Manage global acquisition sources via `Project -> Sources...` or create/assign them inline from the Asset Inspector. Support associating receipts (PDF/images) with Source records.
    - **Preview**: Select an image or audio asset to view a rendered thumbnail or play playback controls directly inside the inspector. Sources with attached receipts will display a receipt preview thumbnail as well.
4. **Save**: Persists changes, newly created Sources, and hash differences to the respective JSON files inside `.metallabs/`.

## Testing

Run tests with standard `unittest`:

```bash
python -m unittest discover test/
```

## Design Decisions

- **Restricted Tooling**: Only standard library components and 3 approved external packages (`Pillow`, `pygame`, `PyMuPDF`) are used.
- **Separation of Concerns**: Splitting code across logical domain models, persistence layers, and UI components cleanly.
- **Strict Hash Semantic Pipeline**: Hash values (`sha256`) observed during scans are kept separate from the persisted baseline until a full transaction Save occurs.
- **Whitelist Enforcement Policy**: Only specific whitelisted asset extensions are processed and hashed, eliminating clutter from `.json`, `.gd`, `.md`, or hidden project files.

## Future Ideas (Out of Scope)

The following items were identified but explicitly rejected for this Sprint:

- Waveform generation or thumbnail generation caches.
- Bulk Asset editing or multi-Asset source assignment.
- Drag-and-drop support.
- Advanced database/ORM migration.
- Automatic metadata and license extraction/validation.
- Configuration UI to manage `scan_roots`.
