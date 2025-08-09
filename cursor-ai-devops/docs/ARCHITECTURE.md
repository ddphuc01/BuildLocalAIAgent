### Architecture Overview

- Electron desktop frontend (React + Monaco + xterm) connects to FastAPI backend via HTTP/WebSocket.
- Backend orchestrates DevOps agents, model routing (OpenAI/Anthropic/Ollama), RAG knowledge base, LSP manager, and integrations (Kubernetes, Docker, Terraform, Git).
- Plugin system allows Python backend plugins and optional Node frontend plugins.

Key backend services:
- API: REST + WS endpoints.
- Agents: code, k8s, IaC, CI/CD, SecOps agents.
- Model Router: provider-agnostic LLM calls.
- RAG: Chroma/FAISS index for DevOps knowledge.
- Context: Git + FS summaries for project awareness.
- Storage: SQLite via SQLModel for conversations.
- Observability: Prometheus metrics.

Security highlights:
- No secrets in code. Use env vars and OS keychain/KMS.
- Sandboxed plugins; validate inputs; rate-limit WS.
- Enforce least-privilege on cloud credentials.


