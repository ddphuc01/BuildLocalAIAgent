### Testing Strategy

- Unit tests: FastAPI routes, Kubernetes analyzer, model router fallbacks.
- Integration tests: Suggest endpoint end-to-end with mocked LLM providers.
- Security: basic static checks for secrets in logs and manifests.

Commands:
- Backend: `pytest -q`
- Lint (optional): `ruff` / `flake8` / `black --check`


