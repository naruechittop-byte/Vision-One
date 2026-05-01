-- Vision One EMR Pro - Production RLS foundation
-- Run only after Supabase Auth is enabled and staff accounts are created.
-- This replaces dev_all policies from schema.sql.

-- 1) Staff profiles mapped to auth.users
create table if not exists staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null check (role in ('admin','doctor','nurse','reception','pharmacy','cashier','viewer')),
  active boolean default true,
  created_at timestamptz default now()
);

alter table staff_profiles enable row level security;

drop policy if exists "staff_can_read_self" on staff_profiles;
create policy "staff_can_read_self"
on staff_profiles for select
to authenticated
using (id = auth.uid() or exists (select 1 from staff_profiles sp where sp.id = auth.uid() and sp.role = 'admin' and sp.active));

-- 2) Helper functions
create or replace function current_staff_role()
returns text language sql stable security definer as $$
  select role from public.staff_profiles where id = auth.uid() and active = true limit 1;
$$;

create or replace function is_staff(roles text[])
returns boolean language sql stable security definer as $$
  select coalesce(public.current_staff_role() = any(roles), false);
$$;

create or replace function drop_dev_policy(t text) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "dev_all" on %I', t);
exception when undefined_table then null;
end; $$;

select drop_dev_policy('patients');
select drop_dev_policy('patient_allergies');
select drop_dev_policy('patient_medical_history');
select drop_dev_policy('doctors');
select drop_dev_policy('services');
select drop_dev_policy('appointments');
select drop_dev_policy('queue_items');
select drop_dev_policy('visits');
select drop_dev_policy('eye_exams');
select drop_dev_policy('drugs');
select drop_dev_policy('prescriptions');
select drop_dev_policy('drug_stock_movements');
select drop_dev_policy('invoices');
select drop_dev_policy('invoice_items');
select drop_dev_policy('payments');
select drop_dev_policy('patient_packages');
select drop_dev_policy('procedures');
select drop_dev_policy('audit_logs');

-- 3) Generic policy helpers
create or replace function create_read_policy(t text, roles text[]) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "role_read" on %I', t);
  execute format('create policy "role_read" on %I for select to authenticated using (public.is_staff(%L::text[]))', t, roles);
end; $$;

create or replace function create_write_policy(t text, roles text[]) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "role_insert" on %I', t);
  execute format('drop policy if exists "role_update" on %I', t);
  execute format('create policy "role_insert" on %I for insert to authenticated with check (public.is_staff(%L::text[]))', t, roles);
  execute format('create policy "role_update" on %I for update to authenticated using (public.is_staff(%L::text[])) with check (public.is_staff(%L::text[]))', t, roles, roles);
end; $$;

-- 4) Read permissions
select create_read_policy('patients', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select create_read_policy('patient_allergies', array['admin','doctor','nurse','pharmacy']);
select create_read_policy('patient_medical_history', array['admin','doctor','nurse']);
select create_read_policy('doctors', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select create_read_policy('services', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select create_read_policy('appointments', array['admin','doctor','nurse','reception','viewer']);
select create_read_policy('queue_items', array['admin','doctor','nurse','reception','pharmacy','cashier','viewer']);
select create_read_policy('visits', array['admin','doctor','nurse']);
select create_read_policy('eye_exams', array['admin','doctor','nurse']);
select create_read_policy('drugs', array['admin','doctor','nurse','pharmacy','cashier','viewer']);
select create_read_policy('prescriptions', array['admin','doctor','nurse','pharmacy']);
select create_read_policy('drug_stock_movements', array['admin','pharmacy']);
select create_read_policy('invoices', array['admin','cashier','reception']);
select create_read_policy('invoice_items', array['admin','cashier','reception']);
select create_read_policy('payments', array['admin','cashier']);
select create_read_policy('patient_packages', array['admin','doctor','nurse','reception','cashier']);
select create_read_policy('procedures', array['admin','doctor','nurse','reception','cashier']);
select create_read_policy('audit_logs', array['admin']);

-- 5) Write permissions
select create_write_policy('patients', array['admin','doctor','nurse','reception']);
select create_write_policy('patient_allergies', array['admin','doctor','nurse']);
select create_write_policy('patient_medical_history', array['admin','doctor','nurse']);
select create_write_policy('doctors', array['admin']);
select create_write_policy('services', array['admin']);
select create_write_policy('appointments', array['admin','doctor','nurse','reception']);
select create_write_policy('queue_items', array['admin','doctor','nurse','reception','pharmacy','cashier']);
select create_write_policy('visits', array['admin','doctor','nurse']);
select create_write_policy('eye_exams', array['admin','doctor','nurse']);
select create_write_policy('drugs', array['admin','pharmacy']);
select create_write_policy('prescriptions', array['admin','doctor','nurse','pharmacy']);
select create_write_policy('drug_stock_movements', array['admin','pharmacy']);
select create_write_policy('invoices', array['admin','cashier','reception']);
select create_write_policy('invoice_items', array['admin','cashier','reception']);
select create_write_policy('payments', array['admin','cashier']);
select create_write_policy('patient_packages', array['admin','doctor','nurse','reception','cashier']);
select create_write_policy('procedures', array['admin','doctor','nurse','reception']);
select create_write_policy('audit_logs', array['admin','doctor','nurse','reception','pharmacy','cashier']);

-- 6) No hard delete except admin. Prefer soft delete in future.
create or replace function create_admin_delete_policy(t text) returns void language plpgsql as $$
begin
  execute format('drop policy if exists "admin_delete" on %I', t);
  execute format('create policy "admin_delete" on %I for delete to authenticated using (public.is_staff(array[''admin'']))', t);
end; $$;

select create_admin_delete_policy('patients');
select create_admin_delete_policy('appointments');
select create_admin_delete_policy('visits');
select create_admin_delete_policy('drugs');
select create_admin_delete_policy('invoices');
select create_admin_delete_policy('payments');
