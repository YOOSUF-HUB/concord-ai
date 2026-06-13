from fastapi import FastAPI, HTTPException

from app.core.config import settings
from app.db.supabase_client import get_supabase_client
from app.reconciliation.models import (
    ReconciliationPreviewResponse,
    ReconciliationRequest,
)
from app.reconciliation.service import preview_source_records

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


@app.get("/health/db")
def database_health_check() -> dict[str, str]:
    get_supabase_client()
    return {
        "status": "database client created",
    }


@app.post("/reconcile/preview", response_model=ReconciliationPreviewResponse)
def reconcile_preview(request: ReconciliationRequest) -> ReconciliationPreviewResponse:
    preview = preview_source_records(request.patient_id)

    if preview is None:
        raise HTTPException(
            status_code=404,
            detail=f"No clinic record found for patient ID: {request.patient_id}",
        )

    return preview