# Vision One — คู่มือติดตั้งแบบง่ายที่สุด

เอกสารนี้ทำมาเพื่อคนที่ยังไม่คุ้นกับ GitHub / Supabase โดยเป้าหมายคือให้ระบบ Vision One ใช้งานได้แบบง่ายที่สุดก่อน แล้วค่อยยกระดับเป็นระบบจริงที่ปลอดภัยขึ้น

---

## ตอนนี้ใน GitHub มีอะไรแล้ว

ไฟล์หลักในโปรเจกต์:

| ไฟล์ | ใช้ทำอะไร |
|---|---|
| `landing.html` | หน้าเว็บแบรนด์ Vision One / หน้าแรกสวย ๆ |
| `index.html` | ระบบ EMR demo เดิม ใช้ localStorage ยังไม่ต่อฐานข้อมูลจริง |
| `app-supabase.html` | ระบบ Clinic OS ที่ออกแบบมาให้ต่อ Supabase |
| `supabase/schema.sql` | สร้างฐานข้อมูลทั้งหมดใน Supabase |
| `supabase/seed.sql` | ใส่ข้อมูลตัวอย่าง เช่น คนไข้ หมอ ยา ใบเสร็จ |
| `supabase/rls_production.sql` | ตั้งสิทธิ์ระบบจริงแบบ role-based ก่อนใช้ข้อมูลคนไข้จริง |

---

# ภาพรวมแบบเข้าใจง่าย

GitHub = ที่เก็บไฟล์เว็บ / โค้ด

Supabase = ฐานข้อมูลหลังบ้าน เช่น คนไข้ ยา นัดหมาย การเงิน

เว็บ Vision One จะทำงานแบบนี้:

`app-supabase.html` → เชื่อม Supabase → อ่าน/เขียนข้อมูลจากตารางจริง

---

# ขั้นตอนทำให้ใช้งานได้เร็วที่สุด

## STEP 1 — เข้า Supabase Project

1. เข้า https://supabase.com
2. เลือก Project ของ Vision One
3. ไปที่เมนูซ้าย **SQL Editor**

---

## STEP 2 — สร้างฐานข้อมูล

1. ใน GitHub เปิดไฟล์ `supabase/schema.sql`
2. Copy ทั้งหมด
3. กลับไป Supabase → SQL Editor
4. กด New query
5. วาง SQL ทั้งหมด
6. กด Run

ถ้าสำเร็จ จะมีตาราง เช่น:

- `patients`
- `doctors`
- `appointments`
- `visits`
- `drugs`
- `invoices`
- `payments`
- `patient_packages`

---

## STEP 3 — ใส่ข้อมูลตัวอย่าง

1. ใน GitHub เปิดไฟล์ `supabase/seed.sql`
2. Copy ทั้งหมด
3. ไป Supabase → SQL Editor
4. New query
5. วาง SQL
6. กด Run

หลังจากนี้ database จะมีข้อมูล demo เช่น:

- คนไข้ตัวอย่าง
- หมอ
- บริการ
- ยา
- appointment
- invoice / payment

---

## STEP 4 — ทดสอบว่า database มีข้อมูลจริง

ใน Supabase ไปที่เมนู **Table Editor** แล้วลองเปิดตาราง:

- `patients`
- `drugs`
- `invoices`
- `payments`

ถ้าเห็นข้อมูล แปลว่าฐานข้อมูลพร้อมแล้ว

---

# STEP 5 — การใส่ Supabase URL / Key

ตอนนี้ไฟล์ `app-supabase.html` ยังไม่ได้ฝัง key จริงลง GitHub เพราะ repo เป็น public และอันตรายมากถ้าเอา key ไปเผยแพร่

วิธีง่ายสุดสำหรับทดสอบส่วนตัว:

1. Download ไฟล์ `app-supabase.html` จาก GitHub ลงเครื่อง
2. เปิดไฟล์ด้วยโปรแกรมแก้โค้ด เช่น VS Code / TextEdit
3. หา 2 บรรทัดนี้:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

