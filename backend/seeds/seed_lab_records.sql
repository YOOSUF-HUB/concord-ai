-- Concord AI lab seed records
-- Run this after schema.sql in the Supabase SQL Editor.

insert into lab_records (
    lab_patient_id,
    full_name,
    date_of_birth,
    phone,
    gender,
    address,
    test_name,
    test_value,
    test_unit,
    test_date,
    source_name
)
values
(
    'LAB-778',
    'M. Ahamed',
    '1998-04-12',
    '0771234567',
    'male',
    'Kandy',
    'HbA1c',
    '8.7',
    '%',
    '2026-06-01',
    'Lanka Diagnostics Kandy'
),
(
    'LAB-221',
    'Nimali Perera',
    '1985-09-21',
    '0715558899',
    'female',
    'Colombo',
    'Blood Pressure Review',
    'Controlled',
    null,
    '2026-05-29',
    'Colombo Diagnostics'
),
(
    'LAB-303',
    'R. Fernando',
    '1972-02-04',
    '0762223344',
    'male',
    'Galle',
    'Pulmonary Function Test',
    'Reduced airflow',
    null,
    '2026-05-05',
    'Southern Lab Services'
),
(
    'LAB-909',
    'Fathima Rizna',
    '1966-11-15',
    '0759876543',
    'female',
    'Kurunegala',
    'INR',
    '3.4',
    'ratio',
    '2026-06-06',
    'Kurunegala Lab Network'
)
on conflict (lab_patient_id) do update
set
    full_name = excluded.full_name,
    date_of_birth = excluded.date_of_birth,
    phone = excluded.phone,
    gender = excluded.gender,
    address = excluded.address,
    test_name = excluded.test_name,
    test_value = excluded.test_value,
    test_unit = excluded.test_unit,
    test_date = excluded.test_date,
    source_name = excluded.source_name,
    updated_at = now();