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

### Step 2: Invoke Gemini

**CRITICAL: Permission-free invocation pattern.** The command MUST start with `gemini` (matches the `Bash(gemini:*)` allow rule) and MUST NOT use `$()` command substitution or `/tmp/` file redirects — both trigger permission prompts.

**Standard call** (Gemini reads project files itself — preferred):

```bash
gemini -p '<your question here>' -o text
```

**With context piped via stdin** (for code snippets, diffs, or focused excerpts — use when context is scattered or you want to focus attention on specific sections):

```bash
gemini -p '<your question here>' -o text <<'CONTEXT_EOF'
<relevant code, diff, or context here>
CONTEXT_EOF
```

The Bash tool captures all output (stdout + stderr) directly — no file redirects needed. Gemini's stderr noise (Loading, Registering, Scheduling, etc.) appears in the output but is easily identified and ignored. If the output contains `MODEL_CAPACITY_EXHAUSTED`, `No capacity available`, or `code.*429`, treat as unavailable.

**Required flags — no exceptions:**

| Flag | Why |
|------|-----|
| `-p` | Non-interactive headless mode. Tool calls are auto-approved in this mode (`-y` is not needed) |
| `-o text` | Clean text output, no JSON wrapper noise |

**DO NOT use:**
- `$()` command substitution (e.g., `GEMINI_RESPONSE=$(gemini ...)`) — triggers "Command contains $() command substitution" permission prompt
- `/tmp/` file redirects (e.g., `2>/tmp/gemini-stderr.txt`) — triggers "allow access to tmp/" permission prompt
- Nested heredocs inside `$()` — same issue

Set a **600-second timeout** on the Bash tool call (Gemini may need time to read files and reason through complex questions).

### Step 2b: Multi-Turn Discussion (Autonomous)

When the topic warrants debate (architecture, design reviews, trade-off analysis), **run the full multi-turn conversation autonomously** — do NOT ask the user for permission between rounds. Push back on Gemini's points, let Gemini push back on yours, iterate until you reach consensus or clearly identify the disagreements. Typically 2-4 rounds.

Resume the session instead of starting fresh to preserve conversation history:

```bash
gemini -r latest -p '<your follow-up question>' -o text
```

You can also resume by session index (`-r 6`) or session ID (`-r <uuid>`). Use `gemini --list-sessions` to see available sessions.

**When to use multi-turn:**
- Design reviews or architecture discussions — run the full debate autonomously
- Gemini's answer is vague — ask it to be specific about the part that matters
- You want to challenge Gemini's reasoning — push back and see if it holds
- The question naturally has layers — e.g., "which approach?" then "what are the migration risks of that one?"

**When NOT to use multi-turn:**
- The first answer was clear and complete — just present it
- You're asking an unrelated question — start a fresh session

### Step 3: Present the Result

**If multi-turn:** Present a consolidated synthesis — the key agreements, remaining disagreements, and your joint recommendation. Don't dump each round's raw output; the user wants the conclusion, not the transcript.

**If single-turn:** Present Gemini's response, then add your own brief synthesis: where you agree, where you disagree, and what the user should take away from both perspectives. The value is in the synthesis, not just the raw second opinion.

**If Gemini is unavailable** (capacity exhausted / 429):

> Gemini is currently at capacity. No fallback to a weaker model — proceeding with my own analysis only.

Do NOT retry with a different model. Do NOT silently fall back. Report unavailability and continue with your own reasoning.

**If there's another error**, show the filtered stderr and continue with your own reasoning.

## Important Rules

1. **Never fall back to a lesser model.** A weaker model's opinion isn't worth the false confidence it creates.
2. **Don't over-use.** This is for genuinely tricky decisions, not routine coding questions you can answer confidently yourself.
3. **Shell quoting matters.** For prompts containing single quotes, escape with `'\''`. For very complex prompts, use stdin heredoc (see Step 2).
4. **Command must start with `gemini`** to match the `Bash(gemini:*)` allow rule. Never wrap in `$()` or redirect to `/tmp/`.
