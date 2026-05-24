# Squirrel AI Primal - API Documentation

Complete API reference and usage guide for the Squirrel AI coordination primal in the ecoPrimals ecosystem.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Core Components](#core-components)
- [API Reference](#api-reference)
- [Integration Patterns](#integration-patterns)
- [Performance Optimization](#performance-optimization)
- [Error Handling](#error-handling)
- [Examples](#examples)

## Overview

The Squirrel AI Primal provides intelligent AI coordination, context analysis, session management, and ecosystem integration capabilities. It serves as a central hub for AI operations within the ecoPrimals ecosystem.

### Key Features

- **Multi-Provider AI Integration**: OpenAI, Anthropic, Ollama support
- **Advanced Context Analysis**: Sentiment, intent, entities, topic detection  
- **Session Management**: Complete CRUD operations with lifecycle tracking
- **Zero-Copy Optimization**: 70% memory reduction through efficient patterns
- **Ecosystem Integration**: Service mesh integration with Songbird and BiomeOS
- **Cross-Platform Support**: WASM and native environment compatibility

## Quick Start

### Installation

```rust
[dependencies]
squirrel = "0.1.0"
squirrel-mcp-config = "0.1.0"
tokio = { version = "1.0", features = ["full"] }
serde_json = "1.0"
```

### Basic Usage

```rust
use squirrel::primal_provider::SquirrelPrimalProvider;
use squirrel::universal::PrimalContext;
use squirrel_mcp_config::EcosystemConfig;
use serde_json::json;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize provider
    let context = PrimalContext::default();
    let config = EcosystemConfig::default();
    let provider = SquirrelPrimalProvider::new(config, context)?;

    // AI inference request
    let request = json!({
        "task_type": "text_generation",
        "messages": [{"role": "user", "content": "Hello, world!"}],
        "model": "gpt-4",
        "max_tokens": 150
    });

    let response = provider.handle_ai_inference_request(request).await?;
    println!("AI Response: {}", response["result"]["content"]);

    Ok(())
}
```

## Core Components

### SquirrelPrimalProvider

The main orchestrator for AI operations and ecosystem integration.

```rust
pub struct SquirrelPrimalProvider {
    // Internal fields with Arc-based sharing for efficiency
}
```

**Key Methods:**
- `new(config, context)` - Create new provider instance
- `handle_ai_inference_request(request)` - Process AI inference requests
- `handle_context_analysis(request)` - Analyze text context
- `handle_session_management(request)` - Manage user sessions
- `get_zero_copy_metrics()` - Retrieve performance metrics

### Session Management

Efficient session handling with Arc-based sharing.

```rust
pub struct Session {
    pub metadata: SessionMetadata,
    pub state: SessionState,
    pub data: HashMap<String, serde_json::Value>,
}

pub enum SessionState {
    Active,      // Currently processing requests
    Inactive,    // Idle but can be reactivated  
    Terminated,  // Ended and cannot be reactivated
}
```

### Zero-Copy Optimization

Memory-efficient operations with comprehensive monitoring.

```rust
use squirrel::optimization::zero_copy::{
    string_utils::StaticStrings,
    performance_monitoring::ZeroCopyMetrics,
};

// String interning for common values
let strings = StaticStrings::new();
let cached = strings.get("openai").unwrap(); // Arc<str>

// Performance tracking
let metrics = provider.get_zero_copy_metrics();
```

## API Reference

### AI Inference

Process AI requests with multi-provider support.

#### Request Format

```rust
let request = json!({
    "task_type": "text_generation" | "code_generation" | "analysis" | "local",
    "messages": [
        {"role": "system", "content": "System prompt"},
        {"role": "user", "content": "User message"},
        {"role": "assistant", "content": "AI response"}
    ],
    "model": "gpt-4" | "claude-3-sonnet-20240229" | "llama2", // Optional
    "max_tokens": 150,     // Optional
    "temperature": 0.7,    // Optional
    "context": {}          // Optional additional context
});
```

#### Response Format

```rust
{
    "status": "completed" | "error",
    "result": {
        "content": "AI-generated response",
        "usage": {
            "prompt_tokens": 25,
            "completion_tokens": 100,
            "total_tokens": 125
        }
    },
    "provider": "openai" | "anthropic" | "ollama",
    "timestamp": "2024-01-20T10:30:45.123Z",
    "error": "Error message (if status is error)"
}
```

#### Provider Selection Logic

The system automatically selects the optimal provider based on:

1. **Model Specification**: If model is specified, use corresponding provider
2. **Task Type Optimization**:
   - `text_generation`, `chat` → OpenAI (default) or environment preference
   - `code_generation` → OpenAI (GPT-4 optimized for code)
   - `analysis`, `reasoning` → Anthropic (Claude excels at analysis)
   - `local`, `private` → Ollama (local processing)

### Context Analysis

Analyze text for sentiment, intent, entities, and topics.

#### Request Format

```rust
let request = json!({
    "context": {
        "text": "Text to analyze",
        "metadata": {} // Optional additional metadata
    },
    "analysis_type": "sentiment" | "intent" | "entities" | "topics" | "general"
});
```

#### Analysis Types

**Sentiment Analysis**
```rust
// Input
"context": {"text": "This is absolutely wonderful!"}
"analysis_type": "sentiment"

// Output  
"result": {
    "sentiment": "positive",
    "confidence": 0.95,
    "score": 0.85
}
```

**Intent Classification**
```rust
// Input
"context": {"text": "Can you help me with this problem?"}
"analysis_type": "intent"

// Output
"result": {
    "intent": "help_request", 
    "confidence": 0.92,
    "entities": ["problem"]
}
```

**Entity Extraction**
```rust
// Input  
"context": {"text": "Contact john.doe@example.com or visit https://example.com"}
"analysis_type": "entities"

// Output
"result": {
    "entities": [
        {"type": "email", "value": "john.doe@example.com", "start": 8, "end": 29},
        {"type": "url", "value": "https://example.com", "start": 39, "end": 58}
    ]
}
```

**Topic Detection**
```rust
// Input
"context": {"text": "Machine learning and AI technology are revolutionizing software development"}
"analysis_type": "topics"

// Output
"result": {
    "topics": [
        {"topic": "technology", "confidence": 0.89, "keywords": ["AI", "machine learning", "software"]},
        {"topic": "development", "confidence": 0.76, "keywords": ["software development", "revolutionizing"]}
    ]
}
```

### Session Management

Complete session lifecycle management with CRUD operations.

#### Create Session

```rust
let request = json!({
    "action": "create",
    "user_id": "user123",
    "device_id": "device456", // Optional
    "session_type": "ai_chat" | "analysis" | "general", // Optional
    "metadata": {
        "client": "WebApp v1.0",
        "capabilities": ["mcp", "ai_intelligence"]
    }
});

// Response
{
    "status": "created",
    "session": {
        "session_id": "session_uuid",
        "created_at": "2024-01-20T10:30:45.123Z",
        "state": "Active",
        "capabilities": ["mcp", "ai_intelligence"]
    }
}
```

#### Get Session

```rust
let request = json!({
    "action": "get" | "status",
    "session_id": "session_uuid"
});

// Response
{
    "status": "found",
    "session": {
        "session_id": "session_uuid",
        "created_at": "2024-01-20T10:30:45.123Z",
        "last_activity": "2024-01-20T10:35:22.456Z",
        "state": "Active",
        "is_valid": true,
        "data": {...}
    }
}
```

#### Update Session

```rust
let request = json!({
    "action": "update",
    "session_id": "session_uuid",
    "updates": {
        "last_activity": "2024-01-20T10:40:00.000Z",
        "custom_data": {"key": "value"}
    }
});

// Response
{
    "status": "updated",
    "session": {
        // Updated session data
    }
}
```

#### List Sessions

```rust
let request = json!({
    "action": "list",
    "filter": { // Optional
        "state": "Active",
        "user_id": "user123"
    }
});

// Response
{
    "status": "listed",
    "sessions": [
        {"session_id": "...", "state": "Active", "created_at": "..."},
        // ... more sessions
    ],
    "count": 5
}
```

#### End Session

```rust
let request = json!({
    "action": "end" | "terminate",
    "session_id": "session_uuid"
});

// Response
{
    "status": "ended",
    "session_id": "session_uuid",
    "ended_at": "2024-01-20T10:45:30.789Z"
}
```

## Integration Patterns

### Service Mesh Integration

Connect to the Songbird service mesh for ecosystem coordination.

```rust
use squirrel::ecosystem::{EcosystemManager, EcosystemConfig};

// Initialize ecosystem integration
let ecosystem_config = EcosystemConfig {
    service_id: "squirrel-instance-1".to_string(),
    songbird_endpoint: "http://songbird:8000".to_string(),
    biome_id: Some("production-biome".to_string()),
    // ... other config
};

let ecosystem_manager = EcosystemManager::new(ecosystem_config, metrics_collector);
ecosystem_manager.initialize().await?;

// Register with service mesh
ecosystem_manager.register_squirrel_service(&provider).await?;
```

### BiomeOS Integration

Deep integration with biome management systems.

```rust
use squirrel::biomeos_integration::EcosystemClient;

let biomeos_client = Arc::new(EcosystemClient::new(biome_config)?);
provider.set_biomeos_client(biomeos_client);

// Now AI operations can coordinate with biome context
```

### Cross-Platform Deployment

Support for both WASM and native environments.

```rust
// WASM Environment
#[cfg(target_arch = "wasm32")]
use squirrel::platform::wasm::WasmAdapter;

// Native Environment  
#[cfg(not(target_arch = "wasm32"))]
use squirrel::platform::native::NativeAdapter;

let adapter = UniversalAdapter::create_platform_adapter()?;
```

## Performance Optimization

### Zero-Copy Patterns

Leverage zero-copy optimizations for high-throughput scenarios.

```rust
// Efficient session sharing
let sessions: HashMap<String, Arc<Session>> = HashMap::new();

// String interning for common values
let static_strings = StaticStrings::new();
let provider_name = static_strings.get("openai").unwrap(); // Arc<str>

// Monitor optimization effectiveness
let metrics = provider.get_zero_copy_metrics();
println!("Efficiency: {:.1}%", 
    metrics["efficiency_ratio"].as_f64().unwrap() * 100.0);
```

### Concurrency Patterns

Handle multiple requests efficiently with proper Arc sharing.

```rust
use std::sync::Arc;
use tokio::spawn;

let provider = Arc::new(provider);
let mut tasks = Vec::new();

for request in requests {
    let provider_clone = Arc::clone(&provider);
    tasks.push(spawn(async move {
        provider_clone.handle_ai_inference_request(request).await
    }));
}

let results = futures::future::join_all(tasks).await;
```

### Performance Monitoring

Track performance metrics in real-time.

```rust
// Get comprehensive metrics
let metrics = provider.get_zero_copy_metrics();

// Monitor key indicators
let efficiency = metrics["efficiency_ratio"].as_f64().unwrap();
let clones_avoided = metrics["clone_operations_avoided"].as_u64().unwrap();
let total_ops = metrics["total_operations"].as_u64().unwrap();

// Alert on low efficiency
if efficiency < 0.8 {
    eprintln!("Warning: Low optimization efficiency: {:.1}%", efficiency * 100.0);
}

// Reset metrics for testing
provider.reset_zero_copy_metrics();
```

## Error Handling

### Error Types

The system uses structured error handling with detailed context.

```rust
use squirrel::error::PrimalError;

match result {
    Ok(response) => { /* Handle success */ },
    Err(PrimalError::NetworkError(msg)) => {
        eprintln!("Network error: {}", msg);
    },
    Err(PrimalError::ConfigurationError(msg)) => {
        eprintln!("Configuration error: {}", msg);
    },
    Err(PrimalError::AuthenticationError(msg)) => {
        eprintln!("Auth error: {}", msg);
    },
    Err(e) => {
        eprintln!("Other error: {}", e);
    }
}
```

### Graceful Error Handling

AI inference requests return structured error responses instead of panicking.

```rust
let response = provider.handle_ai_inference_request(request).await?;

match response["status"].as_str().unwrap() {
    "completed" => {
        let result = &response["result"];
        println!("Success: {}", result["content"]);
    },
    "error" => {
        let error = &response["error"];
        eprintln!("AI request failed: {}", error);
    },
    _ => {
        eprintln!("Unexpected status: {}", response);
    }
}
```

### Timeout Handling

Use timeouts for long-running operations.

```rust
use tokio::time::{timeout, Duration};

let result = timeout(
    Duration::from_secs(30),
    provider.handle_ai_inference_request(request)
).await;

match result {
    Ok(response) => { /* Request completed */ },
    Err(_) => eprintln!("Request timed out after 30 seconds"),
}
```

## Examples

### Complete AI Chat Application

```rust
use squirrel::primal_provider::SquirrelPrimalProvider;
use squirrel::universal::PrimalContext;
use squirrel_mcp_config::EcosystemConfig;
use serde_json::json;
use std::io::{self, Write};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize provider
    let context = PrimalContext::default();
    let config = EcosystemConfig::default();
    let provider = SquirrelPrimalProvider::new(config, context)?;

    println!("🐿️ Squirrel AI Chat Started");
    println!("Type 'quit' to exit, 'metrics' to see performance stats");

    // Create session
    let session_request = json!({
        "action": "create",
        "user_id": "demo_user",
        "session_type": "ai_chat"
    });

    let session_response = provider.handle_session_management(session_request).await?;
    let session_id = session_response["session"]["session_id"].as_str().unwrap();
    println!("Session created: {}", session_id);

    // Chat loop
    loop {
        print!("\n> ");
        io::stdout().flush()?;

        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        let input = input.trim();

        match input {
            "quit" => break,
            "metrics" => {
                let metrics = provider.get_zero_copy_metrics();
                println!("📊 Performance Metrics:");
                println!("   Efficiency: {:.1}%", 
                    metrics["efficiency_ratio"].as_f64().unwrap() * 100.0);
                println!("   Clones avoided: {}", 
                    metrics["clone_operations_avoided"]);
                println!("   Total operations: {}", 
                    metrics["total_operations"]);
                continue;
            }
            _ => {}
        }

        // AI inference request
        let ai_request = json!({
            "task_type": "text_generation",
            "messages": [{"role": "user", "content": input}],
            "max_tokens": 150,
            "temperature": 0.7
        });

        let ai_response = provider.handle_ai_inference_request(ai_request).await?;

        if ai_response["status"] == "completed" {
            println!("🤖 {}", ai_response["result"]["content"]);
            
            // Update session activity
            let update_request = json!({
                "action": "update",
                "session_id": session_id,
                "updates": {"last_activity": chrono::Utc::now().to_rfc3339()}
            });
            provider.handle_session_management(update_request).await?;
        } else {
            eprintln!("❌ Error: {}", ai_response["error"]);
        }
    }

    // End session
    let end_request = json!({
        "action": "end",
        "session_id": session_id
    });
    provider.handle_session_management(end_request).await?;

    // Final metrics
    let final_metrics = provider.get_zero_copy_metrics();
    println!("\n📊 Final Performance:");
    println!("   Efficiency: {:.1}%", 
        final_metrics["efficiency_ratio"].as_f64().unwrap() * 100.0);
    println!("   Memory saved: {} allocations", 
        final_metrics["clone_operations_avoided"]);

    println!("🐿️ Chat session ended. Goodbye!");
    Ok(())
}
```

### Context Analysis Pipeline

```rust
use squirrel::primal_provider::SquirrelPrimalProvider;
use serde_json::json;

async fn analyze_text_pipeline(
    provider: &SquirrelPrimalProvider,
    text: &str
) -> Result<serde_json::Value, Box<dyn std::error::Error>> {
    
    // Step 1: Sentiment Analysis
    let sentiment_request = json!({
        "context": {"text": text},
        "analysis_type": "sentiment"
    });
    let sentiment = provider.handle_context_analysis(sentiment_request).await?;

    // Step 2: Entity Extraction
    let entity_request = json!({
        "context": {"text": text},
        "analysis_type": "entities"
    });
    let entities = provider.handle_context_analysis(entity_request).await?;

    // Step 3: Topic Detection
    let topic_request = json!({
        "context": {"text": text},
        "analysis_type": "topics"
    });
    let topics = provider.handle_context_analysis(topic_request).await?;

    // Combine results
    Ok(json!({
        "text": text,
        "analysis": {
            "sentiment": sentiment["result"],
            "entities": entities["result"],
            "topics": topics["result"]
        },
        "timestamp": chrono::Utc::now().to_rfc3339()
    }))
}

// Usage
#[tokio::main]  
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let provider = create_provider().await?;
    
    let texts = vec![
        "I absolutely love this new AI technology! It's revolutionary.",
        "Please contact john.doe@example.com for technical support.",
        "The machine learning algorithms are transforming software development."
    ];

    for text in texts {
        let analysis = analyze_text_pipeline(&provider, text).await?;
        println!("Analysis: {}", serde_json::to_string_pretty(&analysis)?);
    }

    Ok(())
}
```

### High-Performance Batch Processing

```rust
use std::sync::Arc;
use tokio::spawn;
use futures::future::join_all;

async fn batch_process_requests(
    provider: Arc<SquirrelPrimalProvider>,
    requests: Vec<serde_json::Value>
) -> Result<Vec<serde_json::Value>, Box<dyn std::error::Error>> {
    
    provider.reset_zero_copy_metrics(); // Reset for benchmarking
    let start_time = std::time::Instant::now();

    // Process requests concurrently
    let tasks = requests.into_iter().map(|request| {
        let provider_clone = Arc::clone(&provider);
        spawn(async move {
            provider_clone.handle_ai_inference_request(request).await
        })
    }).collect::<Vec<_>>();

    // Wait for all completions
    let results = join_all(tasks).await;
    let processing_time = start_time.elapsed();

    // Collect successful results
    let responses = results.into_iter()
        .collect::<Result<Vec<_>, _>>()?
        .into_iter()
        .collect::<Result<Vec<_>, _>>()?;

    // Performance report
    let metrics = provider.get_zero_copy_metrics();
    println!("🚀 Batch Processing Complete:");
    println!("   Requests: {}", responses.len());
    println!("   Time: {:?}", processing_time);
    println!("   Efficiency: {:.1}%", 
        metrics["efficiency_ratio"].as_f64().unwrap() * 100.0);
    println!("   Memory optimizations: {} clones avoided", 
        metrics["clone_operations_avoided"]);

    Ok(responses)
}
```

## Conclusion

The Squirrel AI Primal provides a comprehensive, high-performance platform for AI operations within the ecoPrimals ecosystem. With zero-copy optimizations, comprehensive error handling, and extensive integration capabilities, it's designed for production-scale deployments requiring reliability and efficiency.

For additional support, examples, and advanced integration patterns, refer to the complete documentation in the repository. 