# Prime Command

Load core context for the project before working on it. **Default is a LIGHT prime** (~4–6k tokens: spec TOC + opening invariants + structure Map + task-relevant spec sections). `--full` loads the entire docs — reserve for design/architecture/spec-review sessions where broad context genuinely pays.

**Usage:** `/prime [--full] [-p] [--deploy] [module] [task]`

## Routing

Parse `$ARGUMENTS` as whitespace-separated tokens:
1. **Flags** (any order, anywhere in the arguments; strip each match from the token list):
   - `--full` (case-insensitive) → `full_mode = true`
   - `-p` or `--progress` (case-insensitive) → `progress_mode = true`
   - `--deploy` (case-insensitive) → `deploy_mode = true`
2. **Module** *(optional)*: if the first remaining token matches a row in the Module Map below, it scopes the prime to that module; strip it. If no token matches a row, there is no module — default to the **whole project** and treat all remaining tokens as the task.
3. **Task**: remaining tokens are the user's task (if any).

So `/prime`, `/prime fix the login bug`, `/prime --deploy`, and `/prime api --full add rate limiting` are all valid.

**Why light is the default:** loading a full spec for a scoped task dilutes attention on the relevant parts and re-processes that bulk on every turn. Specs with clean `## ` headings give cheap, targeted section reads at a fraction of the cost. `--full` preserves whole-picture loading for sessions that need it.

**Why `--deploy` exists:** `deployment-infrastructure.md` is operational reference (accounts, secrets, hosting, CI/CD) — stable and often large. Loading it on every routine `/prime` wastes context. Read it only when actively touching deploy/infra/CI work.

**Why `-p` exists:** `progress.md` is live roadmap / build-state — useful when resuming or planning, often noise for a scoped one-off task. Opt-in: loaded only with `-p` (alias `--progress`). By default, just note that it exists.

**Important:** Paths below are written as plain text (not `@`-references) on purpose — the harness auto-expands every `@`-mention in a slash-command body before routing runs, which would unconditionally read every listed file (and every module's docs) and defeat both the conditional `--deploy` load and module scoping.

## Module Map (optional)

This kit assumes **one project per repo**. Most repos need no module routing — the default (whole project) is correct, and the table below stays empty. If your project has distinct subsystems with their own spec sections or doc sets, add rows so `/prime <module>` can scope the prime by file path. Keep it generic; a module is just a named region of the codebase.

| Module | Spec / doc focus | Path hint |
|---|---|---|
<!-- e.g. | api | docs/ai-context/spec.md → "## API" section | src/api/ | -->
<!-- e.g. | web | docs/ai-context/spec.md → "## Frontend" section | src/web/ | -->

If a module token is given but matches **no row**, it is treated as task text (default whole-project prime), unless you prefer strict matching — in that case print the Usage line and stop instead of guessing.

## Light Prime (default)

For the selected scope (whole project, or a module if one was matched):

1. **Spec TOC:** `grep -n '^## ' docs/ai-context/spec.md` — keep the line numbers; they drive targeted section reads now and for the rest of the session.
2. **Spec opening:** Read the spec from the top through the end of its first framing/invariants section(s) (use the TOC line numbers — e.g. an "Overview", "Architecture", or "Invariants" section; typically < 80 lines).
3. **Structure Map:** Read the `## Map` section of `docs/ai-context/project-structure.md` (stop at the next `##` header — use `grep -n '^## '` for offsets). If the file has no Map section, read its first 40 lines instead.
4. *(only if `progress_mode`)* Read `docs/ai-context/progress.md` in full.
5. *(only if `deploy_mode`)* Read `docs/ai-context/deployment-infrastructure.md` in full.
6. **Task-aware deepening:** if a task was given, pick from the TOC the spec section(s) governing the task's domain (and the matched module's section, if any) and read just those (Read with offset/limit from the grep line numbers). Torn between two sections → read both; sections are cheap, the full spec is not.

**Standing rule for the rest of the session:** before designing or changing a subsystem whose spec section you haven't read, read that section first — the TOC is your map. Never assert a design fact about an unread section from memory. If mid-session work turns architectural (cross-cutting, multi-surface), escalate yourself to the full spec.

## Full Prime (`--full`)

Read these in parallel via a single message with multiple Read tool calls:
1. *(only if `progress_mode`)* `docs/ai-context/progress.md`
2. `docs/ai-context/spec.md` (entire)
3. `docs/ai-context/project-structure.md` (entire)
4. *(only if `deploy_mode`)* `docs/ai-context/deployment-infrastructure.md`

## Response

After reading, confirm:
- **Scope:** whole project (or which module), and **light vs full** prime.
- **Sections loaded:** which spec sections were read, and that the TOC is in hand for on-demand section reads.
- **Flag state:** whether `--deploy` was active (or skipped — note infra context is available via `--deploy` if wanted), and whether `-p` was active. If `-p` was skipped, mention `progress.md` (roadmap / live build-state) wasn't loaded and `-p` will load it.
- **Current status** and any immediate priorities or blockers visible from what was read.

Then process the user's task portion of `$ARGUMENTS` if any. If no task was given, confirm you're primed and ready: $ARGUMENTS
