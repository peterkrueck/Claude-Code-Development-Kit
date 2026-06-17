# Claude Code Development Kit

**Keep Claude Code coherent across sessions.** A starter kit that maintains the context layer Claude actually reads.

## Why this exists

A static `CLAUDE.md` decays within a few sessions. The context window fills up. Decisions you made yesterday get re-derived today because nothing kept the docs in sync with the code. Every fresh session starts from scratch, even when the answer is one `git log` away.

This kit is the maintenance layer between you and Claude Code. Four focused doc files become the project's working memory. Slash commands keep them current. Hooks catch the things you'd forget. It's the setup you'd build yourself after a few weeks of using Claude Code, packaged so you start with it on day one.

## The loop

```
   /prime           load project context at session start
        ↓
   work             Claude writes the code
        ↓
   /review-work     parallel sub-agents catch bugs + rule violations
        ↓
   /update-docs     keep ai-context docs in sync (skipping trivial changes)
        ↓
   /merge           verify and ship (standard branch or git worktree)
```

`/verify` runs the app or its tests to confirm a change actually works (observed behavior, not just "it compiles") — the run-it-and-watch step `/review-work` points at.

When Claude hits an architecture decision or a debugging dead end, ask for a **second opinion** — an independent review from a different model (OpenAI Codex by default, or Google Gemini).

## Who this is for

You have a Claude Code subscription and want to hit the ground running. Maybe you're building an app, a side project, or starting something new. You want Claude to understand your project structure, review its own work, keep its own notes in sync — and not accidentally `git push --force` your main branch.

