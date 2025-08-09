### Step-by-step Implementation Guide

1) Backend foundation
- Create FastAPI app with REST and WebSocket endpoints.
- Add orchestrator and model router supporting OpenAI/Anthropic/Ollama.
- Add RAG vector store (Chroma/FAISS) and knowledge base loader.
- Integrate Prometheus metrics.

2) DevOps agents
- Code assistance agent: suggestions, review, refactor prompts.
- Kubernetes agent: manifest generation, analyzer, Helm templating.
- IaC agent: Terraform/Pulumi generation and validation hooks.
- CI/CD agent: GitHub Actions/Jenkins/GitLab templates.
- SecOps agent: config checks (tfsec/kube-linter/OPA/conftest).

3) LSP integration
- Spawn language servers (pyright, gopls, tsserver) via manager.
- Wire completion and diagnostics to UI.

4) Desktop UI
- Electron main process, preload bridge.
- React app with Monaco editor, chat sidebar, terminal integration.

5) Plugins
- Plugin loader by env var allowlist.
- Example plugin route.

6) Security & storage
- SQLite via SQLModel for conversations.
- Secrets via env, optional Vault/KMS integration.

7) Packaging
- Electron-builder for installers (later).


