# Project Structure

This document provides the complete technology stack and file tree structure for the VR Language Learning App. **AI agents MUST read this file to understand the project organization before making any changes.**

## Technology Stack

### Backend Technologies
- **Python 3.11+** with **Poetry** - Dependency management and packaging
- **FastAPI 0.115.0+** - Web framework with type hints and async support
- **Uvicorn 0.32.0+** - ASGI server with standard extras
- **Pydantic Settings 2.5.2+** - Configuration management with type validation

### AI/ML Services & Integrations
- **Groq Whisper Large V3 Turbo** - Speech-to-Text (STT) via Groq API
- **Google Generative AI SDK 0.8.0+** - LLM integration (Gemini 2.5 Flash Preview)
- **Google Cloud Text-to-Speech 2.17.1+** - Primary TTS provider
- **LangChain Core 0.3.0+** - Minimal LangChain integration for AI workflows
- **LangSmith 0.2.0+** - LLM observability and tracing

### Real-time Communication
- **Socket.IO** - WebSocket streaming for PTT Gemini Live pipeline
  - Python-SocketIO 5.11.0+ (server)
  - Socket.IO Client 4.7.0 (frontend)
- **AIOHTTP 3.12.13+** - Async HTTP client/server

### API Resilience & Observability
- **aiobreaker 1.2.0+** - Circuit breaker pattern for Gemini API calls
- **Structlog 24.1.0+** - Structured logging with JSON formatting and correlation IDs
- **Client-side Smart Logging** - Category-based filtering with 85% noise reduction and persistent settings
- **Prometheus FastAPI Instrumentator 7.0.0+** - Metrics collection

### Voice Processing Architecture
- **Web Audio API** - Browser-based audio recording and processing
- **Timeline-synchronized progressive audio playback** - Streaming audio with real-time synchronization
- **Push-to-Talk Live API Pipeline** - Real-time voice processing with Gemini 2.5 Flash Preview Native Audio Dialog


### Frontend Technologies
- **TypeScript 5.8.3+** - Type-safe JavaScript development
- **SvelteKit 2.21.3+** - Full-stack Svelte framework
- **Svelte 5.33.18+** - Component framework
- **Vite 6.3.5+** - Build tool and development server
- **@sveltejs/adapter-static 3.0.8+** - Static site generation

### Development & Quality Tools
- **Black 24.0.0+** - Code formatting
- **Ruff 0.7.0+** - Fast Python linter
- **MyPy 1.13.0+** - Static type checking
- **pytest 8.0.0+** with pytest-asyncio - Testing framework
- **Make** - Task automation and orchestration

### Future Technologies
- **Unity 2022.3 LTS** - VR client (Phase 3, directory structure ready)
- **Supabase** - Database and authentication (infrastructure ready)
- **Meta Quest integration** - VR platform bridging

## Complete Project Structure

