---
title: Universal AI Coordinator API Documentation
description: Comprehensive API documentation for the modular AI coordinator system
version: 2.0.0
date: 2025-01-16
status: active
---

# 🤖 Universal AI Coordinator API Documentation

## Overview

The Universal AI Coordinator is a modular system that provides intelligent routing and coordination across multiple AI providers, tools, and services. Following the recent architectural reorganization, the coordinator is now split into focused modules for better maintainability and separation of concerns.

## 🏗️ Architecture Overview

### Module Structure

The coordinator system is organized into five focused modules:

```
code/crates/core/mcp/src/enhanced/coordinator/
├── mod.rs           # Core coordinator implementation and public interface
├── types.rs         # Data structures, enums, and configuration types
├── providers.rs     # AI provider implementations
├── router.rs        # AIRouter and intelligent routing logic
└── tools.rs         # UniversalToolExecutor and tool management
```

### Module Responsibilities

| Module | Lines | Responsibility |
|--------|-------|----------------|
| **types.rs** | 589 | All data structures, enums, and configuration types |
| **providers.rs** | 614 | AI provider implementations (OpenAI, Anthropic, Gemini, etc.) |
| **router.rs** | 453 | AIRouter and intelligent routing logic |
| **tools.rs** | 326 | UniversalToolExecutor and tool management |
| **mod.rs** | 396 | Core AICoordinator implementation with re-exports |

## 🔧 Core Components

### AICoordinator

The main coordinator that orchestrates all AI operations.

```rust
use squirrel_mcp::enhanced::coordinator::AICoordinator;

// Initialize coordinator
let coordinator = AICoordinator::new(config).await?;

// Execute AI requests
let response = coordinator.execute_request(request).await?;

// Stream responses
let stream = coordinator.stream_request(request).await?;
```

#### Key Methods

- `new(config: AICoordinatorConfig) -> Result<Self>` - Initialize coordinator
- `execute_request(request: AIRequest) -> Result<AIResponse>` - Execute single request
- `stream_request(request: AIRequest) -> Result<AIResponseStream>` - Stream responses
- `register_provider(provider: Box<dyn AIProvider>) -> Result<()>` - Register AI provider
- `get_available_providers() -> Vec<ProviderInfo>` - List available providers
- `get_health_status() -> CoordinatorHealthStatus` - Get system health

### AIRouter

Intelligent routing system that selects the best AI provider for each request.

```rust
use squirrel_mcp::enhanced::coordinator::AIRouter;

// Create router with strategy
let router = AIRouter::new(RoutingStrategy::BestFit);

// Route request to optimal provider
let provider_id = router.route_request(&request, &providers).await?;
```

#### Routing Strategies

- **`FirstMatch`** - Use first available provider
- **`HighestPriority`** - Route to highest priority provider
- **`LowestLatency`** - Route to fastest responding provider
- **`LowestCost`** - Route to most cost-effective provider
- **`BestFit`** - Intelligent matching based on capabilities
- **`RoundRobin`** - Distribute load across providers

### UniversalToolExecutor

Manages and executes tools across different AI providers.

```rust
use squirrel_mcp::enhanced::coordinator::UniversalToolExecutor;

// Initialize tool executor
let executor = UniversalToolExecutor::new(config);

// Execute tool
let result = executor.execute_tool(tool_request).await?;

// List available tools
let tools = executor.list_tools().await?;
```

#### Tool Management

- **Registration** - Register tools with metadata and capabilities
- **Discovery** - Find tools based on capabilities and requirements
- **Execution** - Execute tools with proper sandboxing and monitoring
- **Monitoring** - Track tool performance and resource usage

## 🔌 AI Providers

### Supported Providers

