import os
import uuid
from typing import Dict, List, Optional
from app.models import Catalog, Asset, Project
from app.persistence import load_catalog, save_catalog

class CatalogManager:
    """
    Manages catalog operations in memory, wrapping persistence and asset lookups.
    """
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.catalog_path = os.path.join(project_root, "asset_catalog.json")
        self.catalog: Catalog = Catalog()

    def load(self) -> bool:
        """
        Attempts to load the catalog from disk. Returns True if loaded, False if new.
        """
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
        Saves the current catalog state to disk.
        """
        save_catalog(self.catalog, self.catalog_path)

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
