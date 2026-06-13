-- Concord AI pharmacy seed records
-- Run this after schema.sql in the Supabase SQL Editor.

insert into pharmacy_records (
    pharmacy_patient_id,
    full_name,
    date_of_birth,
    phone,
    gender,
    address,
    known_allergies,
    dispensed_medications,
    dispensed_date,
    source_name
)
values
(
    'PHM-554',
    'Mohammed Ahmed',
    '1998-04-12',
    '0771234567',
    'male',
    'Kandy',
    '["None"]'::jsonb,
    '["Amoxicillin", "Metformin"]'::jsonb,
    '2026-06-05',
    'Kandy City Pharmacy'
),
(
    'PHM-102',
    'Nimali Perera',
    '1985-09-21',
    '0715558899',
    'female',
    'Colombo',
    '["None"]'::jsonb,
    '["Amlodipine"]'::jsonb,
    '2026-05-27',
    'Colombo Care Pharmacy'
),
(
    'PHM-333',
    'Ravi S. Fernando',
    '1972-02-03',
    '0762223355',
    'male',
    'Galle',
    '["Aspirin"]'::jsonb,
    '["Salbutamol"]'::jsonb,
    '2026-05-03',
    'Galle Wellness Pharmacy'
),
(
    'PHM-804',
    'Fathima Rizna',
    '1966-11-15',
    '0759876543',
    'female',
    'Kurunegala',
    '["None"]'::jsonb,
    '["Warfarin", "Aspirin"]'::jsonb,
    '2026-06-07',
    'Kurunegala Central Pharmacy'
)
on conflict (pharmacy_patient_id) do update
set
    full_name = excluded.full_name,
    date_of_birth = excluded.date_of_birth,
    phone = excluded.phone,
    gender = excluded.gender,
    address = excluded.address,
    known_allergies = excluded.known_allergies,
    dispensed_medications = excluded.dispensed_medications,
    dispensed_date = excluded.dispensed_date,
    source_name = excluded.source_name,
    updated_at = now();