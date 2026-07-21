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
    _current_sha256: str = field(default="", init=False, repr=False)
    _current_file_size: int = field(default=0, init=False, repr=False)

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
class Source:
    source_uuid: str
    store_name: str = ""
    product_name: str = ""
    creator_name: str = ""
    acquisition_date: str = ""
    license_type: str = ""
    license_url: str = ""
    source_url: str = ""
    receipt_path: str = ""
    requires_attribution: bool = False
    attribution_text: str = ""
    notes: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return {
            "source_uuid": self.source_uuid,
            "store_name": self.store_name,
            "product_name": self.product_name,
            "creator_name": self.creator_name,
            "acquisition_date": self.acquisition_date,
            "license_type": self.license_type,
            "license_url": self.license_url,
            "source_url": self.source_url,
            "receipt_path": self.receipt_path,
            "requires_attribution": self.requires_attribution,
            "attribution_text": self.attribution_text,
            "notes": self.notes
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Source':
        return cls(
            source_uuid=data.get("source_uuid", ""),
            store_name=data.get("store_name", ""),
            product_name=data.get("product_name", ""),
            creator_name=data.get("creator_name", ""),
            acquisition_date=data.get("acquisition_date", ""),
            license_type=data.get("license_type", ""),
            license_url=data.get("license_url", ""),
            source_url=data.get("source_url", ""),
            receipt_path=data.get("receipt_path", ""),
            requires_attribution=data.get("requires_attribution", False),
            attribution_text=data.get("attribution_text", ""),
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
