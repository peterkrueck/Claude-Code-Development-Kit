Update CHANGELOG.md and README.md for a new versioned release. This command handles version determination and file updates only — git operations (commit, tag, push) and GitHub Release creation are handled by the calling workflow.

## Auto-Loaded Project Context:
@/CLAUDE.md
@/CHANGELOG.md

## Step 1: Validate Unreleased Changes

Read CHANGELOG.md and check that the `[Unreleased]` section has content beyond just the heading. If empty, stop and report that there are no unreleased changes to release.

## Step 2: Determine Version

### Parse `$ARGUMENTS`:
- **Explicit version** (e.g., `2.3.0`): Use as the new version directly
- **Bump keyword** (`major`, `minor`, `patch`): Apply that bump to the latest released version
- **`auto`** or **no input**: Auto-detect from changelog headings:
  - If `### Changed` or `### Removed` present under `[Unreleased]` → **major** bump
  - If `### Added` present under `[Unreleased]` → **minor** bump
  - Otherwise → **patch** bump

### Find the latest released version:
Look for the first `## [X.Y.Z]` heading after `[Unreleased]` in CHANGELOG.md and parse the version number. Apply the determined bump to compute the new version.

## Step 3: Update CHANGELOG.md

Modify the `[Unreleased]` section:
- Keep the `## [Unreleased]` heading followed by two blank lines
- Insert a new `## [X.Y.Z] - YYYY-MM-DD` heading (using today's date) with all the unreleased entries beneath it

The result should look like:
```
## [Unreleased]


## [X.Y.Z] - 2026-02-22

### Added
- ...

### Changed
- ...
```

## Step 4: Update README.md Version Badge

Find the changelog badge in README.md and update the version:
- Find: `changelog-v` followed by the old version number
- Replace with: `changelog-v` followed by the new version number

## Step 5: Report

Output a summary:
- The new version number
- The changelog entries that were moved from [Unreleased] to the versioned section
- Confirmation that both CHANGELOG.md and README.md were updated
