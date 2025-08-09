import asyncio
from typing import Optional, Dict, Any

from app.models.router import ModelRouter


class AgentsOrchestrator:
    def __init__(self) -> None:
        self.model_router = ModelRouter()

    async def handle_chat_message(self, content: str) -> str:
        prompt = (
            "You are a DevOps Engineering assistant. Be concise and provide actionable guidance.\n"
            f"User: {content}\nAssistant:"
        )
        try:
            return await self.model_router.complete(prompt)
        except Exception:
            # Fallback minimal echo to ensure WS stays functional during early setup
            await asyncio.sleep(0)
            return "Acknowledged. I will help with DevOps tasks once models are configured."

    async def suggest_code(
        self, language: str, code: str, file_path: Optional[str] = None, context: Optional[Dict[str, Any]] = None
    ) -> str:
        sys_prompt = (
            "You are a DevOps-focused code assistant. Improve the snippet using best practices,"
            " security-first principles, and performance considerations."
        )
        user_prompt = f"Language: {language}\nPath: {file_path}\nContext: {context}\nCode:\n{code}"
        prompt = f"{sys_prompt}\n\n{user_prompt}\n\nAssistant:"
        try:
            return await self.model_router.complete(prompt)
        except Exception:
            return "// Suggestion unavailable until AI providers are configured."


