# 🦀 Modern Rust Error Handling Patterns
**For AI Tools Error Migration**  
**Philosophy**: Idiomatic, descriptive, actionable

---

## 🎯 **Core Principles**

### **1. Errors Should Tell A Story**
```rust
// ❌ BAD: Generic, unhelpful
Err(AIError::NetworkError("error".to_string()))

// ✅ GOOD: Specific, actionable
Err(AIToolsError::Network(
    "Failed to reach OpenAI API at https://api.openai.com. \
     Check network connection and API endpoint configuration.".to_string()
))
```

### **2. Use The Type System**
```rust
// ❌ BAD: Stringly-typed
fn get_api_key() -> Result<String, String>

// ✅ GOOD: Strong types
fn get_api_key() -> Result<ApiKey, AIToolsError>
```

### **3. Leverage From/Into Traits**
```rust
// Instead of manual conversions everywhere:
impl From<reqwest::Error> for AIToolsError {
    fn from(e: reqwest::Error) -> Self {
        if e.is_timeout() {
            AIToolsError::Network("Request timed out. Increase timeout or check connectivity.".to_string())
        } else if e.is_connect() {
            AIToolsError::Network(format!("Connection failed: {}. Verify endpoint URL.", e))
        } else {
            AIToolsError::Network(format!("HTTP error: {}", e))
        }
    }
}

// Then use ? operator cleanly:
let response = client.get(url).send().await?;
```

### **4. Context Propagation**
```rust
// ❌ BAD: Lost context
.map_err(|e| AIError::ParseError(e.to_string()))?

// ✅ GOOD: Preserved context
.map_err(|e| AIToolsError::Parse(
    format!("Failed parsing {} model response: {}. Response may not match expected schema.", 
            model_name, e)
))?
```

---

## 🔧 **Common Patterns**

### **Pattern: HTTP Request Handling**
```rust
// Modern idiomatic pattern:
async fn call_api(&self, request: &Request) -> Result<Response, AIToolsError> {
    let response = self.client
        .post(&self.config.endpoint)
        .json(&request)
        .send()
        .await
        .map_err(|e| AIToolsError::Network(
            format!("Failed to send request to {}: {}. Check API endpoint and network.", 
                    self.config.provider, e)
        ))?;
    
    if !response.status().is_success() {
        let status = response.status();
        let body = response.text().await.unwrap_or_default();
        return Err(AIToolsError::Api(
            format!("API returned error status {}: {}. Verify API key and request format.",
                    status, body)
        ));
    }
    
    response.json().await.map_err(|e| AIToolsError::Parse(
        format!("Failed to parse API response: {}. Response format may have changed.",
                e)
    ))
}
```

### **Pattern: Optional Field Extraction**
```rust
// ❌ Old way:
let choices = response.choices
    .ok_or_else(|| AIError::InvalidResponse("Missing choices".to_string()))?;

// ✅ Modern way:
let choices = response.choices
    .ok_or_else(|| AIToolsError::InvalidResponse(
        format!("Response from {} missing required 'choices' field. \
                 API may be returning unexpected format.",
                provider_name)
    ))?;
```

### **Pattern: Nested Option/Result**
```rust
// ❌ Pyramid of doom:
let content = if let Some(choice) = choices.first() {
    if let Some(msg) = &choice.message {
        if let Some(content) = &msg.content {
            content
        } else {
            return Err(AIError::InvalidResponse("no content".to_string()));
        }
    } else {
        return Err(AIError::InvalidResponse("no message".to_string()));
    }
} else {
    return Err(AIError::InvalidResponse("no choices".to_string()));
};

// ✅ Idiomatic chain:
let content = choices
    .first()
    .and_then(|c| c.message.as_ref())
    .and_then(|m| m.content.as_ref())
    .ok_or_else(|| AIToolsError::InvalidResponse(
        "Response missing message content in expected structure".to_string()
    ))?;
```

---

## 🎨 **Provider-Specific Patterns**

