---
name: review-work
description: Review uncommitted code changes using parallel Claude sub-agents with specialized roles (Bug Hunter, Rules Auditor). Spawns multiple focused reviewers for large diffs (50+ lines), single reviewer for smaller changes. Checks for bugs, security issues, CLAUDE.md compliance, and test coverage gaps. Use after completing substantial implementation work, or when the Stop hook requests it. Also invocable manually with /review-work.
user_invocable: true
---

# Review Work — Automated Code Review

Review uncommitted code changes using **Claude sub-agents** as independent reviewers. For large diffs, spawns **parallel specialist agents** with different roles for deeper, faster coverage.

## Process

### Step 1: Capture the Diff

Run these commands and save the output:

```bash
git diff --stat HEAD
```

```bash
git diff HEAD
```

If the project has a test command configured and relevant source files changed, run the tests:

```bash
# Use whatever test command is appropriate for this project
# Examples: npm test, deno task test:unit, pytest, cargo test
```

If tests fail, include the failure output in the review prompt — test failures are high-priority findings.

### Step 2: Determine Scale

Count the total lines changed from `git diff --stat HEAD` (the summary line).

- **Under 50 lines changed → Single reviewer** (Step 3A)
- **50+ lines changed → Parallel specialist reviewers** (Step 3B)

### Step 3A: Single Reviewer (< 50 lines)

Use the **Agent tool** with `subagent_type: "Explore"` to spawn one read-only reviewer.

**The sub-agent prompt must include:**

1. The full `git diff` output from Step 1
2. The test results (if tests were run)
3. The full review checklist (all categories from both specialists below, combined)
4. The required output format
5. Instruction to read `CLAUDE.md` for project rules

Use the combined checklist:

```
You are a code reviewer. Read CLAUDE.md for project rules, then review this diff.

Check ONLY for real issues. Do not nitpick style, naming, or formatting unless it causes a bug. If no issues found in a category, say "No issues found." Do not invent issues to seem thorough.

**BUGS** — Logic errors, null/nil/undefined handling, off-by-one, missing error handling, race conditions, unreachable code, wrong return types, state machine violations, async/await mistakes

**SECURITY** — Secrets or PII logged or exposed, missing input validation at system boundaries, system internals leaked in error messages, hardcoded secrets, injection vulnerabilities

**COMPLIANCE** — Violations of rules defined in CLAUDE.md. Check the project's specific rules and architecture decisions.

**TESTS** — Do these changes touch shared modules or critical paths? If so, do corresponding tests exist?

For each finding:
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.
```

Note who reviewed: "Reviewed by: Claude (single reviewer)".

### Step 3B: Parallel Specialist Reviewers (50+ lines)

Spawn **two** Agent tool calls in a **single message** (parallel execution), both with `subagent_type: "Explore"`.

Each agent gets the same diff and test output, but a **different role and focused checklist**.

---

**Agent 1 — "Bug Hunter"** (correctness + security)

```
You are a **Bug Hunter** reviewing code changes. Your ONLY job is finding logic errors and security vulnerabilities. Ignore style, naming, and compliance rules — another reviewer handles those.

[Include: full git diff output, test results if any]

Read CLAUDE.md for project context, then review the diff against ONLY these categories:

**BUGS** — Logic errors, null/nil/undefined handling, off-by-one, missing error handling, race conditions, unreachable code, wrong return types, state machine violations, async/await mistakes, incorrect boolean logic

**SECURITY** — Secrets or PII logged or exposed, missing input validation at system boundaries, system internals leaked in error messages, hardcoded secrets, injection vulnerabilities, unsafe deserialization, credential exposure

## Output Format
For each finding:
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.

If no issues found in a category, write "No issues found."
Do not invent issues to seem thorough. Only report what you can point to in the diff.
```

---

**Agent 2 — "Rules Auditor"** (project rules + test coverage)

```
You are a **Rules Auditor** reviewing code changes. Your ONLY job is checking compliance with this project's specific rules and test coverage. Ignore general code quality and security — another reviewer handles those.

[Include: full git diff output, test results if any]

Read CLAUDE.md for project rules and architecture decisions, then review the diff against ONLY these categories:

**COMPLIANCE** — Violations of rules defined in CLAUDE.md. Check architecture decisions, coding conventions, and any project-specific constraints documented there.

**TESTS** — Do these changes touch shared modules or critical paths? If so, do corresponding tests exist? Are test assertions structural (not exact string matches)?

## Output Format
For each finding:
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.

If no issues found in a category, write "No issues found."
Do not invent issues to seem thorough. Only report what you can point to in the diff.
```

---

Note who reviewed: "Reviewed by: Claude (Bug Hunter + Rules Auditor, parallel)".

### Step 4: Evaluate Findings (The Judge)

Combine findings from all reviewers and **critically evaluate each one**. The reviewers have fresh eyes but lack your conversation context — they don't know WHY you made certain choices.

For each finding:

| Verdict | When | Action |
|---------|------|--------|
| **Valid (high/medium)** | The reasoning is sound and you agree it's a real issue | Fix it now |
| **Valid (low)** | Real issue but minor | Note it to the user, don't fix unless asked |
| **False positive** | Reviewer misunderstood context, or the "issue" is intentional | Reject with a one-line explanation |

**Present a summary to the user:**

```
## Code Review Results

Reviewed by: Claude (Bug Hunter + Rules Auditor, parallel) — or: Claude (single reviewer)
Reviewed X files, Y lines changed.

| # | Verdict | Category | File | Issue | Action |
|---|---------|----------|------|-------|--------|
| 1 | Fixed | BUG | file.ts:42 | Null check missing | Fixed |
| 2 | Rejected | COMPLIANCE | config.ts:10 | Not a real violation | False positive |
| 3 | Noted | TESTS | util.ts | No unit tests | Deferred |
```

If all findings are false positives or no issues found, say so briefly and move on.

## Important Rules

1. **Never skip the review.** Don't self-review and claim "looks fine."
2. **Never blindly accept all findings.** Reviewers can hallucinate file paths, misread logic, or flag intentional choices.
3. **Include test output.** If unit tests were run and failed, that's the #1 finding — everything else is secondary.
4. **Parallel when warranted.** Only spawn multiple agents for 50+ line changes. Small diffs get one focused reviewer.
5. **Agents are read-only.** Use `subagent_type: "Explore"` — reviewers must never edit code. You (the judge) make fixes.
