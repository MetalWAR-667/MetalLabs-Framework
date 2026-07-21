import unittest
from app.models import Asset, Project, Catalog

class TestModels(unittest.TestCase):
    def test_asset_serialization(self):
        asset = Asset(
            asset_uuid="uuid-1",
            display_name="test",
            relative_path="assets/test.png",
            sha256="abc",
            file_size=10,
            tags=["tag1", "tag2"]
        )
        data = asset.to_dict()
        self.assertEqual(data["display_name"], "test")
        self.assertEqual(data["tags"], ["tag1", "tag2"])

        asset_loaded = Asset.from_dict(data)
        self.assertEqual(asset_loaded.asset_uuid, "uuid-1")
        self.assertEqual(asset_loaded.tags, ["tag1", "tag2"])

    def test_catalog_serialization(self):
        project = Project(name="TestProj", scan_roots=["assets"])
        catalog = Catalog(project=project)

        data = catalog.to_dict()
        self.assertEqual(data["project"]["name"], "TestProj")

        catalog_loaded = Catalog.from_dict(data)
        self.assertEqual(catalog_loaded.project.name, "TestProj")

    def test_save_atomicity(self):
        import os
        import stat
        import tempfile
        from app.catalog import CatalogManager

        with tempfile.TemporaryDirectory() as project_root:
            manager = CatalogManager(project_root)
            manager.load()

            # Manually create a dirty asset
            asset = Asset(asset_uuid="123", display_name="test", relative_path="test.txt", sha256="", file_size=0, scan_status="NEW")
            asset._current_sha256 = "dummy_hash"
            asset._current_file_size = 100
            manager.catalog.assets.append(asset)

            # Ensure .metallabs exists
            os.makedirs(manager.metallabs_dir, exist_ok=True)

            # Break save_catalog by making the file readonly or a directory
            os.makedirs(manager.catalog_path, exist_ok=True)

            try:
                with self.assertRaises(Exception):
                    manager.save()

                # Internal state should remain dirty (NEW and empty hash)
                self.assertEqual(manager.catalog.assets[0].scan_status, "NEW")
                self.assertEqual(manager.catalog.assets[0].sha256, "")
            finally:
                os.rmdir(manager.catalog_path)

if __name__ == '__main__':
    unittest.main()
