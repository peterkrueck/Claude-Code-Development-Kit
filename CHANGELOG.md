# Changelog

All notable changes to the Claude Code Development Kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [3.1.0] - 2026-05-18

### Added

- **`/plan-feature` command** — Designed for use inside Plan Mode (Shift+Tab). Encodes the pattern: parallel research sub-agents → state tradeoffs (not just choices) → Context7 first for libraries → `/review-work` before final verification → `/second-opinion` before exiting plan mode. Ports proven workflow from production use.
- **`/prime --deploy` flag** — Optional flag that loads `docs/ai-context/deployment-infrastructure.md` in addition to the three core docs. Deployment infra is stable and often large; loading it on every routine `/prime` wastes context. Includes explicit note explaining why paths are plain text (not `@`-references) — the harness auto-expands `@`-mentions before routing, which would defeat the conditional load.
- **`/second-opinion` model override** — New `CLAUDE_SECOND_OPINION_MODEL` env var lets users self-rescue when Google deprecates the pinned `gemini-3.1-pro-preview` (preview models rotate fast). Every bash invocation now uses the `${CLAUDE_SECOND_OPINION_MODEL:-gemini-3.1-pro-preview}` pattern. Expanded error detection distinguishes capacity-exhausted (transient) from model-deprecated (permanent) failures and tells the user exactly how to recover.
- **Operator Model template sections** — New commented sections in `templates/CLAUDE.md` (§2) and `templates/GEMINI.md` (replaces "Developer Workflow") describing the solo-founder / AI-agent collaboration model: role split, "evaluate by maintenance burden not build effort," boundaries, calibration of recommendations. Especially valuable for AI-agent-driven workflows where "over-engineered for a solo dev" is rarely valid critique.

### Changed

