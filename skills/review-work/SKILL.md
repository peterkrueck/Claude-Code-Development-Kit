---
name: review-work
description: Review uncommitted code changes using parallel Claude sub-agents (Bug Hunter, Rules Auditor, optional Architect). The invoking agent triages the diff by file path into impacted modules and risk surfaces, then spawns reviewers scaled to the change. Each reviewer self-primes via /prime, verifies any API/library claim via Context7 (mandatory — unverified claims are auto-discarded), and reports an intent verdict against progress.md before its findings. Catches bugs, security issues, CLAUDE.md compliance, and test-coverage gaps. Skip for trivial typos/formatting. Use after substantive implementation work, or when the Stop hook requests it. Also invocable manually with /review-work.
user_invocable: true
---

# Review Work — Automated Code Review

Review uncommitted code changes using **Claude sub-agents** as independent reviewers. The invoking agent (you) triages the diff and decides who reviews; reviewers self-prime via `/prime`, verify API/library claims via Context7, and report against `progress.md` intent.

This skill is run **by an AI**, not by a human — use judgment about the change you just made. Don't apply a fixed rubric mechanically. Zero external dependencies: reviewers are Claude sub-agents.

## Process

### Step 1: Capture the Diff (+ Tests)

Run these and save the output:

```bash
git diff --stat HEAD
```

```bash
git diff HEAD
```

`git diff HEAD` captures **uncommitted** work — the normal pre-commit flow. If the work was already committed (e.g. direct-to-`main`), review the last commit instead: `git diff HEAD~1 HEAD` (or `git show HEAD`).

If the project has a test command configured and relevant source changed, run it and capture the output:

```bash
# Use whatever test/build command is appropriate for this project's stack.
# e.g. npm test · pytest · cargo test · go test ./... · the test_command in
# hooks/config/pipeline.json if set.
```

Test/build failures are the #1 finding for every reviewer — include the failure output in each reviewer's prompt verbatim.

### Step 2: Triage

Look at the changed file paths and produce two lists.

**Impacted modules** — by default the whole project is one scope (one project per repo). Only split into modules/components when the diff clearly spans distinct top-level areas (e.g. `api/` vs `web/`, `backend/` vs `frontend/`). If it's all one area, that's a single scope — don't manufacture splits.

**Risk surfaces** — flag the presence of any of these generic surfaces. For each one that fires, inject the matching focus-area line into reviewer prompts in Step 4:

| Surface | Inject this focus-area line |
|---|---|
| Authentication / authorization | "Auth code touched — check for privilege escalation, missing access checks, and tokens/sessions handled correctly." |
| Database / schema migration | "Schema migration touched — check locking, backfills, NOT NULL on existing rows, and that access rules/constraints are preserved." |
| Configuration / secrets | "Config or secrets touched — confirm no secrets are hardcoded or logged, and environment-specific values aren't baked into source." |
| Dependency manifest | "Dependency manifest changed — confirm new deps are pinned, sourced legitimately, and not duplicating existing functionality." |
| Critical-path / user-facing flow | "Critical-path or user-facing flow touched — check error handling, input validation at boundaries, and that the happy path plus failure modes are covered." |

Omit the focus-areas section entirely if no surfaces fire.

### Step 3: Decide Reviewers — Judgment Rubric

**Skip the skill entirely** when the change is genuinely trivial:
- Comment-only / formatting / typo-only
- Single-line fix with no logic or contract effect
- Pure doc edits with no code references

If you skip, tell the user once: "Change is trivial, skipping review." Then continue.

For non-trivial changes, scale reviewers to the diff:

- **Under ~50 lines changed → one reviewer** with the combined Bug Hunter + Rules Auditor checklist (Step 4, single-reviewer template).
- **~50+ lines, or 2+ modules → parallel specialists**: a **Bug Hunter** (correctness + security) and a **Rules Auditor** (project rules + tests). When the diff splits into distinct modules, give each specialist the scope note for the modules it covers.

