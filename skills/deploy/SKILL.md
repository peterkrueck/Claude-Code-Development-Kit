---
name: deploy
description: Test and deploy changes safely. Discovers deploy targets, runs fail-stop gates before going live, optionally shadow-deploys and swaps, then runs report-only post-deploy checks. This is a TEMPLATE — customize the commands and checks for your specific deployment pipeline.
user_invocable: true
---

# Deploy — Safe Deployment Pipeline

<!-- ============================================================
     TEMPLATE: Customize this skill for your deployment pipeline.
     Replace every [PLACEHOLDER] and every commented "CUSTOMIZE"
     block with your actual commands. Delete the patterns you
     don't use (shadow/canary is optional). The structure —
     discover → gate → deploy → report — is the part worth keeping.
     ============================================================ -->

Pipeline shape: **discover targets → fail-stop gate → deploy → report-only checks**. The default scope is the whole project; module-level targeting is optional (see Target Discovery).

## Input

```
/deploy [target(s)...] [--all] [--skip-tests]
```

- **`target(s)`** (optional) — specific services/functions/apps to deploy. Omit to auto-detect from the git diff.
- **`--all`** — deploy every target affected by the current diff.
- **`--skip-tests`** — skip the pre-deploy test gate (use only when tests were just run).

<!-- CUSTOMIZE: list your valid deploy targets, or delete this line if your repo has a single deploy target -->
Valid targets: `[YOUR_TARGET_1]`, `[YOUR_TARGET_2]`, ...

## Target Discovery

The pipeline finds *what* to deploy by scanning for **capability-marker files** — the file that signals "this directory is independently deployable." Discover targets instead of hardcoding them, so a newly-added target works without editing this skill.

<!-- CUSTOMIZE: pick the marker file(s) for your stack and the directory layout.
     One project per repo: usually there is a single marker at the repo root,
     and "discovery" just confirms it exists. Use module-level markers only if
     your repo genuinely ships more than one independently-deployable unit. -->
```bash
# Scan for the capability marker. Default to the whole project (repo root).
# Examples of marker files (pick ONE for your stack):
#   <!-- e.g. fly.toml | vercel.json | wrangler.toml | serverless.yml
#         | Dockerfile | Procfile | package.json with a "deploy" script -->
find . -maxdepth 2 -name '[YOUR_MARKER_FILE]' -not -path '*/node_modules/*'
```

If a marker is found at the repo root → the deploy target is the whole project (the common case). If markers exist in multiple subdirectories → each is an independent target; map the diff to the affected one(s).

### Resolving deploy config (fallback hierarchy)

Read deploy config (app id, account/project identifier, region — whatever your provider needs) from the **first** source that exists:

1. **Committed config** — a tracked file checked into the repo (canonical, worktree-safe).
   <!-- CUSTOMIZE: e.g. fly.toml `app =`, vercel.json, a `.deploy-target` file you commit -->
2. **CLI-managed temp/state** — whatever your provider's CLI writes after `link`/`login` (often gitignored).
   <!-- CUSTOMIZE: e.g. `.vercel/project.json`, a CLI cache under the project's temp dir -->
3. **Heuristic** — derive from a convention (directory name, repo name, an env var).
   <!-- CUSTOMIZE: e.g. app name == repo name; region from an env var -->

If none resolve, STOP with an actionable message:
`No deploy config for [target]. Run '[YOUR_LINK_COMMAND]', or create '[YOUR_COMMITTED_CONFIG_FILE]'.`

### Detect what changed

If no target was passed explicitly, map the diff to targets:

```bash
git diff --name-only HEAD
git diff --name-only --cached
```

<!-- CUSTOMIZE: map changed paths → affected target(s). With a single target this
     reduces to "is anything deployable changed?" -->

## Shared-code dependency awareness

If the diff touches shared/library code that other deployable units import, those importers must be redeployed too — they bundle the changed code.

<!-- CUSTOMIZE: point this at your shared dir and your import syntax.
     The pattern: find direct importers, then recurse once for transitive importers. -->
```bash
# Direct importers of the changed shared file:
grep -rl "[CHANGED_SHARED_PATH]" [YOUR_SOURCE_GLOB]

# Transitive: a shared file that imports the changed shared file is itself
# "changed" — repeat the grep for it, then add its importers. Recurse until
# the set stops growing (usually one extra pass is enough).
```

Each affected target then runs through the full deploy pipeline below.

