# Skills Reference

## review-work

**Purpose:** Independent code review using parallel Claude sub-agents.
**Trigger:** Manual (`/review-work`) or via review-on-stop hook advisory.
**Requires:** Nothing.

Captures `git diff`, spawns specialist sub-agents to review against a checklist (bugs, security, compliance, tests), then critically evaluates findings before presenting to the user. For 50+ line changes, spawns two parallel specialists (Bug Hunter + Rules Auditor); for smaller changes, uses a single combined reviewer.

**Customize:** Edit the review checklist in the SKILL.md to add project-specific categories.

---

## second-opinion

**Purpose:** Architecture consultation via Gemini CLI.
**Trigger:** Automatic — when Claude detects tricky decisions, debugging dead ends, or the user asks for a second opinion.
**Requires:** Gemini CLI installed and configured.

Sends focused questions to Gemini with optional code context. Supports autonomous multi-turn debate (2-4 rounds of back-and-forth). Uses permission-free invocation pattern to avoid prompt interruptions. Presents a consolidated synthesis of agreements and disagreements.

**Note:** `user_invocable: false` — Claude invokes this automatically when appropriate.

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
