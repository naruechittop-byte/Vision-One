# Vision One — Vercel + Supabase deployment notes

## Current repository

Repository: `naruechittop-byte/Vision-One`

The current app is a static HTML clinic operating dashboard. The existing `index.html` redirects to `app-netlify.html`, and that file currently expects a Netlify-style config endpoint.

## Recommended Vercel setup

1. Import the GitHub repository into Vercel.
2. Set the build settings as a static project:
   - Framework preset: Other
   - Build command: leave empty
   - Output directory: leave empty / root
3. Add Supabase public environment values in Vercel project settings.
4. Redeploy after saving the variables.

## Database already available

Supabase project is active and has the main Clinic OS tables:

- patients
- doctors
- services
- appointments
- queue_items
- visits
- eye_exams
- drugs
- prescriptions
- drug_stock_movements
- invoices
- invoice_items
- payments
- patient_packages
- procedures
- audit_logs
- staff_profiles

## Next development priorities

1. Make the web app Vercel-compatible instead of Netlify-only.
2. Expand the UI to use existing tables that are not yet visible in the app:
   - Queue monitor
   - Eye examination form
   - Prescription flow
   - Procedure / surgery pipeline
   - Package tracking
   - Audit log viewer
3. Add authentication and role-based screens before using real patient data.
4. Add PDF outputs for appointment slip, receipt, prescription label, and medical certificate.
