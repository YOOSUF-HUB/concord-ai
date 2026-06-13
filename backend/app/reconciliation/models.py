from typing import Any

from pydantic import BaseModel, Field


class ReconciliationRequest(BaseModel):
    patient_id: str = Field(
        ...,
        min_length=1,
        description="The clinic patient ID entered by the clinician.",
    )


class SourceRecordsResponse(BaseModel):
    clinic_record: dict[str, Any]
    lab_candidates: list[dict[str, Any]]
    pharmacy_candidates: list[dict[str, Any]]


class ReconciliationPreviewResponse(BaseModel):
    patient_id: str
    source_records: SourceRecordsResponse