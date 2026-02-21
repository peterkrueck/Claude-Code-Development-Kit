# Claude Code Development Kit

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/changelog-v2.2.0-orange.svg)](CHANGELOG.md)

An integrated system that transforms Claude Code into an orchestrated development environment through automated documentation management, multi-agent workflows, and external AI expertise.

> **Related**: Check out [Freigeist](https://www.freigeist.dev) - upcoming AI coding platform for complex projects!

## Why Claude Code?

Claude Code's Sub-Agents enable this highly automated, integrated approach. While other AI tools can likely use the documentation structure (see FAQ) and some commands, only Claude Code can currently orchestrate parallel agents and use this Development Kit to its full potential.

## 🎯 Why This Kit?

> *Ever tried to build a large project with AI assistance, only to watch it struggle as your codebase grows?*

Claude Code's output quality directly depends on what it knows about your project. As AI-assisted development scales, three critical challenges emerge:

---

### Challenge 1: Context Management

**The Problem:**
```
❌ Loses track of your architecture patterns and design decisions
❌ Forgets your coding standards and team conventions
❌ No guidance on where to find the right context in large codebases
```

**The Solution:**
✅ **Automated context delivery** through two integrated systems:
- **3-tier documentation system** - Auto-loads the right docs at the right time
- **Custom commands with sub-agents** - Orchestrates specialized agents that already know your project
- Result: No manual context loading, consistent knowledge across all agents

---

### Challenge 2: AI Reliability 

**The Problem:**
```
❌ Outdated library documentation
❌ Hallucinated API methods
❌ Inconsistent architectural decisions
```

**The Solution:**
✅ **"Four eyes principle"** through MCP integration:

| Service | Purpose | Benefit |
|---------|---------|---------|
| **Context7** | Real-time library docs | Current APIs, not training data |
| **Gemini** | Architecture consultation | Cross-validation & best practices |

*Result: Fewer errors, better code, current standards*

---

### Challenge 3: Automation Without Complexity

**The Problem:**
```
❌ Manual context loading for every session
❌ Repetitive command sequences
❌ No feedback when tasks complete
```

**The Solution:**
✅ **Intelligent automation** through hooks and commands:
- Automatic updates of documentation through custom commands
- Context injection for Gemini MCP calls via hooks
- CLAUDE.md auto-injected into all sessions and sub-agents by Claude Code
- Audio notifications for task completion (optional)
- One-command workflows for complex tasks

---

### 🎉 The Result

> **Claude Code transforms from a helpful tool into a reliable development partner that remembers your project context, validates its own work, and handles the tedious stuff automatically.**


[![Demo-Video auf YouTube](https://img.youtube.com/vi/kChalBbMs4g/0.jpg)](https://youtu.be/kChalBbMs4g)




## Quick Start

### Prerequisites

- **Required**: [Claude Code](https://github.com/anthropics/claude-code)
- **Recommended**: MCP servers like [Context7](https://github.com/upstash/context7) and [Gemini Assistant](https://github.com/peterkrueck/mcp-gemini-assistant)

#### Platform Support

- **Windows**: ❌ (has reported bugs - use at your own risk)

### Installation

#### Option 1: Quick Install (Recommended)

Run this single command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/drock/Claude-Code-Development-Kit/main/install.sh | bash
```

This will:
1. Download the framework
2. Guide you through an interactive setup
3. Install everything in your chosen project directory
4. Provide links to optional MCP server installations


https://github.com/user-attachments/assets/0b4a1e69-bddb-4b58-8de9-35f97919bf44


#### Option 2: Clone and Install

```bash
git clone https://github.com/drock/Claude-Code-Development-Kit.git
cd Claude-Code-Development-Kit
./setup.sh
```

### What Gets Installed

The setup script will create the following structure in your project:

```
your-project/
├── .claude/
│   ├── commands/          # AI orchestration templates (.md files)
│   ├── hooks/             # Automation scripts
│   │   ├── config/        # Security patterns configuration
│   │   ├── sounds/        # Notification sounds (if notifications enabled)
│   │   ├── set-gh-default.sh  # SessionStart: configures PR targeting for forks
│   │   └── *.sh           # Other hook scripts (based on your selections)
│   ├── logs/              # Hook execution logs (created at runtime)
│   └── settings.json      # Generated Claude Code configuration
├── docs/                  # Documentation templates and examples
│   ├── ai-context/        # Core documentation files
│   ├── open-issues/       # Issue tracking examples
│   ├── specs/             # Specification templates
│   ├── CONTEXT-tier2-component.md  # Component documentation template
│   └── CONTEXT-tier3-feature.md    # Feature documentation template
├── logs/                  # Hook execution logs (created at runtime)
├── CLAUDE.md              # Your project's AI context (from template)
└── MCP-ASSISTANT-RULES.md # MCP coding standards (if Gemini-Assistant-MCP selected)
```

**Note**: The exact files installed depend on your choices during setup (MCP servers, notifications, etc.)

### Post-Installation Setup

1. **Customize your AI context**:
   - Edit `CLAUDE.md` with your project standards
   - Update `docs/ai-context/project-structure.md` with your tech stack

2. **Install MCP servers** (if selected during setup):
   - Follow the links provided by the installer
   - Configure in `.claude/settings.json`

3. **Test your installation**:
   ```bash
   claude
   /full-context "analyze my project structure"
   ```


## Terminology

- **CLAUDE.md** - Master context files containing project-specific AI instructions, coding standards, and integration patterns
- **CONTEXT.md** - Component and feature-level documentation files (Tier 2 and Tier 3) that provide specific implementation details and patterns
- **MCP (Model Context Protocol)** - Standard for integrating external AI services with Claude Code
- **Sub-agents** - Specialized AI agents spawned by Claude Code to work on specific aspects of a task in parallel
- **3-Tier Documentation** - Hierarchical organization (Foundation/Component/Feature) that minimizes maintenance while maximizing AI effectiveness
- **Auto-loading** - Automatic inclusion of relevant documentation when commands execute
- **Hooks** - Shell scripts that execute at specific points in Claude Code's lifecycle for security, automation, and UX enhancements

## Architecture

### Integrated Intelligence Loop

```
                        CLAUDE CODE
                   ┌─────────────────┐
                   │                 │
                   │    COMMANDS      │
                   │                 │
                   └────────┬────────┘
                  Multi-agent│orchestration
                   Parallel │execution
                   Dynamic  │scaling
                           ╱│╲
                          ╱ │ ╲
          Routes agents  ╱  │  ╲  Leverages
          to right docs ╱   │   ╲ expertise
                       ╱    │    ╲
                      ▼     │     ▼
         ┌─────────────────┐│┌─────────────────┐
         │                 │││                 │
         │  DOCUMENTATION  │││  MCP SERVERS   │
         │                 │││                 │
         └─────────────────┘│└─────────────────┘
          3-tier structure  │  Context7 + Gemini
          Auto-loading      │  Real-time updates
          Context routing   │  AI consultation
                      ╲     │     ╱
                       ╲    │    ╱
        Provides project╲   │   ╱ Enhances with
        context for      ╲  │  ╱  current best
        consultation      ╲ │ ╱   practices
                           ╲│╱
                            ▼
                    Integrated Workflow
```

### Auto-Loading Mechanism

Every command execution automatically loads critical documentation:

```
@/CLAUDE.md                              # Master AI context and coding standards
@/docs/ai-context/project-structure.md   # Complete technology stack and file tree
@/docs/ai-context/docs-overview.md       # Documentation routing map
```

Claude Code automatically injects CLAUDE.md into all sessions (CLI and web), including sub-agents spawned via the Task tool. This means any context, conventions, or instructions in CLAUDE.md are available to every agent without needing a hook.

This ensures:
- Consistent AI behavior across all sessions and sub-agents
- Zero manual context management at any level

### Component Integration

**Commands ↔️ Documentation**
- Commands determine which documentation tiers to load based on task complexity
- Documentation structure guides agent spawning patterns
- Commands update documentation to maintain current context

**Commands ↔️ MCP Servers**
- Context7 provides up-to-date library documentation
- Gemini offers architectural consultation for complex problems
- Integration happens seamlessly within command workflows

**Documentation ↔️ MCP Servers**
- Project structure and MCP assistant rules auto-attach to Gemini consultations
- Ensures external AI understands specific architecture and coding standards
- Makes all recommendations project-relevant and standards-compliant

### Hooks Integration

The kit includes battle-tested hooks that enhance Claude Code's capabilities:

- **Security Scanner** - Prevents accidental exposure of secrets when using MCP servers
- **Gemini Context Injector** - Automatically includes project structure in Gemini consultations
- **Notification System** - Provides non-blocking audio feedback for task completion and input requests (optional)
- **GitHub Default Repo** - SessionStart hook that configures `gh` CLI so PRs target this repository instead of an upstream fork (essential for Claude Code Web where `.git/` state doesn't persist between sessions)

These hooks integrate seamlessly with the command and MCP server workflows, providing:
- Pre-execution security checks for all external AI calls
- Automatic context enhancement for external AI consultations
- Developer awareness through pleasant, non-blocking audio notifications
- Correct PR targeting in forked repositories without manual intervention

## Common Tasks

### Starting New Feature Development

```bash
/full-context "implement user authentication across backend and frontend"
```

The system:
1. Auto-loads project documentation
2. Spawns specialized agents (security, backend, frontend)
3. Consults Context7 for authentication framework documentation
4. Asks Gemini 2.5 pro for feedback and improvement suggestions
4. Provides comprehensive analysis and implementation plan

### Code Review with Multiple Perspectives

```bash
/code-review "review authentication implementation"
```

Multiple agents analyze:
- Security vulnerabilities
- Performance implications
- Architectural alignment
- Integration impacts

### Maintaining Documentation Currency

```bash
/update-docs "document authentication changes"
```

Automatically:
- Updates affected CLAUDE.md files across all tiers
- Keeps project-structure.md and docs-overview.md up-to-date
- Maintains context for future AI sessions
- Ensures documentation matches implementation

## Creating Your Project Structure

After installation, you'll add your own project-specific documentation:

```
your-project/
├── .claude/
│   ├── commands/              # AI orchestration templates
│   ├── hooks/                 # Security and automation hooks
│   │   ├── config/            # Hook configuration files
│   │   ├── sounds/            # Notification audio files
│   │   ├── gemini-context-injector.sh
│   │   ├── mcp-security-scan.sh
│   │   ├── notify.sh
│   │   └── set-gh-default.sh  # SessionStart: PR targeting for forks
│   ├── logs/                  # Hook execution logs
│   └── settings.json          # Claude Code configuration
├── docs/
│   ├── ai-context/            # Foundation documentation (Tier 1)
│   │   ├── docs-overview.md   # Documentation routing map
│   │   ├── project-structure.md # Technology stack and file tree
│   │   ├── system-integration.md # Cross-component patterns
│   │   ├── deployment-infrastructure.md # Infrastructure context
│   │   └── handoff.md        # Session continuity
│   ├── open-issues/           # Issue tracking templates
│   ├── specs/                 # Feature specifications
│   └── README.md              # Documentation system guide
├── CLAUDE.md                  # Master AI context (Tier 1)
├── MCP-ASSISTANT-RULES.md     # MCP coding standards (if Gemini selected)
├── backend/
│   ├── **`CONTEXT.md`**       # Backend context (Tier 2) - 🔴 create this
│   └── src/api/
│       └── **`CONTEXT.md`**   # API context (Tier 3) - 🔴 create this
└── frontend/
    ├── **`CONTEXT.md`**       # Frontend context (Tier 2) - 🔴 create this
    └── src/components/
        └── **`CONTEXT.md`**   # Components context (Tier 3) - 🔴 create this
```

The framework provides templates for CONTEXT.md files in `docs/`:
- `docs/CONTEXT-tier2-component.md` - Use as template for component-level docs
- `docs/CONTEXT-tier3-feature.md` - Use as template for feature-level docs

## Configuration

The kit is designed for adaptation:

- **Commands** - Modify orchestration patterns in `.claude/commands/`
- **Documentation** - Adjust tier structure for your architecture
- **MCP Integration** - Add additional servers for specialized expertise
- **Hooks** - Customize security patterns, add new hooks, or modify notifications in `.claude/hooks/`
- **MCP Assistant Rules** - Copy `docs/MCP-ASSISTANT-RULES.md` template to project root and customize for project-specific standards

## Best Practices

1. **Let documentation guide development** - The 3-tier structure reflects natural boundaries
2. **Update documentation immediately** - Use `/update-docs` after significant changes
3. **Trust the auto-loading** - Avoid manual context management
4. **Scale complexity naturally** - Simple tasks stay simple, complex tasks get sophisticated analysis


## Documentation

- [Documentation System Guide](docs/) - Understanding the 3-tier architecture
- [Commands Reference](commands/) - Detailed command usage
- [MCP Integration](docs/CLAUDE.md) - Configuring external services
- [Hooks System](hooks/) - Security scanning, context injection, and notifications
- [Changelog](CHANGELOG.md) - Version history and migration guides

## Contributing

The kit represents one approach to AI-assisted development. Contributions and adaptations are welcome.

## FAQ

**Q: Will the setup overwrite my existing files?**

**A:** No, the installer detects existing files and prompts you to skip or overwrite each one. For safety, I highly recommend installing on a new Git branch. Safe is safe.

**Q: Can I use this with other AI coding tools like Cursor, Cline, or Gemini CLI?**

**A:** Partially. The documentation structure works with any tool (rename CLAUDE.md to match your tool's convention). However, commands are highly optimized for sub-agent usage and hooks are Claude Code-specific. Other tools would need significant adaptation of the orchestration features.

**Q: How much will this cost in tokens?**

**A:** This framework uses tokens heavily due to comprehensive context loading and sub-agent usage. I strongly recommend a Claude Code Max 20x subscription over pay-per-token API usage. The Claude 4 Opus model currently performs best for complex instruction following.

**Q: Can I use other coding consultant MCPs like Zen instead for Gemini Consultation?**

**A:** While technically possible, the templates and hooks are specifically configured and optimized for my Gemini MCP server (available through the link provided during installation). Using alternative coding consultant MCPs would require adjusting the templates, hooks, and potentially the command structures to match their specific interfaces and capabilities.

**Q: Can I use this framework with an existing project?**

**A:** Yes! The framework works well with existing projects. When installing, check if you already have a project structure or CLAUDE.md file and adjust accordingly during the setup prompts. To get started with an existing codebase, use Claude Code with sub-agents to understand your project and create the initial project-structure.md:

```
"Read and understand the project_structure.md template in docs/ai-context/project_structure.md. Your task is to fill out this template with our project's details. For this send out sub agents in parallel across the whole code base. Once the sub agents get back, ultrathink and create the markdown file."
```

After creating the project structure, use the framework's documentation generation system to create component-level and feature-level context files:

```
/create-docs "[your-main-component-path]/CONTEXT.md"
```

This approach lets the framework learn your existing architecture and systematically create appropriate documentation that matches your current project structure.

## Connect

Feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/peterkrueck/) if you have questions, need clarification, or wish to provide feedback.
