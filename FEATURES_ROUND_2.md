# Vision One Clinic OS — Round 2 Features

This round expands Vision One from a basic clinic dashboard into a fuller operating system.

## Database features already applied in Supabase

A migration named `add_growth_operations_features` was applied successfully to the active Supabase project.

New modules:

1. CRM Follow-up
   - Table: `crm_followups`
   - Purpose: recall reminders, post-op follow-ups, medication reminders, review requests, birthday messages, campaign tasks.

2. Clinical Files
   - Table: `clinical_files`
   - Purpose: store metadata for OCT, fundus photos, visual field reports, consent forms, medical reports, prescriptions, receipts, medical certificates, and other patient files.

3. Document Requests
   - Table: `document_requests`
   - Purpose: track appointment slips, receipts, prescription labels, medical certificates, consent forms, visit summaries, and insurance claim documents.

4. Inventory
   - Tables: `inventory_items`, `inventory_movements`
   - Purpose: track clinical supplies, equipment consumables, stock movements, reorder levels, costs, suppliers, expiry dates, receive/use/adjust/return/waste/transfer actions.

5. Marketing Campaigns
   - Tables: `marketing_campaigns`, `campaign_members`
   - Purpose: run recall, promotion, education, birthday, and review campaigns; track patient status and conversion revenue.

## UI plan

The next UI update should expose these modules in Vercel as separate pages or tabs:

- `/app-vercel.html` remains the core Clinic OS dashboard.
- Add Growth Ops navigation for CRM, Files, Documents, Inventory, and Campaigns.
- Keep each module small and isolated to reduce deployment risk.

## Suggested next files

- `growth-crm.html`
- `growth-files.html`
- `growth-documents.html`
- `growth-inventory.html`
- `growth-campaigns.html`

Each page should use the existing `/api/visionone-config` endpoint to connect to Supabase.

## Security notes

- Do not place service role secrets in the browser.
- Use only browser-safe Supabase public configuration from Vercel environment variables.
- Before using real patient data, add authentication and role-based access.
- Current RLS should be tightened by role after staff login is implemented.

## Recommended next product build order

1. CRM Follow-up page
2. Clinical Files page
3. Document Request page
4. Inventory page
5. Campaign page
6. Auth and role-based permissions
7. PDF generation for documents
8. Storage upload integration for clinical files
