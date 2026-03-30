# Operations runbook

## Environments

| Environment | URL | Branch | Auto-deploy |
|---|---|---|---|
| Preview | Vercel preview URL | feature branches | Yes |
| Staging (main) | Vercel main preview | main | Yes |
| Production | your-domain.com | main (promoted) | No — manual |

## Deploy procedure

1. Merge PR to main → Vercel deploys to staging automatically
2. Verify CI is green (GitHub checks tab)
3. Test the change on staging URL
4. Promote to production: Vercel dashboard → Deployments → Promote

## Rollback procedure

**Time to rollback: ~30 seconds**

1. Vercel dashboard → Deployments tab
2. Find last known good deployment
3. Click "..." → "Instant Rollback"
4. Verify production is healthy
5. Record the incident summary: what failed, what we rolled back to, next steps

## Monitoring

- **Runtime logs:** Vercel dashboard → Logs tab (3-day retention)
- **Error spikes:** Vercel Observability → Functions → error rate
- **Longer retention:** Configure a Vercel Drain to export to your log provider

## Supabase health checks

- Dashboard: app.supabase.com → your project
- Check: DB connections, storage usage, auth active users
- RLS audit: `SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';`

## Incident response

### P1 — site is down
1. Check Vercel status page
2. Check Supabase status page
3. Check last deployment — if recent, rollback immediately
4. Check runtime logs for error pattern
5. If data issue: check Supabase logs, do NOT run destructive queries without backup

### P2 — feature broken, site up
1. Identify affected users/paths from logs
2. Determine if rollback is needed or if a hotfix is faster
3. If rollback: follow rollback procedure above
4. If hotfix: use the standard PR flow — do not skip CI

### P3 — performance degraded
1. Check Vercel Observability for slow functions
2. Check Supabase for slow queries (pg_stat_statements)
3. Add index or optimize query — deploy via normal PR flow

## Security incident

1. Rotate compromised credentials immediately (Supabase dashboard → API keys)
2. Update Vercel env vars with new keys
3. Review access logs for scope of exposure
4. Notify affected users if PII was involved
5. File a post-mortem within 48h

## Weekly maintenance checklist

- [ ] Review Dependabot alerts in GitHub
- [ ] Check GitHub Security tab for new Semgrep findings
- [ ] Review failed nightly CI runs
- [ ] Check Vercel function error rate trend