**Add an OPTIONAL Architect reviewer** when ANY of these is true:
- Changes span 2+ modules/components
- New abstraction or API contract introduced (not just a config tweak)
- A refactor / migration is left unfinished, or files were renamed/moved
- The diff shows scope creep — more than the active task called for

Most changes need 1 reviewer. Larger or multi-module changes get 2. The Architect appears only when the change is design-significant — don't pre-spawn it.

### Step 4: Spawn Reviewers (Parallel, Single Message)

Use the **Agent tool** with `subagent_type: "Explore"` (read-only). Send all reviewers in a **single message** so they run in parallel. Inline the role — no custom sub-agent files needed.

Every reviewer prompt includes these shared blocks. Define them once, paste into each template:

```
## Required reading (self-prime)
Before reviewing, run /prime — read .claude/commands/prime.md and follow its
file-loading instructions to load this project's core docs (spec,
project-structure, progress). Skip the acknowledgement step — load the files,
then review.

## The diff
{full `git diff HEAD` output}

## Test results
{Step 1 test/build output, or "n/a — no testable files in this diff"}

## Focus areas flagged by triage
{relevant lines from the Step 2 catalogue; omit this section if none fired}

## Mandatory verification (Context7)
If you flag a finding about an API signature, library usage, deprecation, or
SDK version behavior, you MUST first call the Context7 query-docs tool to
verify it. If that tool isn't directly callable, load it via ToolSearch first
(`select:mcp__context7__query-docs`) — don't skip verification just because the
tool wasn't preloaded. Tag every finding:
- [verified]   — Context7 confirmed the issue.
- [unverified] — you couldn't or didn't check. AUTO-DISCARDED by the judge.
                 Don't bother reporting these.
- [n/a]        — finding is not an API/library claim (most bugs and rules).

## Intent verification (required, output FIRST)
Before your findings, output exactly one line:

    INTENT: [yes | partial | no | n/a] — <one-line reason referencing progress.md>

- yes     — diff fulfills the active task in docs/ai-context/progress.md.
- partial — fulfills part of it, or fulfills it but adds unrelated changes (scope creep).
- no      — diff doesn't match anything in progress.md's active scope.
- n/a     — there is no progress.md, or no active task to verify against.

## Output format
INTENT line first, then one finding per line:

    [high|medium|low] [verified|unverified|n/a] path/to/file:line — Description. Reason: <why this is a problem>.

Check ONLY for real issues. Don't nitpick style, naming, or formatting unless
it causes a bug. If a category is clean, omit it. Don't invent issues to seem
thorough — only report what you can point to in the diff.
```

---

#### Template: Single Reviewer (small diffs)

```
You are a code reviewer for an uncommitted-diff code review. Cover both
correctness/security AND project-rule/test compliance.

{shared blocks}

## Checklist
**BUGS** — Logic errors, null/undefined handling, off-by-one, race conditions,
async/await mistakes, state-machine violations, wrong return types, unreachable
code, missing error handling, incorrect boolean logic.

**SECURITY** — Secrets or PII logged or exposed, missing input validation at
system boundaries, internals leaked in error messages, hardcoded secrets,
injection vulnerabilities, broken access checks.

**PROJECT RULES** — Violations of the loaded CLAUDE.md and ai-context docs:
architecture decisions, coding conventions, wrong storage/transport layer, any
documented project-specific constraint.

**TESTS** — If this touches shared modules or critical paths, do corresponding
tests exist? Are assertions structural rather than exact-string matches?
```

---

#### Template: Bug Hunter (correctness + security)

```
You are the Bug Hunter for an uncommitted-diff code review. Your ONLY job is
logic errors and security vulnerabilities. Ignore style, naming, and project
rules — the Rules Auditor handles those.

{shared blocks}

## Checklist
**BUGS** — Logic errors, null/undefined handling, off-by-one, race conditions,
async/await mistakes, state-machine violations, wrong return types, unreachable
code, missing error handling, incorrect boolean logic.

**SECURITY** — Secrets or PII logged or exposed, missing input validation at
system boundaries, internals leaked in error messages, hardcoded secrets,
injection vulnerabilities, unsafe deserialization, broken access checks.
```

