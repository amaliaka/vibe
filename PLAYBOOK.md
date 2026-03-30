# Vibe Coder SDLC Playbook
> Spec-first · AI-assisted · Gate-enforced · Solo-friendly

A reusable methodology for one-person (or small) teams shipping real products with AI.
Designed around OpenCode, but the prompt patterns work with any AI coding agent.

---

## How this works

You bring: the idea, the decisions, the approvals.
The AI brings: specs, code, tests, migrations, runbooks.
CI brings: the guardrails that keep you honest.

**Three rules:**
1. No code without a spec change first (OpenSpec)
2. No merge without CI green (GitHub Actions)
3. No production without human approval (you promote, never auto-deploy to prod)

---

## Phase 1 — Ideation

**You do this. AI helps structure it.**

Create `docs/vision.md` and fill in:

```markdown
## Problem
[1–2 sentences. What sucks right now?]

## Users
[Who specifically has this problem?]

## Non-goals
[What are you explicitly NOT building?]

## Success looks like
[How do you know it worked?]

## Constraints
[Budget, timeline, compliance, stack preferences]
```

Then paste the above into OpenCode and say:

> "Based on this vision doc, generate an OpenSpec baseline product spec
> using `openspec propose`, including clear scope and acceptance criteria."

**Output you should have:**
- `docs/vision.md` committed
- `openspec/specs/product.yaml` — baseline spec (validated by OpenSpec CLI)

---

## Phase 2 — Requirements

**AI generates, you approve.**

For each feature, prompt:

> "For feature [X], generate user stories with acceptance criteria in the format:
> As a [user], I want [goal] so that [reason].
> Acceptance criteria: [testable conditions].
> Also identify any NFRs: latency targets, SEO needs, data retention."

Review and edit. Then capture the approved scope in `openspec/changes/[feature].yaml`.

Also prompt:
> "Do any of these features need a public API? If so, draft an OpenAPI stub for those routes."

**Output you should have:**
- Approved user stories with acceptance criteria
- `openspec/changes/[feature].yaml` — one change proposal per feature (run `openspec propose`)
- Optional: `docs/api.yaml` OpenAPI stub

---

## Phase 3 — Architecture

**You decide. AI stress-tests your decision.**

Pick your project type and tell the AI:

### Fullstack web app (Nuxt/Next)
> "I'm building a fullstack app with Nuxt SSR on Vercel and Supabase for DB/Auth.
> Review my architecture and flag: trust boundary gaps, secrets leakage risks,
> SSR vs client rendering decisions, and any missing concerns in my vision doc."

### API / backend only
> "I'm building an API-only service. Review my OpenAPI stub and flag:
> auth model gaps, rate limiting needs, and deployment strategy risks."

### Landing page / marketing site
> "I'm building a static marketing site on Vercel. Flag: any dynamic features
> that need a backend, analytics privacy concerns, and performance requirements."

### Any project
Always prompt this before coding:
> "What are the trust boundaries in this project? Where do secrets flow?
> Which operations must be server-side only? Output as a short architecture decision record."

Save the output to `docs/architecture.md`.

**Output you should have:**
- `docs/architecture.md` with trust model
- Confirmed: which keys are server-only (Supabase service role, etc.)
- Confirmed: which routes are SSR vs static vs API

---

## Phase 4 — Implementation

**AI builds. You review PRs.**

Before any feature work, create an OpenSpec change proposal:
> "Create an OpenSpec change proposal for [feature] using `openspec propose`.
> Include: scope, acceptance criteria, DB/RLS impact, test plan (Playwright),
> and rollout/rollback notes."

Then start implementation:
> "Implement [feature] as described in openspec/changes/[feature].yaml. Follow AGENTS.md rules.
> Keep changes small — one PR per logical unit. Include a migration if schema changes.
> After merging, run `openspec archive` to close out the change."

**PR checklist (AI fills this in PR template):**
- [ ] OpenSpec change file referenced (`openspec/changes/`)
- [ ] Unit tests passing
- [ ] Playwright E2E smoke test written
- [ ] No secrets committed
- [ ] RLS policies updated if schema changed
- [ ] Semgrep clean (or findings triaged)

**Rules for AI during implementation (baked into AGENTS.md):**
- Never commit secrets or env vars
- Never expose service_role key in client code
- Always write a migration for schema changes
- Always write at least one Playwright test per new user journey
- Keep PRs under 400 lines of diff

---

## Phase 5 — Testing

**AI scaffolds. CI enforces.**

For each feature, prompt:
> "Write Playwright E2E tests for the [feature] user journey.
> Cover: happy path, auth-required paths, and one error/edge case.
> Use the existing test helpers in tests/e2e/helpers.ts."

For unit tests:
> "Write unit tests for [module/function]. Focus on pure logic, edge cases, and error handling."

For bug fixes, always:
> "Write a regression test that would have caught this bug, then fix it."

**Test file structure:**
```
tests/
  e2e/
    smoke.spec.ts       ← critical paths, always runs
    auth.spec.ts
    [feature].spec.ts
  unit/
    [module].test.ts
```

