# Merge Command

Finalize work on a branch: verify docs + tree are clean, merge to main, clean up. Supports both standard `git checkout -b` branches and `git worktree` flows — auto-detected at pre-flight.

**Context from user:** $ARGUMENTS

---

## Philosophy

`/merge` is a **verify + ship** command, not a do-everything-at-end-of-session cleanup. Doc updates, commits, and testing belong to the **work session** on the branch. By the time `/merge` runs — typically in a fresh `claude` session — those things should already be done. This command verifies the invariant, surfaces violations, and ships if clean.

Rule of thumb: if you're tempted to have `/merge` silently fix something, STOP and surface it to the user instead. Merges are semi-destructive; a missed doc update or an accidentally-committed build artifact is much harder to undo after the fact.

---

## $ARGUMENTS conventions

Two documented uses for `$ARGUMENTS`:

- `Verified: <context>` — appended as a `Verified:` line in the merge commit. Opt-in; only include if user passed one.
  Example: `/merge Verified: integration tests pass + manual smoke check`
- `summary: <override>` — use as the merge-message summary instead of synthesizing from the diff.
  Example: `/merge summary: swap payment provider from Stripe to Adyen`

Do not prompt the user for verification notes. Most merges don't carry a `Verified:` line, and it's a deliberate signal rather than a checkbox.

---

## Pre-flight

1. **Detect mode.** Compare the current git dir to the main git dir:
   ```bash
   git rev-parse --git-dir
   git rev-parse --git-common-dir
   ```
   - **Equal** → **standard mode** (regular clone, or operating from the main repo itself).
   - **Different** → **worktree mode** (current dir is a linked worktree created via `git worktree add`).

   Remember the mode — it controls how Step 4 (merge) and Step 5 (cleanup) behave.

2. **Verify branch.** Run `git branch --show-current`.
   - Branch is `main` → stop: "You're on main — nothing to merge. Create a feature branch with `git checkout -b <name>` (standard mode) or run this from a worktree on the branch you want to merge (worktree mode)."
   - Otherwise → capture `<branch>` = current branch name.

3. **Worktree mode only — capture `<main-repo-path>`:** the path listed for branch `main` in `git worktree list`. Standard mode doesn't need this (everything happens in the cwd).

4. **Survey the branch:**
   ```bash
   git log main..HEAD --oneline
   git diff main --stat
   git log main..HEAD --name-only --format= | sort -u | cut -d/ -f1 | sort -u
   git status
   ```
   In worktree mode, also run `git -C <main-repo-path> status` to spot uncommitted changes in the main repo.

   The third command gives you the top-level directories touched — this drives the docs check in Step 2. Note lines-changed and file-count from `git diff main --stat` — this drives the Step 1 branch.

---

## Step 1: Form a mental model

You have no implicit session context (fresh session). Read the branch before drafting anything.

- **Small diffs** (<200 lines changed AND <10 files): `git diff main` inline.
- **Large diffs** (>200 lines OR >10 files): delegate to an `Explore` sub-agent (Sonnet) to keep context clean.

  ```
  Agent({
    description: "Summarize <branch> vs main",
    subagent_type: "Explore",
    prompt: "Summarize what branch <branch> does relative to main. Focus on: which systems/areas it touches, what new capabilities or changes it introduces, and risk areas (migrations, auth, infra). Under 300 words."
  })
  ```

Use the summary + diff stat to draft the merge message in Step 4. If `$ARGUMENTS` contained `summary: <override>`, use that instead and skip the synthesis.

---

## Step 2: Docs-current guardrail

From the top-level dirs touched (Pre-flight step 4 command), map to docs that might need updating:

| Top-level dir touched | Docs to consider |
|---|---|
| Any code dir | `docs/ai-context/*.md`, root `CLAUDE.md` |
| `assets/` (if present) | `assets/CLAUDE.md` |
| Other top-level dirs | their local `CLAUDE.md` if one exists |

For monorepos with per-product subdirs (e.g., `ProductA/`, `ProductB/`), map each touched product dir to its own `<product>/docs/ai-context/` and `<product>/CLAUDE.md`.

**Decision flow:**

1. **Apply skip criteria** (from `.claude/skills/update-docs/SKILL.md` "When to Skip" section): bug fixes, small refactors, code cleanup, UI tweaks, single-file additions within existing patterns, perf opts without arch impact, comment/formatting changes. If the branch fits these → skip silently, proceed to Step 3.

2. **Check whether docs were already touched on this branch:**
   ```bash
   git log main..HEAD --name-only --format= | grep -E 'docs/ai-context/|CLAUDE\.md'
   ```
   If yes → docs were handled in the work session. Skip silently, proceed to Step 3.

