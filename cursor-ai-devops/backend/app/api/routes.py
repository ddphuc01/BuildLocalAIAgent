from fastapi import APIRouter, Body
from app.api.schemas import SuggestRequest, SuggestResponse
from app.agents.orchestrator import AgentsOrchestrator
from app.integrations.k8s.analyzer import analyze_manifest

router = APIRouter()
orchestrator = AgentsOrchestrator()


@router.get("/info")
async def info():
    return {"name": "Cursor DevOps AI", "version": "0.1.0"}


@router.post("/suggest", response_model=SuggestResponse)
async def suggest(req: SuggestRequest) -> SuggestResponse:
    suggestion = await orchestrator.suggest_code(
        language=req.language, code=req.code, file_path=req.file_path, context=req.context
    )
    return SuggestResponse(suggestion=suggestion)


@router.post("/k8s/analyze")
async def k8s_analyze(manifest: str = Body(..., media_type="text/plain")):
    findings = analyze_manifest(manifest)
    return {"findings": findings}


