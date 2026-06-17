# Skills Reference

## review-work

**Purpose:** Independent code review using parallel Claude sub-agents.
**Trigger:** Manual (`/review-work`) or via review-on-stop hook advisory.
**Requires:** Nothing (Context7 plugin strongly recommended — see below).

Triages the diff by file path into impacted modules + risk surfaces (auth, schema migrations, config/secrets, dependency updates, critical paths), then spawns specialist sub-agents that self-prime via `/prime`. For 50+ line changes: two parallel specialists (Bug Hunter + Rules Auditor); smaller changes use a single combined reviewer; an optional **Architect** joins when the diff spans 2+ modules, adds new abstractions, or leaves a refactor unfinished. Each reviewer **verifies every external-API/library claim against Context7** and tags findings `[verified]` / `[unverified]` / `[n/a]` — the judge **auto-discards unverified API claims**. Reviewers also read the active task in `progress.md` and report an **intent verdict** (does the change actually do the intended task?) before listing findings, which are grouped by severity (Blockers / Mediums / Lows).

**Customize:** Edit the review checklist and risk-surface catalogue in the SKILL.md to add project-specific categories. Pairs best with the Context7 plugin enabled.

---

## second-opinion

**Purpose:** Independent architecture consultation via an external AI with a different model architecture.
**Trigger:** Automatic — when Claude detects tricky decisions, debugging dead ends, or the user asks for a second opinion. Also "ask Codex" / "ask GPT".
**Requires:** OpenAI Codex CLI (default engine; sign in with a ChatGPT account).

The **default** second-opinion engine, driving OpenAI Codex. Codex reads `AGENTS.md` at the repo root to self-prime, then answers read-only. Supports autonomous multi-turn debate (2-4 rounds). Uses a permission-free invocation pattern to avoid prompt interruptions. Reports unavailability (quota/429) rather than silently downgrading the model. Presents a consolidated synthesis of agreements and disagreements.

**Note:** `user_invocable: false`. The installer lets you pick the default engine (Codex, Gemini, or both). When Gemini is chosen as the default, this skill drives Gemini instead.

---

## second-opinion-gemini

**Purpose:** Second opinion from Google's Gemini Pro — the explicit / fallback engine.
**Trigger:** Only on explicit "ask Gemini" / "Gemini's take" / "ask both", or as a fallback when the default engine is unavailable.
**Requires:** Gemini CLI. Installed only when the engine choice is "both".

Same invocation discipline as `second-opinion` (permission-free, 600s timeout, no silent downgrade, autonomous multi-turn). Model is pinned to a Pro-tier default and overridable via the `CLAUDE_SECOND_OPINION_MODEL` env var. "ask both" runs this alongside the default engine and synthesizes all three views.

---

## context7-guidance

**Purpose:** Fetch current library/framework/API documentation via Context7 instead of stale training data.
**Trigger:** Automatic — mentions of a specific library/framework/SDK/API, setup/config questions, version migrations, or library-specific debugging.
**Requires:** Context7 plugin (`claude plugins add context7`).

Teaches the resolve-then-query Context7 flow and when to reach for it (external surfaces) vs. when not to (your own business logic). The kit ships the Context7 permission; this skill is the pedagogy.

---

## update-docs

**Purpose:** Keep `docs/ai-context/` synchronized with code changes.
**Trigger:** Manual (`/update-docs`) or via review-on-stop hook advisory.

Analyzes recent git changes and updates the relevant documentation files (spec, structure, progress, deployment). Follows the "document the is-state only" principle. Skips trivial changes (bug fixes, styling, small refactors).

---

## deploy

**Purpose:** Test-gated deployment pipeline.
**Trigger:** Manual (`/deploy`).

**This is a template.** Customize the `SKILL.md` with your actual test commands, deploy commands, health checks, and rollback procedures.

Workflow: detect changes → run tests → deploy → verify → health check → report.

---

## image-gen

**Purpose:** Generate images using Gemini's image generation API with reference images.
**Trigger:** Manual or when user asks for character art, mascot variations, etc.
**Requires:** `GEMINI_API_KEY` environment variable, Deno runtime.

Uses a bundled TypeScript script (`scripts/generate.ts`) to call the Gemini API with reference images for style consistency. Generates multiple variants, scores them, and picks the best.

---

## image-edit

**Purpose:** Precise image manipulation (crop, resize, rotate, mirror).
**Trigger:** Manual or when user asks to transform images.
**Requires:** Python 3 with Pillow and numpy.

Uses bundled Python scripts (`scripts/analyze_bounds.py`, `scripts/crop_image.py`) for precise operations. The "measure before you cut" approach avoids the common pitfall of guessing crop coordinates from visual inspection.

---

## bg-remove

**Purpose:** Remove backgrounds from images locally.
**Trigger:** Manual (`/bg-remove`).
**Requires:** Python 3 with rembg installed (`pip install "rembg[cpu,cli]"`).

Uses the birefnet-general model via rembg. Runs 100% locally — no images sent to external services. Includes magenta-composite verification to ensure quality.
