from fastapi import APIRouter, Body
from app.api.schemas import (
    SuggestRequest,
    SuggestResponse,
    DeployRequest,
    GenericResponse,
    DriftCheckRequest,
    DriftReport,
    RunbookRequest,
    RunbookResponse,
)
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


@router.post("/deploy", response_model=GenericResponse)
async def deploy(req: DeployRequest) -> GenericResponse:
    # Skeleton: integrate CI/CD trigger and CD tool here
    return GenericResponse(status="queued", message=f"Deployment of {req.service} to {req.environment} queued")


@router.post("/drift/check", response_model=DriftReport)
async def drift_check(req: DriftCheckRequest) -> DriftReport:
    # Skeleton: compare desired (TF state/plan) vs actual (cloud APIs)
    return DriftReport(has_drift=False, added=[], changed=[], removed=[])


@router.post("/runbook/generate", response_model=RunbookResponse)
async def runbook_generate(req: RunbookRequest) -> RunbookResponse:
    # Skeleton: use RAG + model to draft steps
    steps = [
        "Xác minh phạm vi ảnh hưởng",
        "Thu thập logs và metrics liên quan",
        "Thực hiện bước khắc phục tạm thời",
        "Xác nhận hệ thống phục hồi",
        "Viết postmortem và phòng ngừa tái diễn",
    ]
    return RunbookResponse(title=f"Runbook cho sự cố: {req.incident}", steps=steps)


