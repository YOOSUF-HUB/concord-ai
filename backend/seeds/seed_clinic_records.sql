-- Concord AI clinic seed records
-- Run this after schema.sql in the Supabase SQL Editor.

insert into clinic_records (
    clinic_patient_id,
    full_name,
    date_of_birth,
    phone,
    gender,
    address,
    diagnoses,
    allergies,
    prescribed_medications,
    last_visit_date,
    source_name
)
values
(
    'CLN-001',
    'Mohamed Ahamed',
    '1998-04-12',
    '0771234567',
    'male',
    'Kandy',
    '["Type 2 Diabetes"]'::jsonb,
    '["Penicillin"]'::jsonb,
    '["Metformin"]'::jsonb,
    '2026-05-18',
    'Kandy Central Clinic'
),
(
    'CLN-002',
    'Nimali Perera',
    '1985-09-21',
    '0715558899',
    'female',
    'Colombo',
    '["Hypertension"]'::jsonb,
    '["None"]'::jsonb,
    '["Amlodipine"]'::jsonb,
    '2026-05-25',
    'Colombo Family Clinic'
),
(
    'CLN-003',
    'Ravi Fernando',
    '1972-02-03',
    '0762223344',
    'male',
    'Galle',
    '["Asthma"]'::jsonb,
    '["Aspirin"]'::jsonb,
    '["Salbutamol"]'::jsonb,
    '2026-04-30',
    'Galle Medical Centre'
),
(
    'CLN-004',
    'Fathima Rizna',
    '1966-11-15',
    '0759876543',
    'female',
    'Kurunegala',
    '["Atrial Fibrillation"]'::jsonb,
    '["None"]'::jsonb,
    '["Warfarin"]'::jsonb,
    '2026-06-02',
    'Kurunegala Heart Clinic'
)
on conflict (clinic_patient_id) do update
set
    full_name = excluded.full_name,
    date_of_birth = excluded.date_of_birth,
    phone = excluded.phone,
    gender = excluded.gender,
    address = excluded.address,
    diagnoses = excluded.diagnoses,
    allergies = excluded.allergies,
    prescribed_medications = excluded.prescribed_medications,
    last_visit_date = excluded.last_visit_date,
    source_name = excluded.source_name,
    updated_at = now();