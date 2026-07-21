import os
import uuid
from typing import Set
from app.catalog import CatalogManager
from app.models import Asset
from app.hashing import calculate_sha256

class Scanner:
    def __init__(self, manager: CatalogManager):
        self.manager = manager

    def should_ignore(self, name: str) -> bool:
        """
        Check if a file or directory should be ignored.
        Ignores: hidden files/folders (starts with .), __pycache__, asset_catalog.json
        """
        if name.startswith('.'):
            return True
        if name == '__pycache__':
            return True
        if name == 'asset_catalog.json':
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
            # Check modification
            if existing_asset.sha256 == sha256:
                existing_asset.scan_status = "OK"
            else:
                existing_asset.scan_status = "MODIFIED"
                existing_asset.sha256 = sha256
                existing_asset.file_size = file_size

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
                sha256=sha256,
                file_size=file_size,
                asset_type=asset_type,
                scan_status="NEW"
            )
            self.manager.add_or_update_asset(new_asset)
