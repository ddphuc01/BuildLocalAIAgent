### Kiến trúc hoạt động chi tiết

Tài liệu này mô tả cấu trúc hệ thống, các thành phần chính, luồng xử lý và các tham số triển khai của dự án Cursor DevOps AI (Desktop).

#### Tổng quan
- Frontend Electron (React + Monaco + xterm) giao tiếp với Backend FastAPI bằng HTTP/WS.
- Backend điều phối DevOps Agents, tích hợp K8s/Docker/Terraform/Git, sử dụng Model Router (OpenAI/Anthropic/Ollama) và RAG.
- Lưu trữ hội thoại, metadata trong SQLite (SQLModel); đo đạc Prometheus.

#### Sơ đồ tổng thể

```mermaid
graph TD
  subgraph "Desktop (Electron + React)"
    UI["UI VS Code-like\n- File Explorer\n- Monaco Editor\n- xterm Terminal\n- Chat Sidebar\n- Command Palette"]
    Preload["Preload & IPC bridge"]
    WSClient["HTTP/WS Client"]
    UI --> Preload --> WSClient
  end

  subgraph "Backend (FastAPI)"
    API["REST + WebSocket APIs"]
    Orchestrator["Agents Orchestrator\n(Code/K8s/IaC/CI-CD/SecOps)"]
    Router["Model Router\n(OpenAI/Anthropic/Ollama)"]
    RAG["RAG Service\n(Chroma/FAISS + Embeddings)"]
    LSP["LSP Manager\n(pyright/gopls/tsserver)"]
    Context["Project Context\n(Git + FS Watch)"]
    Integrations["Integrations\n- Kubernetes\n- Docker/Podman\n- Terraform/Pulumi\n- Git\n- Vault/KMS"]
    Policy["Policy & Security\n(tfsec, kube-linter, OPA)"]
    Store["Storage\n(SQLite/SQLModel)"]
    Obs["Observability\n(Prometheus + logs)"]
    Plugins["Plugin Runtime (Python)\nAllowlist + sandbox"]

    API <--> Orchestrator
    Orchestrator --> Router
    Orchestrator --> RAG
    Orchestrator --> Integrations
    Orchestrator <--> LSP
    Context --> Orchestrator
    Context --> RAG
    API <--> Store
    API --> Obs
    Policy --> Orchestrator
    Plugins <--> API
    Plugins --> Integrations
  end

  subgraph "AI Providers"
    OpenAI[("OpenAI API")]
    Anthropic[("Anthropic API")]
    Ollama[("Local Ollama")]
  end

  Router --> OpenAI
  Router --> Anthropic
  Router --> Ollama

  subgraph "Infra & Data"
    DB[("SQLite / Postgres")] 
    Vec[("Chroma/FAISS Index")]
    K8s[("Kubernetes Clusters")]
    DockerD[("Docker/Podman")]
    GitRepo[("Local/Remote Git Repos")]
    Secrets[("Vault/KMS/K8s Secrets")]
  end

  Store --> DB
  RAG --> Vec
  Integrations --> K8s
  Integrations --> DockerD
  Integrations --> GitRepo
  Integrations --> Secrets

  WSClient <-.HTTP/WS.-> API
  UI -->|Metrics pings| Obs
```

#### Luồng xử lý chính

1) Suggest code (REST)
```mermaid
sequenceDiagram
  participant UI as UI (React)
  participant API as FastAPI /api/suggest
  participant ORC as Orchestrator
  participant RAG as RAG
  participant LSP as LSP
  participant RT as Model Router

  UI->>API: POST /api/suggest (language, code, context)
  API->>ORC: suggest_code(...)
  ORC->>RAG: search(context)
  RAG-->>ORC: top-k docs
  ORC->>LSP: completion/diagnostics (optional)
  ORC->>RT: build prompt + call model
  RT-->>ORC: suggestion
  ORC-->>API: suggestion
  API-->>UI: SuggestResponse
```

2) Phân tích Kubernetes manifest (REST)
```mermaid
sequenceDiagram
  participant UI as UI/CLI
  participant API as FastAPI /api/k8s/analyze
  participant K8S as K8s Analyzer

  UI->>API: POST text/plain (manifest YAML)
  API->>K8S: analyze_manifest()
  K8S-->>API: findings (severity, rule, message)
  API-->>UI: JSON findings
```

3) Chat (WebSocket)
```mermaid
sequenceDiagram
  participant UI as UI Chat (WS)
  participant WS as FastAPI /ws/chat
  participant ORC as Orchestrator
  participant RT as Model Router

  UI->>WS: user message
  WS->>ORC: handle_chat_message
  ORC->>RT: choose provider + complete()
  RT-->>ORC: reply
  ORC-->>WS: assistant message
  WS-->>UI: stream reply
```

#### Bảo mật & Policy
- Secrets dùng env/Vault/KMS; không commit vào repo.
- K8s: khuyến nghị tránh `:latest`, yêu cầu `requests/limits`, `runAsNonRoot=true`, `allowPrivilegeEscalation=false`, `drop: [ALL]`.
- IaC: tfsec; Policy OPA/conftest; CI/CD scan dependencies.

#### Quan sát & logging
- `/metrics` cho Prometheus (HTTP counters, WS counters, LLM latency/tokens có thể mở rộng).
- Structured logs; có thể thêm OpenTelemetry.

#### Tham số môi trường
- `PROVIDER`: `openai|anthropic|ollama|none`
- `OPENAI_MODEL`, `ANTHROPIC_MODEL`, `OLLAMA_MODEL`, `OLLAMA_HOST`
- `ENABLED_PLUGINS`: danh sách module plugin cho phép nạp.

#### Ports
- Backend: 8000 (HTTP/WS)
- Frontend (Vite dev): 5173
- Prometheus metrics: `/metrics`

#### Lộ trình phát triển
- Streaming WS cho chat/suggest; tích hợp đầy đủ LSP; CI/CD templates (GA/Jenkins/GitLab/ArgoCD); policy scan (tfsec/kube-linter/trivy/OPA); packaging Electron.


