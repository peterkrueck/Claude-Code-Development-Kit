# Claude Code Development Kit

The best-practice Claude Code setup for serious development. Skills, hooks, templates, and settings — configured so you don't have to.

## What's Included

| Component | Count | Purpose |
|-----------|-------|---------|
| **Skills** | 7 | Automated code review, image generation, background removal, and more |
| **Commands** | 1 | `/prime` — load core project context |
| **Hooks** | 3 | Stop pipeline, security scanner, audio notifications |
| **Templates** | 6 | CLAUDE.md, GEMINI.md, and 4 documentation files |
| **Settings** | 6 | Modular permission sets composed at install time |

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

## What Gets Installed

```
your-project/
├── .claude/
│   ├── commands/prime.md               # /prime — load project context
│   ├── hooks/
│   │   ├── stop-pipeline.sh            # Review → test → docs gate
│   │   ├── security-scan.sh            # Block sensitive data in MCP calls
│   │   ├── notify.sh                   # Audio feedback
│   │   ├── config/
│   │   │   ├── pipeline.json           # Pipeline phase configuration
│   │   │   └── sensitive-patterns.json # Security scan patterns
│   │   └── sounds/
│   │       ├── complete.wav
│   │       └── input-needed.wav
│   ├── skills/                         # Selected skills installed here
│   └── settings.local.json             # Composed from selected modules
│
├── assets/                             # Visual assets scaffolding
│   ├── app-icon/
│   ├── character/
│   ├── logo/
│   ├── social/
│   └── web/
│
├── docs/
│   ├── ai-context/
│   │   ├── spec.md                     # What the product does
│   │   ├── project-structure.md        # File tree and tech stack
│   │   ├── progress.md                 # Roadmap and task tracking
│   │   └── deployment-infrastructure.md
│   ├── legal/
│   ├── business/
│   ├── design-brand/
│   └── open-issues/
│
├── CLAUDE.md                           # Your project's AI instruction set
└── GEMINI.md                           # Gemini second-opinion instructions
```

## Skills

### Core Skills (always installed)

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `/update-docs` | Manual or stop hook | Updates `docs/ai-context/` files to match current code state. |

### Review Skills (require [Gemini CLI](https://github.com/google-gemini/gemini-cli))

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `/review-work` | Manual or stop hook | Sends diff to Gemini for independent code review. Falls back to Claude sub-agent. |
| `/second-opinion` | Auto (when stuck or facing trade-offs) | Consults Gemini on architecture decisions, debugging, edge cases. |

### Visual Skills (require Python 3, `/image-gen` also requires `GEMINI_API_KEY`)

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `/image-gen` | Manual | Generates character art via Gemini image API with reference images for consistency. |
| `/image-edit` | Manual | Crop, resize, rotate, mirror images via Python/Pillow. Measures before cutting. |
| `/bg-remove` | Manual | Removes backgrounds locally via rembg (no data sent externally). |

### Template Skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `/deploy` | Manual | Test-gated deployment pipeline. Customize for your stack. |

## Hooks

### Stop Pipeline (`stop-pipeline.sh`)

A state machine that gates Claude from stopping until quality checks pass:

1. **Check** — Are there 10+ lines of uncommitted changes?
2. **Review** — Run `/review-work` for independent code review
3. **Tests** — Run your test command (configured in `pipeline.json`)
4. **Docs** — Run `/update-docs` to keep documentation current

Configure in `.claude/hooks/config/pipeline.json`:
```json
{
  "enabled": true,
  "min_lines_changed": 10,
  "file_patterns": ["*.py", "*.ts", "*.js", "*.swift"],
  "test_command": "npm test",
  "phases": { "review": true, "tests": true, "docs": true }
}
```

### Security Scanner (`security-scan.sh`)

Scans MCP and plugin requests for secrets before they leave your machine. Uses pattern matching from `sensitive-patterns.json`.

### Notifications (`notify.sh`)

Cross-platform audio alerts (macOS/Linux/Windows) when Claude completes tasks or needs input.

## Settings

The installer composes `settings.local.json` from modular permission sets based on your selections:

- **Core** — Always included. Git commands, basic bash, deny list for destructive ops.
- **Review skills** — Gemini CLI permissions.
- **Visual skills** — Python, rembg, image tool permissions.
- **Context7 plugin** — Plugin tool permissions.
- **Supabase plugin** — Plugin tool permissions.

The **deny list** blocks dangerous operations by default:
```
git push --force, git reset --hard, git clean -f,
git checkout -- ., git restore ., git branch -D, rm -rf
```

## Gemini Integration

The kit treats Gemini as a **peer reviewer**, not a subordinate. Gemini gets its own instruction file (`GEMINI.md`) and reads your project docs independently.

**Setup:**
1. Install [Gemini CLI](https://github.com/google-gemini/gemini-cli)
2. Customize `GEMINI.md` with your project details
3. The `/review-work` and `/second-opinion` skills handle invocation automatically

## Plugins

Install plugins separately via Claude Code as needed:

```bash
claude plugins add context7     # Library documentation (highly recommended)
claude plugins add supabase     # Database management
```

## Upgrading from v2

v3 is a major rewrite. Key changes:

- **Commands → Skills**: 7 commands replaced by 7 skills + 1 command
- **3-tier CONTEXT.md → 4 focused files**: `spec.md`, `project-structure.md`, `progress.md`, `deployment-infrastructure.md`
- **Gemini MCP → Gemini CLI**: Native `GEMINI.md` file instead of MCP server + hook injection
- **Context7 MCP → Plugin**: `claude plugins add context7` instead of MCP server setup
- **New**: Stop pipeline hook, modular settings, visual skills, asset directories

**v2 is still available:**
```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/v2/install.sh | bash
```

See [CHANGELOG.md](CHANGELOG.md) for the full migration guide.

## FAQ

**Do I need a Claude Code subscription?**
The kit works on any plan, but skills that spawn sub-agents benefit from higher rate limits.

**Do I need Gemini CLI?**
Only for the review skills (`/review-work`, `/second-opinion`). Everything else works without it.

**Can I use this with Cursor/Windsurf/other editors?**
The skills and hooks are Claude Code-specific. The documentation templates (`CLAUDE.md`, `docs/ai-context/`) work with any AI tool.

**What about Windows?**
Hooks use bash scripts. On Windows, use WSL or Git Bash.

## License

MIT — see [LICENSE](LICENSE).
