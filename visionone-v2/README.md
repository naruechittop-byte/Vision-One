# VisionOneV2

VisionOneV2 is the new foundation for a lean eye clinic operating system. It is intentionally separated from the current Vision-One app so the clinic can move forward without breaking the existing version.

## Product direction

VisionOneV2 is designed around the full clinic flow:

```text
Patient registration
→ Appointment / walk-in queue
→ Screening
→ Doctor visit
→ Eye exam
→ Diagnosis
→ Prescription / procedure
→ Billing / payment
→ Follow-up / CRM
→ Owner reports
```

## Stack

- Frontend: Next.js + TypeScript + Tailwind + shadcn/ui
- Backend: Supabase PostgreSQL + Auth + Storage + RLS
- Hosting: Vercel
- Source control: GitHub

## Supabase

New Supabase project created:

- Project name: VisionOneV2
- Project id/ref: `cpubahnvluadzquavowx`
- Region: `ap-southeast-1`
- Status at creation: `ACTIVE_HEALTHY`

## Git workflow

Current foundation branch:

```text
visionone-v2-foundation
```

Do not merge into `main` until the app shell has been tested against the new Supabase project.

## MVP modules

1. Login and role-based app shell
2. Patient registry
3. Appointment calendar
4. Today queue
5. Visit / encounter
6. Eye exam form
7. Diagnosis
8. Prescription
9. Billing and payment
10. Basic reports
11. Inventory foundation
12. Follow-up / CRM foundation

## Design principle

Keep the system lean, clinical, and reliable:

- One patient can have many visits.
- One visit can have eye exam, diagnoses, prescriptions, procedures, invoice, documents, and follow-ups.
- Clinical data and financial data are connected but not mixed.
- Every important action should be auditable.
- UI must be simple enough for front desk and nurses, but fast enough for doctors.