---

## Phase 6 — CI Gate

**Fully automated. No bypassing.**

The CI pipeline runs on every PR and push to main:

1. Lint + typecheck
2. Unit tests
3. Playwright E2E (against preview deployment)
4. Semgrep SAST scan → SARIF uploaded to GitHub Security tab
5. Trivy SBOM generation + vulnerability scan (fails on CRITICAL/HIGH)

**If CI fails:**
Paste the failure into OpenCode:
> "Analyze this CI failure. Propose minimal fixes without changing product behavior
> beyond the failing scope. Do not refactor unrelated code."

**Never merge a red PR.** The Vercel deployment gate is tied to GitHub check status —
a failed CI blocks production promotion automatically.

---

## Phase 7 — Deploy

**Preview is automatic. Prod is human-gated.**

Workflow:
1. Push branch → Vercel auto-deploys preview URL
2. Test the preview manually for the specific change
3. Merge PR → Vercel deploys to preview of main
4. CI gate confirms all checks green
5. You click "Promote to production" in Vercel (or it auto-promotes if all checks pass)
6. Verify production is healthy (check logs, test one critical path)

**Rollback:**
> Vercel dashboard → Deployments → previous deployment → "Instant Rollback"

For Supabase schema changes — keep migrations forward-compatible.
Write the rollback SQL in the migration file as a comment before merging.

---

## Phase 8 — Monitor + Maintain

**Mostly automated. You review weekly.**

**Daily (automatic):**
- Vercel runtime logs (3-day retention — set up a Drain if you need more)
- Vercel Observability dashboard for error rate spikes

**Weekly (you do this):**
- Run: `pnpm audit` and check Dependabot alerts
- Check GitHub Security tab for new Semgrep findings
- Review any failed nightly CI runs

**Monthly:**
- Schema review: are migrations clean? Any orphaned columns?
- RLS policy review: does every table have policies enabled?

**Quarterly:**
- Rollback drill: deliberately promote a bad deploy, then roll back. Time it.
- Dependency major version review

**AI prompts for maintenance:**
> "Review the current SBOM and list any dependencies with known CVEs or that are more than 2 major versions behind."

> "Generate a runbook for [incident type] based on the current architecture and Vercel/Supabase setup."

---

## OpenCode prompt library

### Spec drafting
```
Create an OpenSpec change proposal for [feature] using `openspec propose`.
Include: scope, acceptance criteria, DB/RLS impact,
test plan (Playwright), and rollout/rollback notes.
Save to openspec/changes/[feature].yaml.
```

### Architecture review
```
Review this architecture for trust boundary gaps,
secrets leakage risks, and missing security concerns.
Output as an architecture decision record.
```

### CI triage
```
Analyze this CI failure log. Propose minimal fixes without
changing product behavior beyond the failing scope.
Do not refactor unrelated code.
```

### RLS policy generation
```
Generate Supabase RLS policies for the [table] table.
Rules: public can read [columns], authenticated users can
insert/update their own rows only (auth.uid() = user_id).
```

### Migration scaffolding
```
Generate a Supabase migration for [schema change].
Include: CREATE TABLE/ALTER TABLE, enable RLS, initial policies,
and a rollback comment showing the reverse SQL.
```

### Runbook generation
```
Generate an operations runbook for [scenario].
Include: detection signals, immediate steps, rollback procedure,
and post-incident review checklist.
```

### Playwright test scaffolding
```
Write Playwright E2E tests for the [feature] user journey.
Cover: happy path, auth-required paths, one error/edge case.
Use test helpers in tests/e2e/helpers.ts.
```

---

## Optional MCP usage by phase

| Phase | MCP server | What it does |
|---|---|---|
| Implementation | Supabase MCP | Check schema, query RLS status |
| Maintain | Supabase MCP | Check RLS policy status per table |

**OpenSpec CLI commands used across phases:**

| Command | When |
|---|---|
| `openspec init` | Once, when setting up the repo |
| `openspec propose` | Before every feature — creates a change file |
| `openspec validate` | In CI — fails if specs are malformed |
| `openspec archive` | After merging — closes out the change as a record |

---

## Project type quick-start

### Fullstack (Nuxt + Vercel + Supabase)
```
Stack confirmed. Start with:
1. nuxt init → connect to Vercel
2. supabase init → link project
3. Copy AGENTS.md, ci.yml, PR template from this playbook
4. Create first spec: openspec propose "initial auth flow"
```

### API only
```
Stack: Node/Hono/Express + Vercel Functions or Railway + Supabase
Same SDLC, same CI. Swap Playwright for supertest for API-level tests.
OpenAPI contract is your source of truth instead of pages/routes.
```

### Landing page / marketing
```
Stack: Nuxt static or Astro + Vercel
Simplify CI: skip Supabase steps. Keep Semgrep + Playwright smoke.
One Playwright test: page loads, CTA button is visible, no console errors.
```
