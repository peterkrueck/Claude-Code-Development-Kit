---
name: review-work
description: Review uncommitted code changes using Gemini CLI (different architecture = independent perspective). Falls back to Claude sub-agent if Gemini is unavailable. Checks for bugs, security issues, CLAUDE.md compliance, and test coverage gaps. Use after completing substantial implementation work, or when the Stop hook requests it.
user_invocable: true
---

# Review Work — Automated Code Review

Review uncommitted code changes using **Gemini** as the primary reviewer (genuinely independent — different model architecture). Falls back to a Claude sub-agent if Gemini is at capacity.

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

### Step 2: Try Gemini Review (Primary)

Send the diff and review checklist to Gemini. Gemini already has project context via `GEMINI.md` (architecture, tech stack, key decisions). The prompt adds the specific review checklist and diff.

**IMPORTANT:** Invocation and error checking MUST be in a **single Bash tool call** — shell variables don't persist across calls.

Write the diff to a temp file first (avoids heredoc quoting issues with code containing backticks, quotes, etc.):

```bash
git diff HEAD > /tmp/gemini-review-diff.txt
```

Then invoke Gemini with the diff piped as stdin context:

```bash
GEMINI_RESPONSE=$(cat /tmp/gemini-review-diff.txt | gemini -p "$(cat <<'PROMPT_EOF'
You are reviewing uncommitted code changes. The git diff is provided via stdin.

Read CLAUDE.md for full project rules, then review the diff against this checklist.

## Review Checklist

Check ONLY for real issues. Do not nitpick style, naming, or formatting unless it causes a bug.

**BUGS** — Logic errors, null/nil/undefined handling, off-by-one, missing error handling, race conditions, unreachable code, wrong return types

**SECURITY** — Secrets or PII logged or exposed, missing input validation, system internals leaked in error messages, hardcoded secrets, injection vulnerabilities

**COMPLIANCE** — Violations of rules defined in CLAUDE.md. Check the project's specific rules and architecture decisions.

**TESTS** — Do these changes touch shared modules or critical paths? If so, do corresponding tests exist?

## Output Format

Return findings in this exact format. If a category has no issues, write "No issues found."

### BUGS
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.

### SECURITY
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.

### COMPLIANCE
- [high|medium|low] `file:line` — Description. **Reason:** Why this is a problem.

### TESTS
- [action needed|note] Description. **Reason:** Why tests are needed here.

### SUMMARY
X issues found (Y high, Z medium, W low). One-sentence overall assessment.
PROMPT_EOF
)" -o text 2>/tmp/gemini-stderr.txt) ; GEMINI_EXIT=$?

if grep -q "MODEL_CAPACITY_EXHAUSTED\|No capacity available\|code.*429" /tmp/gemini-stderr.txt 2>/dev/null; then
  echo "GEMINI_UNAVAILABLE"
elif [ "$GEMINI_EXIT" -ne 0 ]; then
  echo "GEMINI_ERROR"
  cat /tmp/gemini-stderr.txt
else
  echo "$GEMINI_RESPONSE"
fi
```

Set a **600-second timeout** on the Bash tool call.

**If Gemini succeeds:** proceed to Step 4 (Evaluate Findings). Note who reviewed: "Reviewed by: Gemini".

**If Gemini is unavailable (GEMINI_UNAVAILABLE or GEMINI_ERROR):** proceed to Step 3 (Claude fallback).

Clean up temp files after use:
```bash
rm -f /tmp/gemini-review-diff.txt /tmp/gemini-stderr.txt
```

### Step 3: Claude Sub-Agent Fallback

Only use this if Gemini is unavailable. Use the **Agent tool** with `subagent_type: "Explore"` to spawn a read-only reviewer.

**The sub-agent prompt must include:**

1. The full `git diff` output from Step 1
2. The test results (if tests were run)
3. The same review checklist from Step 2
4. The required output format (same as Step 2)

Note who reviewed: "Reviewed by: Claude sub-agent (Gemini unavailable)".

### Step 4: Evaluate Findings (The Judge)

Whether the findings came from Gemini or Claude, **critically evaluate each one**. The reviewer has fresh eyes but lacks your conversation context — it doesn't know WHY you made certain choices.

For each finding:

| Verdict | When | Action |
|---------|------|--------|
| **Valid (high/medium)** | The reasoning is sound and you agree it's a real issue | Fix it now |
| **Valid (low)** | Real issue but minor | Note it to the user, don't fix unless asked |
| **False positive** | Reviewer misunderstood context, or the "issue" is intentional | Reject with a one-line explanation |

**Present a summary to the user:**

```
## Code Review Results

Reviewed by: Gemini (or: Claude sub-agent)
Reviewed X files, Y lines changed.

| # | Verdict | Category | File | Issue | Action |
|---|---------|----------|------|-------|--------|
| 1 | Fixed | BUG | file.ts:42 | Null check missing | Fixed |
| 2 | Rejected | COMPLIANCE | config.ts:10 | Not a real violation | False positive |
| 3 | Noted | TESTS | util.ts | No unit tests | Deferred |
```

If all findings are false positives or no issues found, say so briefly and move on.

## Important Rules

1. **Gemini first, always.** Only fall back to Claude sub-agent on capacity errors. The whole point is an independent architecture reviewing your code.
2. **Never skip the review.** Don't self-review and claim "looks fine."
3. **Never blindly accept all findings.** Reviewers can hallucinate file paths, misread logic, or flag intentional choices.
4. **Include test output.** If unit tests were run and failed, that's the #1 finding — everything else is secondary.
