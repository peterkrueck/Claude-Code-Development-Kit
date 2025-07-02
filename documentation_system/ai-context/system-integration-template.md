# System Integration Patterns - Template

*This file documents cross-cutting patterns for component communication, data flow, and integration across your application system.*

## Purpose

This template helps document:
- **Cross-system communication patterns** for consistent integration
- **Data flow architectures** between components
- **Reusable integration solutions** for common scenarios
- **Performance optimization patterns** applied across systems
- **Testing strategies** for integrated systems

## Template Sections

### Real-Time Communication Patterns

Document WebSocket, Socket.IO, or other real-time communication patterns:

```typescript
// Example: Real-time data streaming pattern
async function streamData(
    sessionId: string,
    data: StreamData,
    chunkIndex: number,
    isFinal: boolean = false
) {
    await socketIO.emit('data_stream', {
        session_id: sessionId,
        data: data,
        chunk_index: chunkIndex,
        is_final: isFinal,
        timestamp: Date.now()
    }, `session_${sessionId}`);
}
```

### API Integration Patterns

Document HTTP API communication patterns:

```python
# Example: Async API client pattern
class APIClient:
    async def process_request(
        self,
        endpoint: str,
        data: Dict[str, Any],
        session_id: Optional[str] = None
    ) -> Dict[str, Any]:
        headers = {"Content-Type": "application/json"}
        if session_id:
            headers["X-Session-ID"] = session_id
            
        response = await self.client.post(
            f"{self.base_url}/{endpoint}",
            json=data,
            headers=headers
        )
        return response.json()
```

### State Management Patterns

Document how state is managed across components:

```typescript
// Example: Cross-component state synchronization
class StateManager {
    private state: Map<string, any> = new Map();
    
    async syncState(sessionId: string, updates: StateUpdate[]): Promise<void> {
        for (const update of updates) {
            this.state.set(`${sessionId}:${update.key}`, update.value);
            
            // Notify other components of state change
            await this.notifyStateChange(sessionId, update);
        }
    }
}
```

### Performance Optimization Patterns

Document optimization strategies applied across systems:

```python
# Example: Connection pooling and pre-warming
class ServiceManager:
    def __init__(self):
        self._connections: Dict[str, Any] = {}
        self._warmup_lock = asyncio.Lock()
    
    async def get_service(self, service_type: str) -> Any:
        async with self._warmup_lock:
            if service_type not in self._connections:
                service = await self._create_service(service_type)
                await self._prewarm_service(service)
                self._connections[service_type] = service
            return self._connections[service_type]
```

### Data Flow Patterns

Document how data flows between components:

```
Client → API Gateway → Service A → Message Queue → Service B → Database
     ↓
Socket.IO ← Stream Processor ← Service B Response
```

### Error Handling Patterns

Document error handling strategies:

```python
# Example: Distributed error handling
async def handle_service_error(
    error: Exception,
    context: Dict[str, Any],
    retry_count: int = 0
) -> Dict[str, Any]:
    if retry_count < MAX_RETRIES:
        await asyncio.sleep(RETRY_DELAY * (2 ** retry_count))
        return await retry_operation(context, retry_count + 1)
    
    # Log and propagate error
    logger.error("Service operation failed", error=str(error), context=context)
    raise ServiceError(f"Operation failed after {MAX_RETRIES} retries")
```

### Testing Patterns

Document testing strategies for integrated systems:

```python
# Example: Integration test pattern
@pytest.mark.asyncio
async def test_full_integration_flow():
    # Setup test environment
    test_session = create_test_session()
    
    # Test data flow
    request_data = {"test": "data"}
    response = await api_client.post("/api/process", json=request_data)
    
    # Verify integration points
    assert response.status_code == 200
    assert "processed_data" in response.json()
    
    # Verify side effects
    state = await get_session_state(test_session.id)
    assert state["status"] == "completed"
```

## Migration Patterns

Document patterns for migrating between platforms:

```typescript
// Example: Browser API to Platform-specific API mapping
// Web Browser
const hashBuffer = await crypto.subtle.digest('SHA-256', data);

// Platform Equivalent (adapt to your target platform)
const hash = await platformCrypto.createHash('sha256', data);
```

## Cross-Platform Considerations

Document considerations for multi-platform deployment:

- **Web Browser**: Client-side limitations and capabilities
- **Mobile**: Native platform integration patterns
- **Desktop**: System-level integration requirements
- **Server**: Scalability and performance patterns

## Customization Guidelines

Adapt this template by:

1. **Replace examples** with your actual integration patterns
2. **Add sections** for your specific technology stack
3. **Document performance metrics** for your optimization patterns
4. **Include troubleshooting** for common integration issues
5. **Update migration patterns** for your target platforms

## Integration with AI Development

This documentation enables AI assistants to:
- **Understand system architecture** when making changes
- **Follow established patterns** for new integrations
- **Optimize performance** using documented strategies
- **Maintain consistency** across system components
- **Troubleshoot integration issues** using documented patterns

---

*This template provides a foundation for documenting system integration patterns. Customize it based on your specific architecture, technology stack, and integration requirements.*