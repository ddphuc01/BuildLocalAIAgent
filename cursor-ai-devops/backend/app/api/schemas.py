from pydantic import BaseModel
from typing import Optional, Dict, Any


class SuggestRequest(BaseModel):
    language: str
    code: str
    file_path: Optional[str] = None
    context: Optional[Dict[str, Any]] = None


class SuggestResponse(BaseModel):
    suggestion: str