| Provider | Status | Capabilities |
|----------|--------|-------------|
| **OpenAI** | ✅ Production | GPT-4, GPT-3.5, function calling, streaming |
| **Anthropic** | ✅ Production | Claude models, function calling, streaming |
| **Google Gemini** | ✅ Production | Gemini models, multimodal, function calling |
| **Ollama** | ✅ Production | Local models, streaming, custom models |
| **LlamaCpp** | ✅ Production | Local models, GGML/GGUF, streaming |
| **Custom** | ✅ Extensible | Plugin-based custom providers |

### Provider Configuration

```rust
use squirrel_mcp::enhanced::coordinator::*;

// OpenAI Provider
let openai_config = OpenAIConfig {
    api_key: "sk-...".to_string(),
    model: "gpt-4".to_string(),
    max_tokens: Some(4096),
    temperature: Some(0.7),
    base_url: None, // Use default OpenAI API
};

// Anthropic Provider
let anthropic_config = AnthropicConfig {
    api_key: "sk-ant-...".to_string(),
    model: "claude-3-sonnet-20240229".to_string(),
    max_tokens: Some(4096),
    temperature: Some(0.7),
};

// Local Provider (Ollama)
let ollama_config = OllamaConfig {
    base_url: "http://localhost:11434".to_string(),
    model: "llama2".to_string(),
    stream: true,
};
```

## 📊 Data Types

### Core Request/Response Types

```rust
use squirrel_mcp::enhanced::coordinator::*;

// AI Request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AIRequest {
    pub id: String,
    pub messages: Vec<Message>,
    pub tools: Option<Vec<Tool>>,
    pub provider_preference: Option<String>,
    pub streaming: bool,
    pub metadata: HashMap<String, Value>,
}

// AI Response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AIResponse {
    pub id: String,
    pub content: String,
    pub tool_calls: Option<Vec<ToolCall>>,
    pub usage: Option<Usage>,
    pub provider_id: String,
    pub metadata: HashMap<String, Value>,
}

// Message
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub role: MessageRole,
    pub content: String,
    pub tool_calls: Option<Vec<ToolCall>>,
    pub tool_call_id: Option<String>,
}

// Tool Definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Tool {
    pub name: String,
    pub description: String,
    pub parameters: Value,
    pub handler: ToolHandler,
}
```

### Configuration Types

```rust
// Main Configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AICoordinatorConfig {
    pub router_config: RouterConfig,
    pub provider_configs: HashMap<String, ProviderConfig>,
    pub tool_config: ToolConfig,
    pub monitoring_config: MonitoringConfig,
}

// Router Configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RouterConfig {
    pub strategy: RoutingStrategy,
    pub fallback_strategy: Option<RoutingStrategy>,
    pub timeout: Duration,
    pub max_retries: usize,
}

// Provider Configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ProviderConfig {
    OpenAI(OpenAIConfig),
    Anthropic(AnthropicConfig),
    Gemini(GeminiConfig),
    Ollama(OllamaConfig),
    LlamaCpp(LlamaCppConfig),
    Custom(CustomProviderConfig),
}
```

## 🛠️ Usage Examples

### Basic Usage

```rust
use squirrel_mcp::enhanced::coordinator::*;
use serde_json::json;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize coordinator
    let config = AICoordinatorConfig::default();
    let coordinator = AICoordinator::new(config).await?;

    // Create request
    let request = AIRequest {
        id: "req-001".to_string(),
        messages: vec![
            Message {
                role: MessageRole::User,
                content: "Explain quantum computing".to_string(),
                tool_calls: None,
                tool_call_id: None,
            }
        ],
        tools: None,
        provider_preference: None,
        streaming: false,
        metadata: HashMap::new(),
    };

    // Execute request
    let response = coordinator.execute_request(request).await?;
    println!("Response: {}", response.content);

    Ok(())
}
```

### Streaming Usage

