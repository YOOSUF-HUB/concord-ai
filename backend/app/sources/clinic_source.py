from typing import Any

from app.db.supabase_client import get_supabase_client


def fetch_clinic_record_by_patient_id(clinic_patient_id: str) -> dict[str, Any] | None:
    supabase = get_supabase_client()

    response = (
        supabase.table("clinic_records")
        .select("*")
        .eq("clinic_patient_id", clinic_patient_id)
        .limit(1)
        .execute()
    )

    if not response.data:
        return None

    return response.data[0]