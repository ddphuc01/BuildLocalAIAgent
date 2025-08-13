from pydantic import BaseModel
from typing import Optional, Dict, Any, List


class SuggestRequest(BaseModel):
    language: str
    code: str
    file_path: Optional[str] = None
    context: Optional[Dict[str, Any]] = None


class SuggestResponse(BaseModel):
    suggestion: str


class DeployRequest(BaseModel):
    service: str
    environment: str  # dev|staging|prod
    parameters: Optional[Dict[str, Any]] = None


class GenericResponse(BaseModel):
    status: str
    message: Optional[str] = None
    data: Optional[Dict[str, Any]] = None


class DriftCheckRequest(BaseModel):
    target: Optional[str] = None  # e.g. terraform module path or cloud provider scope


class DriftReport(BaseModel):
    has_drift: bool
    added: List[str] = []
    changed: List[str] = []
    removed: List[str] = []


class RunbookRequest(BaseModel):
    incident: str
    context: Optional[Dict[str, Any]] = None


class RunbookResponse(BaseModel):
    title: str
    steps: List[str]


