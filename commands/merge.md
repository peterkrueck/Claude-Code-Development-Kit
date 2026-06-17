# Merge Command

Finalize work on a branch: verify docs + tree are clean, merge to main, clean up. Supports both standard `git checkout -b` branches and `git worktree` flows — auto-detected at pre-flight.

**Context from user:** $ARGUMENTS

---

## Philosophy

`/merge` is a **verify + ship** command, not a do-everything-at-end-of-session cleanup. Doc updates, commits, and testing belong to the **work session** on the branch. By the time `/merge` runs — typically in a fresh `claude` session — those things should already be done. This command verifies the invariant, surfaces violations, and ships if clean.

Rule of thumb: if you're tempted to have `/merge` silently fix something, STOP and surface it to the user instead. Merges are semi-destructive; a missed doc update or an accidentally-committed build artifact is much harder to undo after the fact.

**Two scenarios, one command.** When the branch fast-forwards or auto-merges with no conflicts, this is pure verify + ship. When `main` has diverged and the merge conflicts — routine when overlapping branches touch the same files — conflict resolution becomes the real work (→ **Step 4b**). Resolving conflicts is NOT "silently fixing": surface the *approach decision* to the user, then execute it on rails with mandatory verification.

**Prime directive (non-negotiable):** any merge where `main` had diverged — i.e., git *composed* a new tree from both sides, **whether it conflicted or auto-merged cleanly** — MUST pass the project's build/test before the merge commit is finalized (→ **Step 4c**). The nastiest defects are clean auto-merges with no conflict marker: a reference whose declaration the other side moved or deleted compiles on each parent alone and breaks only in the combined tree. Only building the composed tree catches it. (If `main` is already an ancestor of the branch — no divergence — the merged tree equals the branch tree, already built on-branch; the build is skippable.)

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

   The third command gives you the top-level directories touched — this drives the docs check in Step 2 (and, optionally, module-scoped build/test in Step 4c). Note lines-changed and file-count from `git diff main --stat` — this drives the Step 1 branch.

5. **Detect divergence, predict conflicts, scan for rider commits** (read-only — do this BEFORE any merge; it routes Step 4):
   ```bash
   # Divergence? FALSE = main composed a new tree → MANDATORY build/test (Step 4c).
   git merge-base --is-ancestor main HEAD && echo "no divergence (ff-equivalent)" || echo "DIVERGED — build/test the composed tree"
   # Dry-run the merge: see the conflict set without touching anything.
   git merge-tree --write-tree --name-only main HEAD   # exit 0 = clean → 4a; exit 1 = conflicts → 4b
   ```
   - `merge-base --is-ancestor` succeeds (exit 0) → main is already an ancestor → **no divergence** (fast-forward-equivalent); the build in 4c is skippable. Fails (exit 1) → **DIVERGED** → 4c is mandatory.
   - `merge-tree` exit **0** → no conflicts (Step 4a). Exit **1** → the lines after the first (tree-OID) line are the conflicted paths (Step 4b).
   - Pre-flight step 4's `git log main..HEAD --oneline` already lists **every commit this merge introduces**. Scan it for **riders** — unrelated commits riding the branch (merging a branch merges ALL its commits). If you see work beyond the branch's stated purpose, flag it to the user before merging and in the Step 6 report.

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

Two things route this step:
- **Mode** (Pre-flight step 1) — standard vs worktree — controls *where* the merge runs.
- **Divergence** (Pre-flight step 5) — controls *how* the merge runs:
  - **No divergence** → simple, single-command merge (Step 4a, fast path).
  - **Diverged** → two-phase merge: stage with `--no-commit`, verify the composed tree (Step 4c), *then* commit. This is the prime directive — a clean auto-merge can still break the build.
  - **Conflicts predicted** → Step 4b.

Throughout, the only difference between modes is the git invocation prefix:
- **Standard mode:** `git checkout main` once, then run merge commands in the cwd.
- **Worktree mode:** you cannot `git checkout main` inside a worktree (main is checked out in the main repo). Use `git -C <main-repo-path>` for **all** merge operations — never `cd` into the worktree's main.

