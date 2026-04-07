---
name: update-docs
description: Update project documentation after code changes. Maintains the 4 core ai-context files (spec, project-structure, progress, deployment-infrastructure) and CLAUDE.md. Use after completing features, refactors, or any changes that affect project structure, capabilities, or status. Also creates initial documentation if files don't exist yet.
user_invocable: true
---

# Update Docs — Documentation Maintenance

Keep project documentation synchronized with the current state of the code. Updates the core `docs/ai-context/` files and `CLAUDE.md` as needed.

## Core Documentation Principle

**Document current "is" state only — never reference legacy implementations or what changed.**

- Write as if the documentation is being read for the first time
- No "previously", "was changed from", "used to be", or "improved" language
- No migration notes or upgrade paths within the docs themselves
- If something was removed, remove it from docs — don't leave a "removed X" note

## When to Skip

Do NOT run this skill for:
- Bug fixes that don't change architecture or capabilities
- Small refactors (rename, extract method) that don't change behavior
- UI tweaks or styling changes
- Single file additions that don't affect project structure
- Performance optimizations without API changes
- Comment or documentation-only changes

## What NOT to Document

Claude Code can read files and grep code. Only document what **cannot be inferred from the code itself**:

| Don't document | Why | Instead |
|----------------|-----|---------|
| Standard language conventions | Claude already knows them | Only project-specific deviations |
| Response JSON examples | Claude reads actual source files | Request contract + error codes only |
| File-by-file descriptions | Claude can Glob and Read | Only non-obvious file purposes |
| Completed checklist items | Done = in git history | Remove from progress.md |
| ASCII art diagrams | Many lines, low value | Use compact tables |

**Density test:** Before adding content, ask: "Could Claude figure this out by reading the code?" If yes, don't document it.

## Process

### Step 1: Analyze What Changed

Check recent changes:

```bash
git diff --stat HEAD
git log --oneline -5
```

Identify what categories of change occurred:
- **New feature or capability** → update `spec.md`, possibly `progress.md`
- **New files or directories** → update `project-structure.md`
- **Deployment or infrastructure change** → update `deployment-infrastructure.md`
- **Milestone completed or status change** → update `progress.md`
- **New architecture decision or rule** → update `CLAUDE.md`

### Step 2: Update Relevant Files

Only update files where the change is meaningful. The 4 core files and their ownership:

| File | What It Owns | Update When |
|------|-------------|-------------|
| `docs/ai-context/spec.md` | What the product does — features, API contracts, data flows | New feature, API change, behavior change |
| `docs/ai-context/project-structure.md` | File tree, tech stack, directory organization | New files/dirs, dependency changes, tech stack change |
| `docs/ai-context/progress.md` | What's done, what's next, blockers | Phase completed, new work started, status change |
| `docs/ai-context/deployment-infrastructure.md` | Hosting, accounts, secrets, CI/CD | Infrastructure change, new service, new secret |
| `CLAUDE.md` | Project rules, architecture decisions, coding standards | New rule, new decision, changed constraint |

### Step 3: Apply the Single Source of Truth Rule

Each fact lives in exactly ONE file. If you find the same information in multiple files, keep it in the primary owner and remove it from the others.

Examples:
- API endpoint details → `spec.md` (not CLAUDE.md)
- File naming conventions → `CLAUDE.md` (not project-structure.md)
- Deployment URLs → `deployment-infrastructure.md` (not spec.md)

### Step 4: Keep Docs Lean

Only document non-obvious complexity that can't be inferred from reading the code:
- Architecture decisions and their rationale
- Non-obvious constraints (e.g., "audio must never be stored")
- Cross-cutting concerns that span multiple files
- External service configurations

Do NOT document:
- What a function does (the code shows this)
- Standard framework patterns (the framework docs cover this)
- Obvious file purposes (e.g., "utils.ts contains utility functions")

### Step 5: Create Missing Files

If `docs/ai-context/` files don't exist yet, create them from the current codebase state. Analyze the code, tech stack, and project structure to populate each file with accurate current-state documentation.

## Doc-Specific Rules

**progress.md:**
- Use absolute dates, never relative ("March 2026", not "last week")
- When marking items complete, DELETE the item (don't strike through) — the fix is in git history
- Keep completed phase summaries to a single table row (~10 words), not paragraphs
- Remove completed checklist items that have been done for 2+ weeks
- Security items: remove when fixed, keep only open issues

**spec.md:**
- Don't duplicate CLAUDE.md content (architecture principles, coding standards)
- Document request format + error codes + key behaviors — skip response examples
- Reference shared utility files by path, don't reproduce their content

**CLAUDE.md:**
- Only rules that change Claude's behavior — if removing a line wouldn't cause Claude to do anything differently, delete it
- Not a reference doc: no test structure tables, no naming convention tables for standard patterns

## Bloat Check

After updating, silently check `progress.md`:
- Each completed phase row: ~10 words max in "What" column — trim immediately if longer
- No duplication with spec.md — if progress.md restates architecture details, delete and cross-reference
- Dead items: remove completed checklist items done 2+ weeks with no ongoing relevance

Then check if CLAUDE.md would also benefit from an update based on the changes made.