### **OpenAI Errors**:
```rust
// Parse OpenAI error response structure
if let Ok(error_resp) = response.json::<OpenAIErrorResponse>().await {
    return Err(AIToolsError::Api(
        format!("OpenAI API error: {} (type: {}). {}",
                error_resp.error.message,
                error_resp.error.type_,
                suggest_fix(&error_resp.error))
    ));
}

fn suggest_fix(error: &OpenAIError) -> &str {
    match error.type_.as_str() {
        "insufficient_quota" => "Check billing and account quota at platform.openai.com",
        "invalid_api_key" => "Verify API key in configuration",
        "rate_limit_exceeded" => "Reduce request rate or upgrade tier",
        _ => "See OpenAI documentation for details"
    }
}
```

### **Anthropic Errors**:
```rust
// Anthropic uses different structure
match status.as_u16() {
    401 => Err(AIToolsError::Authentication(
        "Invalid Anthropic API key. Generate new key at console.anthropic.com".to_string()
    )),
    429 => Err(AIToolsError::RateLimitExceeded(
        "Anthropic rate limit hit. Consider request throttling.".to_string()
    )),
    _ => Err(AIToolsError::Api(format!("Anthropic API error: {}", body)))
}
```

---

## 🧪 **Testing Error Patterns**

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_error_contains_context() {
        let err = AIToolsError::Network(
            "Failed to connect to OpenAI".to_string()
        );
        
        let msg = err.to_string();
        assert!(msg.contains("OpenAI"), "Error should name provider");
        assert!(msg.contains("Network"), "Error should identify type");
    }
    
    #[test]
    fn test_from_reqwest_error() {
        let reqwest_err = reqwest::Error::from(/* ... */);
        let our_err: AIToolsError = reqwest_err.into();
        
        assert!(matches!(our_err, AIToolsError::Network(_)));
    }
}
```

---

## 📋 **Migration Checklist Per Error**

For each `AIError::*` you encounter:

1. **Understand Context**:
   - [ ] What operation is failing?
   - [ ] What would help user debug?
   - [ ] What's the recovery path?

2. **Choose Modern Pattern**:
   - [ ] Can use From impl + `?`?
   - [ ] Should add operation context?
   - [ ] Can make message more actionable?

3. **Implement**:
   - [ ] Update to AIToolsError variant
   - [ ] Add rich context to message
   - [ ] Include provider/operation name
   - [ ] Suggest fix if obvious

4. **Verify**:
   - [ ] Message is descriptive
   - [ ] Contains actionable info
   - [ ] Maintains error semantics
   - [ ] Compiles cleanly

---

## 🎯 **Before/After Examples**

### **Example 1: Network Error**
```rust
// BEFORE:
.map_err(|e| crate::error::AIError::NetworkError(e.to_string()))?

// AFTER:
.map_err(|e| AIToolsError::Network(
    format!("Failed to connect to {} API endpoint '{}': {}. \
             Verify network connectivity and endpoint configuration.",
            self.provider_name(),
            self.config.endpoint, 
            e)
))?
```

### **Example 2: Missing API Key**
```rust
// BEFORE:
let api_key = config.api_key
    .ok_or(AIError::Configuration("missing api key".to_string()))?;

// AFTER:
let api_key = config.api_key
    .ok_or_else(|| AIToolsError::Configuration(
        format!("{} API key not configured. Set {} environment variable or \
                 add to config file.",
                self.provider_name(),
                self.env_var_name())
    ))?;
```

### **Example 3: Parse Error**
```rust
// BEFORE:
serde_json::from_str(&body)
    .map_err(|e| AIError::ParseError(e.to_string()))?

// AFTER:
serde_json::from_str(&body)
    .map_err(|e| AIToolsError::Parse(
        format!("Failed to deserialize {} API response: {}. \
                 API response format may have changed. Response preview: {}",
                provider,
                e,
                &body.chars().take(100).collect::<String>())
    ))?
```

---

**Guide Version**: 1.0  
**Purpose**: Ensure consistent, modern error handling across migration  
**Status**: Active reference for migration work  

🦀 **Write Rust the way Rust should be written!** 🚀

