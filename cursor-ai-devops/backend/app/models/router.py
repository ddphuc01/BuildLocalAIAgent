import os
from typing import Optional

import httpx


class ModelRouter:
    """Minimal async model router with pluggable providers.

    Configuration via env:
      PROVIDER: openai|anthropic|ollama|none
      OPENAI_API_KEY, ANTHROPIC_API_KEY
      OLLAMA_HOST (default http://localhost:11434)
    """

    def __init__(self) -> None:
        self.provider = os.getenv("PROVIDER", "none").lower()
        self.openai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        self.anthropic_model = os.getenv("ANTHROPIC_MODEL", "claude-3-haiku-20240307")
        self.ollama_model = os.getenv("OLLAMA_MODEL", "llama3:8b")
        self.ollama_host = os.getenv("OLLAMA_HOST", "http://localhost:11434")

    async def complete(self, prompt: str) -> str:
        if self.provider == "openai":
            return await self._openai(prompt)
        if self.provider == "anthropic":
            return await self._anthropic(prompt)
        if self.provider == "ollama":
            return await self._ollama(prompt)
        return "Model provider not configured. Set PROVIDER env to openai|anthropic|ollama."

    async def _openai(self, prompt: str) -> str:
        from openai import AsyncOpenAI

        client = AsyncOpenAI()
        resp = await client.chat.completions.create(
            model=self.openai_model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2,
        )
        return resp.choices[0].message.content or ""

    async def _anthropic(self, prompt: str) -> str:
        from anthropic import AsyncAnthropic

        client = AsyncAnthropic()
        msg = await client.messages.create(
            model=self.anthropic_model,
            max_tokens=512,
            temperature=0.2,
            messages=[{"role": "user", "content": prompt}],
        )
        return "".join(block.text for block in msg.content) if hasattr(msg, "content") else ""

    async def _ollama(self, prompt: str) -> str:
        async with httpx.AsyncClient(timeout=60) as client:
            resp = await client.post(
                f"{self.ollama_host}/api/generate",
                json={"model": self.ollama_model, "prompt": prompt, "stream": False},
            )
            resp.raise_for_status()
            data = resp.json()
            return data.get("response", "")


