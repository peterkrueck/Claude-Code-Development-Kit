# Documentation Architecture

The VR Language Learning App uses a **3-tier documentation system** that organizes knowledge by stability and scope, enabling efficient AI context loading and scalable development.

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
- **[Master Context](/CLAUDE.md)** - *Essential for every session.* Coding standards, security requirements, MCP server integration patterns, and development protocols
- **[Project Structure](/docs/ai-context/project-structure.md)** - *REQUIRED reading.* Complete technology stack, file tree, and Push-to-Talk Live API pipeline architecture. Must be attached to Gemini consultations
- **[System Integration](/docs/ai-context/system-integration.md)** - *For cross-component work.* Production Socket.IO patterns, LangChain integration, Unity migration preparation, and testing strategies
- **[Deployment Infrastructure](/docs/ai-context/deployment-infrastructure.md)** - *Placeholder.* Docker, monitoring, CI/CD patterns (content being developed)
- **[Task Management](/docs/ai-context/HANDOFF.md)** - *Session continuity.* Current tasks, 3-tier documentation system progress, and next session goals

## Tier 2: Component-Level Documentation
- **[Tutor Server Context](/agents/tutor-server/CLAUDE.md)** - *Backend implementation.* Push-to-Talk Live API pipeline, Socket.IO streaming, circuit breaker patterns, and API endpoint specifications
- **[Web Dashboard Context](/web-dashboard/CLAUDE.md)** - *Frontend implementation.* Testing interface, audio processing utilities, modular components, and Unity migration preparation

## Tier 3: Feature-Specific Documentation
Granular CLAUDE.md files co-located with code for minimal cascade effects:

### Backend Feature Documentation
- **[Voice Pipelines](/agents/tutor-server/src/core/pipelines/CLAUDE.md)** - *Implementation patterns.* Single pipeline architecture, audio streaming, timeline synchronization, and performance optimizations with code examples
- **[AI Service Providers](/agents/tutor-server/src/core/providers/CLAUDE.md)** - *Resilience patterns.* Circuit breaker implementation, API integration templates, structured error handling, and correlation ID logging
- **[API Endpoints](/agents/tutor-server/src/api/CLAUDE.md)** - *FastAPI patterns.* Unified endpoints, Pydantic models, middleware implementation, and Socket.IO streaming integration

### Frontend Feature Documentation
- **[Audio Processing](/web-dashboard/src/lib/audio/CLAUDE.md)** - *Browser audio.* PCM-to-WAV conversion, Web Audio API patterns, progressive playback, microphone recording, and timeline synchronization
- **[Client-Side APIs](/web-dashboard/src/lib/api/CLAUDE.md)** - *HTTP/Socket.IO clients.* Modular composition patterns, error handling, retry logic, voice processing integration, and session management
- **[UI Components](/web-dashboard/src/lib/components/CLAUDE.md)** - *Svelte patterns.* Modular component design, TypeScript interfaces, store integration, audio visualization, and TutorAI-specific implementations
- **[Logging System](/web-dashboard/src/lib/utils/logging/CLAUDE.md)** - *Structured logging.* Category-based filtering with 85% noise reduction, persistent Settings page integration, smart audio throttling, and correlation ID tracking
