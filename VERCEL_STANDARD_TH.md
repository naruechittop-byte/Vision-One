# มาตรฐานโปรเจกต์เว็บ + Database ของพี่ Top

หลังจากนี้สำหรับงานแนวเว็บ, dashboard, internal system, ระบบหลังบ้าน, ระบบที่ต้องมี database ให้ใช้ stack นี้เป็นหลัก:

## Standard Stack

- **GitHub** = เก็บโค้ดและ version control
- **Vercel** = deploy เว็บอัตโนมัติ
- **Supabase** = database / auth / storage

---

## ทำไมใช้ Vercel

- ใช้ง่ายกว่า Netlify สำหรับงาน prototype + database
- ต่อ GitHub แล้ว auto deploy ได้ทันที
- ตั้ง Environment Variables ง่าย
- มี API route ได้ เช่น `api/config.js`
- เหมาะกับระบบ dashboard / internal tool

---

## Environment Variables ที่ต้องมีใน Vercel

ใน Vercel → Project Settings → Environment Variables ให้ใส่:

```txt
SUPABASE_URL
```

```txt
SUPABASE_ANON_KEY
```

จากนั้นกด Redeploy

---

## ไฟล์สำคัญในโปรเจกต์นี้

| ไฟล์ | หน้าที่ |
|---|---|
| `api/config.js` | ให้หน้าเว็บอ่าน Supabase config จาก Vercel ENV |
| `app-netlify.html` | Clinic OS เวอร์ชัน Netlify เดิม |
| `app-easy.html` | เวอร์ชันทดสอบที่จำ key ใน browser |
| `supabase/schema.sql` | สร้าง database schema |
| `supabase/seed.sql` | ใส่ข้อมูลตัวอย่าง |
| `supabase/rls_production.sql` | policy สำหรับระบบจริง |

---

## หลักการความปลอดภัย

- ห้าม commit API key หรือ secret ลง GitHub public
- ใช้ Environment Variables ของ Vercel แทน
- ก่อนใช้ข้อมูลจริง ต้องเปิด Supabase Auth + RLS production
- คนไข้จริงต้องมี role permission เช่น admin, doctor, nurse, reception, pharmacy, cashier

---

## Process มาตรฐานหลังจากนี้

1. สร้าง/แก้โค้ดใน GitHub
2. Vercel auto deploy
3. Supabase เก็บข้อมูลจริง
4. ถ้าเพิ่ม field/table ให้แก้ SQL migration ใน `supabase/`
5. ทดสอบผ่านหน้า diagnostic ก่อนใช้งานจริง

---

## Prompt ภายในที่ควรยึดสำหรับโปรเจกต์ใหม่

ถ้าเป็นงานเว็บ + database ให้เริ่มด้วย:

- Static frontend หรือ React/Vite ถ้าระบบใหญ่ขึ้น
- Supabase schema แยกเป็น SQL
- Vercel API route สำหรับ config
- Environment Variables ไม่ฝังใน frontend
- มี diagnostic page เสมอ
- มี seed data สำหรับ demo
- มี RLS production file แยกจาก dev policy
