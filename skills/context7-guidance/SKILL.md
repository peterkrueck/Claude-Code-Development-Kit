---
name: context7-guidance
description: Fetch CURRENT library/framework/API/CLI documentation via Context7 instead of relying on training data. Use whenever the user mentions a specific library, framework, SDK, API, or cloud service, asks a setup/configuration question, plans a version migration, or is debugging library-specific behavior. Triggers on common web frameworks, APIs, and cloud services — even well-known ones, since training data may be stale.
---

# Context7 Guidance — Current Docs Over Training Data

The kit ships the Context7 plugin permission so you can pull **current** documentation at the version the project actually uses. Training data drifts: APIs get deprecated, defaults change, config keys get renamed. When the question is about a real library, fetch the docs — don't answer from memory.

## When to Use

Reach for Context7 when the user:

- Names a specific library, framework, SDK, or cloud service (common web frameworks, APIs, and cloud services — even ones you "know")
- Asks a setup or configuration question ("how do I wire up X middleware?")
- Plans a version migration ("upgrading to vN — what changed?")
- Is debugging library-specific behavior (an error, a deprecation, an unexpected default)
- Wants code that calls a third-party API — verify the signature before writing it

**When NOT to use it:** general programming concepts, refactoring your own code, debugging your own business logic, writing a script from scratch, or code review of non-library logic. Context7 is for *external* surfaces, not your codebase.

## How to Fetch

1. **Resolve the library ID.** Call `resolve-library-id` with the library name and pass the user's **full question** as the query — it sharpens the ranking.
2. **Pick the best match.** Prefer an exact name match and the official/primary package over community forks. If the user named a version, prefer the version-specific ID.
3. **Query the docs.** Call `query-docs` with the chosen library ID and the user's specific question (not a single keyword).
4. **Answer from the result.** Use the fetched docs, include relevant examples, and cite the version when it matters.

If the tools aren't directly callable, load them first via ToolSearch (`select:mcp__context7__resolve-library-id,mcp__context7__query-docs`) — don't skip verification just because they weren't preloaded.

## Guidelines

- **Pass the full question**, not one word — it improves relevance at both steps.
- **Be version-aware** — when the user mentions a version, carry it into the resolve step.
- **Prefer official sources** when several matches exist.
- **Fall back to web search only if Context7 has no coverage** for that library.
