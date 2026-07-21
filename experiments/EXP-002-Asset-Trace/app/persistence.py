import json
import os
from typing import Optional
from app.models import Catalog

def load_catalog(filepath: str) -> Optional[Catalog]:
    """
    Loads the catalog from a JSON file.
    Returns None if the file does not exist.
    """
    if not os.path.exists(filepath):
        return None

    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    return Catalog.from_dict(data)

def save_catalog(catalog: Catalog, filepath: str) -> None:
    """
    Saves the catalog to a JSON file.
    """
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(catalog.to_dict(), f, indent=2, ensure_ascii=False)
