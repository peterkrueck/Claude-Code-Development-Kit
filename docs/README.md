# Documentation Templates

AI-optimized documentation templates that enable sophisticated Claude Code workflows through structured context and auto-loading integration.

## Documentation Architecture: 3-Tier System

This system organizes knowledge by **stability and scope** for efficient AI context loading:

**Tier 1 (Foundation)** - Stable, system-wide documentation that rarely changes  
**Tier 2 (Component)** - Architectural charters for major components  
**Tier 3 (Feature-Specific)** - Granular documentation co-located with code

This hierarchy allows AI agents to load targeted context efficiently while maintaining a stable foundation of core knowledge.

## CLAUDE.md 3-Tier Implementation

The framework includes templates for implementing CLAUDE.md files at each documentation tier:

**Tier 1 (claude-master)** - Project root `CLAUDE.md`  
- Master AI context with project overview and coding standards
- MCP server integration patterns and development protocols  
- System-wide architectural decisions and quality requirements
- Auto-loaded by all commands for consistent AI assistance

**Tier 2 (Component)** - Major component directories  
- Component-specific context referencing master CLAUDE.md
- Architecture patterns and implementation guidelines for that component
- Key module structure and integration points
- Critical implementation details with code examples

**Tier 3 (Feature-Specific)** - Feature/module subdirectories
- Focused technical documentation for specific implementations  
- Detailed code patterns and architectural decisions
- Performance optimizations and error handling approaches
- Integration patterns and technical trade-offs

**Implementation Example**:
```
your-project/
├── CLAUDE.md                          # Tier 1 (claude-master)
├── backend/
│   ├── CLAUDE.md                      # Tier 2 (component)
│   └── src/api/
│       └── CLAUDE.md                  # Tier 3 (feature-specific)
└── frontend/  
    ├── CLAUDE.md                      # Tier 2 (component)
    └── src/components/
        └── CLAUDE.md                  # Tier 3 (feature-specific)
```

## Directory Structure

### ai-context/
**Foundation templates for Tier 1 documentation**

- **project-structure.md** - Technology stack and file tree template
- **docs-overview.md** - 3-tier documentation architecture template
- **system-integration.md** - Cross-component integration patterns
- **deployment-infrastructure.md** - Infrastructure and deployment patterns
- **handoff.md** - Task management and session continuity template

### open-issues/
**Issue tracking templates**

Templates for documenting technical problems, bugs, and improvements requiring investigation or resolution.

- **example-api-performance-issue.md** - Comprehensive issue documentation template

### specs/
**Specification templates**

Templates for documenting technical specifications, feature requirements, and implementation plans.

- **example-feature-specification.md** - Feature and component specification template
- **example-api-integration-spec.md** - External service integration template

### CLAUDE.md Templates
**3-Tier AI context system**

Complete template system for structured AI context management across project levels:

- **CLAUDE.md** - Master AI context template (claude-master, Tier 1)
- **claude-tier2-component.md** - Component-level context template (Tier 2)  
- **claude-tier3-feature.md** - Feature-specific context template (Tier 3)

## Template Purposes

### Foundation Templates (ai-context/)
- **project-structure.md** - Documents complete technology stack, file organization, and architectural decisions
- **docs-overview.md** - Explains 3-tier documentation system implementation and context loading strategies
- **system-integration.md** - Provides patterns for component communication, data flow, and cross-cutting concerns
- **deployment-infrastructure.md** - Templates for containerization, CI/CD, monitoring, and scaling strategies
- **handoff.md** - Structures task continuity, session transitions, and knowledge transfer processes

### Process Templates
- **open-issues/** - Systematic issue tracking with root cause analysis and solution planning
- **specs/** - Structured specification development with requirements, implementation phases, and testing strategies

### Integration Templates (CLAUDE.md System)
- **CLAUDE.md (claude-master)** - Tier 1 master AI context providing project overview, coding standards, and MCP server integration patterns
- **claude-tier2-component.md** - Tier 2 component-specific context template with architecture patterns and implementation guidelines  
- **claude-tier3-feature.md** - Tier 3 feature-specific context template with detailed implementation patterns and technical decisions

## Usage

```bash
# Copy complete structure to your project
cp -r docs/* your-project/docs/

# Customize CLAUDE.md with project specifics
# Replace placeholders in ai-context/ templates
# Adapt process templates for your workflow
```

## Integration with Framework

Templates auto-load into Claude Code commands based on task scope, providing:
- **Efficient context loading** - AI agents load only relevant documentation tiers
- **Consistent AI instructions** - Standardized patterns across all development tasks
- **MCP server integration** - Seamless connection to external AI expertise
- **Scalable documentation** - Structure grows with project complexity

Part of the integrated Claude Code AI Development Framework - see [main README](../README.md) for complete system architecture.