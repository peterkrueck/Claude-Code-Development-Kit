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

Independent code review using Google's Gemini CLI — a completely different AI architecture that catches things Claude might miss. When Gemini is unavailable, falls back to a Claude sub-agent.

- `/review-work` — Sends your uncommitted diff to Gemini with a review checklist
- `/second-opinion` — Auto-triggers when Claude faces tricky architecture decisions

Requires: [Gemini CLI](https://github.com/google-gemini/gemini-cli)

### Optional: Visual skills

Generate app icons, character art, social media graphics, and marketing assets. Edit images with precision. Remove backgrounds locally.

- `/image-gen` — AI image generation via Nanobanana 2 (Gemini). Optional reference photos for style consistency.
- `/image-edit` — Crop, resize, rotate, mirror. Analyzes content bounds before cutting.
- `/bg-remove` — Background removal via rembg. Runs locally, nothing sent externally.

Requires: Python 3, Pillow, numpy. `/image-gen` also needs a `GEMINI_API_KEY`. `/bg-remove` needs rembg.

### Optional: Deploy skill template

A customizable deployment pipeline you fill in with your own commands. Follows: detect changes → run tests → deploy → verify → report.

### Optional: Gemini integration

`GEMINI.md` — an instruction file that Gemini CLI reads automatically. Gives Gemini full context about your project when invoked as a reviewer or consultant.

### Optional: Stop pipeline hook

Prevents Claude from stopping until quality checks pass. When you have 10+ lines of uncommitted changes, it gates stopping on: code review → run tests → update docs. Each phase is configurable.

### Optional: Audio notifications

Plays a sound when Claude finishes a task or needs your input. Supports macOS and Linux.

## What Gets Installed

```
your-project/
├── .claude/
│   ├── commands/prime.md               # /prime — load project context
│   ├── hooks/                          # Automation (security, pipeline, sounds)
│   ├── skills/                         # Selected skills
│   └── settings.local.json             # Permissions and hook config
├── assets/                             # Your visual assets
├── docs/
│   ├── ai-context/                     # Core AI context (4 files)
│   ├── legal/
│   ├── business/
│   ├── design-brand/
│   └── open-issues/
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


## FAQ

**Do I need Gemini CLI?**
Only for the review skills. Everything else works without it.

**Can I use this with Cursor/Windsurf/Codex?**
The skills and hooks are Claude Code-specific. The documentation templates work with any AI tool. SKILLS should work with most AI coding tools by now.

**Is this for large teams?**
It works for teams, but it's designed for individual developers and small teams. If you're running complex multi-agent workflows at scale via the API, this probably isn't what you need.

## License

MIT — see [LICENSE](LICENSE).
