# Documentation Architecture Template

This template demonstrates a **3-tier documentation system** that organizes knowledge by stability and scope, enabling efficient AI context loading and scalable development.

## How the 3-Tier System Works

**Tier 1 (Foundation)**: Stable, system-wide documentation that rarely changes - architectural principles, technology decisions, cross-component patterns, and core development protocols.

**Tier 2 (Component)**: Architectural charters for major components - high-level design principles, integration patterns, and component-wide conventions without feature-specific details.

**Tier 3 (Feature-Specific)**: Granular documentation co-located with code - specific implementation patterns, technical details, and local architectural decisions that evolve with features.

This hierarchy allows AI agents to load targeted context efficiently while maintaining a stable foundation of core knowledge.

## Documentation Principles
- **Co-location**: Documentation lives near relevant code
- **Smart Extension**: New documentation files created automatically when warranted
- **AI-First**: Optimized for efficient AI context loading and machine-readable patterns

## Tier 1: Foundational Documentation (System-Wide)

Example foundational documents for your project:

- **[Master Context](/CLAUDE.md)** - *Essential for every session.* Coding standards, security requirements, MCP server integration patterns, and development protocols
- **[Project Structure](/docs/ai-context/project-structure.md)** - *REQUIRED reading.* Complete technology stack, file tree, and system architecture. Must be attached to Gemini consultations
- **[System Integration](/docs/ai-context/system-integration.md)** - *For cross-component work.* Communication patterns, data flow, testing strategies, and performance optimization
- **[Deployment Infrastructure](/docs/ai-context/deployment-infrastructure.md)** - *Infrastructure patterns.* Containerization, monitoring, CI/CD workflows, and scaling strategies
- **[Task Management](/docs/ai-context/handoff.md)** - *Session continuity.* Current tasks, documentation system progress, and next session goals

## Tier 2: Component-Level Documentation

Component-specific context files for major system areas:

- **[Backend Context](/[backend-dir]/CLAUDE.md)** - *Server implementation.* API patterns, database integration, service architecture, and performance considerations
- **[Frontend Context](/[frontend-dir]/CLAUDE.md)** - *Client implementation.* UI patterns, state management, user interactions, and integration points
- **[Mobile Context](/[mobile-dir]/CLAUDE.md)** - *Mobile implementation.* Platform-specific patterns, native integrations, and cross-platform considerations
- **[Infrastructure Context](/[infra-dir]/CLAUDE.md)** - *DevOps implementation.* Deployment automation, monitoring setup, and operational procedures

## Tier 3: Feature-Specific Documentation

Granular CLAUDE.md files co-located with code for minimal cascade effects:

### Backend Feature Documentation
Example backend documentation structure:
- **[Core Services](/[backend]/src/core/CLAUDE.md)** - *Business logic patterns.* Service architecture, data processing, integration patterns, and error handling
- **[API Layer](/[backend]/src/api/CLAUDE.md)** - *API patterns.* Endpoint design, validation, middleware, and request/response handling
- **[Data Layer](/[backend]/src/data/CLAUDE.md)** - *Data patterns.* Database models, queries, migrations, and data access patterns

### Frontend Feature Documentation
Example frontend documentation structure:
- **[UI Components](/[frontend]/src/components/CLAUDE.md)** - *Component patterns.* Reusable components, styling, state management, and interaction patterns
- **[API Client](/[frontend]/src/api/CLAUDE.md)** - *Client patterns.* HTTP clients, error handling, caching, and data synchronization
- **[State Management](/[frontend]/src/store/CLAUDE.md)** - *State patterns.* Global state, local state, data flow, and persistence

### Shared/Utility Documentation
Cross-cutting concerns documentation:
- **[Logging System](/src/utils/logging/CLAUDE.md)** - *Logging patterns.* Structured logging, correlation IDs, performance monitoring, and debugging support
- **[Security Utils](/src/utils/security/CLAUDE.md)** - *Security patterns.* Authentication, authorization, input validation, and secure communication
- **[Testing Utils](/src/utils/testing/CLAUDE.md)** - *Testing patterns.* Test utilities, mocking strategies, integration testing, and performance testing

## Template Customization

To implement this documentation structure in your project:

1. **Adapt Tier 1 Structure**:
   - Copy foundational documents to your project root and docs folder
   - Update file paths to match your project structure
   - Replace placeholder content with your specific architectural decisions

2. **Create Tier 2 Components**:
   - Add CLAUDE.md files to major component directories
   - Document component-specific patterns and integration points
   - Keep content focused on architectural principles, not implementation details

3. **Establish Tier 3 Features**:
   - Co-locate CLAUDE.md files with feature code
   - Document specific implementation patterns and local decisions
   - Keep content granular and focused on immediate code context

4. **Maintain Documentation Hygiene**:
   - Update documentation when making architectural changes
   - Remove outdated documentation to prevent confusion
   - Ensure AI agents can efficiently navigate the structure

## Benefits for AI Development

This documentation architecture enables:
- **Efficient Context Loading**: AI agents load only relevant documentation
- **Scalable Knowledge Management**: Documentation grows with project complexity
- **Consistent Patterns**: Standardized approaches across all development areas
- **Reduced Context Overhead**: Targeted documentation reduces token usage
- **Enhanced AI Understanding**: Structured information improves AI assistance quality

## Integration with Commands

This documentation structure works seamlessly with command templates:
- **Auto-loading**: Commands automatically load relevant tier documentation
- **Context Hierarchy**: AI agents understand which documentation to prioritize
- **Efficient Workflows**: Multi-agent commands can partition work by documentation tiers
- **Consistent Quality**: Documentation standards ensure reliable AI assistance

---

*This template provides a proven structure for organizing project documentation to maximize AI assistance effectiveness. Adapt it based on your specific project architecture and development needs.*