# Vision One — Go Live Checklist สำหรับใช้ Database จริงใน Supabase

เอกสารนี้คือขั้นตอนเปลี่ยนจาก Demo/Prototype ไปเป็นระบบที่เริ่มใช้กับข้อมูลจริงได้ปลอดภัยขึ้น

> สำคัญ: ข้อมูลคนไข้เป็นข้อมูลละเอียดอ่อน ห้ามใช้ production โดยยังเปิด `dev_all` policy อยู่

---

## สถานะที่ต้องมีก่อน Go Live

### 1) Database พร้อม

ใน Supabase ต้องรันแล้ว:

1. `supabase/schema.sql`
2. `supabase/seed.sql` เฉพาะช่วงทดสอบเท่านั้น

ก่อนใช้จริง แนะนำให้ลบ demo data หรือสร้าง project ใหม่สำหรับ production แล้วไม่รัน seed demo

---

### 2) Vercel พร้อม

ใน Vercel → Project Settings → Environment Variables ต้องมี:

```txt
SUPABASE_URL
SUPABASE_ANON_KEY
```

หลังใส่แล้วต้อง Redeploy

---

### 3) ต้องเปิด Supabase Auth

ใน Supabase:

Authentication → Providers → Email เปิดใช้งาน

แนะนำช่วงแรก:

- เปิด Email/Password
- ปิด self sign-up ถ้าไม่อยากให้คนสมัครเอง
- สร้าง user ให้ staff เองจาก Dashboard

---

### 4) ต้องสร้าง Staff Role

ระบบใช้ตาราง:

```txt
staff_profiles
```

Role ที่รองรับ:

- `admin`
- `doctor`
- `nurse`
- `reception`
- `pharmacy`
- `cashier`
- `viewer`

---

### 5) ต้องรัน RLS Production

หลังจากสร้าง staff user แล้ว ให้รัน:

```txt
supabase/rls_production.sql
```

ไฟล์นี้จะลบ policy `dev_all` และเปลี่ยนเป็น role-based policy

---

## ลำดับที่ถูกต้องแบบง่ายที่สุด

### STEP 1 — สร้าง Supabase Production Project

แนะนำใช้ project แยกจาก demo เพื่อไม่ให้ข้อมูลทดลองปนกับข้อมูลจริง

### STEP 2 — รัน schema

Supabase → SQL Editor → Run:

```txt
supabase/schema.sql
```

### STEP 3 — ไม่ต้องรัน seed ถ้าเป็นข้อมูลจริง

ถ้าจะเริ่มจริง ไม่ต้องรัน `seed.sql`

### STEP 4 — สร้าง Staff User

Supabase → Authentication → Users → Add user

สร้าง user เช่น:

- owner/admin
- doctor
- nurse
- reception
- cashier

### STEP 5 — Map user เป็น staff role

ใช้ SQL จากไฟล์:

```txt
supabase/create_staff_profiles_example.sql
```

### STEP 6 — รัน production RLS

รัน:

```txt
supabase/rls_production.sql
```

### STEP 7 — ตั้งค่า Vercel ENV

Vercel → Environment Variables:

```txt
SUPABASE_URL
SUPABASE_ANON_KEY
```

แล้ว Redeploy

### STEP 8 — ทดสอบ

เปิด:

```txt
/diagnose.html
```

ต้องเห็น:

- Config OK
- Supabase Connection OK
- Table Check OK

---

## สิ่งที่ยังต้องทำก่อนใช้จริงเต็มรูปแบบ

ตอนนี้ระบบมีฐานข้อมูลและ UI หลักแล้ว แต่ก่อนใช้จริง 100% ควรเพิ่ม:

### จำเป็นมาก

- หน้า Login
- Session check
- Logout
- จำกัดเมนูตาม role
- Audit log เมื่อเพิ่ม/แก้ข้อมูล
- Soft delete แทน hard delete
- Backup policy

### ทางการแพทย์ / คลินิก

- Consent form
- File upload สำหรับ OCT / Fundus / ใบยินยอม
- Prescription print
- Receipt print
- Patient timeline

### การเงิน

- Running invoice number แบบล็อกไม่ซ้ำ
- Void invoice พร้อมเหตุผล
- Payment reconciliation
- Export รายวัน

---

## คำแนะนำสั้น ๆ

ถ้าจะเริ่มใช้งานเร็ว:

1. ใช้ Supabase project แยกสำหรับ production
2. รัน `schema.sql`
3. สร้าง user staff
4. รัน SQL map staff role
5. รัน `rls_production.sql`
6. ใช้ Vercel deploy
7. ห้ามเอาข้อมูลจริงใส่จนกว่า login/RLS ผ่านแล้ว
