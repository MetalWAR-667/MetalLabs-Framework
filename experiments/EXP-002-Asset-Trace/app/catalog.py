import os
import uuid
from typing import Dict, List, Optional
from app.models import Catalog, Asset, Project, Source
from app.persistence import load_catalog, save_catalog, load_sources, save_sources

import shutil

class CatalogManager:
    """
    Manages catalog operations in memory, wrapping persistence and asset lookups.
    """
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.metallabs_dir = os.path.join(project_root, ".metallabs")
        self.catalog_path = os.path.join(self.metallabs_dir, "asset_catalog.json")
        self.old_catalog_path = os.path.join(project_root, "asset_catalog.json")
        self.sources_path = os.path.join(self.metallabs_dir, "sources.json")
        self.catalog: Catalog = Catalog()
        self.sources: List[Source] = []

    def load(self) -> bool:
        """
        Attempts to load the catalog from disk. Returns True if loaded, False if new.
        """
        # Migration logic
        if not os.path.exists(self.catalog_path) and os.path.exists(self.old_catalog_path):
            os.makedirs(self.metallabs_dir, exist_ok=True)
            # Try to load the old catalog first to ensure it's valid, but actually just copying is safer to preserve data completely.
            shutil.copy2(self.old_catalog_path, self.catalog_path)

            # Load from new path to verify it parses correctly
            loaded = load_catalog(self.catalog_path)
            if loaded:
                os.remove(self.old_catalog_path)
                self.catalog = loaded
                return True
            else:
                # If loading fails, keep the old one and raise an error, or just return False.
                # Since it was copied successfully, failure to load means it's corrupted anyway.
                # It's better to let standard load handle it and fail.
                pass

        self.sources = load_sources(self.sources_path)

        loaded = load_catalog(self.catalog_path)
        if loaded:
            self.catalog = loaded
            return True
        else:
            project_name = os.path.basename(os.path.normpath(self.project_root))
            self.catalog = Catalog(
                project=Project(name=project_name, scan_roots=["assets", "raw-textures"])
            )
            return False

    def save(self) -> None:
        """
        Saves the current catalog and sources state to disk.
        Converts NEW and MODIFIED to OK and promotes observed hashes.
        """
        for asset in self.catalog.assets:
            if asset.scan_status in ("NEW", "MODIFIED") and hasattr(asset, '_current_sha256') and asset._current_sha256:
                asset.sha256 = asset._current_sha256
                asset.file_size = asset._current_file_size
                asset.scan_status = "OK"

        os.makedirs(self.metallabs_dir, exist_ok=True)
        save_catalog(self.catalog, self.catalog_path)
        save_sources(self.sources, self.sources_path)

    def get_sources(self) -> List[Source]:
        """Returns the list of sources."""
        return self.sources

    def add_or_update_source(self, source: Source) -> None:
        for i, s in enumerate(self.sources):
            if s.source_uuid == source.source_uuid:
                self.sources[i] = source
                return
        self.sources.append(source)

    def remove_source(self, source_uuid: str) -> bool:
        """Removes a source if no asset references it. Returns True on success, False if referenced."""
        for asset in self.catalog.assets:
            if asset.source_uuid == source_uuid:
                return False

        self.sources = [s for s in self.sources if s.source_uuid != source_uuid]
        return True

    def get_asset_by_path(self, relative_path: str) -> Optional[Asset]:
        """
        Finds an asset in the catalog by its relative path.
        """
        for asset in self.catalog.assets:
            if asset.relative_path == relative_path:
                return asset
        return None

    def add_or_update_asset(self, asset: Asset) -> None:
        """
        Adds a new asset or replaces an existing one by relative_path.
        """
        existing = self.get_asset_by_path(asset.relative_path)
        if existing:
            # We found it, replace it in the list to keep order, or just update fields
            idx = self.catalog.assets.index(existing)
            self.catalog.assets[idx] = asset
        else:
            self.catalog.assets.append(asset)

    def mark_all_missing(self) -> None:
        """
        Temporary sets all assets to MISSING before a scan.
        The scanner will update those it finds to OK or MODIFIED.
        """
        for asset in self.catalog.assets:
            asset.scan_status = "MISSING"

    def get_assets(self) -> List[Asset]:
        """Returns the list of assets."""
        return self.catalog.assets
