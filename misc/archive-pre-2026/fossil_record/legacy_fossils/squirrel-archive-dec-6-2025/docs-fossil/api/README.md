# Squirrel Web API Documentation

## Overview

The Squirrel Web API provides a comprehensive HTTP and WebSocket interface for interacting with the Squirrel AI Coding Assistant platform. This API serves as the primary integration point for client applications, external systems, and user interfaces.

## Version

Current API Version: **v1.0**

Base URL: `https://api.squirrel.ai/v1` (Production)  
Base URL: `http://localhost:3000/api` (Development)

## Authentication

The API uses multiple authentication methods depending on the client type and security requirements.

### JWT Bearer Authentication

For user authentication, the API uses JWT (JSON Web Tokens) with a bearer token scheme.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Token Lifecycle:**
- Access tokens: 15 minutes validity
- Refresh tokens: 7 days validity 
- Automatic token rotation on refresh

### API Key Authentication

For service-to-service communication, use API keys.

**Headers:**
```
X-API-Key: <api_key>
```

### Multi-Factor Authentication (MFA)

Admin accounts require MFA using Time-based One-Time Passwords (TOTP).

**Features:**
- TOTP support (Google Authenticator, Authy, etc.)
- Backup recovery codes
- Required for admin accounts
- Optional for regular users

## Security Features

### Rate Limiting

API endpoints are protected with rate limiting:

- **Authentication endpoints**: 5 requests per minute per IP
- **General API endpoints**: 100 requests per minute per user
- **Admin endpoints**: 50 requests per minute per admin

### Security Headers

All responses include security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security` (HTTPS only)

### Input Validation

- Request body size limited to 10MB
- JSON schema validation for all endpoints
- SQL injection protection
- XSS prevention

## API Response Format

All API responses follow a consistent format:

```json
{
  "success": true,
  "data": <response_data>,
  "error": null,
  "meta": {
    "requestId": "uuid",
    "timestamp": "2025-01-15T10:30:00Z",
    "pagination": {
      "page": 1,
      "limit": 10,
      "totalItems": 100,
      "totalPages": 10
    }
  }
}
```

### Error Response Format

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2025-01-15T10:30:00Z"
  }
}
```

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200  | Success |
| 201  | Created |
| 400  | Bad Request |
| 401  | Unauthorized |
| 403  | Forbidden |
| 404  | Not Found |
| 409  | Conflict |
| 422  | Unprocessable Entity |
| 429  | Too Many Requests |
| 500  | Internal Server Error |
| 503  | Service Unavailable |

## Pagination

List endpoints support pagination with query parameters:

- `page`: Page number (1-based, default: 1)
- `limit`: Items per page (default: 10, max: 100)

Example: `/api/commands?page=2&limit=20`

## Filtering and Sorting

Many endpoints support filtering and sorting:

**Filtering:**
- `status=completed`: Filter by status
- `created_after=2025-01-01`: Filter by date
- `user_id=123`: Filter by user

**Sorting:**
- `sort=created_at`: Sort field
- `order=desc`: Sort order (asc/desc)

Example: `/api/commands?status=completed&sort=created_at&order=desc`

## WebSocket API

Real-time communication is available via WebSocket connections.

**Connection URL:** `ws://localhost:3000/ws`

**Authentication:** Include JWT token in connection headers or as query parameter:
```
ws://localhost:3000/ws?token=<jwt_token>
```

### WebSocket Message Format

```json
{
  "id": "message_id",
  "type": "command_status",
  "payload": {
    "command_id": "cmd_123",
    "status": "completed"
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

## API Endpoints

### Authentication

#### POST /auth/login
Authenticate a user and receive JWT tokens.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "securepassword",
  "mfa_code": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_access_token",
    "refreshToken": "jwt_refresh_token",
    "expiresIn": 900,
    "user": {
      "id": "user_id",
      "username": "user@example.com",
      "roles": ["user"]
    }
  }
}
```

#### POST /auth/refresh
Refresh an access token using a refresh token.

#### POST /auth/logout
Logout and invalidate tokens.

### Multi-Factor Authentication

#### POST /auth/mfa/setup
Setup MFA for the current user.

**Response:**
```json
{
  "success": true,
  "data": {
    "secret": "base64_secret",
    "qr_code_url": "otpauth://totp/...",
    "backup_codes": ["1234-5678", "9012-3456"],
    "setup_key": "manual_entry_key"
  }
}
```

#### POST /auth/mfa/verify-setup
Verify MFA setup with a TOTP code.

#### POST /auth/mfa/verify
Verify MFA code during authentication.

#### GET /auth/mfa/status
Get MFA status for current user.

#### DELETE /auth/mfa
Disable MFA (not allowed for admin accounts).

#### POST /auth/mfa/backup-codes
Regenerate backup codes.

### API Keys

#### POST /auth/api-keys
Create a new API key.

#### GET /auth/api-keys
List user's API keys.

#### DELETE /auth/api-keys/{keyId}
Revoke an API key.

### Commands

#### POST /commands
Create and execute a command.

**Request:**
```json
{
  "command": "analyze-repository",
  "parameters": {
    "repository_url": "https://github.com/user/repo",
    "branch": "main"
  }
}
```