```
VR-Language-App/
├── CLAUDE.md                           # Master AI context file (this file)
├── Makefile                            # Root-level development commands
├── .gitignore                          # Git ignore patterns
├── .vscode/                            # VS Code workspace configuration
│   ├── settings.json                   # Python, formatting, linting settings
│   ├── extensions.json                 # Recommended extensions
│   └── launch.json                     # Debug configurations
├── agents/                             # AI agent servers
│   └── tutor-server/                   # Main FastAPI server
│       ├── CLAUDE.md                   # Server-specific AI context
│       ├── src/                        # Source code
│       │   ├── constants.py            # Configuration constants
│       │   ├── core/                   # Core modules
│       │   │   ├── __init__.py
│       │   │   ├── providers/          # AI service providers
│       │   │   │   ├── CLAUDE.md       # AI service provider patterns and integration
│       │   │   │   ├── __init__.py
│       │   │   │   ├── stt.py         # Groq Whisper STT
│       │   │   │   ├── llm.py         # LangChain + Gemini LLM
│       │   │   │   ├── tts.py         # Google Cloud TTS + Gemini TTS (dual providers)
│       │   │   │   └── live_api/      # Live API implementations (Gemini 2.5)
│       │   │   │       ├── __init__.py
│       │   │   │       ├── config.py
│       │   │   │       ├── session.py
│       │   │   │       ├── streaming.py
│       │   │   │       └── provider.py
│       │   │   ├── pipelines/         # Voice processing pipelines
│       │   │   │   ├── CLAUDE.md      # Voice pipeline patterns and implementations
│       │   │   │   ├── __init__.py   # Pipeline exports and active pipeline management
│       │   │   │   ├── ptt_live_api/  # PTT Live API pipeline
│       │   │   │   │   ├── __init__.py # Unified interface
│       │   │   │   │   ├── core.py     # Core pipeline functionality
│       │   │   │   │   ├── streaming.py # Streaming methods
│       │   │   │   │   ├── socketio.py  # Socket.IO integration
│       │   │   │   │   └── context.py   # Pipeline-specific context management
│       │   │   └── utils/             # Utility modules
│       │   │       ├── __init__.py
│       │   │       ├── circuit_breaker.py # Circuit breaker pattern for API resilience
│       │   │       └── logging.py    # Structured logging with correlation IDs
│       │   ├── api/                    # FastAPI application
│       │   │   ├── CLAUDE.md          # API endpoint patterns and implementations
│       │   │   ├── __init__.py
│       │   │   ├── app.py             # FastAPI app with Socket.IO integration
│       │   │   ├── middleware.py       # Request logging and performance middleware
│       │   │   ├── websocket/          # Real-time communication
│       │   │   │   ├── __init__.py
│       │   │   │   └── socketio.py    # Socket.IO server for standardized real-time communication
│       │   │   └── routes/            # API endpoints
│       │   │       ├── __init__.py
│       │   │       ├── health.py      # Health checks
│       │   │       ├── chat.py        # Voice processing endpoint with Socket.IO streaming
│       │   │       └── warming.py     # STT pre-warming endpoints for performance optimization
│       │   └── models/                 # Pydantic data models
│       │       ├── __init__.py
│       │       └── schemas.py         # Request/response models with conversation history
│       ├── config/                     # Configuration files
│       │   ├── __init__.py
│       │   ├── settings.py             # Environment settings + LangSmith
│       │   └── prompts.py             # System prompts
│       ├── tests/                      # Unit tests
│       │   └── __init__.py
│       ├── pyproject.toml              # Poetry deps (includes LangChain)
│       ├── poetry.lock                 # Locked dependencies
│       ├── Makefile                    # Development commands
│       ├── run_local.py               # Local server runner
│       ├── .env.example               # API keys template (use LANGSMITH_API_KEY)
│       ├── .env                        # API keys (create from .env.example)
│       └── google-credentials.json     # Google Cloud credentials
├── web-dashboard/                      # TypeScript SvelteKit testing interface
│   ├── CLAUDE.md                       # Dashboard-specific AI context
│   ├── package.json                    # SvelteKit + TypeScript dependencies
│   ├── package-lock.json               # Locked dependencies
│   ├── tsconfig.json                   # TypeScript configuration
│   ├── svelte.config.js                # SvelteKit configuration
│   ├── vite.config.js                  # Vite development server
│   └── src/                            # TypeScript SvelteKit source code
│       ├── app.html                    # Main HTML template
│       ├── app.css                     # Global styles with dark mode
│       ├── app.d.ts                    # TypeScript app declarations
│       ├── lib/                        # Shared components and utilities
│       │   ├── types/                  # TypeScript type definitions
│       │   │   ├── stores.ts           # Store state interfaces and types
│       │   │   ├── api.ts              # API request/response types
│       │   │   └── components.ts       # Component prop interfaces
│       │   ├── components/             # Typed reusable Svelte components
│       │   │   ├── ui/                 # General UI components
│       │   │   │   ├── StatusIndicator.svelte # Typed status display component
│       │   │   │   └── ChatWindow.svelte   # Main chat container
│       │   │   ├── debug/              # Debug and development components
│       │   │   │   ├── DebugWindow.svelte  # Typed comprehensive debug panel
│       │   │   │   ├── AudioVisualizer.svelte # Typed real-time audio waveform visualization
│       │   │   │   └── LogCategoryControl.svelte # Log category filtering UI with persistent settings
│       │   │   ├── chat/               # Modular chat components (extracted from monolithic ChatWindow)
│       │   │   │   ├── ChatHeader.svelte # Header with scroll controls and message count
│       │   │   │   ├── ChatMessage.svelte # Individual message rendering with metadata
│       │   │   │   ├── ChatMessageList.svelte # Message list container with empty state
│       │   │   │   ├── ChatFooter.svelte # Footer with metadata toggle
│       │   │   │   ├── types.ts        # TypeScript interfaces for all chat components
│       │   │   │   └── utils.ts        # Formatting utilities and audio playback functions
│       │   │   └── tutor-ai/           # Modular TutorAI components (extracted from monolithic page)
│       │   │       ├── PipelineConfiguration.svelte # Pipeline settings and configuration forms
│       │   │       ├── RecordingControls.svelte # Voice recording interface and controls
│       │   │       └── SessionControls.svelte # Session management and debug controls
│       │   ├── stores/                 # Typed Svelte stores for state management
│       │   │   ├── status.ts           # Typed API and microphone status stores
│       │   │   ├── conversation.ts     # Typed conversation history and logging (millisecond precision)
│       │   │   ├── chat.ts             # Typed chat message store
│       │   │   └── debug.ts            # Typed debug data collection and performance monitoring
│       │   ├── api/                     # Modular API client architecture
│       │   │   ├── CLAUDE.md           # Client-side API patterns and implementations
│       │   │   └── tutor/               # TutorAI-specific API client
│       │   │       ├── index.ts         # Main TutorAPIClient (composition of all modules)
│       │   │       ├── base-client.ts   # Core HTTP client & health checks
│       │   │       ├── socket-client.ts # Socket.IO connection & event management
│       │   │       ├── voice-client.ts  # Voice processing methods
│       │   │       ├── audio-client-utils.ts # Audio URL management & utilities
│       │   │       └── session-utils.ts # Session ID generation & utilities
│       │   ├── audio/                   # Audio processing modules
│       │   │   ├── CLAUDE.md           # Audio processing patterns and implementations
│       │   │   ├── recorder.ts         # Typed microphone recording with debug integration
│       │   │   ├── storage.ts          # Client-side audio storage with replay functionality
│       │   │   ├── stream-player.ts    # Progressive audio playbook for Socket.IO streaming
│       │   │   ├── utils.ts            # Audio utilities (PCM-to-WAV conversion)
│       │   │   ├── tutor-ai-utils.ts   # TutorAI-specific audio utilities (hash generation, loading, cleanup)
│       │   │   └── processor.ts        # Main audio processing pipeline logic with TypeScript types
│       │   ├── components/             # Typed reusable Svelte components
│       │   │   ├── CLAUDE.md           # UI component patterns and implementations
│       │   │   ├── ui/                 # General UI components
│       │   │   │   ├── StatusIndicator.svelte # Typed status display component
│       │   │   │   └── ChatWindow.svelte   # Main chat container
│       │   │   ├── debug/              # Debug and development components
│       │   │   │   ├── DebugWindow.svelte  # Typed comprehensive debug panel
│       │   │   │   └── AudioVisualizer.svelte # Typed real-time audio waveform visualization
│       │   │   ├── chat/               # Modular chat components (extracted from monolithic ChatWindow)
│       │   │   │   ├── ChatHeader.svelte # Header with scroll controls and message count
│       │   │   │   ├── ChatMessage.svelte # Individual message rendering with metadata
│       │   │   │   ├── ChatMessageList.svelte # Message list container with empty state
│       │   │   │   ├── ChatFooter.svelte # Footer with metadata toggle
│       │   │   │   ├── types.ts        # TypeScript interfaces for all chat components
│       │   │   │   └── utils.ts        # Formatting utilities and audio playback functions
│       │   │   └── tutor-ai/           # Modular TutorAI components (extracted from monolithic page)
│       │   │       ├── PipelineConfiguration.svelte # Pipeline settings and configuration forms
│       │   │       ├── RecordingControls.svelte # Voice recording interface and controls
│       │   │       └── SessionControls.svelte # Session management and debug controls
│       │   ├── handlers/               # Event handler modules
│       │   │   └── tutor-ai/           # TutorAI-specific handlers
│       │   │       └── recording-handlers.ts # Recording event handlers with dependency injection
│       │   ├── utils/                  # General utility modules
│       │   │   └── logging/             # Structured logging with category-based filtering
│       │   │       ├── CLAUDE.md        # Logging system patterns and usage
│       │   │       ├── index.ts         # Main exports and barrel exports
│       │   │       ├── core.ts          # Logger class with category filtering
│       │   │       ├── api.ts           # API request/response logging functions
│       │   │       ├── handlers.ts      # Specialized audio/chat logging functions
│       │   │       ├── performance.ts   # PerformanceTimer class for operation timing
│       │   │       ├── formatters.ts    # Console/JSON output formatting
│       │   │       ├── types.ts         # TypeScript interfaces, log levels, and categories
│       │   │       ├── category-helpers.ts # Pre-configured category loggers
│       │   │       └── audio-logger.ts  # Smart audio logger with throttling
│       │   # VAD pipeline files archived to /archive/vad-gemini-live-pipeline/
│       └── routes/                     # SvelteKit routing structure
│           ├── +layout.svelte          # Shared layout with navigation (includes Settings link)
│           ├── +page.svelte            # Dashboard home page with debug toggle
│           ├── settings/               # Settings and configuration routes
│           │   └── +page.svelte        # Settings page with persistent log category management
│           └── tutor-ai/               # TutorAI testing routes
│               └── +page.svelte        # Multi-pipeline testing with Socket.IO streaming support
├── unity/                              # VR client (future Phase 3)
├── shared/                             # Shared resources
│   └── config/                         # Shared configuration
├── docs/                               # Documentation
│   ├── specs/                          # Technical specifications and research documents
│   ├── open-issues/                    # Known open issues / tasks
│   └── ai-context/                     # AI context documentation
│       ├── docs-overview.md            # Complete documentation architecture guide
│       ├── project-structure.md        # Complete project file tree (this file)
│       ├── HANDOFF.md                  # Handoff document for current ongoing, uncompleted tasks
│       ├── system-integration.md       # Component communication patterns, Socket.IO protocols
│       └── deployment-infrastructure.md # Docker, monitoring, CI/CD, and infrastructure patterns
├── scripts/                            # Development automation
│   └── setup-dev.sh                    # Environment setup script
├── .claude/                            # Claude Code configuration
│   └── commands/                       # Custom slash commands
│       ├── full-context.md             # Smart context loading slash command
│       └── update-docs.md              # Automatic documentation update slash command
├── supabase/                           # Database (future)
│   ├── functions/                      # Edge functions
│   └── migrations/                     # Database migrations
└── archive/                            # Archived implementations
    ├── ai-language-prototype/          # Early Node.js prototype
    ├── classic-pipeline-2025-06-27/    # Classic STT→LLM→TTS pipeline (archived 2025-06-27)
    ├── livekit-tutor/                  # Previous LiveKit implementation
    └── vad-gemini-live-pipeline/       # Voice Activation Detection pipeline (archived 2025-06-20)
```
