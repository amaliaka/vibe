# Architecture

## Project type

<!-- Fullstack / API only / Landing page -->

## Stack

| Layer | Tool | Notes |
|---|---|---|
| Frontend | | |
| Backend | | |
| Database | Supabase | |
| Auth | Supabase Auth | |
| Deploy | Vercel | |
| CI | GitHub Actions | |

## Trust boundaries

<!-- Where does trust change? What crosses the boundary? -->

```
Public internet
  → Vercel edge (anon key only, RLS enforces access)
  → Supabase (server routes use service_role, never in browser)
  → Postgres (RLS as defense in depth)
```

## Secrets inventory

| Secret | Where it lives | Who can access |
|---|---|---|
| `SUPABASE_URL` | Vercel env | Server + client (safe, public) |
| `SUPABASE_ANON_KEY` | Vercel env | Server + client (safe with RLS) |
| `SUPABASE_SERVICE_ROLE_KEY` | Vercel env (server only) | Server routes ONLY |

**Rule: service_role key never reaches the browser. Ever.**

## Architecture decisions

### ADR-001: [Title]
- **Date:** YYYY-MM-DD
- **Status:** accepted
- **Decision:** [What was decided]
- **Reason:** [Why]
- **Tradeoffs:** [What you gave up]

## Data model overview

<!-- Brief description of main entities. Full schema in migrations. -->

## Rendering strategy (fullstack only)

| Route | Strategy | Reason |
|---|---|---|
| `/` | SSR | SEO |
| `/dashboard` | CSR | Auth-gated, no SEO need |
| `/api/*` | Server route | Privileged operations |
