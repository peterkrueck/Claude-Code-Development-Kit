Trigger the GitHub Actions release workflow to create a new versioned release from the current `[Unreleased]` changelog entries.

## Auto-Loaded Project Context:
@/CLAUDE.md
@/CHANGELOG.md

## Step 1: Validate Unreleased Changes

Read CHANGELOG.md and check that the `[Unreleased]` section has content. If empty, stop and tell the user there are no unreleased changes to release.

## Step 2: Determine Workflow Inputs

### Parse user input from `$ARGUMENTS`:
- **Explicit version** (e.g., "2.3.0"): Will pass as `version` input to the workflow
- **Bump keyword** ("major", "minor", "patch"): Will pass as `bump` input
- **No input**: Will use `bump=auto` (the workflow auto-detects from changelog headings)

### Show the user what will happen:
- Display the unreleased changelog entries
- State the version/bump that will be used
- Ask for confirmation before triggering

## Step 3: Trigger the GitHub Actions Workflow

Use the GitHub CLI to trigger the release workflow:

```bash
# With auto-detect (default):
gh workflow run release.yml -f bump=auto

# With explicit bump:
gh workflow run release.yml -f bump=minor

# With explicit version:
gh workflow run release.yml -f bump=auto -f version=2.3.0
```

**Important**: Only pass the `version` field if the user provided an explicit version. Otherwise, use only the `bump` field.

## Step 4: Monitor and Report

After triggering, inform the user:
- The workflow has been triggered
- They can monitor progress at the repository's **Actions** tab
- The workflow will: update CHANGELOG.md, update the README badge, commit, tag, push, and create a GitHub Release
- The release commit and tag will appear on `main` when complete

Optionally, wait a moment and check the workflow status:
```bash
gh run list --workflow=release.yml --limit=1
```

## Error Handling

- **Empty [Unreleased] section**: Stop early — nothing to release.
- **No CHANGELOG.md**: Stop and inform the user.
- **`gh` CLI unavailable**: Inform the user they can trigger the workflow manually from the GitHub Actions tab (Actions → Release → Run workflow).
- **Workflow trigger failure**: Show the error and suggest triggering manually from the GitHub UI.
