# MCP Web Pro Specification

**Author:** Colin Bitterfield
**Email:** colin@bitterfield.com
**Date Created:** 2025-11-27
**Date Updated:** 2025-11-27
**Version:** 0.1.0

## 1. Project Overview

### 1.1 Purpose
MCP Web Pro is a Model Context Protocol (MCP) server that enables Claude to render and serve web content (HTML, JSX, images, and other web assets) for local preview. This allows users to view Claude-generated web artifacts both within Claude Desktop and in external web browsers.

### 1.2 Target Platforms
- macOS
- Linux
- Windows 11

### 1.3 Primary Use Case
Enable Claude to write web content and provide immediate visual feedback through a local web server without requiring manual file management or server setup by the user.

## 2. Architecture

### 2.1 System Components

#### 2.1.1 MCP Server (stdio transport)
- **Purpose:** Communicates with Claude Desktop via stdin/stdout using JSON-RPC 2.0 protocol
- **Implementation:** Python-based using official MCP SDK
- **Runtime:** Python 3.10+ in virtual environment

#### 2.1.2 HTTP Preview Server
- **Purpose:** Serves rendered content to web browsers
- **Implementation:** Lightweight HTTP server (asyncio-based)
- **Port:** Configurable (default: 8080)
- **Security:** Localhost binding only, no authentication required

#### 2.1.3 Content Storage
- **Purpose:** Temporary storage for rendered previews and uploaded assets
- **Location:** Configurable via MCP configuration
- **Lifecycle:** Persistent across server restarts, manual cleanup

### 2.2 Communication Flow

```
Claude Desktop
    ↓ (stdio - JSON-RPC 2.0)
MCP Server
    ↓ (writes to filesystem)
Preview Directory
    ↑ (HTTP GET)
Web Browser / Claude Desktop Preview
```

## 3. MCP Server Capabilities

### 3.1 Tools

#### 3.1.1 render_html
**Purpose:** Render HTML content and make it available for preview

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "content": {
      "type": "string",
      "description": "HTML content to render"
    },
    "filename": {
      "type": "string",
      "description": "Optional filename (auto-generated if not provided)"
    }
  },
  "required": ["content"]
}
```

**Output:**
- Success: Preview URL and file path
- Error: Error message with details

**Behavior:**
1. Validate HTML content
2. Generate unique ID if filename not provided
3. Write content to preview directory
4. Return accessible URL

#### 3.1.2 render_jsx
**Purpose:** Process JSX content, transpile to JavaScript, and render

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "content": {
      "type": "string",
      "description": "JSX content to render"
    },
    "dependencies": {
      "type": "array",
      "items": {"type": "string"},
      "description": "External libraries (e.g., ['react', 'react-dom'])"
    },
    "filename": {
      "type": "string",
      "description": "Optional filename"
    }
  },
  "required": ["content"]
}
```

**Output:**
- Success: Preview URL and file path
- Error: Transpilation or render errors

**Behavior:**
1. Transpile JSX using Babel (via PyExecJS or similar)
2. Bundle with required dependencies (CDN links)
3. Generate HTML wrapper
4. Write to preview directory
5. Return accessible URL

#### 3.1.3 upload_asset
**Purpose:** Store images, CSS, JavaScript, or other static assets

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "content": {
      "type": "string",
      "description": "Base64-encoded asset content"
    },
    "filename": {
      "type": "string",
      "description": "Asset filename with extension"
    },
    "mime_type": {
      "type": "string",
      "description": "MIME type (e.g., 'image/png')"
    }
  },
  "required": ["content", "filename", "mime_type"]
}
```

**Output:**
- Success: Asset URL and file path
- Error: Storage or validation errors

**Behavior:**
1. Decode base64 content
2. Validate MIME type matches extension
3. Store in assets subdirectory
4. Return accessible URL

#### 3.1.4 list_previews
**Purpose:** List all rendered previews

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "limit": {
      "type": "integer",
      "description": "Maximum number of results (default: 50)"
    }
  }
}
```

**Output:**
- Array of preview metadata (filename, URL, created time, size)

