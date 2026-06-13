# Concord AI

**Autonomous AI agent for reconciling fragmented clinic, lab, and pharmacy records with conflict detection and safety alerts.**

Concord is a hackathon project built for **AgenTrix 2026**. It demonstrates how an autonomous clinical-record reconciliation agent can start from a single patient ID, search across fragmented healthcare sources, detect contradictions, adjudicate conflicts, and execute safety actions with minimal human intervention.

---

## Problem

In many healthcare environments, patient data is fragmented across different providers.

A single patient may have records stored separately in:

- a clinic system
- a laboratory system
- a pharmacy system

These systems may not share the same patient ID. The same patient may appear with slightly different names, phone numbers, or demographic details.

This creates serious clinical risks, such as:

- missed allergies
- conflicting medication histories
- unsafe prescriptions
- duplicated medications
- incomplete referral records
- outdated patient profiles

A clinician may not have time to manually compare every record from every source before making a decision.

---

## Solution

Concord acts as an autonomous clinical-record reconciliation agent.

When a clinician enters a patient ID, the system:

1. Fetches the starting patient record.
2. Searches across separate clinic, lab, and pharmacy datasets.
3. Finds likely matching records using identity similarity.
4. Pulls all matched records into one reconciliation workflow.
5. Detects clinical contradictions using deterministic rules.
6. Uses an LLM to adjudicate all conflicts in one structured batch.
7. Executes safety actions such as alerts, reconciled records, referral packets, and escalations.
8. Uses a final LLM review to flag low-confidence cases for human review.

The goal is not to replace clinicians. The goal is to reduce the manual effort needed to detect dangerous inconsistencies across fragmented records.

---

## Core Idea

Concord does not assume that every healthcare provider uses the same patient ID.

Instead, it uses the entered patient ID as a starting point, then matches records across sources using identity details such as:

- full name
- date of birth
- phone number
- gender
- address

This allows the system to identify that records such as the following may belong to the same real patient:

```text
Clinic:   Mohamed Ahamed
Lab:      M. Ahamed
Pharmacy: Mohammed Ahmed
```

Once the records are matched, Concord checks for contradictions and safety risks.

---

## Example Scenario

A clinician enters:

```text
CLN-001
```

Concord finds records from multiple sources.

### Clinic Record

```text
Name: Mohamed Ahamed
Allergy: Penicillin
Medication: Metformin
Diagnosis: Type 2 Diabetes
```

### Lab Record

```text
Name: M. Ahamed
HbA1c: 8.7%
```

### Pharmacy Record

```text
Name: Mohammed Ahmed
Allergy: None
Dispensed Medication: Amoxicillin
```

Concord detects:

```text
Clinic says the patient has a Penicillin allergy.
Pharmacy says the patient has no known allergies.
Pharmacy dispensed Amoxicillin.
```

This creates a high-severity safety issue because Amoxicillin can be dangerous for a patient with a Penicillin allergy.

Concord then creates a prescriber alert and flags the case for review if confidence is low.

---

## Agentic Workflow

Concord uses a bounded agentic workflow.

The agent is not just an LLM. It is the orchestration layer that coordinates deterministic backend logic, vector matching, conflict detection, LLM adjudication, action execution, and final review.

```text
Patient ID entered
    ↓
Fetch records from clinic, lab, and pharmacy sources
    ↓
Match patient identity using vector similarity
    ↓
Detect clinical conflicts using deterministic rules
    ↓
LLM Call 1: adjudicate all conflicts in one structured batch
    ↓
Execute predefined safety actions
    ↓
LLM Call 2: review actions and flag low-confidence cases
    ↓
Return reconciled result
```

---

## Why Only Two LLM Calls?

Concord deliberately uses only two LLM calls per reconciliation.

### LLM Call 1: Conflict Adjudication

All detected conflicts are sent to the LLM in one batch.

The LLM returns structured JSON containing:

- trusted value
- reasoning
- severity
- recommended action
- confidence score

### LLM Call 2: Action Review

After actions are executed, the LLM reviews the final outcome and decides whether any case should be escalated for human review.

This keeps the system:

- cost-efficient
- free-tier friendly
- faster during live demos
- easier to defend technically
- less dependent on uncontrolled LLM behavior

---

## What the LLM Does

The LLM is used only for controlled reasoning.

It helps with:

- adjudicating already-detected conflicts
- explaining which source should be trusted
- assigning severity
- recommending a predefined action
- reviewing final actions
- flagging low-confidence cases

The LLM does **not**:

- search the database
- directly execute actions
- independently decide which records exist
- detect conflicts from raw data without rules
- make unlimited tool calls
- replace deterministic safety logic

---

## Deterministic Clinical Logic

Clinical conflict detection is handled by deterministic backend rules, not by the LLM.

Example rule types:

- allergy mismatch
- allergy-medication conflict
- dangerous drug interaction
- medication duplication
- missing medication history
- outdated source record
- low-confidence identity match

This makes the safety logic explainable and testable.

---

## Data Source Strategy

For the hackathon demo, Concord uses seeded fake datasets.

The mocked source systems are stored separately as:

- clinic records
- lab records
- pharmacy records

These represent external systems in the demo.

In a real deployment, these seeded tables could be replaced by real API connectors without changing the core reconciliation workflow.

---

