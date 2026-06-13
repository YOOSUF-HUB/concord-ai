from typing import Any
from uuid import uuid4

from app.conflicts.rules import (
    find_high_risk_drug_pair,
    has_allergy_medication_conflict,
    has_allergy_mismatch,
)


def _as_string_list(value: Any) -> list[str]:
    if value is None:
        return []

    if isinstance(value, list):
        return [str(item) for item in value]

    return [str(value)]


def detect_conflicts(
    clinic_record: dict[str, Any],
    lab_records: list[dict[str, Any]],
    pharmacy_records: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    conflicts: list[dict[str, Any]] = []

    clinic_allergies = _as_string_list(clinic_record.get("allergies"))
    clinic_medications = _as_string_list(clinic_record.get("prescribed_medications"))

    for pharmacy_record in pharmacy_records:
        pharmacy_allergies = _as_string_list(pharmacy_record.get("known_allergies"))
        pharmacy_medications = _as_string_list(pharmacy_record.get("dispensed_medications"))

        if has_allergy_mismatch(clinic_allergies, pharmacy_allergies):
            conflicts.append(
                {
                    "conflict_id": str(uuid4()),
                    "conflict_type": "ALLERGY_MISMATCH",
                    "field_name": "allergies",
                    "description": "Clinic and pharmacy allergy records do not match.",
                    "source_values": [
                        {
                            "source": clinic_record.get("source_name", "Clinic"),
                            "value": clinic_allergies,
                        },
                        {
                            "source": pharmacy_record.get("source_name", "Pharmacy"),
                            "value": pharmacy_allergies,
                        },
                    ],
                    "involved_sources": ["clinic", "pharmacy"],
                    "rule_severity": "high",
                }
            )

        combined_medications = clinic_medications + pharmacy_medications

        if has_allergy_medication_conflict(clinic_allergies, combined_medications):
            conflicts.append(
                {
                    "conflict_id": str(uuid4()),
                    "conflict_type": "ALLERGY_MEDICATION_CONFLICT",
                    "field_name": "medications",
                    "description": "A medication may be unsafe because it belongs to a family linked to the patient's allergy.",
                    "source_values": [
                        {
                            "source": clinic_record.get("source_name", "Clinic"),
                            "value": clinic_allergies,
                        },
                        {
                            "source": pharmacy_record.get("source_name", "Pharmacy"),
                            "value": pharmacy_medications,
                        },
                    ],
                    "involved_sources": ["clinic", "pharmacy"],
                    "rule_severity": "critical",
                }
            )

        drug_pair_warning = find_high_risk_drug_pair(combined_medications)

        if drug_pair_warning:
            conflicts.append(
                {
                    "conflict_id": str(uuid4()),
                    "conflict_type": "HIGH_RISK_DRUG_INTERACTION",
                    "field_name": "medications",
                    "description": drug_pair_warning,
                    "source_values": [
                        {
                            "source": clinic_record.get("source_name", "Clinic"),
                            "value": clinic_medications,
                        },
                        {
                            "source": pharmacy_record.get("source_name", "Pharmacy"),
                            "value": pharmacy_medications,
                        },
                    ],
                    "involved_sources": ["clinic", "pharmacy"],
                    "rule_severity": "critical",
                }
            )

    for lab_record in lab_records:
        test_name = str(lab_record.get("test_name", "")).lower()
        test_value = str(lab_record.get("test_value", ""))

        if test_name == "hba1c":
            try:
                hba1c_value = float(test_value)
            except ValueError:
                continue

            if hba1c_value >= 8.0:
                conflicts.append(
                    {
                        "conflict_id": str(uuid4()),
                        "conflict_type": "UNCONTROLLED_DIABETES_SIGNAL",
                        "field_name": "lab_results",
                        "description": "HbA1c result is high and may indicate poor diabetes control.",
                        "source_values": [
                            {
                                "source": lab_record.get("source_name", "Lab"),
                                "value": f"{test_value}{lab_record.get('test_unit') or ''}",
                            }
                        ],
                        "involved_sources": ["lab"],
                        "rule_severity": "medium",
                    }
                )

    return conflicts