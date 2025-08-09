### Deployment Instructions

Dev mode (Windows):
1) Backend
- Install Python 3.10+, create venv, install requirements
- Run: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`

2) Frontend
- Install Node 18+
- Terminal A: `npm run dev:renderer`
- Terminal B: `npm run dev:electron`

Packaging:
- Add electron-builder config and run `npm run package` (later step)

Offline:
- Use `PROVIDER=ollama` and pre-pull a local model
- Keep vector DB (Chroma/FAISS) local


