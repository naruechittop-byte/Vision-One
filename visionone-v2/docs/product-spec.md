# VisionOneV2 Product Specification

## Goal

Build a practical eye clinic operating system that supports daily clinical and business operations with a lean structure and low bug risk.

## Primary users

| User | Main jobs |
|---|---|
| Owner/Admin | See the full clinic picture, manage staff, monitor revenue and operations |
| Doctor | Review patient history, record eye exam, diagnose, prescribe, plan treatment |
| Nurse/Assistant | Screening, visual acuity, IOP, pre-consult notes, attachments |
| Front Desk | Register patients, appointments, check-in, queue, receipts |
| Pharmacist/Stock | Dispense medication, monitor stock and expiry |
| Finance | Invoice, payment, daily revenue report |

## Core flows

### New patient flow

```text
Create patient → Book appointment or walk-in → Check-in → Screening → Doctor → Prescription/procedure → Billing → Payment → Follow-up
```

### Returning patient flow

```text
Search patient → Review history → Create new visit → Pull prior diagnosis/medication context → Record today exam → Update plan → Billing/follow-up
```

### Owner flow

```text
Dashboard → Daily revenue → Patient volume → Service mix → Doctor performance → Follow-up leaks → Stock alerts
```

## MVP scope

### Must have

- Authentication
- Role-aware navigation
- Patient registry and patient profile
- Appointment and walk-in queue
- Visit creation
- Eye exam form
- Diagnosis list
- Prescription with medication master
- Invoice, invoice items, payment
- Basic dashboard and daily report

### Should have after MVP

- Stock movement automation from prescription dispensing
- PDF receipt, prescription, medical certificate, consent
- Follow-up CRM
- Procedure room workflow
- Advanced reports
- LINE OA reminders
- Patient portal

## Clinical data model principle

- `patients` is the identity and long-term profile.
- `visits` is one clinical encounter.
- `eye_exams` is one structured eye exam per visit.
- `visit_diagnoses` stores diagnoses per encounter.
- `prescriptions` and `prescription_items` store medications per visit.
- `invoices`, `invoice_items`, and `payments` store the financial transaction.

## Status flow

### Appointment

```text
scheduled → confirmed → checked_in → completed
                ↓
             cancelled / no_show
```

### Queue

```text
waiting → screening → waiting_doctor → in_consultation → pharmacy → payment → completed
```

### Visit

```text
open → screening → doctor_review → billing → completed
```

## UX principles

- Front desk should see today, queue, payment status, and next action.
- Nurse should see fast screening forms, not finance-heavy data.
- Doctor should see history, last visit, allergy, exam form, diagnosis, medication, and follow-up on one working screen.
- Owner should see high-level business health without clicking too much.

## Design direction

Minimal Medical Luxury:

- White / warm gray / silver / navy / soft gold accent
- Soft cards, clear hierarchy, clean typography
- Left navigation + top context bar + main workspace + right patient summary panel
- Thai-first labels with English clinical fields where useful
