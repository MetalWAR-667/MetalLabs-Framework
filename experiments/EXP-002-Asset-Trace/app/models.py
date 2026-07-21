import uuid
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional

@dataclass
class Project:
    name: str = ""
    scan_roots: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "name": self.name,
            "scan_roots": self.scan_roots
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Project':
        return cls(
            name=data.get("name", ""),
            scan_roots=data.get("scan_roots", [])
        )

@dataclass
class Asset:
    asset_uuid: str
    display_name: str
    relative_path: str
    sha256: str
    file_size: int
    asset_type: str = ""
    source_uuid: str = ""
    scan_status: str = "NEW"
    audit_state: str = "PLACEHOLDER"
    tags: List[str] = field(default_factory=list)
    notes: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return {
            "asset_uuid": self.asset_uuid,
            "display_name": self.display_name,
            "relative_path": self.relative_path,
            "sha256": self.sha256,
            "file_size": self.file_size,
            "asset_type": self.asset_type,
            "source_uuid": self.source_uuid,
            "scan_status": self.scan_status,
            "audit_state": self.audit_state,
            "tags": self.tags,
            "notes": self.notes
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Asset':
        return cls(
            asset_uuid=data.get("asset_uuid", ""),
            display_name=data.get("display_name", ""),
            relative_path=data.get("relative_path", ""),
            sha256=data.get("sha256", ""),
            file_size=data.get("file_size", 0),
            asset_type=data.get("asset_type", ""),
            source_uuid=data.get("source_uuid", ""),
            scan_status=data.get("scan_status", "NEW"),
            audit_state=data.get("audit_state", "PLACEHOLDER"),
            tags=data.get("tags", []),
            notes=data.get("notes", "")
        )

@dataclass
class Catalog:
    schema_version: int = 1
    project: Project = field(default_factory=Project)
    sources: List[Any] = field(default_factory=list)
    assets: List[Asset] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "project": self.project.to_dict(),
            "sources": self.sources,
            "assets": [asset.to_dict() for asset in self.assets]
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Catalog':
        project_data = data.get("project", {})
        assets_data = data.get("assets", [])
        return cls(
            schema_version=data.get("schema_version", 1),
            project=Project.from_dict(project_data),
            sources=data.get("sources", []),
            assets=[Asset.from_dict(asset_data) for asset_data in assets_data]
        )
