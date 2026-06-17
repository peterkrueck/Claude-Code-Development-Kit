# [Project Name]

<!-- Customize this file for your project. This is the primary instruction set
     that Claude Code reads at the start of every session. Keep it focused on
     rules, decisions, and constraints — not documentation that belongs in
     docs/ai-context/. -->

## 1. Critical Rules

- **Use Sub-Agents** for tasks spanning 3+ files or requiring parallel investigation.
- **Always ask before**: git commits, breaking changes, major architecture decisions, deleting files.
- **Stop-and-Replan Rule**: If an approach fails or you discover unexpected complexity, stop and reassess rather than pushing through.
- **Use available skills proactively**: `/review-work` for code review, `/update-docs` after significant changes, `/deploy` for deployments.
- **Context7 first**: When working with external libraries, check Context7 for current documentation before relying on training data.

## 2. Operator Model

<!-- Describe who you are and how development happens so Claude calibrates
     its advice. Optional, but valuable for solo / AI-agent-driven workflows
     where conventional wisdom about effort and complexity doesn't apply.
     Fill in (or delete) the example below.

Example:

- **Who I am.** Solo founder / small-team lead with conceptual technical
  literacy — I understand architecture and trade-offs but don't read or
  write production code line-by-line. I treat AI agents as specialists; my
  role is decision-maker, director, and reviewer.
- **Who writes the code.** AI agents (Claude + sub-agents). Build effort ≈
  zero. Timelines are gated by review, QA, and decision overhead, not typing
  speed.
- **Evaluate by maintenance burden, not build effort.** "Too much code for a
  small team" / "over-engineered for one person" is almost never a valid
  critique. Pick libraries and architectures on technical merit. The right
  questions: hard to debug at 2am? hard to observe in production? hard to swap
  out if the vendor fails? can a future agent reason about it from the code
  alone?
- **Calibrate to a decision-maker, not a junior engineer.** Lead with the
  trade-off and the why; spell out failure modes — don't assume I'll spot a
  subtle bug by reading the diff.
- **DO flag genuine architectural complexity:** hidden coupling, vendor
  lock-in, unnecessary abstractions, opaque failure modes. That's the
  complexity that actually costs me.
- **Boundaries:** always ask before git commits, breaking changes, deleting
  files, and architecture decisions worth ≥1 day of rework to undo. -->

## 3. Key Architecture Decisions

<!-- Document settled decisions here so Claude doesn't relitigate them.
     Include brief rationale for each. -->

<!-- Tip: Also list decisions that are SETTLED so Claude doesn't relitigate them.
     Example: "REST over GraphQL — decided, don't suggest changing." -->

<!--
Example:
- **Authentication**: JWT tokens with refresh rotation. Why: stateless, scales horizontally.
- **Database**: PostgreSQL with RLS on all tables. Why: row-level security eliminates auth middleware bugs.
- **State management**: Server-side only. Why: single source of truth, no sync bugs.
-->

## 4. Tool Usage Rules

<!-- Map tasks to the correct tools for your project. -->

| Task | Use This |
|------|----------|
| Library docs lookup | Context7 plugin (check FIRST) |
| Code review | `/review-work` skill |
| Second opinion | Ask for a "second opinion" (Codex by default; say "ask Gemini" for Gemini, "ask both" to run both) |
| Documentation update | `/update-docs` skill |
| Deployment | `/deploy` skill |

## 5. Technical Documentation

Docs in `docs/ai-context/` are written for AI agents, not humans. Keep them dense — when in doubt, **delete**.

- **Document the is-state only.** Describe how the system works *now*, in present tense. No changelogs, no "we used to…", no migration narratives, no future plans (those live in `progress.md`).
- **Hoist cross-cutting invariants up.** A rule that applies across the codebase belongs in `CLAUDE.md` or `spec.md`, not buried in one feature's notes. State it once, in the highest-level doc it applies to.
- **Fold shipped features into `spec.md`.** A feature doc lives in `docs/` while the work is in flight, then folds into `spec.md` (present tense) when it ships — retire the feature doc afterward. Architecture lives in `spec.md`, never in chat memory.

Run `/update-docs` after significant changes to keep docs in sync with the code.

## 6. Coding Standards

<!-- Keep only standards that are non-obvious or project-specific.
     Don't document standard language conventions — Claude already knows those. -->

<!--
Example:
- TypeScript files: kebab-case (e.g., `rate-limiter.ts`)
- Swift files: PascalCase (e.g., `SettingsView.swift`)
- Error responses: `{ success: false, error_code: 'CODE', message: '...' }`
- All time logic in PostgreSQL, never client-side
-->

## 7. Testing

<!-- Document your test commands and when to run them. -->

<!--
Example:
```bash
npm test              # All tests
npm run test:unit     # Unit tests only (~1s)
npm run test:e2e      # E2E tests (~20s, hits network)
```

**When to run which tests:**
| What changed | Run |
|---|---|
| Shared utilities | Unit tests |
| API endpoints | E2E tests |
| Database schema | Integration tests |
| Before deployment | All suites |
-->

## 8. Privacy & Security

<!-- Document non-negotiable security rules for your project. -->

<!--
Example:
- Audio/media NEVER stored — processed in memory, deleted immediately
- No user accounts — anonymous identity via device UUID
- Never log personal data or audio content
- Never reveal system internals (stack traces, DB schemas) in error messages
- Input validation on all external inputs
- RLS enabled on all database tables
-->
