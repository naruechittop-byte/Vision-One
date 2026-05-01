-- Vision One seed data
-- Run after schema.sql

insert into doctors(display_name, license_no, specialty, email) values
('Dr. Vision', 'MD-0001', 'Comprehensive Ophthalmology', 'doctor.vision@example.com'),
('Dr. Retina', 'MD-0002', 'Retina / Glaucoma', 'doctor.retina@example.com'),
('Dr. Aesthetic', 'MD-0003', 'Aesthetic Eye Care', 'doctor.aesthetic@example.com')
on conflict do nothing;

insert into services(code, name, category, price, duration_minutes) values
('EYE-CHECK', 'Comprehensive Eye Check', 'clinic', 1500, 45),
('DRY-EYE', 'Dry Eye Consultation', 'clinic', 1200, 30),
('OCT', 'OCT Scan', 'diagnostic', 1800, 20),
('FUNDUS', 'Fundus Photo', 'diagnostic', 1200, 15),
('AESTH-CONSULT', 'Aesthetic Eye Consultation', 'aesthetic', 1000, 45),
('EYELID-NONINCISION', 'Non-incisional Eyelid Procedure', 'procedure', 35000, 120),
('IPL-DRYEYE', 'IPL Dry Eye Session', 'procedure', 3500, 45)
on conflict (code) do nothing;

insert into drugs(sku, name, generic_name, form, strength, unit, allergy_group, lot_no, expiry_date, stock_qty, reorder_level, unit_cost, selling_price) values
('DRG-ART-015', 'Artificial Tears 0.15%', 'Carboxymethylcellulose', 'eye drop', '0.15%', 'bottle', '-', 'A210', '2026-08-12', 40, 10, 120, 390),
('DRG-MOXI', 'Moxifloxacin Eye Drop', 'Moxifloxacin', 'eye drop', '0.5%', 'bottle', 'Quinolone', 'M884', '2027-01-09', 25, 8, 210, 520),
('DRG-TIMO', 'Timolol 0.5%', 'Timolol', 'eye drop', '0.5%', 'bottle', 'Beta blocker', 'T452', '2026-06-30', 18, 6, 90, 280),
('DRG-LUBE-GEL', 'Lubricating Eye Gel', 'Carbomer', 'gel', '0.2%', 'tube', '-', 'G119', '2026-12-01', 15, 5, 150, 450)
on conflict (sku) do nothing;

with p as (
  insert into patients(hn, first_name, last_name, nickname, phone, line_id, email, date_of_birth, gender, address, emergency_contact_name, emergency_contact_phone, insurance_provider, pdpa_consent, pdpa_consent_at, tags, note)
  values
  ('HN-00018', 'มณีรัตน์', 'รัตนชัย', 'เมย์', '089-xxx-2456', 'may_eye', 'may@example.com', '1984-02-12', 'female', 'Bangkok', 'คุณเอ', '081-111-1111', 'AIA', true, now(), array['Dry Eye','Aesthetic Interest'], 'ใช้คอมพิวเตอร์นาน'),
  ('HN-00021', 'อนันต์', 'วัฒนา', 'นัน', '081-xxx-1188', 'anan_eye', 'anan@example.com', '1968-09-02', 'male', 'Bangkok', null, null, 'Self-pay', true, now(), array['Glaucoma'], 'Glaucoma suspect'),
  ('HN-00034', 'ศิริพร', 'ธนา', 'แพร', '086-xxx-9088', 'prae_eye', 'prae@example.com', '1990-05-14', 'female', 'Bangkok', null, null, 'Self-pay', false, null, array['Aesthetic'], 'สนใจ eyelid')
  on conflict (hn) do nothing
  returning id, hn
)
select 1;

insert into patient_allergies(patient_id, allergen, reaction, severity)
select id, 'Penicillin', 'ผื่น', 'moderate' from patients where hn = 'HN-00018'
on conflict do nothing;

insert into patient_medical_history(patient_id, history_type, description)
select id, 'eye', 'Dry eye, mild MGD' from patients where hn = 'HN-00018'
on conflict do nothing;

insert into patient_medical_history(patient_id, history_type, description)
select id, 'family', 'Mother has glaucoma history' from patients where hn = 'HN-00021'
on conflict do nothing;

