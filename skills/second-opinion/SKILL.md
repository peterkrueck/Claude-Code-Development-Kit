---
name: second-opinion
description: Get a second opinion from Google's Gemini via the locally installed Gemini CLI. Use this skill when in Plan Mode for large or critical tasks, when stuck on a debugging dead end, when facing architecture trade-offs, for subtle edge cases in code review, or any situation where an independent perspective would add value. Also use when the user explicitly asks for a "second opinion", "ask Gemini", "another perspective", or "cross-check this".
user_invocable: false
---

# Second Opinion — Gemini

Get an independent second opinion from Google's Gemini. This model has a completely different architecture and training, making it genuinely useful for catching blind spots, validating reasoning on edge cases, or surfacing trade-offs you might miss.

Gemini has full read access to the project — it can read files, grep code, and explore the codebase. Its project instructions (GEMINI.md) tell it to prime itself on the key docs before answering. You provide the specific question and any focused context; Gemini handles the rest.

## When to Use

- Architecture decisions with real trade-offs
- Debugging where you've been going in circles
- Code review on tricky logic or subtle edge cases
- Validating your reasoning before the user acts on it
- When the user explicitly asks for a second opinion

Don't use this for routine tasks — every call takes 10-60 seconds and has capacity limits. Reserve it for decisions where being wrong has real consequences.

## Process

### Step 1: Prepare the Prompt

Gemini has NO access to your conversation history, but it CAN read project files. Structure your prompt as:

1. **The question** — what exactly you want Gemini to weigh in on
2. **Your current thinking** (recommended) — share your position so Gemini can challenge it
3. **Specific context** (if needed) — pipe code snippets or diffs via stdin when the relevant code is scattered or you want to focus attention on specific sections

For questions about existing project code, you can simply reference file paths — Gemini will read them itself.

### Step 2: Invoke Gemini and Check for Errors

**IMPORTANT:** The invocation and error checking MUST be in a **single Bash tool call**. Shell variables (`GEMINI_RESPONSE`, exit codes) do not persist across separate Bash tool calls.

**With context piped via stdin** (for code snippets, diffs, or focused excerpts):

```bash
GEMINI_RESPONSE=$(cat <<'CONTEXT_EOF' | gemini -p "$(cat <<'PROMPT_EOF'
<your question here>
PROMPT_EOF
)" -o text 2>/tmp/gemini-stderr.txt
<relevant code, diff, or context here>
CONTEXT_EOF
) ; GEMINI_EXIT=$?

if grep -q "MODEL_CAPACITY_EXHAUSTED\|No capacity available\|code.*429" /tmp/gemini-stderr.txt 2>/dev/null; then
  echo "GEMINI_UNAVAILABLE"
elif [ "$GEMINI_EXIT" -ne 0 ]; then
  echo "GEMINI_ERROR"
  grep -v "^Loading\|^Registering\|^Server '\|^Scheduling\|^Executing\|^Coalescing\|^MCP\|^Loaded\|^Keychain\|^Using FileKeychain\|^Attempt\|^YOLO\|^$" /tmp/gemini-stderr.txt
else
  echo "$GEMINI_RESPONSE"
fi
```

**Without stdin context** (Gemini reads files itself — preferred when you can reference file paths):

```bash
GEMINI_RESPONSE=$(gemini -p '<your question here>' -o text 2>/tmp/gemini-stderr.txt) ; GEMINI_EXIT=$?

if grep -q "MODEL_CAPACITY_EXHAUSTED\|No capacity available\|code.*429" /tmp/gemini-stderr.txt 2>/dev/null; then
  echo "GEMINI_UNAVAILABLE"
elif [ "$GEMINI_EXIT" -ne 0 ]; then
  echo "GEMINI_ERROR"
  grep -v "^Loading\|^Registering\|^Server '\|^Scheduling\|^Executing\|^Coalescing\|^MCP\|^Loaded\|^Keychain\|^Using FileKeychain\|^Attempt\|^YOLO\|^$" /tmp/gemini-stderr.txt
else
  echo "$GEMINI_RESPONSE"
fi
```

**Required flags — no exceptions:**

| Flag | Why |
|------|-----|
| `-p` | Non-interactive headless mode. Tool calls are auto-approved in this mode |
| `-o text` | Clean text output, no JSON wrapper noise |
| `2>/tmp/gemini-stderr.txt` | Capture stderr separately for error detection |

Set a **600-second timeout** on the Bash tool call (Gemini may need time to read files and reason).

### Step 2b: Follow Up (Multi-Turn)

If Gemini's initial response is unclear, incomplete, or you want to drill deeper, **resume the session** instead of starting fresh. This preserves the full conversation history so you don't need to re-explain context.

```bash
GEMINI_RESPONSE=$(gemini -r latest -p '<your follow-up question>' -o text 2>/tmp/gemini-stderr.txt) ; GEMINI_EXIT=$?

if grep -q "MODEL_CAPACITY_EXHAUSTED\|No capacity available\|code.*429" /tmp/gemini-stderr.txt 2>/dev/null; then
  echo "GEMINI_UNAVAILABLE"
elif [ "$GEMINI_EXIT" -ne 0 ]; then
  echo "GEMINI_ERROR"
  grep -v "^Loading\|^Registering\|^Server '\|^Scheduling\|^Executing\|^Coalescing\|^MCP\|^Loaded\|^Keychain\|^Using FileKeychain\|^Attempt\|^YOLO\|^$" /tmp/gemini-stderr.txt
else
  echo "$GEMINI_RESPONSE"
fi
```

### Step 3: Present the Result

**If Gemini responded successfully**, present it clearly:

> **Second opinion from Gemini:**
>
> [Gemini's response]

Then add your own brief synthesis: where you agree, where you disagree, and what the user should take away from both perspectives.

**If Gemini is unavailable** (capacity exhausted / 429):

> Gemini is currently at capacity. Proceeding with my own analysis only.

Do NOT retry with a different model. Report unavailability and continue with your own reasoning.

## Important Rules

1. **Don't over-use.** This is for genuinely tricky decisions, not routine coding questions you can answer confidently yourself.
2. **Shell quoting matters.** Use heredocs (as shown above) for prompts containing quotes, backticks, or special characters. Single-quote the heredoc delimiter (`'PROMPT_EOF'`) to prevent variable expansion.
3. **Clean up.** Delete `/tmp/gemini-stderr.txt` after use if it contains any project-specific information.
4. **Don't over-use multi-turn.** Most second opinions need one call. Only resume a session when the follow-up genuinely depends on the prior exchange.
