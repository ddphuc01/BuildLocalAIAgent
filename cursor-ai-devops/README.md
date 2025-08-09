## Cursor DevOps AI - Desktop Agent

Quick start:

1) Backend (FastAPI)
- Install Python 3.10+
- `cd backend`
- `python -m venv .venv`
- Activate (PowerShell): `.venv\Scripts\Activate.ps1`
- `pip install -r requirements.txt`
- Run: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`

2) Frontend (Electron + React)
- Install Node.js 18+
- `cd frontend`
- `npm install`
- In one terminal: `npm run dev:renderer`
- In another: `npm run dev:electron`

Model config:
- Set env `PROVIDER=openai|anthropic|ollama`
- For local: install Ollama and run `ollama serve`; set `OLLAMA_MODEL`.

Security: do not commit secrets. Use env or OS keychain. Least-privilege IAM.


