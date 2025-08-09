### Hướng dẫn cài đặt và chạy Cursor DevOps AI (Desktop)

Tài liệu ngắn gọn giúp bạn cài đặt nhanh trên Windows 10/11 và chạy cả Backend (FastAPI) và Frontend (Electron + React).

---

### Yêu cầu hệ thống
- Windows 10/11
- Python 3.10+ (khuyên dùng 3.10.x)
- Node.js 18+ (LTS) để chạy UI Electron
- (Tùy chọn) Ollama để chạy model AI offline

---

### Cài đặt Python 3.10+
1) Tải từ `https://www.python.org/downloads/windows/` và chạy installer
2) Chọn “Add Python to PATH” và giữ pip
3) PowerShell mới → kiểm tra:
```
py --version
python --version
```
Nếu PowerShell mở Microsoft Store: Settings → Apps → Advanced app settings → App execution aliases → Tắt `python.exe` và `python3.exe` → Mở PowerShell mới và kiểm tra lại.

---

### Cài đặt Node.js 18+ (để chạy UI)
1) Tải từ `https://nodejs.org/en/download` → cài đặt
2) Kiểm tra phiên bản:
```
node --version
npm --version
```

---

### Chạy Backend (FastAPI)
Thư mục dự án: `C:\BuildLocalAIAgent\cursor-ai-devops\backend`

1) Tạo môi trường ảo và cài phụ thuộc (gói tối thiểu dễ cài hơn):
```
cd C:\BuildLocalAIAgent\cursor-ai-devops\backend
py -3.10 -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements-min.txt
```

2) Chạy server:
```
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

3) Kiểm tra health:
```
Invoke-RestMethod http://127.0.0.1:8000/health
```

---

### Test nhanh K8s Analyzer
Đã có sẵn `backend\demo.yaml`. Gửi YAML qua body (text/plain):
```
cd C:\BuildLocalAIAgent\cursor-ai-devops\backend
Invoke-WebRequest -Uri http://127.0.0.1:8000/api/k8s/analyze -Method POST -InFile .\demo.yaml -ContentType 'text/plain' | Select-Object -Expand Content

# Hoặc dùng curl (Windows):
curl.exe -s -X POST http://127.0.0.1:8000/api/k8s/analyze -H "Content-Type: text/plain" --data-binary "@demo.yaml"
```
Kỳ vọng trả về danh sách `findings` (ví dụ: `image-tag-not-latest`).

---

### Chạy Frontend (Electron + React)
Thư mục: `C:\BuildLocalAIAgent\cursor-ai-devops\frontend`

1) Cài phụ thuộc:
```
cd C:\BuildLocalAIAgent\cursor-ai-devops\frontend
npm install
```

2) Chạy dev (Vite + Electron):
```
npm run dev
```
Electron sẽ mở UI (Monaco editor + Chat sidebar). Backend mặc định: `http://127.0.0.1:8000`.

---

### Cấu hình Model AI
- Biến môi trường (PowerShell):
```
$env:PROVIDER="ollama"      # hoặc "openai" | "anthropic"
$env:OLLAMA_MODEL="llama3:8b"
# Nếu dùng OpenAI/Anthropic:
# $env:OPENAI_API_KEY="sk-..."
# $env:ANTHROPIC_API_KEY="..."
```
- Offline: cài Ollama, chạy `ollama serve`, và pull model: `ollama run llama3:8b`.

---

### Sự cố thường gặp (Troubleshooting)
- `No suitable Python runtime found` khi `py -3.10 -m venv .venv`:
  - Cài Python 3.10 từ python.org, hoặc dùng `python -m venv .venv` nếu `python` đã trỏ đúng 3.10+.
- Mở Microsoft Store khi gõ `python`:
  - Tắt App execution aliases cho `python.exe` và `python3.exe` (mục cài đặt Windows như trên).
- `422 Unprocessable Entity` khi gọi `/api/k8s/analyze`:
  - Đảm bảo gửi YAML trong body với `Content-Type: text/plain` (không gửi qua query string).
- Electron không mở:
  - Kiểm tra Vite đang chạy (`npm run dev` tạo server 5173) và Node 18+.

---

### Tài liệu chi tiết trong repo
- `cursor-ai-devops/README.md` (tổng quan dự án)
- `cursor-ai-devops/docs/WINDOWS_SETUP.md` (cài đặt Windows)
- `cursor-ai-devops/docs/DEPLOYMENT.md` (triển khai)
- `cursor-ai-devops/docs/TESTING.md` (kiểm thử)
- `cursor-ai-devops/docs/ARCHITECTURE.md` (kiến trúc)

---

### Hỗ trợ tiếp theo
Bạn có thể yêu cầu:
- Bật chế độ offline (Ollama) hoặc tích hợp OpenAI/Anthropic
- Thêm CI/CD (GitHub Actions/Jenkins/GitLab) kèm bảo mật (tfsec/kube-linter/trivy/OPA)
- Tích hợp LSP thực (pyright/gopls/tsserver) cho completion/diagnostics