## Demo Data

The demo dataset should include multiple seeded patients:

```text
CLN-001 → Hero patient with planted contradictions
CLN-002 → Clean patient with no conflicts
CLN-003 → Ambiguous identity match
CLN-004 → Drug interaction case
```

The live presentation can focus on the hero patient, while the existence of multiple patients proves that the project is not hardcoded for a single case.

---

## Technology Stack

### Backend

- FastAPI
- PydanticAI
- Supabase Postgres
- pgvector
- sentence-transformers

### Frontend

- Next.js 15
- App Router
- React
- Tailwind CSS

### AI Models

- Gemini 2.0 Flash as the primary LLM
- Groq gpt-oss-120b as the fallback LLM

Both models are accessed through one internal interface so the agent logic can switch providers without changing the reconciliation workflow.

### Embeddings

Concord uses a local sentence-transformers model for identity embeddings.

This avoids paid embedding APIs and keeps the project free-tier friendly.

---

## Planned Project Structure

```text
concord-ai/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   └── llm_client.py
│   │   ├── db/
│   │   │   ├── supabase_client.py
│   │   │   └── schema.sql
│   │   ├── sources/
│   │   │   ├── clinic_source.py
│   │   │   ├── lab_source.py
│   │   │   └── pharmacy_source.py
│   │   ├── matching/
│   │   │   ├── embeddings.py
│   │   │   └── identity_matcher.py
│   │   ├── conflicts/
│   │   │   ├── rules.py
│   │   │   └── detector.py
│   │   ├── adjudication/
│   │   │   ├── models.py
│   │   │   └── adjudicator.py
│   │   ├── actions/
│   │   │   ├── executor.py
│   │   │   └── reviewer.py
│   │   └── reconciliation/
│   │       ├── models.py
│   │       └── service.py
│   ├── seeds/
│   │   ├── seed_clinic_records.sql
│   │   ├── seed_lab_records.sql
│   │   └── seed_pharmacy_records.sql
│   └── requirements.txt
│
├── frontend/
│   ├── app/
│   │   ├── page.tsx
│   │   ├── layout.tsx
│   │   └── reconciliation/
│   │       └── [runId]/
│   │           └── page.tsx
│   ├── components/
│   │   ├── PatientSearchForm.tsx
│   │   ├── AgentTimeline.tsx
│   │   ├── SourceRecordsPanel.tsx
│   │   ├── ConflictCard.tsx
│   │   ├── ActionCard.tsx
│   │   └── EscalationBanner.tsx
│   └── lib/
│       └── api.ts
│
├── docs/
│   ├── architecture.md
│   ├── agentic-loop.md
│   ├── business-logic.md
│   └── demo-script.md
│
├── .env.example
├── .gitignore
└── README.md
```

---

## Main Backend Responsibilities

The backend is responsible for the real reconciliation intelligence.

It handles:

- API requests
- source record fetching
- patient identity matching
- vector similarity search
- conflict detection
- LLM adjudication
- action execution
- final review
- storing reconciliation results

The frontend should only display the process and results.

---

## Main Frontend Responsibilities

The frontend makes the autonomous workflow visible to judges.

It should show:

- patient ID input
- source records found
- identity match confidence
- detected conflicts
- adjudication results
- executed safety actions
- escalation status
- final reconciled summary

The strongest demo moment is when conflicts appear and Concord resolves them automatically without the user touching anything after entering the patient ID.

---

## Safety Actions

Concord can execute predefined safety actions such as:

```text
PRESCRIBER_ALERT
RECONCILED_RECORD
REFERRAL_PACKET
HUMAN_ESCALATION
```

The LLM can recommend these actions, but the backend executes only actions that are already allowed by the system.

This prevents the LLM from performing uncontrolled operations.

---

## Example Output

```json
{
  "patient_id": "CLN-001",
  "matched_sources": ["clinic", "lab", "pharmacy"],
  "conflicts_detected": 3,
  "actions_executed": [
    {
      "type": "PRESCRIBER_ALERT",
      "message": "Possible Penicillin allergy conflict. Amoxicillin may be unsafe."
    },
    {
      "type": "RECONCILED_RECORD",
      "message": "Reconciled clinical summary generated."
    },
    {
      "type": "HUMAN_ESCALATION",
      "message": "High-severity allergy conflict requires clinician review."
    }
  ],
  "requires_human_review": true
}
```

---

## Technical Defense Summary

Concord separates deterministic clinical logic from LLM reasoning.

Deterministic code handles:

- data retrieval
- identity matching
- conflict detection
- action execution

The LLM handles:

- structured adjudication
- final review

This architecture keeps the system explainable, auditable, cost-efficient, and suitable for a live hackathon demo.

---

## Hackathon Scope

This project uses mocked seeded datasets instead of real healthcare integrations.

The integration layer is simulated, but the reconciliation workflow is real.

This means the demo focuses on proving the core intelligence:

- can the system match fragmented records?
- can it detect contradictions?
- can it adjudicate conflicts?
- can it execute safety actions?
- can it escalate uncertain cases?

---

## Repository Name

Recommended repository name:

```text
concord-ai
```

---

## Status

This project is being built incrementally during AgenTrix 2026.

Each component is added step by step with meaningful commits so the technical defense and Git history clearly show how the system was developed.
