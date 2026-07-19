import hashlib

def calculate_sha256(filepath: str, chunk_size: int = 8192) -> str:
    """
    Calculates the SHA-256 hash of a file.
    Reads the file in chunks to efficiently handle large files without consuming too much memory.

    Args:
        filepath: The absolute or relative path to the file.
        chunk_size: Size of the chunks to read in bytes.

    Returns:
        The hexadecimal SHA-256 hash of the file.
    """
    hasher = hashlib.sha256()
    with open(filepath, 'rb') as f:
        while chunk := f.read(chunk_size):
            hasher.update(chunk)
    return hasher.hexdigest()
