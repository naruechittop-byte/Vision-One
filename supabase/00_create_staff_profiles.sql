-- Vision One — 00 Create Staff Profiles Table
-- รันไฟล์นี้ก่อน create_staff_profiles_example.sql และก่อน rls_production.sql
-- ใช้สำหรับสร้างตาราง staff_profiles ที่ผูกกับ Supabase Auth users
-- Updated: ใช้ email เป็น field หลักแทน display_name

-- ลำดับที่ถูกต้อง:
-- 1) supabase/schema.sql
-- 2) supabase/00_create_staff_profiles.sql
-- 3) สร้าง user ใน Supabase Auth
-- 4) supabase/create_staff_profiles_example.sql
-- 5) supabase/rls_production.sql

create table if not exists public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  role text not null check (role in (
    'admin',
    'doctor',
    'nurse',
    'reception',
    'pharmacy',
    'cashier',
    'viewer'
  )),
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Migration safety: ถ้าตารางเคยถูกสร้างด้วย display_name มาก่อน ให้เพิ่ม email เข้าไป
alter table public.staff_profiles
  add column if not exists email text;

-- ถ้ามี display_name เดิมและยังไม่มี email ให้ copy ค่าเดิมมาก่อนชั่วคราว
-- หลังจากนั้นควร update เป็น email จริงของ staff
update public.staff_profiles
set email = display_name
where email is null
  and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'staff_profiles'
      and column_name = 'display_name'
  );

create unique index if not exists staff_profiles_email_unique_idx
on public.staff_profiles(lower(email))
where email is not null;

alter table public.staff_profiles enable row level security;

-- updated_at helper เผื่อ schema หลักยังไม่ได้สร้าง function นี้
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

drop trigger if exists trg_staff_profiles_updated_at on public.staff_profiles;
create trigger trg_staff_profiles_updated_at
before update on public.staff_profiles
for each row execute function public.set_updated_at();

-- Bootstrap policy ชั่วคราวสำหรับให้ staff อ่าน profile ตัวเองได้
-- หลังจากรัน rls_production.sql แล้ว policy หลักจะเข้ามาคุมละเอียดขึ้น

drop policy if exists "staff_can_read_self" on public.staff_profiles;
create policy "staff_can_read_self"
on public.staff_profiles
for select
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

select 'staff_profiles table is ready with email field' as status;
