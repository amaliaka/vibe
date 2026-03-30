# Setup guide

Step-by-step instructions for connecting every service in this stack.
Do this once when starting a new project.

---

## 1. GitHub — create your repo

1. Go to [github.com](https://github.com) → **New repository**
2. Name it, set to private or public, skip the README (you already have one)
3. Push your local project:

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

### Enable GitHub Actions

Actions are enabled by default. Verify at:
`Your repo → Settings → Actions → General → Allow all actions`

### Enable GitHub code scanning (for Semgrep SARIF)

`Your repo → Settings → Security → Code security → Code scanning → Enable`

This is where Semgrep findings will show up after CI runs.

---

## 2. Supabase — create your project

1. Go to [supabase.com](https://supabase.com) → **New project**
2. Choose your organisation, name the project, set a database password (save this somewhere safe), pick a region close to your users
3. Wait ~2 minutes for the project to spin up

### Get your API keys

`Project settings (gear icon) → API`

Copy these — you'll need them in Vercel and locally:

| Key | What it's for |
|---|---|
| **Project URL** | `SUPABASE_URL` |
| **anon / public** key | `SUPABASE_ANON_KEY` — safe to expose in browser |
| **service_role / secret** key | `SUPABASE_SERVICE_ROLE_KEY` — server only, never in browser |

### Apply your first migration

When OpenCode generates a migration file in `supabase/migrations/`:

1. Open the Supabase dashboard → **SQL Editor**
2. Click **New query**
3. Paste the contents of the migration file
4. Click **Run**
5. Verify: go to **Table Editor** — your new table should appear

### Enable Row Level Security

Every table OpenCode creates will have RLS enabled via the migration SQL.
To verify: `Database → Tables → [your table] → RLS enabled` should show a green badge.

---

## 3. Vercel — connect your repo

1. Go to [vercel.com](https://vercel.com) → **Add New Project**
2. Click **Import Git Repository** → connect your GitHub account if prompted
3. Find your repo and click **Import**
4. Vercel auto-detects your framework (Nuxt, Next, Astro, etc.)
5. Click **Deploy** — this creates your first production deployment

### Set environment variables

`Project → Settings → Environment Variables`

Add each variable and choose which environments it applies to:

| Variable | Value | Environments |
|---|---|---|
| `SUPABASE_URL` | Your Supabase project URL | Production, Preview, Development |
| `SUPABASE_ANON_KEY` | Your Supabase anon key | Production, Preview, Development |
| `SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key | Production, Preview only |

> The service role key must never reach the browser. Only add it to server-side
> environments and only use it in server routes / API handlers.

### How preview deployments work

Every branch you push automatically gets its own preview URL:
`https://your-project-git-branch-name-your-username.vercel.app`

Every PR shows the preview URL in the GitHub checks section automatically.

### Gate production with GitHub checks

`Project → Settings → Deployment Protection → Vercel Deployment Checks`

Add your CI checks (e.g. `test`, `e2e`, `semgrep`, `sbom`) so that production
promotion is blocked until all GitHub checks pass.

### How to promote to production

Vercel deploys `main` to production automatically by default.
To make it manual (recommended):

`Project → Settings → Git → Production Branch → disable "Auto-deploy"`

Then promote manually: `Deployments → find the deployment → ... → Promote to Production`

### How to rollback

`Deployments → find the previous good deployment → ... → Instant Rollback`

Takes about 10 seconds.

---

## 4. GitHub Actions — no setup needed

CI runs automatically on every push and pull request.
The `GITHUB_TOKEN` is injected automatically — no secrets to configure.

The only thing to verify after your first push:

`Your repo → Actions` — you should see a workflow run appear.

If it fails on the first run, it's usually a missing `pnpm-lock.yaml`.
Fix: run `pnpm install` locally, commit the lockfile, push again.

---

## 5. OpenCode — connect your AI provider

After installing OpenCode (`npm install -g opencode`), configure your API key:

```bash
opencode auth
```

This will prompt you to select a provider (Anthropic, OpenAI, etc.) and enter
your API key. Keys are stored in your local config, not in the repo.

To verify it's working:

```bash
opencode run "Say hello"
```

### Set repo-level rules

The `AGENTS.md` file in this repo is automatically read by OpenCode when you
run it from the project directory. No extra setup needed — it picks it up automatically.

To verify OpenCode is reading it:

```bash
opencode run "What rules apply to this repo?"
```

It should describe the rules from `AGENTS.md`.

---

## 6. OpenSpec — initialize in your project

After installing OpenSpec (`npm install -g openspec`):

```bash
cd your-project
openspec init
```

This reads `openspec/config.yaml` (already in this template) and sets up the
local OpenSpec environment.

### Verify it works

```bash
openspec validate
```

Should return: `✓ No changes to validate` (since you haven't proposed any yet).

### Create your first spec

```bash
openspec propose "product baseline"
```

This creates `openspec/changes/product-baseline.yaml`. Open it, fill in the
fields, then commit it.

---

## 7. MCP — wire up GitHub and Supabase

MCP servers let OpenCode interact directly with GitHub and Supabase during
development. Add these to your OpenCode MCP config.

### GitHub MCP

Follow the setup at [github.com/github/github-mcp-server](https://github.com/github/github-mcp-server)

You'll need a GitHub Personal Access Token:
`GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens`

Scopes needed: `Contents`, `Issues`, `Pull requests`, `Metadata`

### Supabase MCP

Follow the setup at [github.com/supabase/mcp-server-supabase](https://github.com/supabase/mcp-server-supabase)

You'll need your Supabase project ref and service role key from step 2.

### Verify MCP is working

In OpenCode, try:

```
List my open GitHub issues for this repo
```

If it returns your issues, GitHub MCP is connected. Then try:

```
List the tables in my Supabase project
```

If it returns your tables, Supabase MCP is connected.

---

## Quick reference — where to find things

| What | Where |
|---|---|
| Supabase API keys | supabase.com → Project settings → API |
| Supabase SQL editor | supabase.com → SQL Editor |
| Supabase RLS status | supabase.com → Database → Tables |
| Vercel env vars | vercel.com → Project → Settings → Environment Variables |
| Vercel deployments | vercel.com → Project → Deployments |
| Vercel logs | vercel.com → Project → Logs |
| GitHub Actions runs | github.com → Your repo → Actions |
| GitHub code scanning | github.com → Your repo → Security → Code scanning |
| OpenCode config | `~/.config/opencode/` (local, not in repo) |
| OpenSpec config | `openspec/config.yaml` (in repo) |

---

## Checklist — first-time setup complete when:

- [ ] Repo pushed to GitHub
- [ ] GitHub Actions running on push (check the Actions tab)
- [ ] GitHub code scanning enabled (Security tab visible)
- [ ] Supabase project created and API keys copied
- [ ] Vercel project created and connected to GitHub repo
- [ ] All 3 env vars set in Vercel (URL, anon key, service role key)
- [ ] Preview deployment visible for your main branch
- [ ] `openspec init` run successfully
- [ ] `opencode auth` completed with your API key
- [ ] GitHub MCP connected and returning issues
- [ ] Supabase MCP connected and returning tables
