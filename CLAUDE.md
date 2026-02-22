# Claude Code Development Kit

## Project Structure — Templates vs CDK-Internal Files

**CRITICAL:** This repository is a *kit* that gets installed into other projects. Most top-level directories are **templates** that will be copied into target projects. Only the `.claude/` directory is for managing THIS CDK project itself.

### Template directories (for target projects that install the CDK)
- `commands/` — Slash command templates (e.g., `/code-review`, `/refactor`, `/handoff`). These get installed into the target project's `.claude/commands/`.
- `docs/` — Documentation templates (tier architecture, context files). Installed into the target project.
- `hooks/` — Hook script templates (security scanning, notifications). Installed into the target project's `.claude/hooks/`.

### CDK-internal files (for working on THIS repository)
- `.claude/commands/` — Slash commands for CDK development only (e.g., `/release` for publishing new CDK versions).
- `.claude/hooks/` — Hooks that run during CDK development sessions (e.g., `set-gh-default.sh`).
- `.claude/settings.json` — Claude Code settings for CDK development.

**Do NOT move template files into `.claude/`.** The `commands/`, `docs/`, and `hooks/` directories are intentionally at the repo root because they are templates, not active Claude Code configuration for this repo.

## Changelog & Release Process

This project uses [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

### Maintaining the Changelog
When completing work that introduces user-facing changes, add an entry to the `[Unreleased]` section of `CHANGELOG.md` before committing. Use the appropriate category:
- **Added** — new features or capabilities
- **Changed** — changes to existing functionality
- **Fixed** — bug fixes
- **Improved** — enhancements to existing features (non-breaking)
- **Removed** — removed features or capabilities

**Consolidate entries:** Before adding a new entry, review existing `[Unreleased]` entries. If your change supersedes, revises, or reverts a previous unreleased entry, **update or replace** that entry instead of adding a new one. The `[Unreleased]` section represents the cumulative delta from the last release — end users never see intermediate states. For example, if an unreleased entry says "Changed button color from blue to red" and you now change it to black, update the entry to "Changed button color from blue to black" (or remove it entirely if it returns to the original state).

Skip changelog entries for: internal refactors with no user-visible effect, test-only changes, CI/tooling changes, and documentation-only updates (unless documenting a new feature).

### Creating Releases
Releases are handled by a manually-triggered GitHub Actions workflow (`.github/workflows/release.yml`). The workflow can be triggered in two ways:
- **From Claude Code**: Run `/release` which triggers the workflow via `gh workflow run`
- **From GitHub UI**: Actions → Release → Run workflow

The workflow handles the complete release process:
1. Validates that `[Unreleased]` has content
2. Determines the version (auto-detect from changelog headings, bump keyword, or explicit version)
3. Moves `[Unreleased]` entries to a new versioned section with today's date
4. Updates the README version badge
5. Commits, tags (`vX.Y.Z`), and pushes to `main`
6. Creates a GitHub Release with extracted release notes

Do not create releases, tags, or version bumps manually. Always use the workflow.

### Version Bump Rules (SemVer)
- **patch** (e.g., 2.1.0 → 2.1.1): bug fixes only
- **minor** (e.g., 2.1.0 → 2.2.0): new features, no breaking changes
- **major** (e.g., 2.1.0 → 3.0.0): breaking changes
