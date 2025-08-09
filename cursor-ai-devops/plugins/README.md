### Plugin Framework (Backend - Python)

Plugins are Python packages placed under `plugins/` discovered at runtime.

Contract:
- Each plugin exposes a `register(app)` function.
- Plugins can define tools, routes, or agents.

Security:
- Disabled by default; require explicit enable list via env `ENABLED_PLUGINS`.
- Run with restricted permissions; avoid shell unless necessary.


