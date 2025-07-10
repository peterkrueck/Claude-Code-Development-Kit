# Claude Code Development Kit

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/peterkrueck/Claude-Code-Development-Kit/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/changelog-v2.0.0-orange.svg)](CHANGELOG.md)

An integrated system that transforms Claude Code into an orchestrated development environment through automated documentation management, multi-agent workflows, and external AI expertise.

## System Overview

The kit leverages Claude Code's sub-agent orchestration capabilities to create a self-maintaining development system. Four core components work together to deliver automated, context-aware AI assistance:

1. **Documentation System** - Structured context that auto-loads based on task requirements
2. **Command Templates** - Orchestration patterns for multi-agent workflows
3. **MCP Servers** - External AI services providing current documentation and consultation
4. **Hooks System** - Automated security scanning, context injection, and developer experience enhancements

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

**Commands → MCP Servers**
- Context7 provides up-to-date library documentation
- Gemini offers architectural consultation for complex problems
- Integration happens seamlessly within command workflows

**Documentation → MCP Servers**
- Project structure and MCP assistant rules auto-attach to Gemini consultations
- Ensures external AI understands specific architecture and coding standards
- Makes all recommendations project-relevant and standards-compliant

### Hooks Integration

The kit includes battle-tested hooks that enhance Claude Code's capabilities:

- **Security Scanner** - Prevents accidental exposure of secrets when using MCP servers
- **Gemini Context Injector** - Automatically includes project structure in Gemini consultations
- **Subagent Context Injector** - Ensures all sub-agents receive core documentation automatically
- **Notification System** - Provides non-blocking audio feedback for task completion and input requests

These hooks integrate seamlessly with the command and MCP server workflows, providing:
- Pre-execution security checks for all external AI calls
- Automatic context enhancement for both external AI and sub-agents
- Consistent knowledge across all agents in multi-agent workflows
- Developer awareness through pleasant, non-blocking audio notifications

## Quick Start

### Prerequisites

- **Required**: [Claude Code](https://claude.ai/code)
- **Recommended**: MCP servers like [Context7](https://github.com/upstash/context7) and [Gemini Assistant](https://github.com/peterkrueck/mcp-gemini-assistant)

### Installation

1. **Copy kit structure**:
   ```bash
   cp -r docs/* your-project/docs/
   cp -r commands your-project/.claude/commands/
   cp -r hooks your-project/.claude/hooks/
   ```

2. **Configure foundation files**:
   ```bash
   # Update with your technology stack
   docs/ai-context/project-structure.md
   
   # Customize for your directory layout
   docs/ai-context/docs-overview.md
   
   # Set project-specific standards
   CLAUDE.md
   ```

3. **Install hooks**
   ```bash
   cp hooks/setup/settings.json.template your-project/.claude/settings.json
   # See [hooks/README.md](hooks/) for detailed setup
   ```

4. **If using Gemini MCP server** (recommended):
   ```bash
   # Copy and customize MCP assistant rules
   cp docs/MCP-ASSISTANT-RULES.md your-project/MCP-ASSISTANT-RULES.md
   
   # Edit to include your project-specific:
   # - Coding standards and conventions
   # - Security requirements
   # - Domain-specific guidelines
   # - Performance considerations
   ```
   This file will be automatically included in all Gemini consultations to ensure the AI understands your project's specific requirements.


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

## Example Project Structure

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
│   └── CONTEXT.md              # Backend context (Tier 2)
└── backend/src/api/
    └── CONTEXT.md              # API context (Tier 3)
```

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

*Built for developers seeking automated, context-aware AI assistance without manual overhead.*