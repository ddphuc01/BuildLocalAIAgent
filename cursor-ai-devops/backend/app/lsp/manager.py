from typing import Optional


class LspManager:
    """Placeholder for spawning/managing language servers.

    Future: integrate pygls or spawn node-based LSPs (tsserver, gopls, pyright, etc.).
    """

    def __init__(self) -> None:
        self.started = False

    def start(self) -> None:
        self.started = True

    def is_running(self) -> bool:
        return self.started

    def request_completion(self, language: str, code: str, file_path: Optional[str] = None) -> str:
        return ""  # TODO: wire real LSP completions


