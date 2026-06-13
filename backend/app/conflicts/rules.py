PENICILLIN_FAMILY_MEDICATIONS = {
    "amoxicillin",
    "ampicillin",
    "penicillin",
    "cloxacillin",
}


HIGH_RISK_DRUG_PAIRS = {
    frozenset({"warfarin", "aspirin"}): "Warfarin and Aspirin can increase bleeding risk when used together.",
}


def normalize_text(value: str) -> str:
    return value.strip().lower()


def normalize_list(values: list[str]) -> set[str]:
    return {normalize_text(value) for value in values if value and normalize_text(value) != "none"}


def has_allergy_medication_conflict(
    allergies: list[str],
    medications: list[str],
) -> bool:
    normalized_allergies = normalize_list(allergies)
    normalized_medications = normalize_list(medications)

    has_penicillin_allergy = "penicillin" in normalized_allergies
    has_penicillin_family_medication = bool(
        normalized_medications.intersection(PENICILLIN_FAMILY_MEDICATIONS)
    )

    return has_penicillin_allergy and has_penicillin_family_medication


def find_high_risk_drug_pair(medications: list[str]) -> str | None:
    normalized_medications = normalize_list(medications)

    for drug_pair, warning in HIGH_RISK_DRUG_PAIRS.items():
        if drug_pair.issubset(normalized_medications):
            return warning

    return None


def has_allergy_mismatch(
    clinic_allergies: list[str],
    pharmacy_allergies: list[str],
) -> bool:
    normalized_clinic_allergies = normalize_list(clinic_allergies)
    normalized_pharmacy_allergies = normalize_list(pharmacy_allergies)

    return normalized_clinic_allergies != normalized_pharmacy_allergies