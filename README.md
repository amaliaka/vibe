# Vibe Coder SDLC Template

> Spec-first · AI-assisted · Gate-enforced · Solo-friendly

A reusable project template and methodology for solo builders shipping real
products with AI (OpenCode or any coding agent).

---

## What's in here

```
.
├── AGENTS.md                        ← AI agent rules (OpenCode reads this)
├── PLAYBOOK.md                      ← Full phase-by-phase methodology
├── docs/
│   ├── SETUP.md                     ← Start here — connect all services
│   ├── vision.md                    ← Fill this in second
│   ├── architecture.md              ← Fill after choosing stack
│   └── operations.md                ← Runbooks and procedures
├── openspec/
│   ├── config.yaml                  ← OpenSpec config
│   ├── specs/                       ← Product-level specs (validated by CLI)
│   └── changes/                     ← Per-feature change proposals
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug.yml
│   │   └── feature.yml
│   ├── pull_request_template.md
│   └── workflows/
│       └── ci.yml                   ← Lint → E2E → Semgrep → SBOM → OpenSpec validate
└── supabase/
    └── migrations/
        └── YYYYMMDD_example_table.sql  ← Migration template with RLS
```

---

## Quick start

### Prerequisites

```
Node.js 20+   node --version
pnpm          npm install -g pnpm
Git           git --version
OpenCode      npm install -g opencode
OpenSpec      npm install -g openspec
```

That's it. Everything else (Semgrep, Trivy, Playwright) runs automatically in CI.

---

### 1. Use this as a template

Clone or fork this repo, then rename it to your project.

```bash
git clone https://github.com/your-username/vibe-sdlc-template my-project
cd my-project
git remote set-url origin https://github.com/your-username/my-project
```

> **First time?** Read `docs/SETUP.md` — it walks you through connecting
> GitHub, Supabase, Vercel, OpenCode, OpenSpec, and MCP step by step.

### 2. Initialize OpenSpec

```bash
openspec init
```

This creates `openspec/config.yaml` and the `specs/` and `changes/` folders.

### 3. Fill in vision.md

Edit `docs/vision.md` with your problem, users, and non-goals.
Then paste it into OpenCode and say:

> "Based on this vision doc, generate an OpenSpec baseline product spec
> using `openspec propose` and break it into an epic with 3–5 milestone issues for GitHub."

### 4. Set up Supabase (cloud dashboard)

1. Create a project at [supabase.com](https://supabase.com)
2. Go to Project settings → API to grab your keys
3. For migrations: OpenCode writes the `.sql` files in `supabase/migrations/`
   — you paste and run them in the Supabase dashboard SQL editor

### 5. Connect to Vercel

1. Push your repo to GitHub
2. Go to [vercel.com](https://vercel.com) → New Project → Import your repo
3. Vercel auto-detects the framework and sets up preview + prod deployments

### 6. Set Vercel environment variables

In Vercel → Project settings → Environment variables:

| Variable | Environment |
|---|---|
| `SUPABASE_URL` | All |
| `SUPABASE_ANON_KEY` | All |
| `SUPABASE_SERVICE_ROLE_KEY` | Production + Preview (server-only) |

### 7. Start building

Follow the phases in PLAYBOOK.md.
The AI handles: spec drafts, code, tests, migrations, runbooks.
You handle: approvals, architecture decisions, production promotion.

---

## The three rules

1. **No code without a spec** — Create a markdown spec in `docs/specs/` before implementing
2. **No merge with red CI** — All checks must pass (lint, E2E, Semgrep, SBOM)
3. **No auto-deploy to prod** — You manually promote. Always.

---

## Project types supported

- **Fullstack** — Nuxt/Next SSR + Vercel + Supabase
- **API only** — Node/Hono + Vercel Functions or Railway + Supabase
- **Landing page** — Nuxt static or Astro + Vercel (simplified CI)

See PLAYBOOK.md → "Project type quick-start" for stack-specific guidance.

---

## Tools used

| Tool | Role | License |
|---|---|---|
| OpenCode | AI coding agent | MIT |
| OpenSpec | Spec validation + versioning | MIT |
| GitHub + Actions | Repo, CI, issues | — |
| Vercel | Deploy + preview | Managed |
| Supabase | DB, Auth, APIs | Apache-2.0 |
| Playwright | E2E testing | Apache-2.0 |
| Semgrep CE | SAST security | LGPL 2.1 |
| Trivy | SBOM + vuln scan | Apache-2.0 |
