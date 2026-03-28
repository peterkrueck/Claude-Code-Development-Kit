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
