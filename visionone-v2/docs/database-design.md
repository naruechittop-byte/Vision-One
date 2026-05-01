# VisionOneV2 Database Design

Supabase project:

```text
Project: VisionOneV2
Project ref: cpubahnvluadzquavowx
Region: ap-southeast-1
```

## Foundation tables created

### Tenancy and staff

- `clinics`
- `profiles`

### Patient and operations

- `patients`
- `appointments`
- `queue_items`
- `visits`

### Clinical records

- `eye_exams`
- `diagnosis_master`
- `visit_diagnoses`
- `procedure_master`
- `visit_procedures`

### Medication and pharmacy

- `medications`
- `prescriptions`
- `prescription_items`

### Billing

- `invoices`
- `invoice_items`
- `payments`

### Stock

- `inventory_items`
- `stock_movements`

### Documents, CRM, audit

- `documents`
- `follow_ups`
- `activity_logs`

## Key relational principles

```text
clinics
  ├── profiles
  ├── patients
  │     ├── appointments
  │     ├── queue_items
  │     ├── visits
  │     │     ├── eye_exams
  │     │     ├── visit_diagnoses
  │     │     ├── prescriptions
  │     │     │     └── prescription_items
  │     │     ├── visit_procedures
  │     │     ├── invoices
  │     │     │     ├── invoice_items
  │     │     │     └── payments
  │     │     ├── documents
  │     │     └── follow_ups
  │     └── documents
  └── inventory_items
        └── stock_movements
```

## Important enums

- `user_role`: owner, admin, doctor, nurse, front_desk, pharmacist, finance
- `appointment_status`: scheduled, confirmed, checked_in, cancelled, no_show, completed
- `queue_status`: waiting, screening, waiting_doctor, in_consultation, pharmacy, payment, completed, cancelled
- `visit_status`: open, screening, doctor_review, billing, completed, cancelled
- `eye_side`: OD, OS, OU, NA
- `invoice_status`: draft, issued, partially_paid, paid, void
- `payment_method`: cash, bank_transfer, qr, credit_card, debit_card, other
- `stock_movement_type`: receive, dispense, adjust, return, expire, transfer

## RLS baseline

All public tables have RLS enabled.

Current MVP policy style:

- Authenticated users can access rows within their own `clinic_id`.
- `profiles` allows the user to see their own profile and clinic profiles.
- Fine-grained role policies should be tightened after first real staff users exist.

## Next database tasks

1. Add seed data for clinic, service items, medication master, and procedure master.
2. Add HN and invoice number generation functions.
3. Tighten RLS by role:
   - Doctor: clinical data
   - Front desk: appointments, queue, patient demographic, payment collection
   - Finance: invoices, payments, reports
   - Pharmacist: prescriptions and stock
4. Add storage buckets:
   - `patient-files`
   - `eye-images`
   - `consent-forms`
   - `receipts`
   - `medical-certificates`
   - `clinic-assets`
5. Add audit log triggers for sensitive updates.
6. Add reporting views for dashboard:
   - daily revenue
   - patient count
   - new vs returning patient
   - queue status summary
   - follow-up pending
   - low stock / expiring stock

## Known design choices

- `diagnosis_master` supports global rows with `clinic_id = null` and clinic-specific rows with a clinic id.
- `eye_exams` currently enforces one structured exam per visit via `unique(visit_id)`.
- `invoices` and `payments` are separate so partial payment can be supported later.
- Clinical and financial data are connected by `visit_id` but stored separately.
