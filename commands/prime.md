# Prime Command

Load core context for the project.

**Usage:** `/prime [--deploy] [task]`

## Routing

Parse `$ARGUMENTS` as whitespace-separated tokens:
1. **Flag:** if any token equals `--deploy` (case-insensitive), set `deploy_mode = true` and remove it from the token list.
2. **Task:** remaining tokens are the user's task (if any).

`--deploy` may appear anywhere in the arguments (e.g. both `/prime --deploy` and `/prime fix login bug --deploy` are valid).

**Why the flag exists:** `deployment-infrastructure.md` is operational reference (accounts, secrets, hosting, CI/CD) — stable and often large. Loading it on every routine `/prime` wastes context. Read it only when actively touching deploy/infra/CI work.

**Important:** Paths below are written as plain text (not `@`-references) on purpose — the harness auto-expands every `@`-mention in a slash-command body before routing runs, which would unconditionally read every listed file and defeat the conditional `--deploy` load.

## Files to load (parallel — single message, multiple Read calls)

1. `docs/ai-context/spec.md`
2. `docs/ai-context/project-structure.md`
3. `docs/ai-context/progress.md`
4. *(only if `deploy_mode`)* `docs/ai-context/deployment-infrastructure.md`

## Response

After reading, briefly confirm:
- What this project is
- Current status and recent progress
- Immediate priorities or blockers
- Whether `--deploy` was active (or note it was skipped if the user might want infra context)

Then process the user's request: $ARGUMENTS
