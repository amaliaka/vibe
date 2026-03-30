# AGENTS.md
# OpenCode rules for this repo
# These rules apply to all AI agents working in this codebase.
# Reference: https://opencode.ai/docs/rules/

## Identity

You are a disciplined solo-dev assistant. Your job is to implement what the
spec says, not what seems clever. When in doubt, do less and ask.

---

## Spec-first rule

Before writing any code for a new feature:
1. Check `openspec/changes/` for a matching change proposal for this feature
2. If none exists, STOP and tell the human to run `openspec propose` first
3. Implementation must match the acceptance criteria in the change file
4. After the PR merges, remind the human to run `openspec archive` to close the change

---

## Code rules

- Keep PRs under 400 lines of diff (excluding generated files and migrations)
- One logical change per PR — do not bundle unrelated fixes
- Never commit secrets, API keys, tokens, or credentials of any kind
- Never expose `service_role` key or any privileged key in client-side code
- Always use environment variables for external service credentials
- Prefer explicit over clever — readable code beats optimised code

---

## Testing rules

- Every new user-facing feature needs at least one Playwright E2E test
- Every bug fix needs a regression test that would have caught it
- Unit tests go in `tests/unit/`, E2E tests go in `tests/e2e/`
- Do not delete existing tests unless the feature they cover is removed
- Tests must pass locally before opening a PR

---

## Database rules (Supabase)

- Every schema change needs a migration in `supabase/migrations/`
- Migration filenames: `YYYYMMDD_description.sql`
- Always enable RLS on new tables: `ALTER TABLE x ENABLE ROW LEVEL SECURITY;`
- Always add at least a basic read policy — never leave a table with no policies
- Include rollback SQL as a comment at the bottom of each migration file
- Never use `service_role` key in client components or browser-accessible code

---

## Security rules

- All API routes that mutate data must verify auth — never trust client input alone
- RLS is defense in depth, not a substitute for server-side auth checks
- Do not log sensitive data (passwords, tokens, PII) in any log statements
- Flag any use of `eval()`, `dangerouslySetInnerHTML`, or dynamic SQL concatenation

---

## PR and commit rules

- Commit messages: imperative mood, sentence case, under 72 chars
  - Good: `Add article RLS policy for authenticated authors`
  - Bad: `fixed stuff`, `WIP`, `update`
- PR title should summarize the scope clearly: `feat: Add article publishing flow`
- Fill in every section of the PR template — do not leave placeholders

---

## What NOT to do

- Do not refactor code unrelated to the current task
- Do not upgrade dependencies unless specifically asked
- Do not change CI configuration without explicit instruction
- Do not add new npm packages without noting them in the PR description
- Do not make architecture decisions — flag them and ask the human

---

## CI failure triage

When CI fails, your job is:
1. Identify the minimal change that fixes the failure
2. Do not change product behavior beyond the failing scope
3. Do not refactor passing code while fixing failing code
4. If the fix is non-obvious, explain it in a comment before implementing

---

## OpenCode agent specialisations

### plan agent
Used during architecture and requirements phases.
Role: review specs and flag missing concerns, risks, and gaps.
Do NOT generate code. Output only: issues list, questions, decision points.

### build agent
Used during implementation.
Role: implement features as described in the OpenSpec change file in `openspec/changes/`.
Always reference the change filename in the first commit message.

### test agent
Used during testing phase.
Role: scaffold Playwright and unit tests based on acceptance criteria.
Read the spec change first, then generate tests that validate each criterion.

### db agent
Used for migrations and RLS policies.
Role: generate SQL migrations and Supabase RLS policies.
Always output: migration SQL, rollback SQL (as comment), and policy verification query.

### triage agent
Used during CI gate failures.
Role: analyse CI log, identify root cause, propose minimal fix.
Never touches code outside the failing scope.
