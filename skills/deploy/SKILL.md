---
name: deploy
description: Test and deploy changes safely. Runs tests as a pre-deploy gate, deploys, then runs post-deploy verification. This is a TEMPLATE — customize the commands and checks for your specific deployment pipeline.
user_invocable: true
---

# Deploy — Safe Deployment Pipeline

<!-- ============================================================
     TEMPLATE: Customize this skill for your deployment pipeline.
     Replace all [PLACEHOLDER] sections with your actual commands.
     ============================================================ -->

Deploy changes to production with automated testing and verification.

## Input

Arguments after `/deploy`:
- **Target name(s)** (optional) — specific services/functions to deploy. If omitted, auto-detect from git changes.
- **`--all`** — deploy everything
- **`--skip-tests`** — skip pre-deploy tests (use only if tests were just run)

<!-- CUSTOMIZE: List your valid deployment targets -->
Valid targets: `[YOUR_SERVICE_1]`, `[YOUR_SERVICE_2]`, `[YOUR_SERVICE_3]`

## Process

### Step 1: Detect What Changed

If no target specified, check git for changes:

```bash
git diff --name-only HEAD
git diff --name-only --cached
```

<!-- CUSTOMIZE: Map changed files to affected deployment targets -->
Map changed files to affected targets and determine what needs deploying.

### Step 2: Run Tests (Pre-Deploy Gate)

<!-- CUSTOMIZE: Replace with your test command -->
```bash
[YOUR_TEST_COMMAND]
```

- **If tests fail: STOP. Do not deploy. Fix the issue first.**
- Report: number of tests passed/failed, which suite failed

### Step 3: Deploy

<!-- CUSTOMIZE: Replace with your deploy command -->
```bash
[YOUR_DEPLOY_COMMAND] [target-name]
```

Deploy targets one at a time. If a deploy fails, stop and report — do not continue deploying remaining targets.

### Step 4: Post-Deploy Verification

<!-- CUSTOMIZE: Replace with your verification command (E2E tests, smoke tests, etc.) -->
```bash
[YOUR_VERIFICATION_COMMAND]
```

**If verification fails:**
1. Check if it's transient (API timeout, rate limit) — re-run once
2. If still failing, **rollback immediately:**

<!-- CUSTOMIZE: Replace with your rollback procedure -->
```bash
# Example rollback: restore previous version and redeploy
git checkout [previous-commit] -- [path/to/service/]
[YOUR_DEPLOY_COMMAND] [target-name]
git checkout HEAD -- [path/to/service/]
```

3. Report the failure and rollback to the user

### Step 5: Health Check

<!-- CUSTOMIZE: Replace with your health check -->
```bash
[YOUR_HEALTH_CHECK_COMMAND]
```

### Step 6: Report

```
Deploy Complete
───────────────
Targets deployed: [list]
Tests: X/Y passed
Verification: passed
Health: ok
```

## Skip Conditions

**Do NOT use this skill for:**
- Documentation-only changes
- Frontend-only changes (if deploying backend)
- Test file changes
- Configuration that doesn't require deployment

## Important Notes

1. **Tests are the safety gate** — they catch logic bugs before deploy
2. **Verification is the smoke test** — confirms the deployed code works
3. **Rollback is fast** — redeploy from a previous git commit
4. **Verification failures may be transient** — retry once before investigating

---

## Example: filled-in version

Here's what the skeleton above looks like with the placeholders replaced. Stack: a Node.js API on Fly.io with a Postgres backend, health-checked via `curl`. **Adapt to your own stack — this is reference, not prescription.**

### Step 1: Detect What Changed
```bash
git diff --name-only HEAD
git diff --name-only --cached
```
Mapping: anything under `src/api/` → deploy `api`. `migrations/` touched → run migration after deploy.

### Step 2: Run Tests (Pre-Deploy Gate)
```bash
npm test
```
Fail → STOP, fix first.

### Step 3: Deploy
```bash
flyctl deploy --app my-api
```
Fail → STOP. Don't continue to other targets if this is part of a multi-target deploy.

### Step 4: Post-Deploy Verification
```bash
curl -fsSL https://my-api.fly.dev/health
```
- 2xx → pass.
- Fail → re-run once (transient API timeouts happen). Still failing → rollback:
  ```bash
  flyctl releases list --app my-api
  flyctl deploy --image registry.fly.io/my-api:<previous-tag>
  ```

### Step 5: Health Check
```bash
curl -fsSL https://my-api.fly.dev/health | jq '.db_connected'
```
Confirms DB and downstream dependencies are reachable, not just the HTTP listener.

### Step 6: Report
```
Deploy Complete
───────────────
Targets deployed: api
Tests: 47/47 passed
Verification: passed
Health: ok (db_connected: true)
```

**Other stacks fit the same shape:** Supabase Edge Functions (shadow-slug deploy + smoke probe + swap), Vercel (preview → promote with `vercel --prod`), Cloudflare Workers (`wrangler deploy` + health probe), AWS Lambda (`sam deploy` + CloudWatch check). Pick the one closest to your stack and substitute. The 6-step structure stays.
