import unittest
import os
import tempfile
import uuid
from app.models import Asset
from app.catalog import CatalogManager
from app.scanner import Scanner

class TestScanner(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.project_root = self.temp_dir.name

        # Create assets folder
        self.assets_dir = os.path.join(self.project_root, "assets")
        os.makedirs(self.assets_dir)

        # Create test files
        self.file1 = os.path.join(self.assets_dir, "test1.txt")
        with open(self.file1, "w") as f:
            f.write("content1")

        # Hidden file should be ignored
        self.hidden_file = os.path.join(self.assets_dir, ".hidden.txt")
        with open(self.hidden_file, "w") as f:
            f.write("hidden")

        self.manager = CatalogManager(self.project_root)
        self.manager.load() # Sets up defaults including scan_roots

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_scan_new_files(self):
        scanner = Scanner(self.manager)
        scanner.scan()

        assets = self.manager.get_assets()
        self.assertEqual(len(assets), 1)
        self.assertEqual(assets[0].scan_status, "NEW")
        self.assertEqual(assets[0].relative_path, "assets/test1.txt")

    def test_scan_ok_and_modified(self):
        # Initial scan
        scanner = Scanner(self.manager)
        scanner.scan()

        # We must save so the NEW item gets persisted hash, changing to OK
        self.manager.save()

        # Change file1
        with open(self.file1, "w") as f:
            f.write("changed_content")

        # Add new file
        file2 = os.path.join(self.assets_dir, "test2.txt")
        with open(file2, "w") as f:
            f.write("content2")

        # Scan again
        scanner.scan()

        assets = self.manager.get_assets()
        # Sort for predictable asserting
        assets_dict = {a.relative_path: a for a in assets}

        self.assertEqual(len(assets), 2)
        self.assertEqual(assets_dict["assets/test1.txt"].scan_status, "MODIFIED")
        self.assertEqual(assets_dict["assets/test2.txt"].scan_status, "NEW")

    def test_scan_missing(self):
        scanner = Scanner(self.manager)
        scanner.scan()

        # Remove file
        os.remove(self.file1)

        # Scan again
        scanner.scan()
        assets = self.manager.get_assets()
        self.assertEqual(len(assets), 1)
        self.assertEqual(assets[0].scan_status, "MISSING")

    def test_scan_no_roots(self):
        # Remove assets dir
        import shutil
        shutil.rmtree(self.assets_dir)

        scanner = Scanner(self.manager)
        with self.assertRaises(ValueError):
            scanner.scan()

    def test_repeated_scans_without_save(self):
        scanner = Scanner(self.manager)
        scanner.scan()

        assets = self.manager.get_assets()
        self.assertEqual(assets[0].scan_status, "NEW")

        # Scan again without saving
        scanner.scan()
        assets = self.manager.get_assets()
        self.assertEqual(assets[0].scan_status, "NEW")

        self.manager.save()
        scanner.scan()
        assets = self.manager.get_assets()
        self.assertEqual(assets[0].scan_status, "OK")

        # Change file
        with open(self.file1, "w") as f:
            f.write("modified_content_here")

        scanner.scan()
        assets = self.manager.get_assets()
        self.assertEqual(assets[0].scan_status, "MODIFIED")

        # Scan again without saving
        scanner.scan()
        assets = self.manager.get_assets()
        self.assertEqual(assets[0].scan_status, "MODIFIED")


    def test_stable_uuid_and_metadata_across_transitions(self):
        scanner = Scanner(self.manager)
        scanner.scan()

        assets = self.manager.get_assets()
        asset = assets[0]
        original_uuid = asset.asset_uuid

        # Manually edit metadata
        asset.tags = ["test_tag"]
        asset.notes = "test note"

        self.manager.save()

        # Change file to trigger modification
        with open(self.file1, "w") as f:
            f.write("changed_for_metadata_test")

        scanner.scan()
        assets = self.manager.get_assets()
        asset = assets[0]

        # UUID and metadata should be stable
        self.assertEqual(asset.asset_uuid, original_uuid)
        self.assertEqual(asset.tags, ["test_tag"])
        self.assertEqual(asset.notes, "test note")
        self.assertEqual(asset.scan_status, "MODIFIED")

if __name__ == '__main__':
    unittest.main()
