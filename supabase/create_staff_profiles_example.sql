-- Vision One — Create staff profile examples
-- ใช้หลังจากสร้าง user ใน Supabase Auth แล้ว
-- วิธีใช้:
-- 1) Supabase → Authentication → Users
-- 2) Copy User UID ของแต่ละคน
-- 3) แทนค่า 'PASTE_AUTH_USER_UUID_HERE'
-- 4) Run SQL นี้

-- ตัวอย่าง admin / owner
insert into public.staff_profiles(id, display_name, role, active)
values (
  'PASTE_AUTH_USER_UUID_HERE',
  'Owner / Admin',
  'admin',
  true
)
on conflict (id) do update set
  display_name = excluded.display_name,
  role = excluded.role,
  active = excluded.active;

-- ตัวอย่าง doctor
-- insert into public.staff_profiles(id, display_name, role, active)
-- values (
--   'PASTE_DOCTOR_AUTH_USER_UUID_HERE',
--   'Doctor Name',
--   'doctor',
--   true
-- )
-- on conflict (id) do update set
--   display_name = excluded.display_name,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง nurse
-- insert into public.staff_profiles(id, display_name, role, active)
-- values (
--   'PASTE_NURSE_AUTH_USER_UUID_HERE',
--   'Nurse Name',
--   'nurse',
--   true
-- )
-- on conflict (id) do update set
--   display_name = excluded.display_name,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง reception
-- insert into public.staff_profiles(id, display_name, role, active)
-- values (
--   'PASTE_RECEPTION_AUTH_USER_UUID_HERE',
--   'Reception Name',
--   'reception',
--   true
-- )
-- on conflict (id) do update set
--   display_name = excluded.display_name,
--   role = excluded.role,
--   active = excluded.active;

-- ตัวอย่าง cashier
-- insert into public.staff_profiles(id, display_name, role, active)
-- values (
--   'PASTE_CASHIER_AUTH_USER_UUID_HERE',
--   'Cashier Name',
--   'cashier',
--   true
-- )
-- on conflict (id) do update set
--   display_name = excluded.display_name,
--   role = excluded.role,
--   active = excluded.active;