## Pipeline

### Step 1 — Preflight

1. Resolve target(s), the deploy list, and deploy config.
2. Print a summary so the operator can sanity-check before anything ships:
   ```
   Repo:    <path>
   Branch:  <name> @ <short-sha>
   Targets: <list>
   ```
   <!-- CUSTOMIZE: if you work on feature branches, also show `git log main..HEAD --oneline` -->
3. **Classify each target as new vs. existing** in production (see Step 3 — the two branches differ).
   <!-- CUSTOMIZE: how to ask your provider "does this already exist live?"
        e.g. `flyctl status`, `vercel ls`, `wrangler deployments list`, an API call -->

### Step 2 — Pre-deploy gate (FAIL-STOP)

These run **before** anything goes live. A failure here means **nothing is deployed** — the live target is untouched.

<!-- CUSTOMIZE: replace with your test command. Discover it if you can
     (e.g. a "test" script in package.json) and skip cleanly if none exists. -->
```bash
[YOUR_TEST_COMMAND]
```

- Non-zero exit → **STOP**. Report which suite failed, pass/fail counts. Deploy nothing.
- Skipped only when `--skip-tests` is set or no test command is discovered.

### Step 3 — Deploy

Deploy targets **one at a time**. If one fails, stop and report — do not continue to the remaining targets.

#### 3a. New target (does not yet exist in production)

Nothing live to protect, so deploy directly:

```bash
[YOUR_DEPLOY_COMMAND] [target]
```

