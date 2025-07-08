# Claude Code AI Development Framework

An integrated system that transforms Claude Code into an orchestrated development environment through automated documentation management, multi-agent workflows, and external AI expertise.

## System Overview

The framework leverages Claude Code's sub-agent orchestration capabilities to create a self-maintaining development system. Four core components work together to deliver automated, context-aware AI assistance:

1. **Documentation System** - Structured context that auto-loads based on task requirements
2. **Command Templates** - Orchestration patterns for multi-agent workflows
3. **MCP Servers** - External AI services providing current documentation and consultation
4. **Hooks System** - Automated security scanning, context injection, and developer experience enhancements

## Terminology

- **CLAUDE.md** - Master context files containing project-specific AI instructions, coding standards, and integration patterns
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

This ensures:
- Consistent AI behavior across all sessions
- Zero manual context management
- Efficient token usage through targeted loading

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
- Project structure auto-attaches to Gemini consultations
- Ensures external AI understands specific architecture
- Makes all recommendations project-relevant

### Hooks Integration

The framework includes battle-tested hooks that enhance Claude Code's capabilities:

- **Security Scanner** - Prevents accidental exposure of secrets when using MCP servers
- **Context Injector** - Automatically includes Tier 1 files in Gemini consultations
- **Notification System** - Provides audio feedback for task completion and input requests

These hooks integrate seamlessly with the command and MCP server workflows, providing:
- Pre-execution security checks for all external AI calls
- Automatic context enhancement for better AI responses
- Developer awareness through pleasant audio notifications

## Quick Start

### Prerequisites

- **Required**: [Claude Code](https://claude.ai/code)
- **Recommended**: MCP servers like [Context7](https://github.com/upstash/context7) or [Gemini Assistant](https://github.com/peterkrueck/mcp-gemini-assistant)

### Installation

1. **Copy framework structure**:
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
   - See [hooks/README.md](hooks/) for setup instructions


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
│   │   └── notify.sh
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
│   └── CLAUDE.md              # Backend context (Tier 2)
└── backend/src/api/
    └── CLAUDE.md              # API context (Tier 3)
```

## Configuration

The framework is designed for adaptation:

- **Commands** - Modify orchestration patterns in `.claude/commands/`
- **Documentation** - Adjust tier structure for your architecture
- **MCP Integration** - Add additional servers for specialized expertise
- **Hooks** - Customize security patterns, add new hooks, or modify notifications in `.claude/hooks/`

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

## Contributing

The framework represents one approach to AI-assisted development. Contributions and adaptations are welcome.

## Connect

Feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/peterkrueck/) if you have questions, need clarification, or wish to provide feedback.

---

*Built for developers seeking automated, context-aware AI assistance without manual overhead.*