3. **If substantive diff AND no doc touches on branch** → STOP. List the specific files likely needing attention, then present three options:
   - **(a)** Abort the merge so the user can invoke the `/update-docs` skill in this or another session.
   - **(b)** Proceed anyway (user explicitly accepts doc drift — note this for Step 6).
   - **(c)** Cancel entirely.

   **Wait for user choice. Do NOT auto-invoke `/update-docs`.** Merge is semi-destructive; this is a deliberate exception to the usual "skip redundant confirmation" preference.

---

## Step 3: Clean-tree guardrail

- **Clean worktree** (`git status` shows nothing) → proceed silently to Step 4.
- **Dirty worktree** → STOP. Show:
  - `git status` output
  - `git diff --stat` summary
  - A one-line categorization hint ("looks like build artifacts / generated files" vs "looks like code changes")

  Ask the user to choose:
  - **(a)** Commit specific named files — user names them. Follow repo commit style (conventional `feat:`/`fix:`/`chore:` prefix, HEREDOC message, `Co-Authored-By: Claude <noreply@anthropic.com>` trailer).
  - **(b)** Discard the uncommitted changes.
  - **(c)** Abort the merge.

**Never `git add -A` or `git add .`.** Never auto-commit without the user naming files. A merge commit that quietly swallows regenerated build output or stale `.DS_Store`s is painful to undo.

---

## Step 4: Merge to main

Branch on the mode detected at pre-flight.

### Standard mode

You can check out main directly in the cwd.

1. Confirm commits exist:
   ```bash
   git log main..HEAD --oneline
   ```
   If empty → ask the user whether to just run Step 5 cleanup (zero-commit edge case; the branch had no work).

2. Check out main and merge with `--no-ff`:
   ```bash
   git checkout main
   git merge <branch> --no-ff -m "$(cat <<'EOF'
   Merge branch '<branch>' — <short summary>

   [optional Verified: line ONLY if provided via $ARGUMENTS]

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

3. Sanity-check: `git log -1 --oneline`.

### Worktree mode

**Critical:** you cannot `git checkout main` inside a worktree — main is checked out in the main repo. Use `git -C <main-repo-path>` for all merge operations.

1. Confirm commits exist:
   ```bash
   git log main..HEAD --oneline
   ```
   If empty → ask the user whether to just run Step 5 cleanup.

2. Merge from the main repo:
   ```bash
   git -C <main-repo-path> merge <branch> --no-ff -m "$(cat <<'EOF'
   Merge branch '<branch>' — <short summary>

   [optional Verified: line ONLY if provided via $ARGUMENTS]

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

3. Sanity-check: `git -C <main-repo-path> log -1 --oneline`.

### Both modes — merge message summary style

One em-dash-separated clause capturing what the branch accomplished. Synthesize from Step 1 mental model or use `summary:` override from `$ARGUMENTS`. Examples of good summary clauses:
- "auth middleware rewrite for compliance — drops session-token storage"
- "swap payment provider from Stripe to Adyen"
- "feature flag for new onboarding flow + telemetry plumbing"

### Both modes — on merge conflicts

**STOP.**
- Report the conflicted files.
- Do NOT clean up. The user needs the working dir intact to resolve conflicts.
- Do NOT attempt auto-resolution.

---

## Step 5: Clean up

Only after a **successful** merge in Step 4.

### Standard mode

You're already on main with the branch merged. Just delete the branch ref:

```bash
git branch -d <branch>
```

`-d` (lowercase) refuses to delete an unmerged branch — self-checking. If it errors, surface it to the user; do NOT escalate to `-D`.

### Worktree mode

1. Remove the worktree directory using the `ExitWorktree` tool:
   - `action: "remove"`
   - `discard_changes: true`

   This is safe because all work is now on main. The tool warns about "unmerged commits" because it checks the worktree branch, not main — but the commits ARE on main after Step 4.

2. Delete the branch ref. Without this, the branch sits at its pre-merge tip; a later `git worktree add` matching the same name will reuse the stale branch instead of branching off current main.
   ```bash
   git -C <main-repo-path> branch -d <branch>
   ```
   `-d` (lowercase) refuses to delete an unmerged branch. If it errors, surface it; do NOT escalate to `-D`.

---

## Step 6: Confirm

Report to the user:
- Branch name + commit count merged
- File/line summary (from Pre-flight stat)
- One-line shipped summary (from Step 1 mental model or `$ARGUMENTS` override)
- Any flags carried forward (e.g., "docs flagged as possibly stale but you chose to proceed")
- "Back on main." — append "(worktree removed)" if you were in worktree mode.