#### GET /commands
List user's commands with filtering and pagination.

#### GET /commands/{id}
Get command status and details.

#### DELETE /commands/{id}
Cancel a running command.

#### GET /commands/available
List available commands.

### Health & Monitoring

#### GET /health
System health check.

#### GET /metrics
Prometheus metrics (admin only).

## Error Codes

### Authentication Errors

| Code | Description |
|------|-------------|
| `AUTH_INVALID_CREDENTIALS` | Invalid username or password |
| `AUTH_MFA_REQUIRED` | MFA code required |
| `AUTH_MFA_INVALID` | Invalid MFA code |
| `AUTH_TOKEN_EXPIRED` | JWT token expired |
| `AUTH_TOKEN_INVALID` | Invalid JWT token |

### Validation Errors

| Code | Description |
|------|-------------|
| `VALIDATION_REQUIRED_FIELD` | Required field missing |
| `VALIDATION_INVALID_FORMAT` | Invalid field format |
| `VALIDATION_OUT_OF_RANGE` | Value out of allowed range |

### Business Logic Errors

| Code | Description |
|------|-------------|
| `COMMAND_NOT_FOUND` | Command not found |
| `COMMAND_NOT_CANCELLABLE` | Command cannot be cancelled |
| `MFA_ALREADY_CONFIGURED` | MFA already setup |
| `MFA_NOT_CONFIGURED` | MFA not configured |

## Rate Limiting

Rate limits are enforced per endpoint and user:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

When rate limited, the API returns HTTP 429 with retry information:

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "details": {
      "retryAfter": 60
    }
  }
}
```

## SDKs and Libraries

### Official SDKs

- **JavaScript/TypeScript**: `@squirrel/web-sdk`
- **Python**: `squirrel-web-sdk`
- **Rust**: `squirrel-web-client`

### Community SDKs

- **Go**: `github.com/community/squirrel-go`
- **Java**: `com.community:squirrel-java-sdk`

## Examples

### Complete Authentication Flow

```javascript
// 1. Login
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'user@example.com',
    password: 'password123'
  })
});

const { data: { token, refreshToken } } = await loginResponse.json();

// 2. Use token for API calls
const commandResponse = await fetch('/api/commands', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    command: 'analyze-repository',
    parameters: { repository_url: 'https://github.com/user/repo' }
  })
});

// 3. Refresh token when needed
const refreshResponse = await fetch('/api/auth/refresh', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ refreshToken })
});
```

### WebSocket Connection

```javascript
const ws = new WebSocket(`ws://localhost:3000/ws?token=${token}`);

ws.onopen = () => {
  console.log('Connected to WebSocket');
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Received:', message);
};

// Subscribe to command updates
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'commands',
  filters: { user_id: 'current' }
}));
```

### MFA Setup Flow

```javascript
// 1. Setup MFA
const setupResponse = await fetch('/api/auth/mfa/setup', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` }
});

const { data: { qr_code_url, backup_codes, secret } } = await setupResponse.json();

// 2. Show QR code to user for scanning with authenticator app
console.log('Scan this QR code:', qr_code_url);
console.log('Backup codes:', backup_codes);

// 3. Verify setup with TOTP code from app
const verifyResponse = await fetch('/api/auth/mfa/verify-setup', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ code: '123456' })
});
```

## Interactive Documentation

### Swagger UI

Interactive API documentation is available at:
- Development: `http://localhost:3000/docs`
- Production: `https://api.squirrel.ai/docs`

### OpenAPI Specification

The complete OpenAPI 3.0 specification is available at:
- JSON: `/api/openapi.json`
- YAML: `/api/openapi.yaml`

## Support

### Documentation

- **API Reference**: `/docs`
- **Tutorials**: `https://docs.squirrel.ai/tutorials`
- **Examples**: `https://github.com/squirrel-ai/examples`

### Community

- **Discord**: `https://discord.gg/squirrel-ai`
- **GitHub**: `https://github.com/squirrel-ai/squirrel`
- **Stack Overflow**: Tag with `squirrel-ai`

### Support Channels

- **Email**: `support@squirrel.ai`
- **Bug Reports**: `https://github.com/squirrel-ai/squirrel/issues`
- **Feature Requests**: `https://github.com/squirrel-ai/squirrel/discussions`

## Changelog

### v1.0.0 (2025-01-15)

**Security Enhancements:**
- ✅ Implemented MFA support for admin accounts
- ✅ Added rate limiting to all endpoints
- ✅ Enhanced JWT security with refresh token rotation
- ✅ API key authentication for service-to-service communication

**Documentation:**
- ✅ Complete OpenAPI 3.0 specification
- ✅ Interactive Swagger UI documentation
- ✅ Comprehensive API examples and tutorials
- ✅ Security audit and best practices documentation

**API Features:**
- ✅ RESTful command execution API
- ✅ WebSocket real-time communication
- ✅ Plugin management endpoints
- ✅ Health monitoring and metrics

**Breaking Changes:**
- None (initial release)

---

*Last updated: January 15, 2025*  
*API Version: 1.0.0* 