4. แทนค่าด้วย URL และ anon key ของพี่
5. Save
6. เปิดไฟล์ `app-supabase.html` ใน browser

ถ้าเชื่อมต่อสำเร็จ จะเห็น Dashboard ดึงข้อมูลจาก Supabase

---

# ทำไมไม่ควร commit key ลง GitHub

เพราะ GitHub repo นี้เป็น public

ถ้าใส่ anon key ลงไฟล์ใน public repo และตอนนี้ policy ยังเป็น dev mode คนอื่นที่เห็น key อาจเข้าถึงข้อมูลได้

ดังนั้นช่วงทดลองให้ใส่ key ในไฟล์บนเครื่องตัวเองก่อน หรือให้ deploy ผ่าน Vercel/Netlify โดยใช้ Environment Variables

---

# ขั้นตอนก่อนใช้ข้อมูลคนไข้จริง

ก่อนใช้ข้อมูลจริง ต้องทำ 3 อย่างนี้:

## 1. เปิด Supabase Auth

ให้ staff login ด้วย email/password หรือ magic link

## 2. สร้าง staff role

เช่น:

- admin
- doctor
- nurse
- reception
- pharmacy
- cashier
- viewer

## 3. รัน `supabase/rls_production.sql`

ไฟล์นี้จะเปลี่ยนจากโหมดทดลองเป็นระบบสิทธิ์จริง

สำคัญ: อย่ารัน production RLS ก่อนมี user/staff role ไม่งั้นอาจอ่าน/เขียนข้อมูลไม่ได้จนต้องแก้ policy

---

# Flow การใช้งานระบบที่แนะนำ

## Reception

1. เพิ่มคนไข้ใหม่ใน Patients
2. สร้าง Appointment
3. Check-in คนไข้
4. ส่งเข้าคิว Pre-test / Doctor

## Nurse

1. เปิด Visit
2. บันทึกค่าสายตา / IOP / note เบื้องต้น
3. ส่งต่อแพทย์

## Doctor

1. เปิด Visit / EMR
2. บันทึก diagnosis
3. บันทึก plan
4. สั่งยา / สั่ง procedure / นัด follow-up

## Pharmacy

1. ดู Prescription
2. จ่ายยา
3. ระบบตัด stock

## Cashier

1. เปิด Invoice
2. รับชำระเงิน
3. บันทึก Payment

---

# สิ่งที่ควรทำต่อจากนี้

ลำดับที่แนะนำ:

1. รัน `schema.sql`
2. รัน `seed.sql`
3. ทดสอบ `app-supabase.html` ในเครื่อง
4. ถ้าใช้งานได้ ค่อยทำ login
5. เปิด role-based security
6. Deploy ผ่าน Vercel หรือ Netlify
7. ใช้งานจริงเฉพาะหลังเปิด security แล้ว

---

# Feature ที่ควรเพิ่มในรอบถัดไป

## จำเป็นมาก

- Login staff
- Role permission จริง
- ป้องกัน delete ข้อมูลสำคัญ
- Audit log ทุก action
- Backup database
- Upload file / รูปตา / OCT / consent form

## ควรมี

- LINE OA reminder
- Print invoice / receipt
- Print prescription
- Patient timeline
- Dashboard รายได้ / จำนวนเคส / ยาคงเหลือ

## ภายหลัง

- Online booking
- Consent e-signature
- Package/course usage
- Insurance claim support
- Multi-branch support

---

# สรุปสั้น ๆ

ถ้าจะให้ระบบเริ่มทำงานเร็วที่สุด:

1. รัน `supabase/schema.sql`
2. รัน `supabase/seed.sql`
3. ใส่ URL/anon key ในไฟล์ `app-supabase.html` เฉพาะบนเครื่องตัวเอง
4. เปิดไฟล์ใน browser แล้วทดสอบ

ถ้าจะใช้จริงกับข้อมูลคนไข้:

1. ต้องทำ login
2. ต้องทำ role permission
3. ต้องรัน `supabase/rls_production.sql`
4. ห้ามเปิด public key + dev policy กับข้อมูลจริง
