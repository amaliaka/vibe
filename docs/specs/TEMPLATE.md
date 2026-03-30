# Spec: [Feature name]

> Status: draft | approved | implemented
> Issue: #
> Date: YYYY-MM-DD

---

## Problem

<!-- What user problem does this solve? 1–2 sentences. -->

## Scope

<!-- What's included. Be explicit about what's NOT included too. -->

**In scope:**
-

**Out of scope:**
-

## Acceptance criteria

<!-- Testable conditions. Each one should map to a Playwright test. -->

- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]

## DB / RLS impact

<!-- Any schema changes? New tables, columns, policies? -->

- [ ] No schema changes
- [ ] New table: `table_name`
- [ ] New columns: `table.column`
- [ ] RLS policies updated

## Test plan

<!-- Which tests cover this feature? -->

- Playwright E2E: `tests/e2e/[feature].spec.ts`
- Unit tests: `tests/unit/[module].test.ts`

## Rollout / rollback notes

<!-- Any risk? How do you undo this if it breaks? -->

- Rollback: revert PR + run rollback SQL in Supabase dashboard
- Risk level: low / medium / high
