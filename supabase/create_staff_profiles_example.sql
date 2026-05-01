-- Vision One — Create staff profile examples
-- ใช้หลังจากสร้าง user ใน Supabase Auth แล้ว
-- Updated: ใช้ email แทน display_name

-- วิธีใช้:
-- 1) Supabase → Authentication → Users
-- 2) Copy User UID และ Email ของแต่ละคน
-- 3) แทนค่า 'PASTE_AUTH_USER_UUID_HERE' และ 'owner@example.com'
-- 4) Run SQL นี้

-- 0) Create staff_profiles table if it does not exist yet
create table if not exists public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  role text not null check (role in ('admin','doctor','nurse','reception','pharmacy','cashier','viewer')),
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.staff_profiles
  add column if not exists email text;

create unique index if not exists staff_profiles_email_unique_idx
on public.staff_profiles(lower(email))
where email is not null;

alter table public.staff_profiles enable row level security;

-- ให้ admin อ่านข้อมูลตัวเองได้ก่อน เพื่อกันล็อกตัวเองออกตอนเริ่มต้น
-- หมายเหตุ: production policy หลักอยู่ใน supabase/rls_production.sql
drop policy if exists "staff_can_read_self" on public.staff_profiles;
create policy "staff_can_read_self"
on public.staff_profiles for select
to authenticated
using (
  id = auth.uid()
  or exists (
    select 1 from public.staff_profiles sp
    where sp.id = auth.uid()
      and sp.role = 'admin'
      and sp.active = true
  )
);

-- ตัวอย่าง admin / owner
insert into public.staff_profiles(id, email, role, active)
values (
  'PASTE_AUTH_USER_UUID_HERE',
  'owner@example.com',
  'admin',
  true
)
on conflict (id) do update set
  email = excluded.email,
  role = excluded.role,
  active = excluded.active;

-- ตัวอย่าง doctor
-- insert into public.staff_profiles(id, email, role, active)
-- values (
--   'PASTE_DOCTOR_AUTH_USER_UUID_HERE',
--   'doctor@example.com',
--   'doctor',
--   true
-- )
-- on conflict (id) do update set
--   email = excluded.email,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง nurse
-- insert into public.staff_profiles(id, email, role, active)
-- values (
--   'PASTE_NURSE_AUTH_USER_UUID_HERE',
--   'nurse@example.com',
--   'nurse',
--   true
-- )
-- on conflict (id) do update set
--   email = excluded.email,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง reception
-- insert into public.staff_profiles(id, email, role, active)
-- values (
--   'PASTE_RECEPTION_AUTH_USER_UUID_HERE',
--   'reception@example.com',
--   'reception',
--   true
-- )
-- on conflict (id) do update set
--   email = excluded.email,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง pharmacy
-- insert into public.staff_profiles(id, email, role, active)
-- values (
--   'PASTE_PHARMACY_AUTH_USER_UUID_HERE',
--   'pharmacy@example.com',
--   'pharmacy',
--   true
-- )
-- on conflict (id) do update set
--   email = excluded.email,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง cashier
-- insert into public.staff_profiles(id, email, role, active)
-- values (
--   'PASTE_CASHIER_AUTH_USER_UUID_HERE',
--   'cashier@example.com',
--   'cashier',
--   true
-- )
-- on conflict (id) do update set
--   email = excluded.email,
--   role = excluded.role,
--   active = excluded.active;
