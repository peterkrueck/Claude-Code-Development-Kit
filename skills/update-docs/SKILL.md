---
name: update-docs
description: Update project documentation after code changes. Maintains the 4 core ai-context files (spec, project-structure, progress, deployment-infrastructure) and CLAUDE.md. Use after completing features, refactors, or any changes that affect project structure, capabilities, or status. Also creates initial documentation if files don't exist yet.
user_invocable: true
---

# Update Docs — Documentation Maintenance

Keep project documentation synchronized with the current state of the code. Updates the core `docs/ai-context/` files and `CLAUDE.md` as needed.

## Core Documentation Principle

**Compress aggressively — the default for every line is DELETE.** A line earns its place only when it encodes something an AI agent cannot derive from the code, git log, or spec.md. Every run prunes as much as it adds.

**Document current "is" state only — never reference legacy implementations or what changed.**

- Write as if the documentation is being read for the first time
- No "previously", "was changed from", "used to be", or "improved" language
- No migration notes or upgrade paths within the docs themselves
- If something was removed, remove it from docs — don't leave a "removed X" note
- No build-state qualifiers ("recently added", "just landed", "new in this release") — dead the moment work ships; git log carries that

**Audience: AI agents, not humans.** These docs exist so a future session can prime fast. No marketing, no narrative arc, no "we did X then Y," no friendly hedging. Prefer tables, bold inline labels, and pseudocode over prose. Put code identifiers in backticks. Pair every non-obvious rule with a one-phrase reason (security, past incident, vendor quirk).

## When to Skip

**The bar is architecture, not activity.** A run only earns doc changes when a change lands **new architecture** — a data flow, contract, invariant, or design decision a future session could not reconstruct from code alone. Fold that into `spec.md` in present tense. That is the ONLY thing that earns new lines — never a record that the work happened (git carries that), never a "we fixed/added X" note. If "document this change" reduces to "note that we did it," write nothing.

Do NOT run this skill for:
- Bug fixes that don't change architecture or capabilities
- Small refactors (rename, extract method) that don't change behavior
- UI tweaks or styling changes
- Single file additions within existing patterns
- Performance optimizations without architectural impact
- Comment or formatting changes

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

### Step 0 (optional): Scope to a module

Default scope is the **whole project** — one project per repo. If your repo splits into modules/components under distinct top-level paths (each with its own `docs/ai-context/`), you may narrow to the one touched this session: `git status --short` shows which path has modified files; update only that module's docs. Skip this step entirely if the project has a single `docs/ai-context/` — which is the common case.

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

**State each fact exactly once** across the ai-context + `CLAUDE.md` bundle. If the same fact appears in multiple files, keep only the canonical owner and delete the rest — no breadcrumb pointer left behind. Resolve contradictions by trusting the canonical owner.

- **Internal section refs are allowed** — within one file, pointing `§3.7 → §3.2` for navigation is fine.
- **Cross-file breadcrumbs are forbidden.** `/update-docs` and `/prime` load the bundle together, so writing `See spec.md §X` from another file is pure overhead. Move the fact to its owner; don't leave a pointer.

Examples:
- API endpoint details → `spec.md` (not CLAUDE.md)
- File naming conventions → `CLAUDE.md` (not project-structure.md)
- Deployment URLs → `deployment-infrastructure.md` (not spec.md)

**Header-rename hazard:** in single-source-of-truth docs, section-number pointers are load-bearing. If `/prime` is light (TOC + opening invariants only), deep facts are reached via `CLAUDE.md → spec.md <section>` pointers. Renaming a `## ` header means updating every pointer that cites it — or the pointer dangles.

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
- Load-bearing / cross-cutting invariants live in the spec's **opening** section(s). Light prime reads only the opening + TOC, so an invariant buried mid-doc is invisible at session start. When folding a shipped feature in, hoist any new cross-cutting invariant up as one terse line + a `→ §` pointer to its detail section.

**CLAUDE.md:**
- Only rules that change Claude's behavior — if removing a line wouldn't cause Claude to do anything differently, delete it
- Not a reference doc: no test structure tables, no naming convention tables for standard patterns

## Doc Lifecycle — Permanent vs Non-Permanent

- **Fold-on-ship.** When a feature ships, fold its feature-doc's current architecture into `spec.md` (present tense) and retire the feature doc. Never leave shipped architecture in a future/feature doc.
- **Hoist cross-cutting invariants up.** An invariant that spans the whole project belongs in `spec.md`'s opening, not buried in a feature doc.
- **Permanence.** `spec.md` / `project-structure.md` / `CLAUDE.md` are permanent and must NOT cite non-permanent docs (e.g. `open-issues/*`, feature docs) by specific-file link. Only `progress.md` (the roadmap) may. Carve-out: `project-structure.md` may list a non-permanent doc as a file-tree entry (filename + one-line role), but no deep section-number citations into it.

## Named-Reference Lifecycle (optional convention)

If you tag recurring traps, gotchas, or open issues with stable IDs, give each tag a stale-pass rule so dead references get pruned instead of accumulating. The exact scheme is yours — below is one example using an open-issue tag `T-XX`; adopt it, rename it, or skip it entirely.

- **Traps / gotchas:** for each tagged item, grep the cited files/symbols. If ALL referenced files/symbols are gone, the item is dead — delete it. If the item is keyed to a resolution that has shipped, verify and delete.
- **Gates / checklists:** any checked (`[x]`) row → delete immediately; done lives in git.
- **Open follow-ups:** if the cited file/symbol is gone OR a recent commit closes the item → delete.
- **Library-version notes** (e.g. "X needs Y ≥ 0.31"): if the current pin is already past the threshold, surface it to the user rather than silently deleting — you may not know whether upstream actually fixed the issue.

Run the stale pass every invocation, regardless of which tagging scheme (if any) you use.

## Bloat Check

After updating, silently check `progress.md`:
- Each completed phase row: ~10 words max in "What" column — trim immediately if longer
- No duplication with spec.md — if progress.md restates architecture details, delete and cross-reference
- Dead items: remove completed checklist items done 2+ weeks with no ongoing relevance

**Net-line audit guard:** if a run adds ≥10 lines while deleting 0, pause and reconsider. Something is almost always prunable — a run that only grows is a smell.

Then check if CLAUDE.md would also benefit from an update based on the changes made.