#### 3.1.5 delete_preview
**Purpose:** Remove a specific preview

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "preview_id": {
      "type": "string",
      "description": "Preview identifier or filename"
    }
  },
  "required": ["preview_id"]
}
```

**Output:**
- Success confirmation or error

#### 3.1.6 set_preview_root
**Purpose:** Change the HTML root directory dynamically

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "path": {
      "type": "string",
      "description": "Absolute path to new preview root directory"
    }
  },
  "required": ["path"]
}
```

**Output:**
- Success confirmation with new path or error

**Behavior:**
1. Validate path exists and is accessible
2. Check write permissions
3. Update configuration
4. Return confirmation

### 3.2 Resources

#### 3.2.1 previews://list
**URI:** `previews://list`
**Purpose:** Provide context about all available previews
**MIME Type:** `application/json`

**Content Structure:**
```json
{
  "previews": [
    {
      "id": "abc123",
      "filename": "example.html",
      "url": "http://localhost:8080/preview/abc123",
      "created": "2025-11-27T10:30:00Z",
      "size": 2048
    }
  ]
}
```

#### 3.2.2 preview://{id}
**URI:** `preview://{id}`
**Purpose:** Access specific preview content
**MIME Type:** `text/html` or appropriate type

**Behavior:**
- Read preview file from storage
- Return content with appropriate MIME type
- Return error if preview not found

## 4. Configuration

### 4.1 MCP Server Configuration

**Location:** Claude Desktop config file
- macOS/Linux: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

**Example Configuration:**
```json
{
  "mcpServers": {
    "mcp-web-pro": {
      "command": "python",
      "args": ["/absolute/path/to/mcp-web-pro/src/server.py"],
      "env": {
        "PYTHONUNBUFFERED": "1",
        "MCP_WEB_LOG_LEVEL": "info",
        "MCP_WEB_PREVIEW_PORT": "8080",
        "MCP_WEB_PREVIEW_ROOT": "/Users/username/previews"
      }
    }
  }
}
```

### 4.2 Server Configuration File

**Location:** `config.json` in project root (optional)

**Schema:**
```json
{
  "server": {
    "preview_port": 8080,
    "preview_root": "./previews",
    "max_preview_size_mb": 10,
    "auto_cleanup_days": 7
  },
  "logging": {
    "level": "info",
    "file": null
  },
  "jsx": {
    "react_version": "18.2.0",
    "babel_standalone": true
  }
}
```

### 4.3 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MCP_WEB_LOG_LEVEL` | Logging level (debug, info, warning, error) | `info` |
| `MCP_WEB_PREVIEW_PORT` | HTTP server port | `8080` |
| `MCP_WEB_PREVIEW_ROOT` | Preview storage directory | `./previews` |
| `MCP_WEB_CONFIG_FILE` | Path to config.json | `./config.json` |

## 5. Logging

### 5.1 Log Destinations

**Claude Desktop Integration:**
- Logs sent via MCP logging protocol (notifications to client)
- Uses syslog severity levels

**Local File Logging:**
- Optional file-based logging for debugging
- Location: `logs/mcp-web-pro.log`
- Rotation: Daily, keep 7 days

### 5.2 Log Levels

- **debug:** Detailed diagnostic information
- **info:** General operational messages
- **warning:** Warning messages for recoverable issues
- **error:** Error messages for failures
- **critical:** Critical issues requiring attention

### 5.3 Security Requirements

Logs MUST NOT contain:
- User credentials or tokens
- Personal identifying information (PII)
- Full file paths that could expose system structure
- Sensitive content from previews

## 6. Security Considerations

### 6.1 Access Control
- HTTP server binds to localhost only (127.0.0.1)
- No authentication required (local-only access)
- Preview root directory must be user-writable
- Validate all file paths to prevent directory traversal

### 6.2 Content Validation
- HTML/JSX content sanitization (optional, configurable)
- File size limits enforced
- MIME type validation for assets
- Extension whitelist for uploaded files

### 6.3 Resource Limits
- Maximum preview size: 10 MB (configurable)
- Maximum number of previews: 1000 (auto-cleanup oldest)
- Rate limiting: Not required (localhost only)

### 6.4 TLS/SSL
- Not required (localhost communication)
- Optional via reverse proxy (out of scope)

## 7. Installation & Deployment

