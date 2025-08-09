from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response

from app.api.routes import router as api_router
from app.agents.orchestrator import AgentsOrchestrator
import importlib
import os
import sys
from pathlib import Path

app = FastAPI(title="Cursor DevOps AI", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api")

ws_messages_total = Counter("ws_messages_total", "Total websocket messages", ["role"])

orchestrator = AgentsOrchestrator()


@app.get("/health")
async def health() -> JSONResponse:
    return JSONResponse({"status": "ok"})


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.websocket("/ws/chat")
async def chat_ws(websocket: WebSocket) -> None:
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            ws_messages_total.labels(role="user").inc()
            reply = await orchestrator.handle_chat_message(data)
            ws_messages_total.labels(role="assistant").inc()
            await websocket.send_text(reply)
    except WebSocketDisconnect:
        return


def load_plugins() -> None:
    enabled = os.getenv("ENABLED_PLUGINS", "").split(",")
    # Ensure project root and plugins dir are importable
    app_dir = Path(__file__).resolve().parents[2]  # .../cursor-ai-devops
    plugins_dir = app_dir / "plugins"
    for p in {str(app_dir), str(plugins_dir)}:
        if p not in sys.path:
            sys.path.append(p)
    for name in [p.strip() for p in enabled if p.strip()]:
        try:
            module = importlib.import_module(name)
            if hasattr(module, "register"):
                module.register(app)
        except Exception:
            # Ignore plugin load errors in bootstrap
            continue


load_plugins()


