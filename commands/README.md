# Command Templates

Multi-agent orchestration templates that structure sophisticated AI development workflows.

## How Commands Work

Each command template leverages Claude Code's **sub-agent spawning capability** to orchestrate parallel analysis by specialized AI agents. Commands automatically load project context and integrate with MCP servers for enhanced expertise.

## Available Templates

### full-context.md
**Adaptive multi-agent analysis** - Intelligently scales from direct analysis to complex multi-agent orchestration based on task complexity. Spawns specialized sub-agents for comprehensive code understanding.

### code-review.md  
**Production-focused review** - Dynamically allocates specialized agents (security, performance, architecture) based on review scope. Surfaces only critical, high-impact findings with quantified business impact.

### refactor.md
**Strategic refactoring orchestration** - Systematic multi-agent analysis of refactoring scope, impact assessment, and incremental implementation planning with risk mitigation.

### handoff.md
**Knowledge transfer coordination** - Structures comprehensive project handoffs with context preservation, task continuity, and team transition management.

### create-docs.md & update-docs.md
**Documentation workflow automation** - Orchestrates documentation generation, consistency checking, and lifecycle integration across development workflows.

## Usage

```bash
# Commands integrate automatically with documentation system and MCP servers
claude exec full-context "analyze authentication system"
claude exec code-review "review payment processing security" 
claude exec refactor "optimize data pipeline performance"
```

## Template Structure

Each command template includes:
- **Multi-agent strategy selection** - Adaptive orchestration based on complexity
- **Context auto-loading** - Efficient integration with documentation system  
- **MCP server integration** - Leverages external expertise (Gemini, Context7)
- **Result synthesis** - Combines findings from multiple specialized agents

## Customization

Adapt templates for your specific:
- **Agent allocation patterns** - Modify how sub-agents are spawned and specialized
- **Context loading strategy** - Customize which documentation auto-loads
- **Integration workflows** - Adjust MCP server usage patterns
- **Output synthesis** - Tailor how multi-agent results are combined

Commands work as part of the integrated framework - see the [main README](../README.md) for complete system architecture.