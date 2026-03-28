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
- Mark completed items with dates
- Keep the "Next Steps" section current — remove items that are done

**spec.md:**
- Include exact API contracts (request/response shapes)
- Document data flows end-to-end
- Specify platform requirements and compatibility

**CLAUDE.md:**
- Rules must be actionable and verifiable
- Architecture decisions should include brief rationale
- Group rules by domain (security, testing, architecture, etc.)