```rust
use squirrel_mcp::enhanced::coordinator::*;
use futures_util::StreamExt;

async fn stream_example() -> Result<(), Box<dyn std::error::Error>> {
    let coordinator = AICoordinator::new(config).await?;
    
    let request = AIRequest {
        // ... request configuration
        streaming: true,
        ..Default::default()
    };

    let mut stream = coordinator.stream_request(request).await?;
    
    while let Some(chunk) = stream.next().await {
        match chunk {
            Ok(chunk) => {
                println!("Chunk: {}", chunk.content);
            }
            Err(e) => {
                eprintln!("Stream error: {}", e);
                break;
            }
        }
    }

    Ok(())
}
```

### Tool Usage

```rust
use squirrel_mcp::enhanced::coordinator::*;

async fn tool_example() -> Result<(), Box<dyn std::error::Error>> {
    let coordinator = AICoordinator::new(config).await?;
    
    // Define custom tool
    let tool = Tool {
        name: "calculate".to_string(),
        description: "Perform mathematical calculations".to_string(),
        parameters: json!({
            "type": "object",
            "properties": {
                "expression": {
                    "type": "string",
                    "description": "Mathematical expression to evaluate"
                }
            },
            "required": ["expression"]
        }),
        handler: ToolHandler::Function(Box::new(|args| {
            Box::pin(async move {
                // Tool implementation
                Ok(json!({
                    "result": "42"
                }))
            })
        })),
    };

    // Register tool
    coordinator.tool_executor.register_tool(tool).await?;

    // Use tool in request
    let request = AIRequest {
        id: "req-tool-001".to_string(),
        messages: vec![
            Message {
                role: MessageRole::User,
                content: "Calculate 2 + 2".to_string(),
                tool_calls: None,
                tool_call_id: None,
            }
        ],
        tools: Some(vec![/* tools available for this request */]),
        provider_preference: None,
        streaming: false,
        metadata: HashMap::new(),
    };

    let response = coordinator.execute_request(request).await?;
    println!("Tool result: {}", response.content);

    Ok(())
}
```

### Advanced Routing

```rust
use squirrel_mcp::enhanced::coordinator::*;

async fn advanced_routing() -> Result<(), Box<dyn std::error::Error>> {
    let config = AICoordinatorConfig {
        router_config: RouterConfig {
            strategy: RoutingStrategy::BestFit,
            fallback_strategy: Some(RoutingStrategy::FirstMatch),
            timeout: Duration::from_secs(30),
            max_retries: 3,
        },
        provider_configs: HashMap::from([
            ("openai".to_string(), ProviderConfig::OpenAI(OpenAIConfig {
                api_key: std::env::var("OPENAI_API_KEY")?,
                model: "gpt-4".to_string(),
                max_tokens: Some(4096),
                temperature: Some(0.7),
                base_url: None,
            })),
            ("anthropic".to_string(), ProviderConfig::Anthropic(AnthropicConfig {
                api_key: std::env::var("ANTHROPIC_API_KEY")?,
                model: "claude-3-sonnet-20240229".to_string(),
                max_tokens: Some(4096),
                temperature: Some(0.7),
            })),
        ]),
        tool_config: ToolConfig::default(),
        monitoring_config: MonitoringConfig::default(),
    };

    let coordinator = AICoordinator::new(config).await?;

    // Request with provider preference
    let request = AIRequest {
        id: "req-advanced".to_string(),
        messages: vec![
            Message {
                role: MessageRole::User,
                content: "Write a complex Python function".to_string(),
                tool_calls: None,
                tool_call_id: None,
            }
        ],
        provider_preference: Some("openai".to_string()),
        streaming: false,
        metadata: HashMap::from([
            ("priority".to_string(), json!("high")),
            ("complexity".to_string(), json!("advanced")),
        ]),
        tools: None,
    };

    let response = coordinator.execute_request(request).await?;
    println!("Advanced routing result: {}", response.content);

    Ok(())
}
```

## 📊 Monitoring and Metrics

### Health Monitoring

