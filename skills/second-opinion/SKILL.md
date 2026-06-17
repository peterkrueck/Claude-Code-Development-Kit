---
name: second-opinion
description: Get a second opinion from OpenAI's Codex CLI running locally. Use this skill when in Plan Mode for large or critical tasks, when stuck on a debugging dead end, when facing architecture trade-offs, for subtle edge cases in code review, or any situation where an independent perspective would add value. Also use when the user explicitly asks for a "second opinion", "another perspective", "cross-check this", "ask Codex", or "ask GPT". This is the DEFAULT second-opinion engine — Codex runs a completely different model architecture from Claude, so it catches blind spots Claude shares with itself. For a Gemini second opinion specifically, the user says "ask Gemini" (separate second-opinion-gemini skill); "ask both" runs this skill and that one, then synthesizes.
user_invocable: false
---

# Second Opinion — OpenAI Codex

Get an independent second opinion from OpenAI's Codex CLI. It uses Codex's default model — a completely different architecture and training run from Claude, which makes it genuinely useful for catching blind spots, validating reasoning on edge cases, or surfacing trade-offs Claude would miss (Claude's own errors tend to be invisible to Claude).

Codex has full read access to the project — it can read files, grep code, and explore the codebase. Its project instructions (`AGENTS.md` at the repository root) tell it to prime itself on the key docs before answering. You provide the specific question and any focused context; Codex handles the rest.

This is the **default** second-opinion engine. For a Gemini second opinion specifically, the user invokes the separate `second-opinion-gemini` skill ("ask Gemini"). When the user says "ask both", run this skill and that one, then synthesize all three views (yours + Codex + Gemini).

## When to Use

- Architecture decisions with real trade-offs
- Debugging where you've been going in circles
- Code review on tricky logic or subtle edge cases
- Validating your reasoning before the user acts on it
- When the user explicitly asks for a second opinion

Don't use this for routine tasks — every call takes 10-60+ seconds and consumes ChatGPT-plan quota. Reserve it for decisions where being wrong has real consequences.

## Process

### Step 1: Prepare the Prompt

Codex has NO access to your conversation history, but it CAN read project files. Structure your prompt as:

1. **The question** — what exactly you want Codex to weigh in on
2. **Your current thinking** (recommended) — share your position so Codex can challenge it
3. **Relevant area** (optional) — if the project has distinct modules or components, state which one this is about so Codex primes on the right docs. Default is the whole project; only narrow this when it helps.
4. **Specific context** (if needed) — pipe code snippets or diffs via stdin when the relevant code is scattered or you want to focus attention on specific sections

For questions about existing project code, you can simply reference file paths — Codex will read them itself.

### Step 2: Invoke Codex

In the commands below, `<repo-root>` is the root of your repository — the directory containing `AGENTS.md` (and your `.git` directory). Use an absolute path so `AGENTS.md` and the project docs are discoverable regardless of the current working directory.

**CRITICAL: Permission-free invocation pattern.** The command MUST start with `codex` (matches the `Bash(codex:*)` allow rule) and MUST NOT use `$()` command substitution or `/tmp/` file redirects — both trigger permission prompts.

**Standard call** (Codex reads project files itself — preferred):

```bash
codex exec -s read-only -C <repo-root> '<your question here>' < /dev/null
```

**With context piped via stdin** (for code snippets, diffs, or focused excerpts — Codex appends piped stdin as a `<stdin>` block):

```bash
codex exec -s read-only -C <repo-root> '<your question here>' <<'CONTEXT_EOF'
<relevant code, diff, or context here>
CONTEXT_EOF
```

**Required flags / arguments — no exceptions:**

| Flag | Why |
|------|-----|
| `exec` | Non-interactive headless mode. Tool calls are auto-approved in this mode. |
| `-s read-only` | Sandbox the consultant to read-only — it explores files but cannot modify anything. Matches its `AGENTS.md` "do not modify" instruction with a hard guarantee. |
| `-C <repo-root>` | Working root = repository root, so `AGENTS.md` and the project docs are discoverable regardless of cwd. |
| `< /dev/null` (standard call) | Close stdin so Codex doesn't block waiting on it when no context is piped. |

**DO NOT pass `-m`.** Leave the model unset so Codex uses its own default. Pinning a slug goes stale, and the `-codex` model family (e.g. `*-codex`) is **rejected on a ChatGPT-account login** — only the chat models work, so leaving it unset is correct. If the default ever resolves to something that is NOT a real GPT chat model, treat the run as unavailable rather than accepting a degraded second opinion (see Important Rules).

**Output shape.** Codex prints a running transcript to stdout: a startup banner, its reasoning, any `exec`/tool calls it makes (e.g. `rg`, file reads), a `tokens used` line, and then **the final answer as the trailing block**. The Bash tool captures everything. The noise is easily identified and ignored — the final agent message is the last paragraph(s) after the `tokens used` line. If the output contains a `429`, `usage limit`, `quota`, or `rate limit` error, treat as unavailable.

Set a **600-second timeout** on the Bash tool call (Codex may need time to read files and reason through complex questions).

**DO NOT use:**
- `$()` command substitution (e.g., `RESPONSE=$(codex ...)`) — triggers a permission prompt
- `/tmp/` file redirects (e.g., `-o /tmp/out.txt` or `2>/tmp/err.txt`) — triggers an "allow access to tmp/" prompt
- Nested heredocs inside `$()` — same issue

### Step 2b: Multi-Turn Discussion (Autonomous)

When the topic warrants debate (architecture, design reviews, trade-off analysis), **run the full multi-turn conversation autonomously** — do NOT ask the user for permission between rounds. Push back on Codex's points, let Codex push back on yours, iterate until you reach consensus or clearly identify the disagreements. Typically 2-4 rounds.

Resume the session instead of starting fresh to preserve conversation history:

```bash
codex -C <repo-root> -s read-only exec resume --last '<your follow-up question>' < /dev/null
```

**Flag order matters on resume.** The `resume` sub-subcommand does NOT accept `-s/--sandbox` or `-C/--cd` (unlike `codex exec`, which does) — passing them *after* `resume` fails with `error: unexpected argument '-s' found`. Put both globals BEFORE the `exec resume` chain (they're root-level flags on `codex` and propagate down), as shown above.

You can also resume a specific session by id: `codex -C <repo-root> -s read-only exec resume <SESSION_ID> '<follow-up>' < /dev/null`. The session id is printed in the startup banner of the first call (`session id: <uuid>`).

**When to use multi-turn:**
- Design reviews or architecture discussions — run the full debate autonomously
- Codex's answer is vague — ask it to be specific about the part that matters
- You want to challenge Codex's reasoning — push back and see if it holds
- The question naturally has layers — e.g., "which approach?" then "what are the migration risks of that one?"

**When NOT to use multi-turn:**
- The first answer was clear and complete — just present it
- You're asking an unrelated question — start a fresh session (omit `resume`)

### Step 3: Present the Result

**If multi-turn:** Present a consolidated synthesis — the key agreements, remaining disagreements, and your joint recommendation. Don't dump each round's raw output; the user wants the conclusion, not the transcript.

**If single-turn:** Present Codex's response, then add your own brief synthesis: where you agree, where you disagree, and what the user should take away from both perspectives. The value is in the synthesis, not just the raw second opinion.

**If Codex is unavailable** (quota / usage limit / 429 / rate limit):

> Codex is currently unavailable (usage limit / rate limited). I won't silently swap in a weaker model. You can say "ask Gemini" for an independent second opinion from a different architecture, or I'll proceed with my own analysis only.

Do NOT silently fall back to a different model within Codex. Report unavailability, offer Gemini as the alternate independent voice, and continue with your own reasoning.

**If there's another error**, show the filtered output and continue with your own reasoning.

## Important Rules

1. **Don't accept a degraded model silently.** The whole value is an independent second architecture. Leaving the model unset (Codex's default chat model) is correct; if the default ever resolves to a non-GPT or a thin/local model, report it rather than presenting it as a meaningful second opinion.
2. **Don't over-use.** This is for genuinely tricky decisions, not routine coding questions you can answer confidently yourself.
3. **Shell quoting matters.** For prompts containing single quotes, escape with `'\''`. For very complex prompts, use the stdin heredoc form (see Step 2).
4. **Command must start with `codex`** to match the `Bash(codex:*)` allow rule. Never wrap in `$()` or redirect to `/tmp/`.
5. **Codex is read-only here.** Always pass `-s read-only`. Never grant it write/`danger-full-access` sandbox modes for a second opinion — it's a consultant, not a builder.
