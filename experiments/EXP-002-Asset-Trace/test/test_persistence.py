import unittest
import os
import tempfile
from app.models import Asset, Catalog, Project
from app.catalog import CatalogManager
from app.persistence import save_catalog, load_catalog

class TestPersistenceAndCatalog(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.project_root = self.temp_dir.name

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_catalog_manager_new(self):
        manager = CatalogManager(self.project_root)
        self.assertFalse(manager.load())
        self.assertEqual(manager.catalog.project.name, os.path.basename(self.project_root))
        self.assertEqual(manager.catalog.project.scan_roots, ["assets", "raw-textures"])

    def test_catalog_save_and_load(self):
        manager = CatalogManager(self.project_root)
        manager.load()
        asset = Asset(
            asset_uuid="123",
            display_name="test",
            relative_path="assets/test.png",
            sha256="abc",
            file_size=10
        )
        manager.add_or_update_asset(asset)
        manager.save()

        manager2 = CatalogManager(self.project_root)
        self.assertTrue(manager2.load())
        self.assertEqual(len(manager2.catalog.assets), 1)
        self.assertEqual(manager2.catalog.assets[0].display_name, "test")

    def test_source_attribution_fields(self):
        from app.models import Source
        manager = CatalogManager(self.project_root)
        manager.load()
        source = Source(
            source_uuid="src-1",
            requires_attribution=True,
            attribution_text="Please credit me."
        )
        manager.add_or_update_source(source)
        manager.save()

        manager2 = CatalogManager(self.project_root)
        self.assertTrue(manager2.load())
        sources = manager2.get_sources()
        self.assertEqual(len(sources), 1)
        self.assertTrue(sources[0].requires_attribution)
        self.assertEqual(sources[0].attribution_text, "Please credit me.")

if __name__ == '__main__':
    unittest.main()