```rust
use squirrel_mcp::enhanced::coordinator::*;

async fn monitor_health() -> Result<(), Box<dyn std::error::Error>> {
    let coordinator = AICoordinator::new(config).await?;
    
    // Get overall health status
    let health = coordinator.get_health_status().await?;
    println!("Coordinator health: {:?}", health.status);
    
    // Get provider-specific health
    for provider_health in health.providers {
        println!("Provider {}: {:?}", provider_health.id, provider_health.status);
    }
    
    // Get metrics
    let metrics = coordinator.get_metrics().await?;
    println!("Total requests: {}", metrics.total_requests);
    println!("Average latency: {}ms", metrics.average_latency.as_millis());

    Ok(())
}
```

### Performance Metrics

- **Request latency** - Time from request to response
- **Provider response times** - Individual provider performance
- **Tool execution times** - Tool performance metrics
- **Error rates** - Success/failure rates by provider
- **Resource utilization** - Memory and CPU usage

## 🔒 Security Considerations

### Authentication

All AI providers require proper authentication:

```rust
// Environment variables for API keys
std::env::set_var("OPENAI_API_KEY", "sk-...");
std::env::set_var("ANTHROPIC_API_KEY", "sk-ant-...");
```

### Rate Limiting

Built-in rate limiting for all providers:

```rust
let config = ProviderConfig::OpenAI(OpenAIConfig {
    // ... other config
    rate_limit: Some(RateLimit {
        requests_per_minute: 60,
        tokens_per_minute: 90000,
    }),
});
```

### Input Validation

All requests are validated before processing:

- Message content sanitization
- Tool parameter validation
- Provider capability verification
- Resource limit enforcement

## 🚀 Migration Guide

### From Legacy Coordinator

If you're migrating from the old monolithic coordinator.rs:

```rust
// Old way (still works via re-exports)
use squirrel_mcp::enhanced::coordinator::AICoordinator;

// New way (explicit module imports)
use squirrel_mcp::enhanced::coordinator::{
    AICoordinator,
    AIRouter,
    UniversalToolExecutor,
    RoutingStrategy,
    ProviderConfig,
};
```

### Breaking Changes

- **None** - All existing imports continue to work
- **Performance** - Improved compilation times due to modular structure
- **Maintainability** - Easier to modify individual components

## 🔧 Configuration Reference

### Environment Variables

```bash
# Required for OpenAI
OPENAI_API_KEY=sk-...

# Required for Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Required for Gemini
GEMINI_API_KEY=...

# Optional for custom endpoints
OPENAI_BASE_URL=https://api.openai.com/v1
ANTHROPIC_BASE_URL=https://api.anthropic.com
```

### Configuration File

```toml
[coordinator]
default_provider = "openai"
timeout_seconds = 30
max_retries = 3

[coordinator.router]
strategy = "BestFit"
fallback_strategy = "FirstMatch"

[providers.openai]
model = "gpt-4"
max_tokens = 4096
temperature = 0.7

[providers.anthropic]
model = "claude-3-sonnet-20240229"
max_tokens = 4096
temperature = 0.7

[providers.ollama]
base_url = "http://localhost:11434"
model = "llama2"
stream = true

[tools]
sandbox_enabled = true
timeout_seconds = 60
max_memory_mb = 512
```

## 📚 Additional Resources

- [MCP Protocol Documentation](../MCP_PROTOCOL.md)
- [Provider Integration Guide](../PROVIDER_INTEGRATION.md)
- [Tool Development Guide](../TOOL_DEVELOPMENT.md)
- [Performance Tuning Guide](../PERFORMANCE_TUNING.md)

## 🤝 Contributing

To contribute to the coordinator system:

1. **Focus on single modules** - Each module has a specific responsibility
2. **Maintain backward compatibility** - Don't break existing APIs
3. **Add comprehensive tests** - Test both individual modules and integration
4. **Update documentation** - Keep this guide current with any changes

## 📄 License

This documentation is part of the Squirrel MCP Platform and follows the same license terms.

---

*Last updated: January 16, 2025*
*Version: 2.0.0*
*Module Structure: 5 focused modules, 396-614 lines each* 