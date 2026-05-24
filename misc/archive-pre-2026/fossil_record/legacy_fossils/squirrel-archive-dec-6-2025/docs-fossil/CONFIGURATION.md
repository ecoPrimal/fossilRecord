# 🔧 Squirrel MCP Platform Configuration

This document describes all the environment variables available to configure the Squirrel MCP Platform, replacing hardcoded values throughout the codebase.

## 🌐 Network Configuration

Configure network-related settings:

```bash
# Server binding (default: 127.0.0.1)
export SQUIRREL_HOST=127.0.0.1

# Server port (default: 8080)
export SQUIRREL_PORT=8080

# CORS allowed origins (default: http://localhost:3000)
export SQUIRREL_CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# WebSocket endpoint (optional)
export SQUIRREL_WS_ENDPOINT=ws://localhost:8080/ws
```

## 🗄️ Database Configuration

Configure database connections:

```bash
# Database connection string (default: sqlite::memory:)
export DATABASE_URL=postgresql://user:password@localhost/squirrel

# Maximum number of database connections (default: 10)
export DB_MAX_CONNECTIONS=10

# Database connection timeout in seconds (default: 30)
export DB_TIMEOUT=30
```

## 🔗 External Services

Configure external service endpoints:

```bash
# Songbird service URL (default: http://localhost:8080)
export SONGBIRD_URL=http://songbird:8080

# Toadstool service URL (default: http://localhost:8445)
export TOADSTOOL_URL=http://toadstool:8445

# NestGate service URL (default: http://localhost:8444)
export NESTGATE_URL=http://nestgate:8444

# BearDog service URL (default: http://localhost:8443)
export BEARDOG_URL=http://beardog:8443

# BiomeOS service URL (default: http://localhost:5000)
export BIOMEOS_URL=http://biomeos:5000
```

## 🤖 AI Services

Configure AI service integrations:

```bash
# OpenAI API endpoint (default: https://api.openai.com/v1)
export OPENAI_API_URL=https://api.openai.com/v1

# Anthropic API endpoint (default: https://api.anthropic.com/v1)
export ANTHROPIC_API_URL=https://api.anthropic.com/v1

# Ollama API endpoint (default: http://localhost:11434)
export OLLAMA_API_URL=http://localhost:11434

# Default AI model temperature (default: 0.7)
export AI_TEMPERATURE=0.7

# AI service timeout in seconds (default: 30)
export AI_TIMEOUT=30
```

## 🔐 Authentication

Configure authentication settings:

```bash
# JWT secret key (default: your-secret-key)
export JWT_SECRET=your-secure-secret-key-here

# Authentication token expiry in seconds (default: 3600)
export AUTH_TOKEN_EXPIRY=3600
```

## 📝 Session Management

Configure session settings:

```bash
# Session timeout in seconds (default: 300)
export SESSION_TIMEOUT_SECS=300

# Maximum concurrent sessions (default: 100)
export SESSION_MAX_CONNECTIONS=100
```

## 🌍 Environment

Configure general environment settings:

```bash
# Environment type (default: development)
export ENVIRONMENT=development

# Log level (default: info)
export LOG_LEVEL=info

# Rust log configuration
export RUST_LOG=info
```

## 📡 MCP Configuration

Configure MCP protocol settings:

```bash
# MCP server host (default: localhost)
export MCP_HOST=localhost

# MCP server port (default: 50051)
export MCP_PORT=50051

# MCP timeout in seconds (default: 30)
export MCP_TIMEOUT=30
```

## 🔌 Plugin Configuration

Configure plugin system:

```bash
# Plugin directory (default: ~/.squirrel/plugins)
export PLUGIN_DIR=~/.squirrel/plugins

# Plugin timeout in seconds (default: 30)
export PLUGIN_TIMEOUT=30

# Plugin maximum memory in MB (default: 128)
export PLUGIN_MAX_MEMORY=128
```

## 🌐 Ecosystem Client

Configure ecosystem client settings:

```bash
# Ecosystem client timeout in seconds (default: 30)
export ECOSYSTEM_CLIENT_TIMEOUT_SECS=30

# Ecosystem client retry count (default: 3)
export ECOSYSTEM_CLIENT_RETRY_COUNT=3
```

## 📋 Example Configuration

### Development Environment
```bash
# Development setup
export ENVIRONMENT=development
export SQUIRREL_HOST=127.0.0.1
export SQUIRREL_PORT=8080
export DATABASE_URL=sqlite::memory:
export SONGBIRD_URL=http://localhost:8080
export OLLAMA_API_URL=http://localhost:11434
export LOG_LEVEL=debug
```

### Production Environment
```bash
# Production setup
export ENVIRONMENT=production
export SQUIRREL_HOST=0.0.0.0
export SQUIRREL_PORT=8080
export DATABASE_URL=postgresql://user:password@db:5432/squirrel
export SONGBIRD_URL=http://songbird:8080
export TOADSTOOL_URL=http://toadstool:8445
export NESTGATE_URL=http://nestgate:8444
export BEARDOG_URL=http://beardog:8443
export BIOMEOS_URL=http://biomeos:5000
export LOG_LEVEL=info
export AI_TIMEOUT=60
export DB_MAX_CONNECTIONS=50
```

### Docker Compose Environment
```bash
# Docker environment
export SONGBIRD_URL=http://songbird:8080
export TOADSTOOL_URL=http://toadstool:8445
export NESTGATE_URL=http://nestgate:8444
export BEARDOG_URL=http://beardog:8443
export BIOMEOS_URL=http://biomeos:5000
export DATABASE_URL=postgresql://postgres:password@db:5432/squirrel
export SQUIRREL_HOST=0.0.0.0
```

## 🔧 Usage

### Loading Configuration

```rust
use config::AppConfig;

// Load configuration from environment variables
let config = AppConfig::from_env().unwrap_or_default();

// Load configuration from file
let config = AppConfig::from_file("config.toml")?;

// Use specific service URL
let songbird_url = config.get_service_url("songbird").unwrap();
```

### Configuration Priority

1. Environment variables (highest priority)
2. Configuration file
3. Default values (lowest priority)

## 📚 Migration Guide

### Before (Hardcoded)
```rust
let url = "http://localhost:8080";
let timeout = Duration::from_secs(30);
```

### After (Configurable)
```rust
let config = AppConfig::from_env().unwrap_or_default();
let url = config.external_services.songbird_url;
let timeout = Duration::from_secs(config.ai_services.timeout_seconds);
```

This configuration system replaces **441+ hardcoded values** throughout the codebase, making the system deployable in different environments without code changes. 