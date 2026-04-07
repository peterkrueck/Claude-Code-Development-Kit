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

## 2. Key Architecture Decisions

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

## 3. Tool Usage Rules

<!-- Map tasks to the correct tools for your project. -->

| Task | Use This |
|------|----------|
| Library docs lookup | Context7 plugin (check FIRST) |
| Code review | `/review-work` skill |
| Second opinion | Ask for "second opinion" (auto-triggers Gemini) |
| Documentation update | `/update-docs` skill |
| Deployment | `/deploy` skill |

## 4. Coding Standards

<!-- Keep only standards that are non-obvious or project-specific.
     Don't document standard language conventions — Claude already knows those. -->

<!--
Example:
- TypeScript files: kebab-case (e.g., `rate-limiter.ts`)
- Swift files: PascalCase (e.g., `SettingsView.swift`)
- Error responses: `{ success: false, error_code: 'CODE', message: '...' }`
- All time logic in PostgreSQL, never client-side
-->

## 5. Testing

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

## 6. Privacy & Security

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
