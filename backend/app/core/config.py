from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    database_url: str = "mysql+pymysql://pitagoras:pitagoras@localhost:3306/pitagoras"
    api_title: str = "Pitágoras API"
    api_version: str = "0.1.0"

    # Auth / JWT
    jwt_secret_key: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 30
    jwt_refresh_expire_days: int = 14
    # Rate limit login/register (slowapi). Desactivar en tests con AUTH_RATE_LIMIT_ENABLED=false
    auth_rate_limit_enabled: bool = True
    auth_rate_limit: str = "10/minute"

    # RAG / ChromaDB
    chroma_persist_directory: str = "./data/chroma"
    chroma_collection_name: str = "pitagoras_knowledge"
    embedding_model: str = "all-MiniLM-L6-v2"
    rag_chunk_size: int = 800
    rag_chunk_overlap: int = 120

    # LLM / Tutor
    llm_provider: str = "openai"
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash"
    google_api_key: str = ""
    tutor_rag_top_k: int = 5
    rag_max_pdf_pages: int = 40
    rag_max_upload_mb: int = 25

    # Agentes (diagnóstico / motivador / padres)
    # mode: compact = briefing + 1 llamada (menos tokens)
    #       full = ADK con tools (más preciso, más caro)
    #       rules = solo plantillas (0 tokens LLM)
    agent_execution_mode: str = "compact"
    use_llm_for_diagnostic: bool = True
    use_llm_for_motivator: bool = True
    use_llm_for_parents: bool = True
    agent_cache_ttl_seconds: int = 3600
    agent_brief_max_items: int = 3
    agent_rag_top_k: int = 2
    agent_rag_fragment_chars: int = 160
    agent_max_output_tokens: int = 220
    agent_max_output_chars: int = 900

    # CORS (Flutter web, etc.). Orígenes extra separados por coma.
    cors_origins: str = ""

    def google_api_key_effective(self) -> str:
        """Clave Gemini: GEMINI_API_KEY o GOOGLE_API_KEY."""
        if self.gemini_api_key.strip():
            return self.gemini_api_key.strip()
        return self.google_api_key.strip()


settings = Settings()


def cors_origin_list() -> list[str]:
    if not settings.cors_origins.strip():
        return []
    return [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