insert into appointments(patient_id, doctor_id, service_id, start_at, end_at, room, device, status, chief_complaint, reminder_sent_at, note)
select p.id, d.id, s.id, now() + interval '1 day' + interval '9 hour', now() + interval '1 day' + interval '9 hour 45 minutes', 'Exam 1', 'OCT', 'confirmed', 'ตาแห้ง แสบตา', now(), 'LINE reminder sent'
from patients p, doctors d, services s
where p.hn='HN-00018' and d.display_name='Dr. Vision' and s.code='EYE-CHECK'
on conflict do nothing;

insert into appointments(patient_id, doctor_id, service_id, start_at, end_at, room, device, status, chief_complaint, note)
select p.id, d.id, s.id, now() + interval '1 day' + interval '10 hour 30 minutes', now() + interval '1 day' + interval '11 hour 15 minutes', 'Consult', '-', 'pending', 'ปรึกษาความงามรอบดวงตา', 'Aesthetic consultation'
from patients p, doctors d, services s
where p.hn='HN-00034' and d.display_name='Dr. Aesthetic' and s.code='AESTH-CONSULT'
on conflict do nothing;

insert into visits(patient_id, doctor_id, visit_date, visit_type, chief_complaint, diagnosis, plan, clinical_note)
select p.id, d.id, current_date, 'consultation', 'ตาแห้ง ใช้คอมพิวเตอร์นาน', 'Dry Eye Syndrome OU, mild MGD', 'Artificial tears qid OU, warm compress, consider IPL Dry Eye course', '{"dryScore":"OSDI 28","tbutOD":"5 sec","tbutOS":"4 sec"}'::jsonb
from patients p, doctors d
where p.hn='HN-00018' and d.display_name='Dr. Vision'
on conflict do nothing;

insert into eye_exams(visit_id, eye, ucva, bcva, sph, cyl, axis, add_power, iop, pupil, eom, slit_lamp, lens, cup_disc_ratio, macula, rnfl, note)
select v.id, 'OD', '20/30', '20/25', '-1.00', '-0.50', '180', '+1.00', 15, 'Normal', 'Full', 'Mild MGD, clear cornea', 'Clear', '0.3', 'Normal', 92, 'Right eye'
from visits v join patients p on p.id = v.patient_id where p.hn='HN-00018'
on conflict do nothing;

insert into eye_exams(visit_id, eye, ucva, bcva, sph, cyl, axis, add_power, iop, pupil, eom, slit_lamp, lens, cup_disc_ratio, macula, rnfl, note)
select v.id, 'OS', '20/30', '20/25', '-1.25', '-0.50', '175', '+1.00', 16, 'Normal', 'Full', 'Mild MGD, tear film unstable', 'Clear', '0.3', 'Normal', 90, 'Left eye'
from visits v join patients p on p.id = v.patient_id where p.hn='HN-00018'
on conflict do nothing;

insert into patient_packages(patient_id, package_name, total_sessions, used_sessions, price, start_date, expiry_date, status, note)
select id, 'IPL Dry Eye 4 Sessions', 4, 1, 12000, current_date, current_date + interval '6 months', 'active', 'Demo package' from patients where hn='HN-00018'
on conflict do nothing;

insert into procedures(patient_id, doctor_id, procedure_name, scheduled_at, quote_amount, deposit_amount, status, precheck_done, consent_signed, note)
select p.id, d.id, 'Non-incisional Eyelid Procedure', now() + interval '7 days', 35000, 5000, 'scheduled', false, false, 'Aesthetic procedure demo'
from patients p, doctors d where p.hn='HN-00034' and d.display_name='Dr. Aesthetic'
on conflict do nothing;

insert into invoices(invoice_no, patient_id, status, subtotal, discount, tax, total, paid_amount, note)
select 'INV-2026-0001', id, 'paid', 4200, 0, 294, 4494, 4494, 'Consult + OCT + Rx' from patients where hn='HN-00018'
on conflict (invoice_no) do nothing;

insert into payments(invoice_id, patient_id, method, amount, reference_no, note)
select i.id, i.patient_id, 'qr', i.total, 'QR-DEMO-001', 'Demo paid invoice'
from invoices i where i.invoice_no='INV-2026-0001'
on conflict do nothing;
