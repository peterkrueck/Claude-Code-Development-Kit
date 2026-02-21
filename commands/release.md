Execute the project's release process to create a new versioned release from the current `[Unreleased]` changelog entries.

## Auto-Loaded Project Context:
@/CLAUDE.md
@/CHANGELOG.md

## Step 1: Determine Release Version

### Parse user input from `$ARGUMENTS`:
- **Explicit version** (e.g., "2.3.0"): Use as-is
- **Bump keyword** ("major", "minor", "patch"): Calculate from the latest released version in CHANGELOG.md
- **No input**: Auto-detect the bump type from `[Unreleased]` entries:
  - Contains `### Added` with new features → **minor**
  - Contains only `### Fixed` or `### Improved` → **patch**
  - Contains `### Changed` with breaking changes or `### Removed` → **major**
  - When in doubt, default to **minor**

### Validate:
- `[Unreleased]` section in CHANGELOG.md must have content (not empty). If empty, stop and tell the user there are no unreleased changes to release.
- The computed version must be greater than the current latest version.

## Step 2: Update CHANGELOG.md

1. **Read** the current CHANGELOG.md
2. **Replace** `## [Unreleased]` and its content with:
   - A fresh, empty `## [Unreleased]` section (two blank lines after it)
   - A new `## [X.Y.Z] - YYYY-MM-DD` section containing the previous unreleased content
3. **Preserve** all existing versioned sections below unchanged

### Expected result structure:
```
## [Unreleased]


## [X.Y.Z] - YYYY-MM-DD

### Added
- (moved from unreleased)
...

## [previous version] - previous date
...
```

## Step 3: Update Version Badge in README.md

Find the changelog badge line:
```
[![Changelog](https://img.shields.io/badge/changelog-vX.Y.Z-orange.svg)](CHANGELOG.md)
```
Update the version to the new release version.

## Step 4: Commit the Release

Stage only the changed files and create a commit:
```
release: vX.Y.Z — <brief summary of key changes>
```

The summary should be derived from the most notable entries in the release section (1 short line).

## Step 5: Create Git Tag

Create an annotated git tag on the release commit:
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

## Step 6: Push to Main and Push Tag

Releases must land on `main`. Push the release commit explicitly to `main`, then push the tag:
```bash
git push origin HEAD:main
git push origin vX.Y.Z
```

**Why `HEAD:main`?** On Claude Code Web, editing files may auto-create a session branch even if the session started from `main`. Using `HEAD:main` ensures the release commit lands on `main` regardless of the current local branch name.

If `HEAD:main` is rejected (e.g., non-fast-forward), **stop and inform the user** — `main` may have diverged and needs manual reconciliation. Do not force-push.

If a GitHub Actions release workflow exists (`.github/workflows/release.yml`), inform the user that a GitHub Release will be created automatically from the tag push. If no workflow exists, suggest the user create a GitHub Release manually or add the workflow.

## Step 7: Summary

Output a clear summary:
```
Released vX.Y.Z

- Changelog: updated with N entries
- README badge: updated to vX.Y.Z
- Git tag: vX.Y.Z created and pushed
- GitHub Release: (auto-created by workflow / manual step needed)
```

## Error Handling

- **Empty [Unreleased] section**: Stop early with a clear message — nothing to release.
- **No CHANGELOG.md**: Stop and inform the user the project needs a CHANGELOG.md following Keep a Changelog format.
- **Git push failure**: Retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s) for network errors. For permission errors, stop and inform the user.
- **Tag already exists**: Stop and inform the user the tag already exists — they may need to specify a different version.
