# Chaos Testing Implementation Guide

## 🎯 Goal
Enable chaos tests to run without full service deployment using mock services.

## 📊 Current Status

```
Chaos Tests Defined:    15 comprehensive tests
Status:                 All marked #[ignore]
Reason:                 Require service deployment
Solution:               Mock-based testing
```

## 🏗️ Implementation Strategy

### Phase 1: Mock Service Framework
Create lightweight mock services for testing.

### Phase 2: Runnable Tests
Remove #[ignore] from 5 easiest tests.

### Phase 3: CI/CD Integration
Add to continuous integration pipeline.

## 🔧 Mock Service Pattern

### Basic Mock Server

```rust
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

pub struct MockService {
    port: u16,
    responses: HashMap<String, String>,
}

impl MockService {
    pub async fn start(port: u16) -> Self {
        let listener = TcpListener::bind(format!("127.0.0.1:{}", port))
            .await
            .unwrap();
        
        tokio::spawn(async move {
            loop {
                let (socket, _) = listener.accept().await.unwrap();
                // Handle connection
            }
        });
        
        Self {
            port,
            responses: HashMap::new(),
        }
    }
    
    pub fn set_response(&mut self, path: &str, response: &str) {
        self.responses.insert(path.to_string(), response.to_string());
    }
}
```

## 🎯 5 Easiest Tests to Enable

### 1. Basic Timeout Test (easiest)

```rust
#[tokio::test]
async fn chaos_basic_timeout() -> Result<(), Box<dyn std::error::Error>> {
    // Start mock service with artificial delay
    let mock = MockService::start_with_delay(8080, Duration::from_secs(5)).await;
    
    // Make request with short timeout
    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(2))
        .build()?;
    
    let result = client
        .get("http://localhost:8080/test")
        .send()
        .await;
    
    // Should timeout
    assert!(result.is_err());
    
    mock.shutdown().await;
    Ok(())
}
```

### 2. Connection Refused Test

```rust
#[tokio::test]
async fn chaos_connection_refused() -> Result<(), Box<dyn std::error::Error>> {
    // Don't start service - port should be closed
    let client = reqwest::Client::new();
    
    let result = client
        .get("http://localhost:9999/test")
        .send()
        .await;
    
    // Should fail with connection refused
    assert!(result.is_err());
    Ok(())
}
```

### 3. Invalid Response Test

```rust
#[tokio::test]
async fn chaos_invalid_response() -> Result<(), Box<dyn std::error::Error>> {
    let mock = MockService::start(8080).await;
    mock.set_response("/test", "INVALID JSON{{{");
    
    let client = reqwest::Client::new();
    let response = client
        .get("http://localhost:8080/test")
        .send()
        .await?;
    
    // Should fail to parse
    let result: Result<serde_json::Value, _> = response.json().await;
    assert!(result.is_err());
    
    mock.shutdown().await;
    Ok(())
}
```

### 4. Rate Limit Test

```rust
#[tokio::test]
async fn chaos_rate_limiting() -> Result<(), Box<dyn std::error::Error>> {
    let mock = MockRateLimitedService::start(8080, 5).await; // 5 req/sec limit
    
    let client = reqwest::Client::new();
    let mut success_count = 0;
    let mut rate_limited_count = 0;
    
    // Make 20 requests rapidly
    for _ in 0..20 {
        let response = client
            .get("http://localhost:8080/test")
            .send()
            .await?;
        
        if response.status().is_success() {
            success_count += 1;
        } else if response.status() == 429 {
            rate_limited_count += 1;
        }
    }
    
    // Should hit rate limit
    assert!(rate_limited_count > 0);
    assert!(success_count <= 5);
    
    mock.shutdown().await;
    Ok(())
}
```

### 5. Intermittent Failure Test

```rust
#[tokio::test]
async fn chaos_intermittent_failures() -> Result<(), Box<dyn std::error::Error>> {
    // Service fails 30% of requests randomly
    let mock = MockIntermittentService::start(8080, 0.3).await;
    
    let client = reqwest::Client::new();
    let mut success_count = 0;
    let mut failure_count = 0;
    
    // Make 100 requests
    for _ in 0..100 {
        let result = client
            .get("http://localhost:8080/test")
            .send()
            .await;
        
        match result {
            Ok(resp) if resp.status().is_success() => success_count += 1,
            _ => failure_count += 1,
        }
    }
    
    // Should have ~30% failures
    assert!(failure_count > 20);
    assert!(failure_count < 40);
    assert!(success_count > 60);
    
    mock.shutdown().await;
    Ok(())
}
```

## 🛠️ Implementation Steps

### Step 1: Create Mock Service Module

```rust
// tests/chaos/mock_services.rs

use std::sync::Arc;
use tokio::sync::RwLock;
use warp::Filter;

pub struct MockService {
    port: u16,
    shutdown_tx: tokio::sync::oneshot::Sender<()>,
}

impl MockService {
    pub async fn start(port: u16) -> Self {
        let (shutdown_tx, shutdown_rx) = tokio::sync::oneshot::channel();
        
        let routes = warp::path("test")
            .map(|| warp::reply::json(&"OK"));
        
        let (_addr, server) = warp::serve(routes)
            .bind_with_graceful_shutdown(
                ([127, 0, 0, 1], port),
                async {
                    shutdown_rx.await.ok();
                }
            );
        
        tokio::spawn(server);
        
        Self { port, shutdown_tx }
    }
    
    pub async fn shutdown(self) {
        let _ = self.shutdown_tx.send(());
        tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    }
}
```

### Step 2: Update chaos_testing.rs

```rust
// Remove #[ignore] from these tests
#[tokio::test]
async fn chaos_01_basic_timeout() -> ChaosResult<()> {
    // Implementation using MockService
}

#[tokio::test]
async fn chaos_02_connection_refused() -> ChaosResult<()> {
    // Implementation without any service
}

// ... etc
```

### Step 3: Add to CI/CD

```yaml
# .github/workflows/tests.yml

- name: Run chaos tests
  run: cargo test --test chaos_testing -- --nocapture
```

## 📊 Expected Results

After implementation:

```
Before:
  Chaos tests: 0 running (15 ignored)
  
After:
  Chaos tests: 5 running ✅
  Coverage: +2-3 percentage points
  CI/CD: Automated chaos testing
```

## 🎯 Success Criteria

- [ ] 5 chaos tests running without #[ignore]
- [ ] Mock service framework complete
- [ ] Tests pass in CI/CD
- [ ] Documentation complete
- [ ] Zero regressions in existing tests

## 📈 Impact

```
Test Coverage:         +2-3pp
Chaos Coverage:        33% (5/15 tests)
CI/CD Coverage:        Automated
Production Confidence: Significantly improved
```

## 💡 Tips

1. **Use unique ports** - Avoid conflicts (8080-8089)
2. **Clean shutdown** - Always cleanup mock services
3. **Timeout tests** - Use short timeouts for fast tests
4. **Random seed** - Use fixed seed for reproducibility
5. **Parallel safe** - Tests should not interfere

## 🚀 Next Steps

1. Implement MockService framework
2. Convert 5 easiest tests
3. Run and verify
4. Add to CI/CD
5. Document patterns
6. Enable remaining 10 tests (Phase 2)

---

**Goal**: Enable real chaos testing without full deployment! 🎯

