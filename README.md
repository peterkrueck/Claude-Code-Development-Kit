# Claude Code Development Kit

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/peterkrueck/Claude-Code-Development-Kit/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/changelog-v2.0.0-orange.svg)](CHANGELOG.md)

An integrated system that transforms Claude Code into an orchestrated development environment through automated documentation management, multi-agent workflows, and external AI expertise.

## Why This Kit?

Ever tried to build a large project with AI assistance, only to watch it struggle as your codebase grows? As AI-assisted development scales, three critical challenges emerge:

### 1. Context Management
Your AI's output quality directly depends on what it knows about your project. In growing codebases, Claude Code can lose track of your architecture, forget your coding standards, or miss critical dependencies. This kit solves this with a structured 3-tier documentation system that automatically loads the right context at the right time - no more copy-pasting the same context over and over.

### 2. AI Reliability 
Even advanced AI models hallucinate and make mistakes. The kit implements a "four eyes principle" through MCP integration:
- **Context7** provides real-time, up-to-date library documentation beyond Claude's training cutoff
- **Gemini** offers architectural consultation and cross-validation for complex problems
- Together, they catch errors, reduce hallucinations, and ensure your code follows current best practices

### 3. Automation Without Complexity
Manual context loading, repetitive commands, and workflow management slow you down. The kit automates everything through intelligent hooks and command orchestration - from security scanning to context injection - delivering faster, more accurate results without the overhead.

**The result**: Claude Code transforms from a helpful tool into a reliable development partner that remembers your project context, validates its own work, and handles the tedious stuff automatically.


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

The `subagent-context-injector.sh` hook extends auto-loading to all sub-agents:
- Sub-agents spawned via the Task tool automatically receive the same core documentation
- No manual context inclusion needed in Task prompts
- Ensures consistent knowledge across all agents in multi-agent workflows

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
- **Subagent Context Injector** - Ensures all sub-agents receive core documentation automatically
- **Notification System** - Provides non-blocking audio feedback for task completion and input requests (optional)

These hooks integrate seamlessly with the command and MCP server workflows, providing:
- Pre-execution security checks for all external AI calls
- Automatic context enhancement for both external AI and sub-agents
- Consistent knowledge across all agents in multi-agent workflows
- Developer awareness through pleasant, non-blocking audio notifications

## Quick Start

### Prerequisites

- **Required**: [Claude Code](https://github.com/anthropics/claude-code)
- **Recommended**: MCP servers like [Context7](https://github.com/upstash/context7) and [Gemini Assistant](https://github.com/peterkrueck/mcp-gemini-assistant)

### Installation

#### Option 1: Quick Install (Recommended)

Run this single command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/peterkrueck/Claude-Code-Development-Kit/main/install.sh | bash
```

This will:
1. Download the framework
2. Guide you through an interactive setup
3. Install everything in your chosen project directory
4. Provide links to optional MCP server installations

#### Option 2: Clone and Install

```bash
git clone https://github.com/peterkrueck/Claude-Code-Development-Kit.git
cd Claude-Code-Development-Kit
./setup.sh
```

### What Gets Installed

The setup script will create the following structure in your project:

```
your-project/
├── commands/              # AI orchestration templates (.md files)
├── hooks/                 # Automation scripts
│   ├── config/            # Security patterns configuration
│   ├── sounds/            # Notification sounds (if notifications enabled)
│   └── *.sh               # Hook scripts (based on your selections)
├── docs/                  # Documentation templates and examples
│   ├── ai-context/        # Core documentation files
│   ├── open-issues/       # Issue tracking examples
│   └── specs/             # Specification templates
├── logs/                  # Hook execution logs (created at runtime)
├── .claude/               
│   └── settings.local.json # Generated Claude Code configuration
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
   - Configure in `.claude/settings.local.json`

3. **Test your installation**:
   ```bash
   claude
   /full-context "analyze my project structure"
   ```


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
│   │   └── subagent-context-injector.sh
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
├── backend/
│   └── CONTEXT.md              # Backend context (Tier 2) - create this
└── backend/src/api/
    └── CONTEXT.md              # API context (Tier 3) - create this
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

## Connect

Feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/peterkrueck/) if you have questions, need clarification, or wish to provide feedback.

---


## ADDITIONAL DISCLAIMER:

This AI Development Framework is provided as an educational and development tool.
Users are solely responsible for:
- The security and safety of their own systems
- Any code generated or modified using this framework
- Compliance with all applicable laws and regulations
- Validation and testing of any implementations

The author assumes no liability for:
- Data loss or system damage
- Security vulnerabilities introduced through use
- Costs incurred from AI service usage
- Any direct or indirect consequences of using this framework

USE AT YOUR OWN RISK. Always review and understand code before execution.