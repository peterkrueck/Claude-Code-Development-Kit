# Framework Documentation

This directory contains documentation for the Claude Code Development Kit itself.

## Reference

- **[skills.md](skills.md)** — Detailed reference for all skills
- **[../README.md](../README.md)** — Main project README with quick start guide

## Commands

| Command | Purpose |
|---------|---------|
| `/prime` | Load project context — tiered (light by default, `--full`, `--deploy`) |
| `/merge` | Verify docs + clean tree, then ship to main (build-verified on divergence) |
| `/verify` | Run the app/tests to confirm a change actually works (cross-stack template) |

Second-opinion consultant briefings install as `AGENTS.md` (OpenAI Codex) and/or `GEMINI.md` (Gemini CLI), depending on the engine you choose at install.

## Installed Documentation

When the kit is installed into a project, it creates documentation templates in `docs/ai-context/`:

| File | Purpose |
|------|---------|
| `spec.md` | What the product does — features, API contracts, data flows |
| `project-structure.md` | File tree, tech stack, directory organization |
| `progress.md` | Roadmap, completed work, next steps |
| `deployment-infrastructure.md` | Hosting, accounts, secrets, CI/CD |

Additional scaffolding directories are created for `legal/`, `business/`, `design-brand/`, and `open-issues/`.