- Then run the **smoke probe** (see below). A hard failure (target won't boot / not routable) → STOP and report. There is no previous version to fall back to; the operator inspects.

#### 3b. Existing target — optional Shadow/Canary, then swap

<!-- OPTIONAL PATTERN. Skip this whole sub-step if your provider already does
     atomic, instant rollback (most PaaS do — keep a previous-release id instead,
     see "Rollback" below). Use shadow/canary when a bad deploy would otherwise
     be served to users before you can verify it. -->

Deploy a **staging variant** alongside the live one, probe it, and only swap if it passes. The live target keeps serving the old code until the swap.

1. **Shadow-deploy** a parallel variant (a separate slug / preview URL / canary slice):
   ```bash
   [YOUR_SHADOW_DEPLOY_COMMAND]      # deploy as <target>-shadow / a preview / N% canary
   ```
   <!-- CUSTOMIZE per provider, e.g.:
        Vercel:      vercel deploy            (preview URL, not --prod)
        Fly.io:      flyctl deploy --strategy canary
        AWS Lambda:  publish a new version + weighted alias
        Cloudflare:  wrangler deploy --name <target>-shadow   (separate Worker) -->
   - Shadow deploy fails → run **Cleanup helper** on the shadow, STOP. Live target untouched.

2. **Smoke-probe gate (FAIL-STOP)** — probe the shadow URL:
   ```bash
   [YOUR_SHADOW_SMOKE_PROBE]
   ```
   - Fail → run **Cleanup helper** on the shadow, STOP. Live target untouched.

3. **Swap** — promote the verified bundle to the live target:
   ```bash
   [YOUR_SWAP_COMMAND]               # promote shadow → live / shift 100% traffic
   ```
   <!-- CUSTOMIZE per provider, e.g.:
        Vercel:      vercel promote <deployment-url>
        Fly.io:      shift traffic to the canary release
        AWS Lambda:  point the alias at the new version
        Cloudflare:  deploy the verified bundle to the live Worker name -->
   - Swap fails → see **Retry-once** in Error handling. The live target may be mid-state; do NOT touch git.

4. **Post-swap probe (REPORT-ONLY)** — probe the live URL. See Step 4. On failure, **report and keep the shadow live** for inspection — do not roll back automatically.

5. **Cleanup** — on success, remove the shadow (see Cleanup helper).

### Step 4 — Post-deploy verification (REPORT-ONLY)

These run **after** the target is live. They **cannot** un-deploy — by definition the new code is already serving. So they are **report-only**: surface the result, never trigger a destructive auto-rollback.

<!-- CUSTOMIZE: e2e / smoke / health checks against the LIVE target -->
```bash
[YOUR_POST_DEPLOY_CHECK]
```

- Pass → report success.
- Fail → **re-run once** (post-deploy checks are flaky: cold starts, propagation lag, rate limits). Still failing → **report it**. If a shadow is still live (3b), **keep it live** for the operator to inspect. **Do NOT** auto-rollback via git or redeploy of old code.

> The split that matters: **gates fail-stop before the swap; post-deploy checks only report after it.** A check that runs after code is live can warn but must never silently mutate the deployment or the repo.

## Smoke probe semantics

A minimal "is it alive and routable?" check — no app secrets or auth needed.

<!-- CUSTOMIZE: replace the URL; adjust which codes mean PASS for your auth setup -->
```bash
curl -s -o /dev/null -w "%{http_code}" "[YOUR_TARGET_URL]"
```

- **5xx** — crashed on boot or dispatch. **FAIL.**
- **404** — the router doesn't know this target (bad deploy / wrong name). **FAIL.**
- **401 / 403** — auth middleware rejected the unauthenticated probe, but the target is alive. **PASS.**
- **2xx / other 4xx** — the target responded. **PASS.**

## Cleanup helper

Remove a shadow/canary variant after a swap, or after a failed gate. Safe to run idempotently; cleanup failures are reported but never block an already-completed swap.

```bash
# Remote: delete the shadow deployment.
[YOUR_SHADOW_DELETE_COMMAND]

# Local (if your shadow created files): note that `rm -rf` may be permission-gated.
# A surgical enumerate-then-remove avoids the prompt:
find [SHADOW_DIR] -depth -type f -delete
find [SHADOW_DIR] -depth -type d -empty -delete
```

## Error handling

- **Pre-deploy test failure** → nothing deployed; report.
- **Shadow deploy failure** → run Cleanup helper on the shadow, stop; live target untouched.
- **Gate (smoke-probe) failure** → run Cleanup helper on the shadow, stop; live target untouched.
- **Swap failure (Retry-once)** → swaps are normally atomic but can hit a transient error. Re-run the swap command **once**. If it fails again, **report** — the live target may be in an unknown state (old code still serving, or partially updated). Do NOT mutate git state. Operator inspects.
- **Post-swap / post-deploy check failure** → **report**. Keep the shadow live (don't clean it up) so the operator can compare. Do NOT auto-rollback.

## Rollback

<!-- IMPORTANT: prefer your provider's native, atomic rollback. Almost every host
     keeps previous immutable releases you can re-point traffic to instantly. That
     is far safer than rebuilding old code from git. Capture the previous release
     id at deploy time so rollback is a one-liner. -->
```bash
[YOUR_NATIVE_ROLLBACK_COMMAND]    # re-point traffic to the previous good release
```
<!-- CUSTOMIZE per provider, e.g.:
     Vercel:      vercel rollback <previous-deployment-url>
     Fly.io:      flyctl releases list  →  flyctl deploy --image <previous-image>
     AWS Lambda:  point the alias back at the previous version
     Cloudflare:  wrangler rollback [<version-id>] -->

> Do **not** rebuild old code with `git checkout` and redeploy as a rollback path. It's destructive (can clobber working-tree state), slow, and may not reproduce the exact bytes that were live. The shadow-then-swap flow above already gives you the real safety net: **if anything fails before the swap, the live target was never touched** — "rollback" is simply "don't swap."

## Step — Report

```
Deploy Complete
───────────────
Targets: <target> @ <deploy-id>
Branch:  <branch> @ <sha>
Tests:   <X/X passed | skipped (none found) | skipped (--skip-tests)>
Results:
  <target1>: shadow → gate PASS → swap → post-check OK → cleaned
  <target2>: new → deploy → probe OK
```

## Skip conditions

Do NOT deploy for:
- Documentation-only changes (`*.md`)
- Client/frontend-only changes when deploying a backend (and vice-versa)
- Test-only changes (unless `--all` is explicit)
- Config that doesn't require redeploy

## Notes

1. **Gates are the safety net** — the pre-deploy test gate and the shadow smoke-probe both fail-stop *before* the swap. If anything fails there, the live target was never touched.
2. **Post-deploy checks only report** — once code is live they can't un-deploy it, so they warn but never auto-rollback.
3. **Shadow/canary is optional** — use it when a bad deploy would reach users before you can verify. If your host already does atomic instant rollback, you may not need it.
4. **Rollback should be native and atomic** — re-point traffic to a previous release; never rebuild old code from git.
5. **Every fresh worktree that deploys** needs the committed deploy-config file (Target Discovery #1), or it falls back to CLI state / heuristic.
