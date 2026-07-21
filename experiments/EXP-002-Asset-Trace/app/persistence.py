import json
import os
from typing import Optional
from typing import List
from app.models import Catalog, Source

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

def load_sources(filepath: str) -> List[Source]:
    """
    Loads sources from a JSON file.
    Returns empty list if the file does not exist.
    """
    if not os.path.exists(filepath):
        return []

    with open(filepath, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
            if isinstance(data, list):
                return [Source.from_dict(item) for item in data]
            return []
        except json.JSONDecodeError:
            return []

def save_sources(sources: List[Source], filepath: str) -> None:
    """
    Saves the sources to a JSON file.
    """
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump([s.to_dict() for s in sources], f, indent=2, ensure_ascii=False)
