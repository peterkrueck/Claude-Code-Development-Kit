# Changelog

All notable changes to the Claude Code Development Kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


### What's New in v2.0.0:
- **Security**: Automatic scanning prevents accidental exposure of API keys and secrets
- **Context Enhancement**: Project structure automatically included in Gemini consultations
- **Sub-Agent Context**: All sub-agents now automatically receive core project documentation
- **Developer Experience**: Audio notifications for task completion and input requests
- **No Breaking Changes**: All v1.0.0 features remain unchanged and fully compatible


## [2.0.0] - 2025-07-08

### Added
- Comprehensive hooks system as 4th core framework component
  - Security scanner hook to prevent accidental exposure of secrets when using MCP servers
  - Gemini context injector for automatic project structure inclusion in consultations
  - Subagent context injector for automatic documentation inclusion in all sub-agent tasks
  - Cross-platform notification system with audio feedback
- Hook setup command (`/hook-setup`) for easy configuration verification
- Settings template for Claude Code configuration with all hooks pre-configured
- Hook configuration examples and comprehensive documentation
- Multi-Agent Workflows documentation section in `docs/CLAUDE.md`
- Automatic context injection documentation in `commands/README.md`


### Improved
- Developer experience with automatic sub-agent context injection
- More consistent multi-agent workflow patterns across all commands
- Simplified sub-agent prompts by removing manual context loading

### Changed
- Tier 2 and Tier 3 documentation files renamed from CLAUDE.md to CONTEXT.md
- Updated all documentation and templates to reflect new naming convention
- Clarified that only Tier 1 (master context) remains as CLAUDE.md


## [1.0.0] - 2025-07-01

### Added
- Initial framework release with 3 core components
- 3-tier documentation system (Foundation/Component/Feature)
- Command templates for multi-agent workflows
  - `/full-context` - Comprehensive context gathering and analysis
  - `/code-review` - Multi-perspective code analysis
  - `/update-docs` - Documentation synchronization
  - `/create-docs` - Initial documentation generation
  - `/refactor` - Intelligent code restructuring
  - `/handoff` - Session context preservation
- MCP server integration patterns (Context7, Gemini)
- Auto-loading mechanism for critical documentation
- Comprehensive documentation structure with routing system
- Example templates for issues and specifications
- Integration guide for external AI services

### Core Features
- Automatic context management through documentation hierarchy
- Sub-agent orchestration for complex tasks
- Seamless integration with external AI expertise
- Self-maintaining documentation system


## Upgrading from v1.0.0 to v2.0.0

The hooks system is optional but recommended for enhanced security and developer experience.

### To add hooks to your existing v1.0.0 project:

1. **Copy the hooks directory to your project**:
   ```bash
   cp -r hooks your-project/.claude/hooks/
   ```

2. **Configure hooks in your project**:
   ```bash
   # Copy the settings template to your project
   cp hooks/setup/settings.json.template your-project/.claude/settings.json
   
   # Edit to update the WORKSPACE path
   # All hooks including subagent-context-injector are pre-configured
   ```

3. **Test the installation**:
   ```bash
   # Run the hook setup verification
   /hook-setup
   ```

4. **Update existing command files** (optional):
   - Commands will work without changes, but you can simplify sub-agent prompts
   - Remove manual `Read /CLAUDE.md` instructions from Task prompts
   - Sub-agents now automatically receive core documentation