-- Vision One EMR Pro - Supabase schema
-- Run this file in Supabase SQL Editor.
-- Designed for clinic operations: patients, appointments, visits, drugs, invoices, payments, packages, audit logs.

create extension if not exists pgcrypto;

-- ========== ENUMS ==========
do $$ begin
  create type gender_type as enum ('male','female','other','unspecified');
exception when duplicate_object then null; end $$;

do $$ begin
  create type appointment_status as enum ('pending','confirmed','checked_in','in_service','completed','cancelled','no_show');
exception when duplicate_object then null; end $$;

do $$ begin
  create type queue_status as enum ('waiting','pre_test','doctor','pharmacy','cashier','done','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type invoice_status as enum ('draft','unpaid','partial','paid','void');
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_method as enum ('cash','qr','credit_card','transfer','insurance','other');
exception when duplicate_object then null; end $$;

-- ========== CORE TABLES ==========
create table if not exists patients (
  id uuid primary key default gen_random_uuid(),
  hn text unique not null,
  first_name text not null,
  last_name text,
  nickname text,
  phone text,
  line_id text,
  email text,
  national_id text,
  date_of_birth date,
  gender gender_type default 'unspecified',
  address text,
  emergency_contact_name text,
  emergency_contact_phone text,
  insurance_provider text,
  insurance_policy_no text,
  pdpa_consent boolean default false,
  pdpa_consent_at timestamptz,
  tags text[] default '{}',
  note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists patient_allergies (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete cascade,
  allergen text not null,
  reaction text,
  severity text check (severity in ('mild','moderate','severe','unknown')) default 'unknown',
  created_at timestamptz default now()
);

create table if not exists patient_medical_history (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete cascade,
  history_type text not null check (history_type in ('medical','eye','surgical','family','social','medication')),
  description text not null,
  created_at timestamptz default now()
);

create table if not exists doctors (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  license_no text,
  specialty text,
  phone text,
  email text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists services (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  category text not null default 'clinic',
  price numeric(12,2) not null default 0,
  duration_minutes int default 30,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid references patients(id) on delete set null,
  doctor_id uuid references doctors(id) on delete set null,
  service_id uuid references services(id) on delete set null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  room text,
  device text,
  status appointment_status default 'pending',
  chief_complaint text,
  reminder_sent_at timestamptz,
  note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint appointment_valid_time check (end_at > start_at)
);

create index if not exists idx_appointments_start_at on appointments(start_at);
create index if not exists idx_appointments_patient on appointments(patient_id);

create table if not exists queue_items (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid references appointments(id) on delete set null,
  patient_id uuid references patients(id) on delete set null,
  queue_no text not null,
  status queue_status default 'waiting',
  priority text default 'normal',
  checked_in_at timestamptz default now(),
  completed_at timestamptz,
  note text
);

create table if not exists visits (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete cascade,
  appointment_id uuid references appointments(id) on delete set null,
  doctor_id uuid references doctors(id) on delete set null,
  visit_date date not null default current_date,
  visit_type text default 'consultation',
  chief_complaint text,
  diagnosis text,
  plan text,
  clinical_note jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists eye_exams (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid not null references visits(id) on delete cascade,
  eye text not null check (eye in ('OD','OS','OU')),
  ucva text,
  bcva text,
  sph text,
  cyl text,
  axis text,
  add_power text,
  iop numeric(6,2),
  pupil text,
  eom text,
  slit_lamp text,
  lens text,
  cup_disc_ratio text,
  macula text,
  rnfl numeric(8,2),
  note text,
  created_at timestamptz default now()
);

-- ========== PHARMACY ==========
create table if not exists drugs (
  id uuid primary key default gen_random_uuid(),
  sku text unique,
  name text not null,
  generic_name text,
  form text,
  strength text,
  unit text default 'item',
  allergy_group text,
  lot_no text,
  expiry_date date,
  stock_qty numeric(12,2) not null default 0,
  reorder_level numeric(12,2) not null default 5,
  unit_cost numeric(12,2) default 0,
  selling_price numeric(12,2) default 0,
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists prescriptions (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid not null references visits(id) on delete cascade,
  drug_id uuid not null references drugs(id) on delete restrict,
  eye text check (eye in ('OD','OS','OU','NA')) default 'NA',
  dose text,
  frequency text,
  duration_days int,
  quantity numeric(12,2) not null default 1,
  instruction text,
  created_at timestamptz default now()
);

create table if not exists drug_stock_movements (
  id uuid primary key default gen_random_uuid(),
  drug_id uuid not null references drugs(id) on delete cascade,
  movement_type text not null check (movement_type in ('receive','dispense','adjust','return','waste')),
  quantity numeric(12,2) not null,
  ref_table text,
  ref_id uuid,
  note text,
  created_at timestamptz default now()
);

-- ========== BILLING ==========
create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_no text unique not null,
  patient_id uuid references patients(id) on delete set null,
  visit_id uuid references visits(id) on delete set null,
  status invoice_status default 'draft',
  subtotal numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  tax numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  paid_amount numeric(12,2) not null default 0,
  issued_at timestamptz default now(),
  note text
);

create table if not exists invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices(id) on delete cascade,
  item_type text not null check (item_type in ('service','drug','procedure','package','other')),
  item_ref_id uuid,
  description text not null,
  quantity numeric(12,2) not null default 1,
  unit_price numeric(12,2) not null default 0,
  total numeric(12,2) generated always as (quantity * unit_price) stored
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id) on delete set null,
  patient_id uuid references patients(id) on delete set null,
  method payment_method not null default 'qr',
  amount numeric(12,2) not null,
  paid_at timestamptz default now(),
  reference_no text,
  note text
);

-- ========== PACKAGE / PROCEDURE ==========
create table if not exists patient_packages (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete cascade,
  package_name text not null,
  total_sessions int not null,
  used_sessions int not null default 0,
  price numeric(12,2) default 0,
  start_date date default current_date,
  expiry_date date,
  status text default 'active',
  note text
);

create table if not exists procedures (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid references patients(id) on delete set null,
  doctor_id uuid references doctors(id) on delete set null,
  procedure_name text not null,
  scheduled_at timestamptz,
  quote_amount numeric(12,2) default 0,
  deposit_amount numeric(12,2) default 0,
  status text default 'scheduled',
  precheck_done boolean default false,
  consent_signed boolean default false,
  timeout_done boolean default false,
  postcare_given boolean default false,
  note text,
  created_at timestamptz default now()
);

-- ========== SYSTEM ==========
create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid,
  actor_role text,
  action text not null,
  table_name text,
  record_id uuid,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

-- Auto updated_at helper
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

drop trigger if exists trg_patients_updated_at on patients;
create trigger trg_patients_updated_at before update on patients for each row execute function set_updated_at();

drop trigger if exists trg_appointments_updated_at on appointments;
create trigger trg_appointments_updated_at before update on appointments for each row execute function set_updated_at();

drop trigger if exists trg_visits_updated_at on visits;
create trigger trg_visits_updated_at before update on visits for each row execute function set_updated_at();

drop trigger if exists trg_drugs_updated_at on drugs;
create trigger trg_drugs_updated_at before update on drugs for each row execute function set_updated_at();

-- Simple stock deduction when prescription is created.
create or replace function dispense_drug_from_prescription()
returns trigger language plpgsql as $$
begin
  update drugs set stock_qty = stock_qty - new.quantity where id = new.drug_id;
  insert into drug_stock_movements(drug_id, movement_type, quantity, ref_table, ref_id, note)
  values(new.drug_id, 'dispense', new.quantity, 'prescriptions', new.id, 'Auto dispense from prescription');
  return new;
end; $$;

drop trigger if exists trg_prescription_dispense on prescriptions;
create trigger trg_prescription_dispense after insert on prescriptions for each row execute function dispense_drug_from_prescription();

-- Recommended RLS foundation. For prototype, policies allow anon access.
-- Before real patient use, enable Supabase Auth and replace these policies with role-based policies.
alter table patients enable row level security;
alter table patient_allergies enable row level security;
alter table patient_medical_history enable row level security;
alter table doctors enable row level security;
alter table services enable row level security;
alter table appointments enable row level security;
alter table queue_items enable row level security;
alter table visits enable row level security;
alter table eye_exams enable row level security;
alter table drugs enable row level security;
alter table prescriptions enable row level security;
alter table drug_stock_movements enable row level security;
alter table invoices enable row level security;
alter table invoice_items enable row level security;
alter table payments enable row level security;
alter table patient_packages enable row level security;
alter table procedures enable row level security;
alter table audit_logs enable row level security;

create or replace function create_dev_policy(table_name text) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "dev_all" on %I', table_name);
  execute format('create policy "dev_all" on %I for all using (true) with check (true)', table_name);
end; $$;

select create_dev_policy('patients');
select create_dev_policy('patient_allergies');
select create_dev_policy('patient_medical_history');
select create_dev_policy('doctors');
select create_dev_policy('services');
select create_dev_policy('appointments');
select create_dev_policy('queue_items');
select create_dev_policy('visits');
select create_dev_policy('eye_exams');
select create_dev_policy('drugs');
select create_dev_policy('prescriptions');
select create_dev_policy('drug_stock_movements');
select create_dev_policy('invoices');
select create_dev_policy('invoice_items');
select create_dev_policy('payments');
select create_dev_policy('patient_packages');
select create_dev_policy('procedures');
select create_dev_policy('audit_logs');