### 7.1 Installation Methods

#### 7.1.1 Via Makefile
```bash
# Install on current platform
make install

# Platform-specific
make install-macos
make install-linux
make install-windows
```

#### 7.1.2 Manual Installation
```bash
# Create virtual environment
python3 -m venv venv

# Activate (platform-specific)
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate.bat  # Windows

# Install dependencies
pip install -r requirements.txt

# Configure Claude Desktop
# Edit claude_desktop_config.json manually
```

### 7.2 Makefile Targets

| Target | Description |
|--------|-------------|
| `install` | Auto-detect platform and install |
| `install-macos` | Install on macOS |
| `install-linux` | Install on Linux |
| `install-windows` | Install on Windows 11 |
| `dev` | Install development dependencies |
| `test` | Run test suite |
| `lint` | Run code quality checks |
| `snyk-test` | Run Snyk security scan |
| `clean` | Remove generated files |
| `uninstall` | Remove installation |

### 7.3 Dependencies

**Core:**
- Python 3.10+
- `mcp` (official MCP SDK)
- `aiohttp` (async HTTP server)
- `watchdog` (file system monitoring)

**JSX Support:**
- `PyExecJS` (JavaScript runtime)
- `babel-standalone` (via CDN in HTML)

**Development:**
- `pytest` (testing)
- `black` (code formatting)
- `pylint` (linting)
- `mypy` (type checking)

## 8. Development Workflow

### 8.1 Issue Tracking
- All code changes tracked via GitHub Issues
- Labels: `enhancement`, `bug`, `security`, `documentation`
- Milestones for version releases

### 8.2 Pull Request Process
1. Create issue describing change
2. Create feature branch from `master`
3. Implement changes with tests
4. Run Snyk scan locally (`make snyk-test`)
5. Create pull request referencing issue
6. Code review required before merge
7. Update specification and README as needed

### 8.3 Version Control
- Branch protection on `master`
- Semantic versioning (MAJOR.MINOR.PATCH)
- Version number in each source file header
- Backup old versions to `./backups` with timestamp

### 8.4 Testing Requirements
- Unit tests for all tools
- Integration tests for MCP protocol
- Manual testing in Claude Desktop
- Security scan with Snyk (no high/critical vulnerabilities)

## 9. GitHub Actions

### 9.1 CI Pipeline

**Triggers:** Push to any branch, pull request

**Jobs:**
1. **Lint & Format Check**
   - Run `black --check`
   - Run `pylint`
   - Run `mypy`

2. **Security Scan**
   - Run Snyk test
   - Fail on high/critical vulnerabilities

3. **Unit Tests**
   - Run pytest with coverage
   - Minimum 80% coverage

4. **Integration Tests**
   - Test MCP protocol compliance
   - Test tool execution

### 9.2 Release Pipeline

**Trigger:** Tag push (`v*.*.*`)

**Jobs:**
1. Run full CI pipeline
2. Build distribution package
3. Create GitHub release
4. Attach artifacts

## 10. Future Enhancements

### 10.1 Phase 2 Features
- Live reload for HTML/JSX previews
- WebSocket support for real-time updates
- Template system for common layouts
- CSS preprocessor support (SASS, LESS)

### 10.2 Phase 3 Features
- Multi-user support (authentication)
- Remote deployment capability
- Preview history and versioning
- Collaborative editing support

## 11. Known Limitations

### 11.1 Current Version (0.1.0)
- JSX transpilation requires JavaScript runtime
- No automatic browser refresh on content update
- Single preview root directory at a time
- No built-in HTTPS support
- Limited to localhost access only

### 11.2 Platform-Specific Issues
- Windows: Path handling differences
- macOS: Gatekeeper warnings for unsigned code
- Linux: Varies by distribution

## 12. References

- [MCP Specification](https://modelcontextprotocol.io/specification/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Claude Desktop Documentation](https://claude.ai/docs)
- [Babel Standalone](https://babeljs.io/docs/en/babel-standalone)

## 13. Change Log

### Version 0.1.0 (2025-11-27)
- Initial specification
- Core architecture defined
- Tool and resource definitions
- Configuration structure
- Security requirements
- Installation procedures
