# Claude Code Development Kit

## Changelog & Release Process

This project uses [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

### Maintaining the Changelog
When completing work that introduces user-facing changes, add an entry to the `[Unreleased]` section of `CHANGELOG.md` before committing. Use the appropriate category:
- **Added** — new features or capabilities
- **Changed** — changes to existing functionality
- **Fixed** — bug fixes
- **Improved** — enhancements to existing features (non-breaking)
- **Removed** — removed features or capabilities

Skip changelog entries for: internal refactors with no user-visible effect, test-only changes, CI/tooling changes, and documentation-only updates (unless documenting a new feature).

### Creating Releases
Releases are user-initiated via the `/release` command. Do not create releases, tags, or version bumps automatically. The `/release` command handles:
1. Moving `[Unreleased]` entries to a new versioned section with today's date
2. Updating the README version badge
3. Committing, tagging (`vX.Y.Z`), and pushing
4. GitHub Release is auto-created by the `.github/workflows/release.yml` Action on tag push

### Version Bump Rules (SemVer)
- **patch** (e.g., 2.1.0 → 2.1.1): bug fixes only
- **minor** (e.g., 2.1.0 → 2.2.0): new features, no breaking changes
- **major** (e.g., 2.1.0 → 3.0.0): breaking changes
