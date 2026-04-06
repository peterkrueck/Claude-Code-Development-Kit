# Claude Code Development Kit

A lightweight starter kit for Claude Code subscribers. Gives your project a solid foundation — documentation structure, code review automation, image tools, and sensible defaults — that you extend as you go.

This isn't a heavy framework. It's the setup you'd build yourself after a few weeks of using Claude Code, packaged so you start with it on day one.

## Who This Is For

You have a Claude Code subscription and want to hit the ground running. Maybe you're building an app, a side project, or starting something new. You want Claude to understand your project structure, review its own work, and not accidentally `git push --force` your main branch.

This kit gives you that. Install what you need, skip what you don't, extend it however you want.

## Quick Start

**One command:**
```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/main/install.sh | bash
```

**Or clone and run:**
```bash
git clone https://github.com/peterkrueck/Claude-Code-Development-Kit.git
cd Claude-Code-Development-Kit
./setup.sh
```

The installer walks you through what to include. Everything is optional except the core.

## How It Works

**Skills** are things Claude does — automatically based on context, or when you type a `/slash-command`. **Hooks** run in the background on specific events (security checks, review nudges, notification sounds). **Commands** are manual triggers you type, like `/prime` to load your project context.

The installer gives you three paths: **full** (recommended — installs everything), **customize** (choose each feature individually), or **minimal** (core only). Re-run anytime to add more.

## What You Get

### Always installed (core)

- **`CLAUDE.md`** — A template for your project's AI instruction set. This is how you tell Claude your project's rules, architecture decisions, and constraints.
- **`/prime` command** — Loads your documentation into context. Run it at the start of a session.
- **`/update-docs` skill** — Keeps your documentation in sync after code changes.
- **Documentation scaffolding** — Four structured files (`spec.md`, `project-structure.md`, `progress.md`, `deployment-infrastructure.md`) plus directories for legal, business, design, and open issues.
- **Security scanner** — Blocks API keys and secrets from leaking through MCP plugins.
- **Deny list** — Prevents `git push --force`, `rm -rf`, `git reset --hard`, and other destructive commands.
- **Asset directories** — `assets/` for your app icons, logos, and graphics.

### Optional: Review skills

Independent code review and architecture consultation.

- `/review-work` — Spawns parallel Claude sub-agents (Bug Hunter + Rules Auditor) to review your uncommitted diff. Scales automatically: single reviewer for small changes, parallel specialists for 50+ lines.
- `/second-opinion` — Auto-triggers when Claude faces tricky architecture decisions. Consults Google's Gemini CLI for a genuinely independent perspective (different AI architecture).

`/second-opinion` requires: [Gemini CLI](https://github.com/google-gemini/gemini-cli)

### Optional: Visual skills

For any project that needs visual assets — app icons, UI artwork, social media graphics, marketing materials, or website imagery. Generate images with AI, edit with precision, remove backgrounds locally.

- `/image-gen` — AI image generation via Gemini. Optional reference photos for style consistency across variations.
- `/image-edit` — Crop, resize, rotate, mirror. Analyzes content bounds before cutting (never guesses coordinates).
- `/bg-remove` — Background removal via rembg. Runs 100% locally, nothing sent externally.

Requires: Python 3, Pillow, numpy. `/image-gen` also needs a `GEMINI_API_KEY`. `/bg-remove` needs rembg.

### Optional: Deploy skill template

A customizable deployment pipeline you fill in with your own commands. Follows: detect changes → run tests → deploy → verify → report.

### Optional: Gemini integration

`GEMINI.md` — an instruction file that Gemini CLI reads automatically. Gives Gemini full context about your project when invoked as a reviewer or consultant.

### Optional: Review-on-stop hook

Nudges you to review before finishing. When you have 10+ lines of new code (net changes this session, not pre-existing dirty state), the first stop shows an advisory with changed files and suggests review/test/docs. Stop again for a reminder, a third time to skip entirely. Never traps you — three stops always gets you out.

### Optional: Audio notifications

Plays a sound when Claude finishes a task or needs your input. Supports macOS and Linux.

## What Gets Installed

```
your-project/
├── .claude/
│   ├── commands/
│   │   └── prime.md                    # /prime — load project context
│   ├── hooks/
│   │   ├── security-scan.sh            # Blocks secrets from leaking to plugins
│   │   ├── review-on-stop.sh           # Advisory review nudge (if selected)
│   │   ├── snapshot-baseline.sh        # Session baseline capture (if selected)
│   │   ├── notify.sh                   # Audio notifications (if selected)
│   │   ├── config/
│   │   │   ├── pipeline.json           # Review-on-stop configuration
│   │   │   └── sensitive-patterns.json # Security scan patterns
│   │   └── sounds/
│   │       ├── complete.wav
│   │       └── input-needed.wav
│   ├── skills/                         # Selected skills (review, visual, deploy)
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
└── GEMINI.md                           # Gemini instructions (if selected)
```


## Upgrading from v2

v3 is a major rewrite. Commands became skills, the 3-tier doc system became 4 focused files, Gemini moved from MCP to native CLI, Context7 is now a plugin.

**v2 is still available:**
```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/v2/install.sh | bash
```

See [CHANGELOG.md](CHANGELOG.md) for the full migration guide.


## Uninstalling

Remove the installed files from your project:

```bash
rm -rf .claude/ docs/ai-context/ assets/ CLAUDE.md GEMINI.md
```

The scaffolding directories (`docs/legal/`, `docs/business/`, etc.) are empty by default — remove them too if unused. Your code is never modified.

## FAQ

**Do I need Gemini CLI?**
Only for `/second-opinion`. The `/review-work` skill uses Claude sub-agents and works without it. Everything else works without it too.

**Can I use this with Cursor/Windsurf/Codex?**
The skills and hooks are Claude Code-specific. The documentation templates work with any AI tool. SKILLS should work with most AI coding tools by now.

**Is this for large teams?**
It works for teams, but it's designed for individual developers and small teams. If you're running complex multi-agent workflows at scale via the API, this probably isn't what you need.

## License

MIT — see [LICENSE](LICENSE).
