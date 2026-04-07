# Merge Command

Finalize worktree work: update docs, commit, merge to main, clean up.

**Context from user:** $ARGUMENTS

---

## Pre-flight

1. **Verify worktree:**
   ```bash
   git worktree list
   git branch --show-current
   ```
   If the current branch is `main`, stop: "You're on main — nothing to merge. Use this command from inside a worktree."

2. **Capture branch name** and **main repo path** (the `git worktree list` entry on branch `main`).

3. **Survey what this branch has done** — this informs the commit/merge messages and doc updates:
   ```bash
   git log main..HEAD --oneline
   git diff main --stat
   git diff --stat
   git status
   ```

## Step 1: Update Documentation

Invoke the `/update-docs` skill, passing the branch changes as context. If no doc updates are needed, it will skip — that's fine.

## Step 2: Commit Uncommitted Changes

Run `git status`. If there are uncommitted changes:

1. Review the diff to understand what changed
2. Stage relevant files by name — never stage `.env`, credentials, or secrets
3. Write a commit message following repo style (`feat:`, `fix:`, `chore:`, etc.)
4. Commit using HEREDOC format with Co-Authored-By trailer

If the working tree is clean, skip to Step 3.

## Step 3: Merge to Main

**Critical: You cannot `git checkout main` inside a worktree** — main is checked out in the main repo. Use `git -C <main-repo-path>` for all merge operations.

1. Verify there are commits to merge:
   ```bash
   git log main..HEAD --oneline
   ```
   If empty (no commits at all on branch), ask the user whether to just clean up.

2. Merge with `--no-ff` to preserve branch history:
   ```bash
   git -C <main-repo-path> merge <branch> --no-ff -m "<message>"
   ```

   Merge message format — match established pattern:
   ```
   Merge branch '<branch-name>' — <short summary of what the branch accomplished>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   Use HEREDOC for the message to preserve formatting.

3. **If merge conflicts occur: STOP.** Report the conflicts to the user. Do NOT clean up the worktree — the user needs it to resolve conflicts.

## Step 4: Clean Up Worktree

Only after a **successful** merge:

Use the `ExitWorktree` tool with:
- `action: "remove"`
- `discard_changes: true`

This is safe because all work is now on main. The tool warns about "unmerged commits" because it checks the worktree branch, not main — but the commits ARE on main after Step 3.

## Step 5: Confirm

Report to user: what was merged (commit count + summary), and that we're back on main.
