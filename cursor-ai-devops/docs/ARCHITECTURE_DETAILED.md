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

---

### CI/CD pipelines và gates bảo mật

#### Mô hình pipeline nhiều giai đoạn
- Build → Test → Security Scan → Package → Deploy (Dev → Staging → Prod) với approval gates.
- Tích hợp SAST/DAST, dependency scan, container image scan (trivy), IaC/K8s scan (tfsec/kube-linter/OPA).

```mermaid
flowchart LR
  A[Push/PR] --> B[Build]
  B --> C[Test Unit/Integration]
  C --> D[Security Scans\nSAST/DAST/Deps]
  D --> E[Container Scan\nTrivy]
  E --> F[IaC/K8s Policy\ntfsec/kube-linter/OPA]
  F --> G[Package Artifact]
  G --> H[Deploy Dev]
  H --> I[Promote Staging\n+Approval]
  I --> J[Promote Prod\n+Approval]
```

#### Một số job/gate điển hình
- SAST: semgrep/codeql
- Dependency scan: npm audit / pip-audit / osv-scanner
- Container scan: trivy image
- IaC scan: tfsec (Terraform), checkov (tuỳ chọn)
- K8s scan: kube-linter, conftest/OPA cho policy

---

### One-click Deployment workflow

```mermaid
sequenceDiagram
  participant UI as UI (Command Palette)
  participant API as FastAPI /api/deploy (tương lai)
  participant ORC as Orchestrator
  participant CI as CI/CD Provider
  participant REG as Container Registry
  participant CD as CD Tool (ArgoCD/kubectl)
  participant K8S as Kubernetes

  UI->>API: Deploy service S (env=staging)
  API->>ORC: plan_deploy(S, staging)
  ORC->>CI: trigger build+test (commit/tag)
  CI-->>REG: push image (sha/tag)
  CI-->>ORC: status + artifact refs
  ORC->>CD: apply Helm/manifest (image sha)
  CD->>K8S: rollout
  K8S-->>CD: status events
  CD-->>ORC: success/failure + details
  ORC-->>API: response
  API-->>UI: deploy result + links/logs
```

Ghi chú:
- Có thể thêm canary/blue-green và auto-rollback khi liveness/readiness fail hoặc SLO xấu.

---

### Drift Detection workflow (IaC)

```mermaid
sequenceDiagram
  participant SCH as Scheduler (cron)
  participant API as FastAPI /api/drift/check (tương lai)
  participant ORC as Orchestrator
  participant TF as Terraform State
  participant CSP as Cloud APIs

  SCH->>API: trigger drift check
  API->>ORC: compare desired vs actual
  ORC->>TF: load desired state (plan)
  ORC->>CSP: fetch live resources
  ORC-->>API: drift report (added/changed/removed)
  API-->>SCH: result
```

T tuỳ chọn: tự động reconcile với approval trước khi apply.

---

### Runbook generation & execution

```mermaid
sequenceDiagram
  participant UI as UI (Runbook)
  participant API as FastAPI /api/runbook (tương lai)
  participant ORC as Orchestrator
  participant RAG as RAG
  participant RT as Model Router
  participant OPS as Ops Integrations (K8s/Docker/Cloud)

  UI->>API: generate runbook for incident X
  API->>ORC: build context (logs/events/metrics)
  ORC->>RAG: retrieve KB snippets
  ORC->>RT: draft runbook
  RT-->>ORC: steps/checklists
  ORC-->>API: runbook doc
  API-->>UI: view/execute steps
  UI->>API: execute step N
  API->>OPS: perform action (e.g., scale, restart)
  OPS-->>API: result
  API-->>UI: status update
```

---

### Tuân thủ & dữ liệu
- Compliance: SOC2/PCI-DSS/GDPR – bật audit logging, retention, RBAC chặt chẽ, mã hoá in-transit/at-rest.
- Data retention: cấu hình thời gian lưu hội thoại và logs; hỗ trợ export/anonymize.

### Chi phí & tối ưu hiệu năng
- Ưu tiên Ollama offline khi phù hợp để giảm chi phí API.
- Cache ngữ cảnh dự án, index RAG theo incremental.
- Giới hạn token/temperature theo loại tác vụ DevOps.