In the commands below, `<merge-git>` stands for `git` (standard mode, after `git checkout main`) or `git -C <main-repo-path>` (worktree mode). Substitute the right one.

### Step 4a: Merge

1. Confirm commits exist:
   ```bash
   git log main..HEAD --oneline
   ```
   If empty → ask the user whether to just run Step 5 cleanup (zero-commit edge case; the branch had no work).

2. **Standard mode only:** check out main in the cwd first:
   ```bash
   git checkout main
   ```

3. **Fast path — no divergence** (Pre-flight: `merge-base --is-ancestor` succeeded). The merged tree equals the branch tree, already built on-branch. Merge in one shot:
   ```bash
   <merge-git> merge <branch> --no-ff -m "$(cat <<'EOF'
   Merge branch '<branch>' — <short summary>

   [optional Verified: line ONLY if provided via $ARGUMENTS]

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```
   Then sanity-check (bullet 7 below) — skip bullet 6, the commit is already done — and go to **Step 5: Clean up**.

4. **Two-phase path — diverged** (Pre-flight: `merge-base --is-ancestor` failed). Stage the merge WITHOUT committing so you can verify the composed tree before finalizing:
   ```bash
   <merge-git> merge <branch> --no-ff --no-commit
   ```
   - **Conflicts** (Pre-flight predicted them) → go to **Step 4b**. Do NOT clean up the branch/worktree.
   - **No conflicts** → continue to bullet 5 (Verify the composed tree) below.

5. **Verify the composed tree** → run **Step 4c** now. A clean auto-merge can still break the build.