- **`/merge` command — full rewrite for safety, then dual-mode for reach.** Previously auto-invoked `/update-docs`, auto-staged with implicit commit logic, had no clean-tree check, AND required a `git worktree` (regular-branch users couldn't use it at all). New version is **verify + ship, not do-everything cleanup**, and supports both flows:
  - **Pre-flight auto-detects mode** by comparing `git rev-parse --git-dir` to `--git-common-dir`. Equal → standard mode (`git checkout main && git merge ...`). Different → worktree mode (`git -C <main-repo-path> merge ...` + `ExitWorktree`). Steps 1/2/3/6 are mode-independent; Steps 4/5 branch.
  - **Philosophy block** clarifies that doc updates, commits, and tests belong to the work session — `/merge` only verifies and ships.
  - **`$ARGUMENTS` conventions**: `Verified: <context>` (opt-in commit annotation) and `summary: <override>` (skip auto-synthesis of merge message).
  - **Step 1 — mental model**: form understanding from `git diff main` inline (small diffs) or via Explore sub-agent (>200 lines OR >10 files) to keep context clean.
  - **Step 2 — docs-currency guardrail**: maps touched top-level dirs to candidate docs; applies skip criteria from the `update-docs` skill; if substantive diff lacks doc touches → **STOPS and asks user** (abort / proceed-with-drift / cancel). Never auto-invokes `/update-docs`.
  - **Step 3 — clean-tree guardrail**: dirty tree → **STOPS and asks user** to name files explicitly. Never `git add -A` or `.`.
  - **Step 5 — branch ref cleanup**: adds `git branch -d <branch>` after merge in both modes so a future branch (or `git worktree add`) with the same name doesn't reuse a stale ref.
- **README restructured around the "maintenance engine" framing.** Leads with the problem (static `CLAUDE.md` decay, session continuity loss) then the loop (`/prime` → work → `/review-work` → `/update-docs` → `/merge`) instead of a parts list. Adds `/merge` and `/plan-feature` to the installed-commands list and file tree (both previously missing). Pulls FAQ into a focused Compatibility section.
- **setup.sh in-installer tutorial extended to 8 steps including `/merge`.** Adds a footer mention of `/plan-feature` for Plan Mode users. Post-install "test your setup" line now shows the `/prime → /merge` workflow pair instead of just `/prime`. Version banner bumped from v3.0.0 to v3.1.0.

### Template renumbering

- `templates/CLAUDE.md` sections renumbered to accommodate new §2 Operator Model: previous 2→3 (Architecture Decisions), 3→4 (Tool Usage), 4→5 (Coding Standards), 5→6 (Testing), 6→7 (Privacy & Security). Existing users with customized `CLAUDE.md` files are unaffected (the installer preserves existing files).


## [3.0.3] - 2026-05-06

### Added

- **`cleanup-session.sh` hook** — New `SessionEnd` hook that removes per-session `/tmp/claude-baseline-*.numstat` and `/tmp/claude-stop-*.state` files. Wired automatically when `review-on-stop` is installed. Prevents `/tmp` accumulation across long-lived development machines.
- **Gemini 3.1 Pro Preview pin in `second-opinion`** — All `gemini` invocations now pass `-m gemini-3.1-pro-preview` explicitly. Without the pin, Gemini CLI may default to a smaller model and silently degrade the second-opinion value.
- **`progress.md` template** — New commented `Recent Changes` section between Project Status and Completed, for dated short-form session-handoff notes.
- **`GEMINI.md` template** — Severity-flag usage example; expanded `Do NOT` list with two new entries (don't suggest undocumented commands; don't re-derive rules already in CLAUDE.md).

### Maintenance

- The `gemini-3.1-pro-preview` pin in `skills/second-opinion/SKILL.md` will need updating when Google renames or deprecates that preview model. This is the cost of pinning vs. floating; we accept it for second-opinion quality.


## [3.0.2] - 2026-04-08

### Added

- **`/merge` command** — Worktree finalization workflow: survey changes → update docs → commit → merge to main via `git -C` → clean up worktree. Installed as core (always available).
- **Two-tier review suggestions** — `review-on-stop.sh` now only suggests `/review-work` at 50+ lines changed; below that, suggests tests + docs only. Configurable via `review_threshold` in `pipeline.json`.
- **Anti-bloat rules in `/update-docs`** — "What NOT to Document" table, density test, doc-specific enforcement (delete don't strike, 10-word row limit), and a Bloat Check procedure. Backported from production use.
- **Template improvements** — Richer commented examples across all templates:
  - `CLAUDE.md`: settled-decisions tip, test-to-code mapping table
  - `GEMINI.md`: Developer Workflow section (AI-agent calibration)
  - `spec.md`: Rate Limiting & Quotas, Feature Flags sections
  - `progress.md`: Security Issues, Technical Debt, Deferred Work sections
  - `deployment-infrastructure.md`: DNS Records, Plan Limits sections

### Fixed

- **snapshot-baseline.sh**: Now runs on `SessionStart` instead of `Notification` — captures git baseline before any work happens, not after the first tool notification.


## [3.0.1] - 2026-04-06

### Changed

- **review-work**: Switched from Gemini-first to Claude sub-agents. Spawns parallel specialists (Bug Hunter + Rules Auditor) for 50+ line diffs, single reviewer for smaller changes. No longer requires Gemini CLI.
- **second-opinion**: Permission-free invocation pattern — no more `$()` wrapping or `/tmp/` redirects that triggered permission prompts. Added autonomous multi-turn debate mode (2-4 rounds without user confirmation). Explicit no-fallback-to-weaker-models policy.

### Fixed

- **review-on-stop.sh**: Session ID robustness — uses `"unknown"` fallback instead of silently exiting when session ID is missing.
- **review-on-stop.sh**: Worktree support — reads `cwd` from hook input JSON for correct `PROJECT_DIR` in git worktrees.
- **review-on-stop.sh**: State file stores advice (`PHASE:ADVICE`) so phase 2 recalls the original suggestion without re-reading config.
- **snapshot-baseline.sh**: Same session ID and worktree CWD fixes as review-on-stop.sh.


## [3.0.0] - 2026-03-28

### Philosophy

From "build orchestration on top of Claude Code" to "configure Claude Code optimally."

Claude Code has evolved significantly since v2 — native features now handle what v2 built manually. v3 leans on the platform instead of reimplementing it.

### Breaking Changes

- **Commands replaced by Skills** — 7 command templates removed, replaced by 7 skills + 1 command (`/prime`)
- **3-tier CONTEXT.md system removed** — replaced by 4 focused `docs/ai-context/` files (spec, structure, progress, deployment)
- **Gemini MCP integration removed** — replaced by native Gemini CLI + `GEMINI.md` file
- **Context7 MCP setup removed** — now a Claude Code plugin (`claude plugins add context7`)
- **Subagent context injector hook removed** — Claude Code handles this natively
- **Gemini context injector hook removed** — `GEMINI.md` replaces the injection pattern
- **MCP-ASSISTANT-RULES.md removed** — replaced by `GEMINI.md`
- **setup.sh completely rewritten** — new feature selection flow, modular settings

### Added

- 7 skills: `/review-work`, `/second-opinion`, `/update-docs`, `/deploy`, `/image-gen`, `/image-edit`, `/bg-remove`
- `/prime` command (replaces `/full-context`)
- Review-on-stop hook — advisory 3-stop model with session baseline tracking, configurable via `pipeline.json`
- `GEMINI.md` template for Gemini CLI second-opinion integration
- Modular settings system with composable permission modules (core, review, visual, context7, supabase)
- Deny list for destructive operations (git push --force, rm -rf, etc.)
- Asset directory scaffolding (`assets/{app-icon,character,logo,social,web}`)
- Documentation scaffolding for `docs/{legal,business,design-brand,open-issues}`
- Framework documentation (`docs/README.md`, `docs/skills.md`)

### Changed

- `mcp-security-scan.sh` renamed to `security-scan.sh`
- `setup.sh` completely rewritten with skill/plugin selection and settings composition
- `install.sh` updated for v3 branding
- `README.md` rewritten for new positioning
- Documentation templates moved from `docs/` to `templates/docs/`

### Removed

- Commands: `/full-context`, `/code-review`, `/update-docs` (command), `/create-docs`, `/refactor`, `/handoff`, `/gemini-consult`
- Hooks: `gemini-context-injector.sh`, `subagent-context-injector.sh`
- Documentation: `docs-overview.md`, `system-integration.md`, `handoff.md`
- Templates: `CONTEXT-tier2-component.md`, `CONTEXT-tier3-feature.md`
- Directories: `docs/specs/`, `logs/`, `hooks/setup/`


## Upgrading from v2.x to v3.0.0

### Before you start

v2 is preserved on the `v2` branch. You can always go back:
```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/v2/install.sh | bash
```

### Migration steps

1. **Back up your customized files**: `CLAUDE.md`, any `CONTEXT.md` files, `MCP-ASSISTANT-RULES.md`

2. **Run the v3 installer**: It detects existing files and prompts for overwrite/skip
   ```bash
   curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/main/install.sh | bash
   ```

3. **Migrate content manually**:
   - `MCP-ASSISTANT-RULES.md` -> `GEMINI.md` (restructure to match new template)
   - `docs/ai-context/handoff.md` -> `docs/ai-context/progress.md`
   - Custom `CONTEXT.md` files -> merge into `CLAUDE.md` or keep as-is (Claude still reads them)

4. **Install Gemini CLI** if using review or second-opinion skills

5. **Enable Context7 plugin**: `claude plugins add context7`

### What you can keep

- Your customized `CLAUDE.md` (just remove MCP-specific sections)
- `hooks/config/sensitive-patterns.json` (unchanged format)
- `hooks/sounds/` (unchanged)
- Any custom hooks you've written

### What to remove

- `.claude/hooks/gemini-context-injector.sh`
- `.claude/hooks/subagent-context-injector.sh`
- Old command files from `.claude/commands/` (v3 keeps only `prime.md` there; all others are now in `.claude/skills/`)


---


## [2.1.0] - 2025-07-11

### Added
- New `/gemini-consult` command for deep, iterative conversations with Gemini MCP
- Core Documentation Principle section in `/update-docs` command

### Improved
- Enhanced setup script with conditional command installation


## [2.0.0] - 2025-07-10

### Added
- Comprehensive hooks system (security scanner, context injectors, notifications)
- MCP-ASSISTANT-RULES.md support
- Remote installation via curl
- Interactive setup.sh with prerequisite checking

### Changed
- Tier 2/3 documentation files renamed from CLAUDE.md to CONTEXT.md


## [1.0.0] - 2025-07-01

### Added
- Initial release: 3-tier documentation, 6 command templates, MCP integration
