# Vision One — ตั้งค่า Netlify ให้เชื่อม Supabase อัตโนมัติ

ไฟล์เว็บหลักตอนนี้ใช้ `app-netlify.html` และดึง Supabase config ผ่าน Netlify Function:

`/.netlify/functions/config`

ดังนั้นไม่ต้องกรอก URL/key ในหน้าเว็บอีก แต่ต้องตั้งค่า Environment Variables ใน Netlify แค่ครั้งเดียว

---

## ต้องตั้งค่าใน Netlify แค่ 2 ค่า

ไปที่:

Netlify → Site configuration → Environment variables → Add variable

เพิ่ม:

```txt
SUPABASE_URL
```

และ

```txt
SUPABASE_ANON_KEY
```

จากนั้นไปที่:

Deploys → Trigger deploy → Deploy site

---

## หลัง deploy เสร็จ

เปิด:

https://visionone-pat.netlify.app/

ระบบจะเปิดหน้า Clinic OS และอ่านค่า Supabase อัตโนมัติจาก Netlify

---

## จุดสำคัญเรื่องความปลอดภัย

- อย่า commit key ลง GitHub public
- อย่าใช้ข้อมูลคนไข้จริงตอนที่ Supabase ยังเป็น dev_all policy
- ก่อนใช้จริงต้องทำ Supabase Auth + RLS production
- ไฟล์ที่เตรียมไว้แล้วคือ `supabase/rls_production.sql`

---

## ถ้าเจอ Not connected

ให้เช็ก 3 อย่าง:

1. ตั้งชื่อ variable ตรงเป๊ะไหม
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
2. กด Redeploy หลังตั้งค่าแล้วหรือยัง
3. Supabase ได้รัน `schema.sql` และ `seed.sql` แล้วหรือยัง
