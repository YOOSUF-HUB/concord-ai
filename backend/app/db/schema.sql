-- Concord AI database schema
-- Run this file in the Supabase SQL Editor.

create extension if not exists vector;

-- ------------------------------------------------------------
-- Mock source table: clinic system
-- ------------------------------------------------------------
create table if not exists clinic_records (
    id uuid primary key default gen_random_uuid(),
    clinic_patient_id text not null unique,
    full_name text not null,
    date_of_birth date not null,
    phone text,
    gender text,
    address text,
    diagnoses jsonb not null default '[]'::jsonb,
    allergies jsonb not null default '[]'::jsonb,
    prescribed_medications jsonb not null default '[]'::jsonb,
    last_visit_date date,
    source_name text not null default 'Clinic',
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Mock source table: lab system
-- ------------------------------------------------------------
create table if not exists lab_records (
    id uuid primary key default gen_random_uuid(),
    lab_patient_id text not null unique,
    full_name text not null,
    date_of_birth date not null,
    phone text,
    gender text,
    address text,
    test_name text not null,
    test_value text not null,
    test_unit text,
    test_date date not null,
    source_name text not null default 'Lab',
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Mock source table: pharmacy system
-- ------------------------------------------------------------
create table if not exists pharmacy_records (
    id uuid primary key default gen_random_uuid(),
    pharmacy_patient_id text not null unique,
    full_name text not null,
    date_of_birth date not null,
    phone text,
    gender text,
    address text,
    known_allergies jsonb not null default '[]'::jsonb,
    dispensed_medications jsonb not null default '[]'::jsonb,
    dispensed_date date,
    source_name text not null default 'Pharmacy',
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Vector table for identity matching
-- all-MiniLM-L6-v2 produces 384-dimensional embeddings.
-- ------------------------------------------------------------
create table if not exists patient_identity_vectors (
    id uuid primary key default gen_random_uuid(),
    source_type text not null check (source_type in ('clinic', 'lab', 'pharmacy')),
    source_record_id uuid not null,
    source_patient_id text not null,
    identity_text text not null,
    embedding vector(384) not null,
    created_at timestamptz not null default now()
);

create index if not exists patient_identity_vectors_embedding_idx
on patient_identity_vectors
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);

create index if not exists patient_identity_vectors_source_type_idx
on patient_identity_vectors (source_type);

-- ------------------------------------------------------------
-- Reconciliation run tracking
-- ------------------------------------------------------------
create table if not exists reconciliation_runs (
    id uuid primary key default gen_random_uuid(),
    input_patient_id text not null,
    status text not null default 'started'
        check (status in ('started', 'matched', 'conflicts_detected', 'adjudicated', 'actions_executed', 'reviewed', 'completed', 'failed')),
    identity_match_confidence numeric(5, 4),
    requires_human_review boolean not null default false,
    started_at timestamptz not null default now(),
    completed_at timestamptz
);

-- ------------------------------------------------------------
-- Deterministically detected conflicts
-- ------------------------------------------------------------
create table if not exists detected_conflicts (
    id uuid primary key default gen_random_uuid(),
    run_id uuid not null references reconciliation_runs(id) on delete cascade,
    conflict_type text not null,
    field_name text not null,
    description text not null,
    source_values jsonb not null default '[]'::jsonb,
    involved_sources jsonb not null default '[]'::jsonb,
    rule_severity text not null check (rule_severity in ('low', 'medium', 'high', 'critical')),
    created_at timestamptz not null default now()
);

create index if not exists detected_conflicts_run_id_idx
on detected_conflicts (run_id);

-- ------------------------------------------------------------
-- LLM Call 1 result: adjudication for detected conflicts
-- ------------------------------------------------------------
create table if not exists adjudication_results (
    id uuid primary key default gen_random_uuid(),
    run_id uuid not null references reconciliation_runs(id) on delete cascade,
    conflict_id uuid not null references detected_conflicts(id) on delete cascade,
    trusted_value text not null,
    reasoning text not null,
    severity text not null check (severity in ('low', 'medium', 'high', 'critical')),
    recommended_action text not null
        check (recommended_action in ('PRESCRIBER_ALERT', 'RECONCILED_RECORD', 'REFERRAL_PACKET', 'HUMAN_ESCALATION')),
    confidence numeric(5, 4) not null check (confidence >= 0 and confidence <= 1),
    created_at timestamptz not null default now()
);

create index if not exists adjudication_results_run_id_idx
on adjudication_results (run_id);

create index if not exists adjudication_results_conflict_id_idx
on adjudication_results (conflict_id);

-- ------------------------------------------------------------
-- Executed safety actions
-- ------------------------------------------------------------
create table if not exists executed_actions (
    id uuid primary key default gen_random_uuid(),
    run_id uuid not null references reconciliation_runs(id) on delete cascade,
    adjudication_result_id uuid references adjudication_results(id) on delete set null,
    action_type text not null
        check (action_type in ('PRESCRIBER_ALERT', 'RECONCILED_RECORD', 'REFERRAL_PACKET', 'HUMAN_ESCALATION')),
    action_message text not null,
    action_status text not null default 'created'
        check (action_status in ('created', 'skipped', 'failed')),
    requires_human_review boolean not null default false,
    created_at timestamptz not null default now()
);

create index if not exists executed_actions_run_id_idx
on executed_actions (run_id);