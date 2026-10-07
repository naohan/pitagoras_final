from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class LLMResponse:
    content: str
    model: str
    provider: str


class LLMProvider(ABC):
    @abstractmethod
    def generate(
        self,
        *,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.3,
        max_output_tokens: int | None = None,
    ) -> LLMResponse:
        ...


class OpenAILLMProvider(LLMProvider):
    def __init__(self, api_key: str, model: str) -> None:
        self._api_key = api_key
        self._model = model
        self._base_url: str | None = None
        # LiteLLM/OpenRouter style: openrouter/google/gemini-2.0-flash-001
        if model.startswith("openrouter/"):
            self._base_url = "https://openrouter.ai/api/v1"
            self._model = model.removeprefix("openrouter/")
        elif api_key.startswith("sk-or-"):
            self._base_url = "https://openrouter.ai/api/v1"

    def generate(
        self,
        *,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.3,
        max_output_tokens: int | None = None,
    ) -> LLMResponse:
        try:
            from openai import OpenAI
        except ImportError as exc:
            raise ImportError("Install openai: pip install openai") from exc

        client = OpenAI(api_key=self._api_key, base_url=self._base_url)
        kwargs: dict = {
            "model": self._model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": temperature,
        }
        if max_output_tokens is not None and max_output_tokens > 0:
            kwargs["max_tokens"] = max_output_tokens

        response = client.chat.completions.create(**kwargs)
        content = response.choices[0].message.content or ""
        return LLMResponse(content=content.strip(), model=self._model, provider="openai")


class GeminiLLMProvider(LLMProvider):
    def __init__(self, api_key: str, model: str) -> None:
        self._api_key = api_key
        self._model = model

    def generate(
        self,
        *,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.3,
        max_output_tokens: int | None = None,
    ) -> LLMResponse:
        try:
            from google import genai
            from google.genai import types
        except ImportError as exc:
            raise ImportError("Install google-genai: pip install google-genai") from exc

        client = genai.Client(api_key=self._api_key)
        config_kwargs: dict = {"temperature": temperature}
        if max_output_tokens is not None and max_output_tokens > 0:
            config_kwargs["max_output_tokens"] = max_output_tokens

        response = client.models.generate_content(
            model=self._model,
            contents=f"{system_prompt}\n\n{user_prompt}",
            config=types.GenerateContentConfig(**config_kwargs),
        )
        content = response.text or ""
        return LLMResponse(content=content.strip(), model=self._model, provider="gemini")


def create_llm_provider(
    provider: str,
    *,
    openai_api_key: str,
    openai_model: str,
    gemini_api_key: str,
    gemini_model: str,
) -> LLMProvider:
    if provider == "openai":
        if not openai_api_key:
            raise ValueError("OPENAI_API_KEY is required when LLM_PROVIDER=openai")
        return OpenAILLMProvider(api_key=openai_api_key, model=openai_model)
    if provider == "gemini":
        if not gemini_api_key:
            raise ValueError("GEMINI_API_KEY or GOOGLE_API_KEY is required when LLM_PROVIDER=gemini")
        return GeminiLLMProvider(api_key=gemini_api_key, model=gemini_model)
    raise ValueError(f"Unsupported LLM provider: {provider}")
