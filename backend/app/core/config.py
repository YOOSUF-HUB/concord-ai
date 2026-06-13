from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    backend_host: str = "127.0.0.1"
    backend_port: int = 8000
    environment: str = "development"

    supabase_url: str
    supabase_service_role_key: str

    llm_provider: str = "gemini"

    gemini_api_key: str | None = None
    gemini_model: str = "gemini-2.0-flash"

    groq_api_key: str | None = None
    groq_model: str = "gpt-oss-120b"

    embedding_model_name: str = "sentence-transformers/all-MiniLM-L6-v2"

    identity_match_threshold: float = 0.78
    low_confidence_threshold: float = 0.70

    model_config = SettingsConfigDict(
        env_file="../.env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()