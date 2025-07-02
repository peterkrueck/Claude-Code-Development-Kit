# Command Templates

Sophisticated Claude Code command templates for advanced AI-assisted development workflows.

## Available Commands

### full-context.md
Multi-agent context analysis system that:
- Intelligently decides between direct analysis and multi-agent orchestration
- Launches specialized sub-agents in parallel for complex tasks
- Synthesizes findings from multiple perspectives
- Adapts strategy based on task complexity

### code-review.md
Production-focused code review that surfaces only critical, high-impact findings:
- Prioritizes needle-moving discoveries over exhaustive lists
- Uses dynamic agent allocation based on review scope
- Focuses on security, performance, and architectural concerns
- Provides actionable fixes with quantified impact

### refactor.md
Strategic refactoring approach for complex codebases:
- Systematic analysis of refactoring scope and impact
- Risk assessment and mitigation strategies
- Incremental refactoring plans with verification steps

### handoff.md
Knowledge transfer and context switching documentation:
- Comprehensive project handoff procedures
- Context preservation for team transitions
- Documentation of current state and pending work

### create-docs.md & update-docs.md
Documentation management workflows:
- Automated documentation generation and updates
- Consistency checking across documentation
- Integration with project development lifecycle

## Usage Patterns

Execute commands using Claude Code:
```bash
claude exec full-context "analyze the authentication system"
claude exec code-review "review the payment processing module"
claude exec refactor "optimize the data processing pipeline"
```

## Customization

Each command template can be customized for your specific:
- Project architecture and patterns
- Technology stack and frameworks
- Development workflow requirements
- Team collaboration needs

## Integration with MCP Servers

Commands are designed to leverage MCP servers for enhanced capabilities:
- Gemini consultation for complex analysis
- Context7 for up-to-date documentation
- Custom MCP servers for domain-specific tasks