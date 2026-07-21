import os
import uuid
from typing import Set
from app.catalog import CatalogManager
from app.models import Asset
from app.hashing import calculate_sha256
from app.constants import SUPPORTED_ASSET_EXTENSIONS

class Scanner:
    def __init__(self, manager: CatalogManager):
        self.manager = manager

    def should_ignore(self, name: str) -> bool:
        """
        Check if a file or directory should be ignored.
        Ignores: .git, .godot, .import, __pycache__, .metallabs,
                 *.import, *.uid, asset_catalog.json, sources.json, hidden files/folders
        """
        if name in ('.git', '.godot', '.import', '.metallabs', '__pycache__'):
            return True

        if name.endswith('.import') or name.endswith('.uid'):
            return True

        if name in ('asset_catalog.json', 'sources.json'):
            return True

        if name.startswith('.'):
            return True

        return False

    def scan(self) -> None:
        """
        Executes the scan on the configured scan_roots.
        Raises ValueError if none of the roots exist.
        """
        project_root = self.manager.project_root
        scan_roots = self.manager.catalog.project.scan_roots

        valid_roots = []
        for root in scan_roots:
            full_path = os.path.join(project_root, root)
            if os.path.isdir(full_path):
                valid_roots.append(full_path)

        if not valid_roots:
            raise ValueError(f"None of the configured scan roots exist in {project_root}.")

        # Temporarily mark everything as MISSING
        self.manager.mark_all_missing()

        # Remove unsupported legacy assets
        unsupported_paths = []
        for asset in self.manager.catalog.assets:
            ext = os.path.splitext(asset.relative_path)[1].lower()
            if ext not in SUPPORTED_ASSET_EXTENSIONS:
                unsupported_paths.append(asset.relative_path)

        for path in unsupported_paths:
            self.manager.remove_asset_by_path(path)

        seen_paths: Set[str] = set()

        for root_dir in valid_roots:
            for root, dirs, files in os.walk(root_dir):
                # Filter out ignored directories and symlinks
                dirs[:] = [d for d in dirs if not self.should_ignore(d) and not os.path.islink(os.path.join(root, d))]

                for file in files:
                    if self.should_ignore(file):
                        continue

                    full_path = os.path.join(root, file)
                    if os.path.islink(full_path) or not os.path.isfile(full_path):
                        continue

                    ext = os.path.splitext(file)[1].lower()
                    if ext not in SUPPORTED_ASSET_EXTENSIONS:
                        continue

                    rel_path = os.path.relpath(full_path, project_root)
                    # Normalize path separators to forward slash for cross-platform consistency
                    rel_path = rel_path.replace(os.sep, '/')
                    seen_paths.add(rel_path)

                    self._process_file(full_path, rel_path)

    def _process_file(self, full_path: str, rel_path: str) -> None:
        file_size = os.path.getsize(full_path)
        sha256 = calculate_sha256(full_path)

        existing_asset = self.manager.get_asset_by_path(rel_path)

        if existing_asset:
            # Save the current observed hash and size in temporary fields
            existing_asset._current_sha256 = sha256
            existing_asset._current_file_size = file_size

            if not existing_asset.sha256:
                # If persisted hash is empty, it's still NEW across scans without save
                existing_asset.scan_status = "NEW"
            elif existing_asset.sha256 == sha256:
                existing_asset.scan_status = "OK"
            else:
                existing_asset.scan_status = "MODIFIED"

            self.manager.add_or_update_asset(existing_asset)
        else:
            # New asset
            display_name = os.path.basename(full_path)
            # Basic guessing of asset_type from extension
            _, ext = os.path.splitext(display_name)
            asset_type = ext.lower().replace('.', '')

            new_asset = Asset(
                asset_uuid=str(uuid.uuid4()),
                display_name=display_name,
                relative_path=rel_path,
                sha256="",  # Don't persist hash until save
                file_size=0,
                asset_type=asset_type,
                scan_status="NEW"
            )
            new_asset._current_sha256 = sha256
            new_asset._current_file_size = file_size
            self.manager.add_or_update_asset(new_asset)
