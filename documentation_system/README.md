# Documentation System

This directory contains templates for creating AI-optimized documentation structures that enable sophisticated Claude Code workflows with MCP server integration.

## Components

### CLAUDE-template.md
The master AI context file that serves as the primary instruction set for Claude Code. Contains:
- Project overview and architecture
- Coding standards and conventions
- MCP server integration patterns (Gemini and Context7)
- Development workflow instructions

### ai-context/
Structured documentation templates optimized for AI consumption:

- **project-structure-template.md**: Complete technology stack and file tree documentation
- **docs-overview-template.md**: Documentation architecture and available resources
- **handoff-template.md**: Knowledge transfer and context switching documentation
- **system-integration-template.md**: Cross-cutting integration patterns and data flow

### open-issues/
Issue tracking and documentation templates:

- **README.md**: Guide for documenting technical issues
- **example-api-performance-issue.md**: Template for bug reports and technical problems

### specs/
Feature and integration specification templates:

- **README.md**: Guide for creating technical specifications
- **example-feature-specification.md**: Template for feature planning and implementation
- **example-api-integration-spec.md**: Template for external service integrations

## Usage

1. **Copy CLAUDE-template.md** to your project root as `CLAUDE.md`
2. **Copy the complete documentation_system/ structure** to your project's `docs/` folder
3. **Customize templates** with your project-specific information:
   - Replace placeholder text with actual project details
   - Update file paths and references to match your project structure
   - Add your specific technology stack and patterns
4. **Install required MCP servers**:
   - [Gemini MCP Server](https://github.com/peterkrueck/gemini-mcp) for AI consultation
   - [Context7 MCP Server](https://github.com/upstash/context7) for documentation access

## Key Principles

- **AI-First Design**: Documentation structured for optimal AI consumption
- **Context Layering**: Information organized by frequency of AI access
- **Auto-Loading**: Critical context files automatically loaded by commands
- **Adaptive Scope**: Documentation that scales with project complexity
- **MCP Integration**: Seamless integration with specialized AI servers

## Integration with Commands

The documentation system integrates seamlessly with the command templates, providing:
- Automatic context loading for AI analysis
- Structured information hierarchy for multi-agent workflows
- Consistent patterns across development workflows
- Reduced context management overhead
- Enhanced AI capabilities through MCP server integration

## MCP Server Integration

### Gemini Consultation
- Complex coding problems requiring deep analysis
- Multi-turn conversations with context retention
- File attachment and session management
- Specialized assistance modes (solution, review, debug, optimize)

### Context7 Documentation
- Up-to-date library and framework documentation
- Topic-focused documentation retrieval
- Support for specific library versions
- Integration with current development practices

## Template Customization

When adapting templates:

1. **Project-Specific Details**: Replace all placeholder text with your actual project information
2. **Technology Stack**: Update examples to match your specific frameworks and tools
3. **File Paths**: Adjust all file references to match your project structure
4. **Command Integration**: Ensure documentation paths match your command templates
5. **MCP Configuration**: Set up MCP servers according to your development needs

## Benefits for AI Development

This documentation structure enables:
- **Enhanced AI Understanding**: Comprehensive project context for better assistance
- **Sophisticated Workflows**: Multi-agent analysis and implementation patterns
- **Consistent Quality**: Standardized approaches across development tasks
- **Reduced Setup Time**: Templates accelerate new project documentation
- **Scalable Practices**: Documentation that grows with project complexity

The system transforms AI-assisted development from simple Q&A to sophisticated, context-aware collaboration with specialized AI capabilities through MCP server integration.