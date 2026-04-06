# Changelog

All notable changes to the Claude Code Development Kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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