This isn't a heavy framework. It's structured defaults that compound over time.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/main/install.sh | bash
```

Or clone:

```bash
git clone https://github.com/peterkrueck/Claude-Code-Development-Kit.git
cd Claude-Code-Development-Kit
./setup.sh
```

The installer walks you through what to include — Full (recommended), Customize, or Minimal. Re-run anytime to add features.

**First session:**

```bash
cd your-project
claude
> /prime
```

Claude reads your docs, summarizes the project, and you're ready to work.

## What's in the box

### Core (always installed)

| | |
|---|---|
| `CLAUDE.md` template | Your project's AI instruction set |
| `/prime` command | Load core docs into context — tiered: a light prime by default (~4-6k tokens), `--full` for everything, `--deploy` to also load infra |
| `/merge` command | Verify docs are current + tree is clean, then ship to main. Detects silent clean-merge breakage with a build/test pass. Works with standard branches and `git worktree`. |
| `/verify` command | Run the app or its tests to confirm a change actually works — a cross-stack template you fill in for your stack |
| `/update-docs` skill | Keep `docs/ai-context/` in sync after code changes — density-first, skips trivial diffs |
| `context7-guidance` skill | Fetch current library/framework/API docs via Context7 instead of stale training data |
| Doc scaffolding | Four focused files: `spec.md`, `project-structure.md`, `progress.md`, `deployment-infrastructure.md` |
| Security scanner hook | Blocks API keys and secrets from leaking to MCP plugins |
| Deny list + allowlist | Blocks `git push --force`, `rm -rf`, `sudo`, `git reset --hard`, etc.; auto-allows safe read-only shell utilities and doc-domain fetches |
| Asset directories | `assets/` scaffolding for icons, logos, social, web |

### Quality gates (optional)

| | |
|---|---|
| `/review-work` | Spawns parallel Claude sub-agents (Bug Hunter + Rules Auditor, plus an optional Architect) to review your uncommitted diff. Verifies every external-API claim against Context7 (unverified claims are discarded) and reports whether the change actually fulfills the task in `progress.md`. |
| `/second-opinion` | Auto-triggers when Claude hits architecture decisions or debugging dead ends. Consults an external AI with a different model architecture — **OpenAI Codex by default**, **Google Gemini** on "ask Gemini", or "ask both" to triangulate. |
| Review-on-stop hook | Three-stop advisory nudge, scoped to the files *this session* edited. First stop shows changes + review suggestions, second stop is a reminder, third stop lets you out. Never traps you. |

`/second-opinion` needs the CLI for your chosen engine: [OpenAI Codex](https://github.com/openai/codex) and/or [Gemini CLI](https://github.com/google-gemini/gemini-cli). The installer asks which one(s) to wire up.

### Templates

`AGENTS.md` (read natively by OpenAI Codex) and/or `GEMINI.md` (read natively by Gemini CLI) — the second-opinion consultant briefings — plus the four `docs/ai-context/` files and asset directory scaffolding.

### Optional add-ons

- **Visual skills** — `/image-gen` (AI image generation via Gemini), `/image-edit` (crop/resize/rotate/mirror with content-bounds detection), `/bg-remove` (local background removal via rembg). Needs Python 3, Pillow, numpy; `/image-gen` needs a `GEMINI_API_KEY`; `/bg-remove` needs rembg.
- **Deploy skill template** — A customizable deployment pipeline you fill in with your own commands. Follows: detect changes → run tests → deploy → verify → report.
- **Audio notifications** — Plays a sound when Claude finishes a task or needs your input. macOS + Linux.

## What gets installed

```
your-project/
├── .claude/
│   ├── commands/
│   │   ├── prime.md                    # /prime — load project context (tiered)
│   │   ├── merge.md                    # /merge — verify and ship
│   │   └── verify.md                   # /verify — run app/tests to confirm it works
│   ├── hooks/
│   │   ├── security-scan.sh            # Blocks secrets from leaking to plugins
│   │   ├── review-on-stop.sh           # Advisory review nudge (if selected)
│   │   ├── snapshot-baseline.sh        # Session baseline capture (if selected)
│   │   ├── track-file-touch.sh         # Records this session's edits (if selected)
│   │   ├── cleanup-session.sh          # Clears per-session temp files (if selected)
│   │   ├── notify.sh                   # Audio notifications (if selected)
│   │   ├── config/
│   │   │   ├── pipeline.json           # Review-on-stop configuration
│   │   │   └── sensitive-patterns.json # Security scan patterns
│   │   └── sounds/
│   │       ├── complete.wav
│   │       └── input-needed.wav
│   ├── skills/                         # update-docs, context7-guidance (core) + review/visual/deploy
│   └── settings.local.json             # Permissions, hooks, deny list
│
├── assets/                             # Your visual assets
│
├── docs/
│   ├── ai-context/
│   │   ├── spec.md                     # What the product does
│   │   ├── project-structure.md        # File tree and tech stack
│   │   ├── progress.md                 # Roadmap and task tracking
│   │   └── deployment-infrastructure.md # Hosting, secrets, CI/CD
│   ├── legal/
│   ├── business/
│   ├── design-brand/
│   └── open-issues/
│
├── CLAUDE.md                           # Your project's AI rules
├── AGENTS.md                           # Codex consultant briefing (if selected)
└── GEMINI.md                           # Gemini consultant briefing (if selected)
```

## Compatibility

**Do I need an external CLI?**
Only for `/second-opinion`. The installer asks which engine to wire up — [OpenAI Codex](https://github.com/openai/codex) (default), [Gemini CLI](https://github.com/google-gemini/gemini-cli), or both — and you only need the CLI for what you picked. The `/review-work` skill uses Claude sub-agents and works without either. Everything else works without them too.

**Can I use this with Cursor / Windsurf / Codex?**
The skills and hooks are Claude Code-specific. The documentation templates work with any AI tool. Skills should work with most AI coding tools that support the skill format.

**Is this for large teams?**
It works for teams, but it's designed for individual developers and small teams. If you're running complex multi-agent workflows at scale via the API, this probably isn't what you need.

## Upgrading from v2

v3 is a major rewrite. Commands became skills, the 3-tier doc system became 4 focused files, Gemini moved from MCP to native CLI, Context7 is now a plugin.

v2 is still available:

```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/v2/install.sh | bash
```

See [CHANGELOG.md](CHANGELOG.md) for the full migration guide.

## Uninstalling

Remove the installed files from your project:

```bash
rm -rf .claude/ docs/ai-context/ assets/ CLAUDE.md AGENTS.md GEMINI.md
```

The scaffolding directories (`docs/legal/`, `docs/business/`, etc.) are empty by default — remove them too if unused. Your code is never modified.

## License

MIT — see [LICENSE](LICENSE).
