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

if __name__ == '__main__':
    unittest.main()
