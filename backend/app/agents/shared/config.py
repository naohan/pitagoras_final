"""Configuración ADK/LLM compartida por todos los agentes."""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any

from app.agents.exceptions import LLMConfigurationError
from app.core.config import settings


@dataclass(frozen=True)
class AgentConfig:
    app_name: str
    agent_name: str
    description: str
    temperature: float = 0.3


def _effective_gemini_api_key() -> str:
    key = settings.google_api_key_effective()
    if key:
        return key
    return os.environ.get("GOOGLE_API_KEY", "").strip()


def _is_openrouter_key(api_key: str) -> bool:
    return api_key.startswith("sk-or-")


def _adk_openai_model_name() -> str:
    """Normaliza el modelo para LiteLLM / OpenRouter.

    Si la key es de OpenRouter (`sk-or-...`) pero el modelo viene como
    `openai/gpt-4o-mini`, LiteLLM pegaría a api.openai.com y fallaría con 401.
    En ese caso forzamos el prefijo `openrouter/`.
    """
    model = settings.openai_model.strip()
    if _is_openrouter_key(settings.openai_api_key) and not model.startswith("openrouter/"):
        return f"openrouter/{model}"
    return model


def ensure_adk_env() -> None:
    """Mapea variables del proyecto a las que espera Google ADK / LiteLLM."""
    gemini_key = _effective_gemini_api_key()
    if gemini_key and not os.environ.get("GOOGLE_API_KEY"):
        os.environ["GOOGLE_API_KEY"] = gemini_key
    if settings.openai_api_key and not os.environ.get("OPENAI_API_KEY"):
        os.environ["OPENAI_API_KEY"] = settings.openai_api_key
    # OpenRouter (LiteLLM) usa OPENROUTER_API_KEY con modelos openrouter/...
    if settings.openai_api_key and (
        settings.openai_model.startswith("openrouter/")
        or _is_openrouter_key(settings.openai_api_key)
    ):
        os.environ["OPENROUTER_API_KEY"] = settings.openai_api_key


def resolve_adk_model(*, temperature: float = 0.3) -> Any:
    """Resuelve el modelo ADK según LLM_PROVIDER."""
    ensure_adk_env()

    if settings.llm_provider == "gemini":
        if not _effective_gemini_api_key():
            raise LLMConfigurationError(
                "GEMINI_API_KEY or GOOGLE_API_KEY is required when LLM_PROVIDER=gemini"
            )
        return settings.gemini_model

    if settings.llm_provider == "openai":
        if not settings.openai_api_key:
            raise LLMConfigurationError("OPENAI_API_KEY is required when LLM_PROVIDER=openai")
        try:
            from google.adk.models.lite_llm import LiteLlm
        except ImportError as exc:
            raise LLMConfigurationError(
                "OpenAI con ADK requiere google-adk[extensions]: "
                "pip install 'google-adk[extensions]'"
            ) from exc
        model_name = _adk_openai_model_name()
        litellm_kwargs: dict[str, Any] = {"temperature": temperature}
        # Con key OpenRouter, pasar api_key explícita evita que LiteLLM
        # use OPENAI_API_KEY contra api.openai.com por accidente.
        if model_name.startswith("openrouter/") or _is_openrouter_key(settings.openai_api_key):
            litellm_kwargs["api_key"] = settings.openai_api_key
        return LiteLlm(model=model_name, **litellm_kwargs)

    raise LLMConfigurationError(f"Unsupported LLM provider: {settings.llm_provider}")


def resolve_model_label() -> tuple[str, str]:
    if settings.llm_provider == "openai":
        return _adk_openai_model_name(), "openai"
    return settings.gemini_model, "gemini"
