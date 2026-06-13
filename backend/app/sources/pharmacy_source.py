from typing import Any

from app.db.supabase_client import get_supabase_client


def fetch_pharmacy_candidates(identity: dict[str, Any]) -> list[dict[str, Any]]:
    supabase = get_supabase_client()

    date_of_birth = identity.get("date_of_birth")
    phone = identity.get("phone")

    query = supabase.table("pharmacy_records").select("*")

    if phone:
        response = query.eq("phone", phone).execute()
        if response.data:
            return response.data

    if date_of_birth:
        response = query.eq("date_of_birth", date_of_birth).execute()
        return response.data or []

    return []