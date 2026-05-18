---
name: second-opinion
description: Get a second opinion from Google's Gemini Pro via the locally installed Gemini CLI (defaults to gemini-3.1-pro-preview; override with the CLAUDE_SECOND_OPINION_MODEL env var). Use this skill when in Plan Mode for large or critical tasks, when stuck on a debugging dead end, when facing architecture trade-offs, for subtle edge cases in code review, or any situation where an independent perspective would add value. Also use when the user explicitly asks for a "second opinion", "ask Gemini", "another perspective", or "cross-check this". Reports unavailability rather than falling back to a weaker model.
user_invocable: false
---

# Second Opinion — Gemini 3.1 Pro Preview

Get an independent second opinion from Google's Gemini 3.1 Pro Preview. This model has a completely different architecture and training, making it genuinely useful for catching blind spots, validating reasoning on edge cases, or surfacing trade-offs you might miss.

Gemini has full read access to the project — it can read files, grep code, and explore the codebase. Its project instructions (GEMINI.md) tell it to prime itself on the key docs before answering. You provide the specific question and any focused context; Gemini handles the rest.

## When to Use

- Architecture decisions with real trade-offs
- Debugging where you've been going in circles
- Code review on tricky logic or subtle edge cases
- Validating your reasoning before the user acts on it
- When the user explicitly asks for a second opinion

Don't use this for routine tasks — every call takes 10-60 seconds and has capacity limits. Reserve it for decisions where being wrong has real consequences.

## Model selection

Pinned to `gemini-3.1-pro-preview` by default for quality (smaller models give weaker second opinions; not worth the false confidence they create).

When Google deprecates the preview pin — preview models rotate fast — override per-session or globally:

```bash
export CLAUDE_SECOND_OPINION_MODEL=gemini-3.2-pro   # or whatever the current Pro-tier model is
```

Every invocation below uses the bash pattern `${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}` — the env var wins if set, otherwise the pinned default.

Do **not** fall back to a smaller/older model when the pin breaks. Report unavailability and continue with Claude-only analysis.

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
gemini -m "${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}" -p '<your question here>' -o text
```

**With context piped via stdin** (for code snippets, diffs, or focused excerpts — use when context is scattered or you want to focus attention on specific sections):

```bash
gemini -m "${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}" -p '<your question here>' -o text <<'CONTEXT_EOF'
<relevant code, diff, or context here>
CONTEXT_EOF
```

The Bash tool captures all output (stdout + stderr) directly — no file redirects needed. Gemini's stderr noise (Loading, Registering, Scheduling, etc.) appears in the output but is easily identified and ignored.

Output markers that mean Gemini did NOT answer:

- **Capacity exhausted (transient):** `MODEL_CAPACITY_EXHAUSTED`, `No capacity available`, `code.*429`. Retry later or proceed without second opinion.
- **Model deprecated (permanent):** `model not found`, `MODEL_NOT_FOUND`, `unknown model`, `model_id_invalid`, or `404` paired with the model name. The pinned model is dead — see the unavailable-block below.

**Required flags — no exceptions:**

| Flag | Why |
|------|-----|
| `-m "${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}"` | Pro-tier model required; env var lets users self-rescue when the pin breaks |
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
gemini -m "${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}" -r latest -p '<your follow-up question>' -o text
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

**If Gemini is unavailable — capacity exhausted / 429:**

> Gemini Pro is currently at capacity. No fallback to a weaker model — only Pro-tier is capable enough for meaningful second opinions. Proceeding with my own analysis only.

Do NOT retry with a different model. Do NOT silently fall back. Report unavailability and continue with your own reasoning.

**If the model is deprecated / not found** (the pinned `gemini-3.1-pro-preview` was rotated out by Google):

> The pinned model `gemini-3.1-pro-preview` is no longer available. Set `CLAUDE_SECOND_OPINION_MODEL` to a current Gemini Pro-tier model and re-run (check `gemini --list-models` for current options). Proceeding without second opinion for this turn.

Tell the user clearly — this isn't a transient failure; the skill needs an env var update or an upstream patch to keep working.

**If there's another error**, show the filtered stderr and continue with your own reasoning.

## Important Rules

1. **Never fall back to a lesser model.** Gemini Pro-tier (`gemini-3.1-pro-preview` by default, or whatever `CLAUDE_SECOND_OPINION_MODEL` is set to) or nothing. A weaker model's opinion isn't worth the false confidence it creates.
2. **Don't over-use.** This is for genuinely tricky decisions, not routine coding questions you can answer confidently yourself.
3. **Shell quoting matters.** For prompts containing single quotes, escape with `'\''`. For very complex prompts, use stdin heredoc (see Step 2).
4. **Command must start with `gemini`** to match the `Bash(gemini:*)` allow rule. Never wrap in `$()` or redirect to `/tmp/`.
