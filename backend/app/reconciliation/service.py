from app.reconciliation.models import (
    ReconciliationPreviewResponse,
    SourceRecordsResponse,
)
from app.sources.clinic_source import fetch_clinic_record_by_patient_id
from app.sources.lab_source import fetch_lab_candidates
from app.sources.pharmacy_source import fetch_pharmacy_candidates


def preview_source_records(patient_id: str) -> ReconciliationPreviewResponse | None:
    clinic_record = fetch_clinic_record_by_patient_id(patient_id)

    if clinic_record is None:
        return None

    lab_candidates = fetch_lab_candidates(clinic_record)
    pharmacy_candidates = fetch_pharmacy_candidates(clinic_record)

    source_records = SourceRecordsResponse(
        clinic_record=clinic_record,
        lab_candidates=lab_candidates,
        pharmacy_candidates=pharmacy_candidates,
    )

    return ReconciliationPreviewResponse(
        patient_id=patient_id,
        source_records=source_records,
    )