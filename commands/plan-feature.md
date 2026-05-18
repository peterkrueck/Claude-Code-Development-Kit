# Plan Feature Command

Plan a feature with parallel research and a Gemini second opinion before exiting plan mode. Designed to run inside Plan Mode (toggle with Shift+Tab).

**Usage:** `/plan-feature [feature description]`

If no description is given, plan the next feature based on prior session context (typically loaded by `/prime`).

---

## Approach

For concerns not directly in front of you — a third-party API/SDK, a platform capability, a library version question, or a cross-cutting code search — dispatch sub-agents in parallel. Treat training data as potentially stale, especially for fast-moving platforms, SDKs, and APIs. Context7 MCP first; WebSearch only if Context7 lacks coverage.

For architecture decisions, state the tradeoff, not just the chosen option. For UI flows, plan how you'll verify the change end-to-end (manual browser test, simulator run, integration test — whatever applies). After implementing the code, but before final verification, run `/review-work` to catch bugs upfront.

Before exiting plan mode, invoke `/second-opinion` on the draft. You are the authority — Gemini's role is to flag blind spots or alternatives worth considering, not to overwrite your judgment. Note what you took vs rejected, then exit plan mode with the synthesized plan.

ultrathink

---

**Feature to plan:** $ARGUMENTS
