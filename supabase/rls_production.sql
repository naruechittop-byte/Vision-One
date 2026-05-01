-- Vision One EMR Pro - Production RLS foundation
-- Run only after Supabase Auth is enabled and staff accounts are created.
-- This replaces dev_all policies from schema.sql.
-- Updated: staff_profiles uses email as staff identity, linked to auth.users by id.

-- 1) Staff profiles mapped to auth.users
create table if not exists public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  role text not null check (role in ('admin','doctor','nurse','reception','pharmacy','cashier','viewer')),
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.staff_profiles add column if not exists email text;
alter table public.staff_profiles add column if not exists updated_at timestamptz default now();

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'staff_profiles'
      and column_name = 'display_name'
  ) then
    alter table public.staff_profiles alter column display_name drop not null;
  end if;
end $$;

create unique index if not exists staff_profiles_email_unique_idx
on public.staff_profiles(lower(email))
where email is not null;

alter table public.staff_profiles enable row level security;

drop policy if exists "dev_all" on public.staff_profiles;
drop policy if exists "staff_can_read_self" on public.staff_profiles;
create policy "staff_can_read_self"
on public.staff_profiles for select
to authenticated
using (
  id = auth.uid()
  or exists (
    select 1
    from public.staff_profiles sp
    where sp.id = auth.uid()
      and sp.role = 'admin'
      and sp.active = true
  )
);

-- 2) Helper functions
create or replace function public.current_staff_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.staff_profiles where id = auth.uid() and active = true limit 1;
$$;

create or replace function public.current_staff_email()
returns text language sql stable security definer set search_path = public as $$
  select email from public.staff_profiles where id = auth.uid() and active = true limit 1;
$$;

create or replace function public.is_staff(roles text[])
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.current_staff_role() = any(roles), false);
$$;

create or replace function public.drop_dev_policy(t text) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "dev_all" on public.%I', t);
exception when undefined_table then null;
end; $$;

select public.drop_dev_policy('patients');
select public.drop_dev_policy('patient_allergies');
select public.drop_dev_policy('patient_medical_history');
select public.drop_dev_policy('doctors');
select public.drop_dev_policy('services');
select public.drop_dev_policy('appointments');
select public.drop_dev_policy('queue_items');
select public.drop_dev_policy('visits');
select public.drop_dev_policy('eye_exams');
select public.drop_dev_policy('drugs');
select public.drop_dev_policy('prescriptions');
select public.drop_dev_policy('drug_stock_movements');
select public.drop_dev_policy('invoices');
select public.drop_dev_policy('invoice_items');
select public.drop_dev_policy('payments');
select public.drop_dev_policy('patient_packages');
select public.drop_dev_policy('procedures');
select public.drop_dev_policy('staff_profiles');
select public.drop_dev_policy('audit_logs');

-- 3) Generic policy helpers
create or replace function public.create_read_policy(t text, roles text[]) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "role_read" on public.%I', t);
  execute format('create policy "role_read" on public.%I for select to authenticated using (public.is_staff(%L::text[]))', t, roles);
end; $$;

create or replace function public.create_write_policy(t text, roles text[]) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "role_insert" on public.%I', t);
  execute format('drop policy if exists "role_update" on public.%I', t);
  execute format('create policy "role_insert" on public.%I for insert to authenticated with check (public.is_staff(%L::text[]))', t, roles);
  execute format('create policy "role_update" on public.%I for update to authenticated using (public.is_staff(%L::text[])) with check (public.is_staff(%L::text[]))', t, roles, roles);
end; $$;

-- 4) Read permissions
select public.create_read_policy('patients', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select public.create_read_policy('patient_allergies', array['admin','doctor','nurse','pharmacy']);
select public.create_read_policy('patient_medical_history', array['admin','doctor','nurse']);
select public.create_read_policy('doctors', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select public.create_read_policy('services', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select public.create_read_policy('appointments', array['admin','doctor','nurse','reception','viewer']);
select public.create_read_policy('queue_items', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select public.create_read_policy('visits', array['admin','doctor','nurse']);
select public.create_read_policy('eye_exams', array['admin','doctor','nurse']);
select public.create_read_policy('drugs', array['admin','doctor','nurse','pharmacy','cashier','viewer']);
select public.create_read_policy('prescriptions', array['admin','doctor','nurse','pharmacy']);
select public.create_read_policy('drug_stock_movements', array['admin','pharmacy']);
select public.create_read_policy('invoices', array['admin','cashier','reception']);
select public.create_read_policy('invoice_items', array['admin','cashier','reception']);
select public.create_read_policy('payments', array['admin','cashier']);
select public.create_read_policy('patient_packages', array['admin','doctor','nurse','reception','cashier']);
select public.create_read_policy('procedures', array['admin','doctor','nurse','reception','cashier']);
select public.create_read_policy('audit_logs', array['admin']);

-- 5) Write permissions
select public.create_write_policy('patients', array['admin','doctor','nurse','reception']);
select public.create_write_policy('patient_allergies', array['admin','doctor','nurse']);
select public.create_write_policy('patient_medical_history', array['admin','doctor','nurse']);
select public.create_write_policy('doctors', array['admin']);
select public.create_write_policy('services', array['admin']);
select public.create_write_policy('appointments', array['admin','doctor','nurse','reception']);
select public.create_write_policy('queue_items', array['admin','doctor','nurse','reception','pharmacy','cashier']);
select public.create_write_policy('visits', array['admin','doctor','nurse']);
select public.create_write_policy('eye_exams', array['admin','doctor','nurse']);
select public.create_write_policy('drugs', array['admin','pharmacy']);
select public.create_write_policy('prescriptions', array['admin','doctor','nurse','pharmacy']);
select public.create_write_policy('drug_stock_movements', array['admin','pharmacy']);
select public.create_write_policy('invoices', array['admin','cashier','reception']);
select public.create_write_policy('invoice_items', array['admin','cashier','reception']);
select public.create_write_policy('payments', array['admin','cashier']);
select public.create_write_policy('patient_packages', array['admin','doctor','nurse','reception','cashier']);
select public.create_write_policy('procedures', array['admin','doctor','nurse','reception']);
select public.create_write_policy('audit_logs', array['admin','doctor','nurse','reception','pharmacy','cashier']);

-- 6) Staff profile update permissions
-- Admin can manage staff profiles. Staff can read self through staff_can_read_self above.
drop policy if exists "admin_manage_staff_profiles" on public.staff_profiles;
create policy "admin_manage_staff_profiles"
on public.staff_profiles
for all
to authenticated
using (public.is_staff(array['admin']))
with check (public.is_staff(array['admin']));

-- 7) No hard delete except admin. Prefer soft delete in future.
create or replace function public.create_admin_delete_policy(t text) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "admin_delete" on public.%I', t);
  execute format('create policy "admin_delete" on public.%I for delete to authenticated using (public.is_staff(array[''admin'']))', t);
end; $$;

select public.create_admin_delete_policy('patients');
select public.create_admin_delete_policy('appointments');
select public.create_admin_delete_policy('visits');
select public.create_admin_delete_policy('drugs');
select public.create_admin_delete_policy('invoices');
select public.create_admin_delete_policy('payments');