6. **Finalize the commit** (only after 4c is green):
   ```bash
   <merge-git> commit -m "$(cat <<'EOF'
   Merge branch '<branch>' — <short summary>

   [optional Verified: line ONLY if provided via $ARGUMENTS]

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

7. **Sanity-check** HEAD moved as expected:
   ```bash
   <merge-git> log -1 --oneline
   ```

**Merge message summary style:** one em-dash-separated clause capturing what the branch accomplished. Synthesize from the Step 1 mental model or use the `summary:` override from `$ARGUMENTS`. Examples of good summary clauses:
- "auth middleware rewrite for compliance — drops session-token storage"
- "swap payment provider from Stripe to Adyen"
- "feature flag for new onboarding flow + telemetry plumbing"

---

## Step 4b: Resolve conflicts

Conflict-heavy merges are routine when parallel branches touch overlapping files — a real workflow, not a failure. But it's judgment-heavy and semi-destructive, so it runs on rails. **Never auto-resolve.**

1. **Present + decide.** Show the user the conflicted-path set (from `merge-tree` in Pre-flight) and the commits being merged, then ask how to proceed:
   - **(a) Resolve now** — resolve in this `--no-commit` merge, verify (4c), then finalize.
   - **(b) Rebase first** — rebase the branch onto main, resolve there, then merge fast-forward (linear history; rewrites the branch).
   - **(c) Abort** — `<merge-git> merge --abort`; leave it for a dedicated session.

   Wait for the choice — never auto-pick.

2. **Resolve each hunk by INTENT, not by mechanically keeping both sides:**
   ```bash
   <merge-git> diff --name-only --diff-filter=U   # conflicted paths
   ```
   - **Both-added** (each side adds different members) → usually keep both.
   - **Delete-vs-keep** (one side deleted code the other still carries) → the deletion usually wins, but VERIFY intent before keeping code (see archaeology below). If a branch merely INHERITED code the other side DELIBERATELY deleted, take the deletion — keeping it resurrects removed behavior.
   - **modify/delete** → decide by intent; `<merge-git> rm <path>` to accept the delete.
   - **docs** → merge both narratives, but re-verify every factual CLAIM (test counts, file counts, version numbers) against reality — divergent branches assert different numbers (4c measures the truth).

3. **(optional) Conflict archaeology — opt-in advanced path.** When intent isn't obvious from the conflict alone, reconstruct it from history. Surface this to the user as an option; don't run it on every hunk by default.
   ```bash
   MB=$(git merge-base main <branch>)
   git show $MB:<path>                            # the file as it was at the common ancestor
   git show $MB:<path> | grep -n <symbol>         # was the symbol present in the base?
   git log $MB..main --diff-filter=D --oneline -- <path>  # did main delete it on purpose?
   ```
   Reading the merge-base version (`git show <merge-base>:<path>`) tells you what BOTH sides started from, so you can tell an intentional deletion from an accidental inheritance. This is a read-only investigation — it never resolves anything for you.

4. **(optional) Parallelize ANALYSIS, never resolution.** For a large conflict set (≳5 files, or conflicts needing archaeology), you MAY dispatch `Explore` sub-agents — one per file or cluster — each reporting, per conflict: what each side INTENDS, the merge-base archaeology, a recommended resolution + risks. The main agent SYNTHESIZES and APPLIES every resolution itself — cross-file invariants (one decision spanning several files) are invisible to per-file agents. Sub-agents read; they never edit.

5. **Stage resolved files by name** (never `git add -A`); confirm `<merge-git> diff --name-only --diff-filter=U` is empty.

6. **Verify + finalize** → run **Step 4c**, then `<merge-git> commit` (the in-progress merge picks up the staged resolution; use the Step 4a message template plus a one-line note on what conflicted and how you decided). Sanity-check HEAD.

---

## Step 4c: Verify the composed tree (mandatory when main diverged)

The prime directive. Run whenever git composed a new tree (divergence TRUE) — conflict or clean auto-merge — BEFORE finalizing the merge commit.

1. **Discover the project's build/test command — don't hardcode it.** Look, in order, for what this repo already uses:
   - A test/build runner declared in project config (e.g., `package.json` scripts, `Makefile` targets, `justfile`, `pyproject.toml`, `Cargo.toml`, a CI workflow under `.github/workflows/`, or a project skill/command that wraps the build).
   - The repo's own `CLAUDE.md` or `docs/ai-context/*.md`, which often record the canonical build/test invocation.
   - If a project `deploy` or build skill exists, reuse its discovery logic rather than reinventing it.

   <!-- e.g. `npm test` / `make check` / `cargo test` / `pytest` / `go build ./...` — discover, don't assume -->

   If you genuinely can't find one, STOP and ask the user how to build/test this repo rather than guessing.

2. **Scope it (optional — default is the whole project).** Default to building/testing the **whole project**: it's the safest and this kit assumes one project per repo. *Optionally*, if the project is large and clearly partitioned, you MAY narrow to the **module/component** the diff touched — detect it by file path (the top-level dirs from Pre-flight step 4), and only when the build system supports targeting that subset cheaply. When in doubt, build the whole thing.

3. **Build, then test.** Run the discovered build; if it has platform/target variants that the diff touched, build each affected one (a target gated out of one build is invisible to it). Then run the test suite if the touched code is test-covered.

4. **Fix every error the merge produced** (auto-merge orphans — a use whose declaration the other side removed — live here), then rebuild to green. If a fix is non-trivial or changes behavior, surface it to the user rather than guessing.

5. **Reconcile doc claims.** If you corrected any doc test-count / file-count / version numbers during conflict resolution, set them to the MEASURED value from this build/test run.

6. Only once green → return to Step 4a/4b to commit.

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

1. Remove the worktree directory:
   - If this worktree was created by `EnterWorktree` **this session**, use the `ExitWorktree` tool (`action: "remove"`, `discard_changes: true`). It warns about "unmerged commits" (it checks the worktree branch, not main) — but the commits ARE on main after Step 4.
   - Otherwise — a pre-existing `git worktree add` — use:
     ```bash
     git -C <main-repo-path> worktree remove <worktree-path>
     ```
     It refuses if the worktree is dirty; it's clean here (all work is on main). The current shell cwd may be inside the worktree, so it can get deleted out from under you — keep using absolute paths / `git -C <main-repo-path>` afterward.

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
- **If conflicts were resolved (4b):** which files + the key resolution decisions
- **If the tree was composed (divergence — 4c ran):** the build/test result
- **Any rider commits** that came along (Pre-flight step 5) — name them so the user can revert if unwanted
- Any flags carried forward (e.g., "docs flagged as possibly stale but you chose to proceed")
- "Back on main." — append "(worktree removed)" if you were in worktree mode.
