from fastapi import FastAPI

from app.core.config import settings

app = FastAPI(
    title="Concord AI API",
    description="Backend API for autonomous clinical-record reconciliation.",
    version="0.1.0",
)


@app.get("/")
def read_root() -> dict[str, str]:
    return {
        "service": "Concord AI API",
        "status": "running",
        "environment": settings.environment,
    }


@app.get("/health")
def health_check() -> dict[str, str]:
    return {
        "status": "healthy",
    }