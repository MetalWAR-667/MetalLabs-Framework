import unittest
import os
import tempfile
from app.hashing import calculate_sha256

class TestHashing(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_file_path = os.path.join(self.temp_dir.name, "test_file.txt")
        with open(self.test_file_path, "wb") as f:
            f.write(b"Hello, World!")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_calculate_sha256(self):
        # Known sha256 for "Hello, World!"
        expected_hash = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"
        calculated_hash = calculate_sha256(self.test_file_path)
        self.assertEqual(calculated_hash, expected_hash)

if __name__ == '__main__':
    unittest.main()