---

#### Template: Rules Auditor (project rules + test coverage)

```
You are the Rules Auditor for an uncommitted-diff code review. Your ONLY job is
compliance with this project's rules and test coverage. Ignore general
correctness and security — the Bug Hunter handles those.

{shared blocks}

## Checklist
**PROJECT RULES** — Violations of the loaded CLAUDE.md and ai-context docs:
architecture decisions, coding conventions, wrong storage/transport layer, any
documented project-specific constraint.

**TESTS** — If this touches shared modules or critical paths, do corresponding
tests exist? Are assertions structural rather than exact-string matches?
```

---

#### Template: Architect (optional — design-significant changes)

```
You are the Architect reviewer for an uncommitted-diff code review. You look at
the diff AS A WHOLE — design coherence, structural soundness, invariants. You do
NOT report line-level bugs or style; the other reviewers handle that.

{shared blocks}

## What to check
- **Premature abstraction** — a new abstraction wrapping one caller, or where a
  few inline lines would have been clearer.
- **Half-finished migrations** — files renamed inconsistently, removed code
  still referenced, dual code paths left after a rewrite.
- **Cross-file invariants** — type renames, signature/contract changes: are all
  call sites updated?
- **Cross-module impact** — when a shared module changes, do its consumers still
  hold conceptually? Are public APIs preserved, or the break noted?
- **Dead code** — branches, parameters, or files no longer reachable.
- **Scope creep** — does the diff do more than progress.md's active task called
  for? Refactor mixed into feature work?

Architect findings tend to be MEDIUM/HIGH because they're structural. Be
precise — point to specific files and behaviors, not vibes.
```

### Step 5: Judge Findings

Combine output from all reviewers and evaluate each finding. Reviewers have fresh eyes but lack your conversation context — they don't know WHY you made certain choices.

**Auto-discard unconditionally:**
- Findings tagged `[unverified]` about API/library/SDK claims. Context7 is mandatory — no verification, no finding.

**For everything else:**

| Verdict | Action |
|---------|--------|
| Valid (high/medium) — real issue, agreed | Fix it now |
| Valid (low) — real but minor | Note to user, don't fix unless asked |
| False positive — reviewer misread context or flagged an intentional choice | Reject with a one-line reason |

**Lead with INTENT** if any reviewer reported `partial` or `no` — that's the headline, not the line findings. Code can be locally clean but solving the wrong problem.

### Step 6: Output to User

```
## Code Review Results

Reviewers: <list, e.g. "Bug Hunter + Rules Auditor (parallel)" or "single reviewer">
Modules touched: <list, or "whole project">
Tests: <pass | fail | n/a>
**Intent: <yes | partial | no | n/a>** — <one-line reason>

### Blockers
- [high] file:line — <description>. **Action:** Fixed | Rejected (reason) | Noted

### Mediums
- [med] file:line — <description>. **Action:** …

### Lows
<N findings — expand if you want details>
```

If everything is clean: a single line — "No blockers. N low-severity items (expand if interested). Intent: <verdict>."

## Important Rules

1. **Never skip review for non-trivial work.** Self-review is not review.
2. **Trivial means trivial.** Comments, formatting, typos, no-logic-effect single-line fixes. Anything that changes behavior is non-trivial.
3. **Never blindly accept findings.** Reviewers can hallucinate file paths, misread logic, or flag intentional choices. You're the judge.
4. **Auto-discard `[unverified]` API/library findings.** Context7 is mandatory — no verification, no finding. Don't relax this.
5. **Lead with INTENT.** A diff that's clean but off-target is worse than a diff with fixable bugs.
6. **Reviewers are read-only.** Use `subagent_type: "Explore"`. They never edit code — only the judge (you) applies fixes.
7. **Test failures dominate.** If tests failed, that's finding #1; everything else is secondary.
8. **Don't pre-spawn the Architect.** Use the rubric — most changes don't need it.
9. **Spawn in parallel.** Multiple reviewers → single message with multiple Agent calls.
</content>
</invoke>
