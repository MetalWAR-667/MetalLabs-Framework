import unittest
import os
import shutil
import tempfile
import json
from app.catalog import CatalogManager
from app.models import Catalog, Project

class TestMigration(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.old_catalog_path = os.path.join(self.test_dir, "asset_catalog.json")
        self.metallabs_dir = os.path.join(self.test_dir, ".metallabs")
        self.new_catalog_path = os.path.join(self.metallabs_dir, "asset_catalog.json")

    def tearDown(self):
        shutil.rmtree(self.test_dir)

    def test_migration_existing_old_catalog(self):
        # Create an old catalog in the root
        old_catalog = Catalog(project=Project(name="TestProj", scan_roots=["assets"]))
        with open(self.old_catalog_path, 'w', encoding='utf-8') as f:
            json.dump(old_catalog.to_dict(), f)

        # Load using manager
        manager = CatalogManager(self.test_dir)
        loaded = manager.load()

        self.assertTrue(loaded)
        self.assertTrue(os.path.exists(self.metallabs_dir))
        self.assertTrue(os.path.exists(self.new_catalog_path))
        self.assertFalse(os.path.exists(self.old_catalog_path))
        self.assertEqual(manager.catalog.project.name, "TestProj")

    def test_no_migration_if_new_exists(self):
        # Create both old and new catalogs
        os.makedirs(self.metallabs_dir)
        new_catalog = Catalog(project=Project(name="NewProj", scan_roots=["assets"]))
        with open(self.new_catalog_path, 'w', encoding='utf-8') as f:
            json.dump(new_catalog.to_dict(), f)

        old_catalog = Catalog(project=Project(name="OldProj", scan_roots=["assets"]))
        with open(self.old_catalog_path, 'w', encoding='utf-8') as f:
            json.dump(old_catalog.to_dict(), f)

        # Load using manager
        manager = CatalogManager(self.test_dir)
        loaded = manager.load()

        self.assertTrue(loaded)
        self.assertTrue(os.path.exists(self.new_catalog_path))
        self.assertTrue(os.path.exists(self.old_catalog_path)) # Old one shouldn't be deleted
        self.assertEqual(manager.catalog.project.name, "NewProj")

    def test_start_fresh_if_neither_exists(self):
        manager = CatalogManager(self.test_dir)
        loaded = manager.load()

        self.assertFalse(loaded)
        self.assertFalse(os.path.exists(self.new_catalog_path)) # not created until save

        manager.save()
        self.assertTrue(os.path.exists(self.metallabs_dir))
        self.assertTrue(os.path.exists(self.new_catalog_path))

if __name__ == '__main__':
    unittest.main()
