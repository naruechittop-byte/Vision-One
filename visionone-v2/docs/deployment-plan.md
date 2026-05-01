# VisionOneV2 Deployment Plan

## Current status

- GitHub repo: `naruechittop-byte/Vision-One`
- Foundation branch: `visionone-v2-foundation`
- Supabase project: `VisionOneV2`
- Supabase ref: `cpubahnvluadzquavowx`
- Supabase region: `ap-southeast-1`

## Recommended target structure

Long-term, VisionOneV2 should either become:

1. A new clean repository named `VisionOneV2`, or
2. A clean app directory inside the current repo, for example `apps/visionone-v2`.

Because the current available GitHub connector can update existing repositories but does not expose a create-repository action, this foundation is placed in the existing repo on a separate branch first.

## Environment variables

Production / Preview Vercel variables:

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_APP_URL=
```

Do not expose `SUPABASE_SERVICE_ROLE_KEY` to client-side code.

## Vercel setup

Vercel connector currently shows no teams in `list_teams`, so project creation/import was not performed automatically from here.

Manual setup recommendation:

1. Create/import a new Vercel project from GitHub.
2. Use branch `visionone-v2-foundation` only for preview until the app shell is complete.
3. Add Supabase env vars.
4. Set framework preset to Next.js.
5. Deploy preview.
6. Test Supabase connectivity and auth.
7. Merge only after core flows are stable.

## Deployment environments

```text
Local development
  ↓
Vercel Preview
  ↓
Vercel Production
```

## Supabase environments

Current project is production candidate. For safer development, create a Supabase branch or separate dev project before large schema changes.

Recommended flow:

```text
Migration file in GitHub
  ↓
Apply to Supabase dev branch/project
  ↓
Test app
  ↓
Apply to production project
```

## First app shell milestone

1. Create Next.js app shell.
2. Add Supabase browser/server clients.
3. Add auth pages.
4. Add role-aware sidebar.
5. Add dashboard route.
6. Add patient list route.
7. Add appointment/queue route.
8. Add visit route.
9. Add billing route.
10. Add basic report route.

## Production readiness checklist

- [ ] No hardcoded Supabase secrets in frontend
- [ ] RLS enabled on all public tables
- [ ] Role policies tested
- [ ] First admin user seeded safely
- [ ] Storage buckets created
- [ ] PDF generation tested
- [ ] Error logging added
- [ ] Vercel preview tested
- [ ] Core workflow tested with demo patients
- [ ] Backup/export policy decided
