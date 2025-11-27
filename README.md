# MCP Web Pro

> Model Context Protocol server providing web content preview capabilities for Claude - render HTML, JSX, and images locally

**Organization:** [Temple of Epiphany](https://github.com/Temple-of-Epiphany)
**Author:** Colin Bitterfield <colin@bitterfield.com>
**License:** Private
**Version:** 0.1.0

---

## 🚀 Quick Start

### Prerequisites

- **Python**: 3.10+
- **Claude Desktop**: Latest version
- **Git**: 2.40+
- **GitHub CLI**: 2.40+ (recommended)

### Installation

#### Method 1: Using Makefile (Recommended)

```bash
# Clone the repository
git clone https://github.com/Temple-of-Epiphany/mcp-web-pro.git
cd mcp-web-pro

# Install for your platform (auto-detects OS)
make install

# Or specify platform explicitly
make install-macos    # macOS
make install-linux    # Linux
make install-windows  # Windows 11
```

#### Method 2: Manual Installation

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate.bat  # Windows

# Install dependencies
pip install -r requirements.txt

# Configure Claude Desktop (see Configuration section)
```

### Configuration

Add to your Claude Desktop config file:

**macOS/Linux:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

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
        "MCP_WEB_PREVIEW_ROOT": "/Users/yourusername/previews"
      }
    }
  }
}
```

**Important:**
- Use **absolute paths** only
- Restart Claude Desktop completely after configuration changes
- Create the preview root directory if it doesn't exist

---

## 📋 Features

### 🌐 Web Content Rendering

- **HTML Rendering** - Write and preview HTML content instantly
- **JSX Support** - Transpile and render React JSX components
- **Static Assets** - Upload images, CSS, JavaScript files
- **Live Preview** - View content in browser at `http://localhost:8080`
- **Dynamic Root** - Switch preview directories on-the-fly

### 🔧 MCP Tools

| Tool | Description |
|------|-------------|
| `render_html` | Render HTML content to preview directory |
| `render_jsx` | Transpile JSX and render with React |
| `upload_asset` | Store images, CSS, JS files |
| `list_previews` | List all rendered previews |
| `delete_preview` | Remove specific preview |
| `set_preview_root` | Change HTML root directory |

### 📦 MCP Resources

| Resource | URI | Description |
|----------|-----|-------------|
| Preview List | `previews://list` | Metadata for all previews |
| Preview Content | `preview://{id}` | Specific preview content |

### 🔒 Security Features

- **Localhost Only** - HTTP server binds to 127.0.0.1
- **No Authentication** - Safe for local-only access
- **Path Validation** - Prevents directory traversal
- **File Size Limits** - Configurable maximum file sizes
- **Secure Logging** - No PII or secrets in logs

---

## 📁 Project Structure

```
mcp-web-pro/
├── .github/
│   ├── workflows/              # CI/CD pipelines
│   │   ├── ci-development.yml  # Development CI
│   │   └── snyk-security.yml   # Security scanning
│   └── ISSUE_TEMPLATE/         # Issue templates
│
├── src/
│   ├── server.py               # Main MCP server
│   ├── tools/                  # MCP tool implementations
│   │   ├── __init__.py
│   │   ├── render_html.py
│   │   ├── render_jsx.py
│   │   ├── upload_asset.py
│   │   └── preview_manager.py
│   ├── resources/              # MCP resource implementations
│   │   ├── __init__.py
│   │   ├── preview_resource.py
│   │   └── resource_manager.py
│   ├── http_server.py          # HTTP preview server
│   └── config.py               # Configuration management
│
├── tests/                      # Test suites
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── test_mcp_protocol.py    # MCP protocol tests
│
├── docs/                       # Documentation
│   └── specifications/
│       └── mcp_web_specification.md
│
├── logs/                       # Log files (gitignored)
├── previews/                   # Default preview storage (gitignored)
├── backups/                    # Script backups (gitignored)
│
├── .gitignore                  # Git ignore rules
├── requirements.txt            # Python dependencies
├── requirements-dev.txt        # Development dependencies
├── Makefile                    # Installation automation
├── config.json                 # Server configuration
├── mcp_web_specification.md    # Technical specification
├── README.md                   # This file
└── LICENSE                     # License file
```

---

## 🛠️ Development

### Setup Development Environment

```bash
# Install development dependencies
make dev

# Or manually
pip install -r requirements-dev.txt
```

### Running Tests

```bash
# Run all tests
make test

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/unit/test_render_html.py
```

### Code Quality

```bash
# Format code
black src/ tests/
isort src/ tests/

# Lint code
flake8 src/ tests/
pylint src/
mypy src/

# Or use Makefile
make lint
```

### Security Scanning

```bash
# Run Snyk scan locally (required before push)
make snyk-test

# Or manually
snyk test
snyk code test
```

---

## 🔄 Development Workflow

### Branch Strategy

```
main (production)
  ↑ PR with review + all checks
develop (integration)
  ↑ PR from feature branches
feature/* or bugfix/* (development)
```

### Creating Issues

All code changes must be tracked via GitHub Issues:

```bash
# List current issues
gh issue list

# Create new issue
gh issue create --title "Add CSS preprocessing support" \
  --body "Description of the feature..." \
  --label enhancement

# View issue
gh issue view 123
```

### Pull Request Process

1. **Create Issue** - Describe the change
2. **Create Branch** - `git checkout -b feature/issue-123-description`
3. **Implement Changes** - Follow specification
4. **Run Snyk** - `make snyk-test` (must pass)
5. **Run Tests** - `make test` (must pass)
6. **Update Docs** - Update specification and README if needed
7. **Create PR** - `gh pr create --base develop`
8. **Code Review** - Required before merge
9. **Merge** - Squash and merge to develop

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<optional body>

<optional footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example:**
```
feat(jsx): add support for React Hooks

Implement JSX transpilation with React Hooks support.
Includes babel-standalone integration.

Closes #42
```

---

## 📚 Usage Examples

### In Claude Desktop

Once configured, Claude can use these tools directly:

**Render HTML:**
```
Claude: I'll create a simple HTML page for you.

[Uses render_html tool]
Content: <!DOCTYPE html><html>...</html>

Result: Preview available at http://localhost:8080/preview/abc123
```

**Render JSX:**
```
Claude: I'll create a React component.

[Uses render_jsx tool]
Content: function App() { return <div>Hello</div>; }

Result: Preview available at http://localhost:8080/preview/xyz789
```

**Upload Image:**
```
Claude: I'll add this image to your preview.

[Uses upload_asset tool]
Content: [base64-encoded image]

Result: Image available at http://localhost:8080/assets/image.png
```

---

## 🔐 Security

### Reporting Vulnerabilities

See [SECURITY.md](SECURITY.md) for vulnerability reporting procedures.

### Security Best Practices

- Run `make snyk-test` before every push
- Never commit credentials or secrets
- Review security scan results in GitHub Security tab
- Keep dependencies updated via Dependabot

### Logging

Logs are stored in `logs/mcp-web-pro.log` (not committed to git).

Log levels: `debug`, `info`, `warning`, `error`, `critical`

Configure via environment variable:
```bash
export MCP_WEB_LOG_LEVEL=debug
```

---

## 🐛 Troubleshooting

### Claude Desktop Can't Find Server

**Problem:** Server doesn't appear in Claude Desktop tools

**Solutions:**
1. Verify configuration path is absolute (not relative)
2. Check virtual environment Python path
3. Restart Claude Desktop completely (Cmd+Q, not just close window)
4. Check logs at `logs/mcp-web-pro.log`

### Preview Port Already in Use

**Problem:** Port 8080 is already in use

**Solution:** Change port in configuration:
```json
"MCP_WEB_PREVIEW_PORT": "8081"
```

### Permission Denied on Preview Root

**Problem:** Can't write to preview directory

**Solution:** Ensure directory exists and is writable:
```bash
mkdir -p /path/to/previews
chmod 755 /path/to/previews
```

### JSX Transpilation Fails

**Problem:** JSX content doesn't render

**Solution:** Ensure PyExecJS is installed and Node.js is available:
```bash
pip install PyExecJS
node --version  # Should output version number
```

---

## 📊 Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MCP_WEB_LOG_LEVEL` | Logging level | `info` |
| `MCP_WEB_PREVIEW_PORT` | HTTP server port | `8080` |
| `MCP_WEB_PREVIEW_ROOT` | Preview storage directory | `./previews` |
| `MCP_WEB_CONFIG_FILE` | Path to config.json | `./config.json` |

### config.json

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
    "file": "logs/mcp-web-pro.log"
  },
  "jsx": {
    "react_version": "18.2.0",
    "babel_standalone": true
  }
}
```

---

## 📖 Documentation

- **Specification:** [mcp_web_specification.md](mcp_web_specification.md)
- **MCP Protocol:** [Model Context Protocol](https://modelcontextprotocol.io/)
- **MCP Python SDK:** [GitHub](https://github.com/modelcontextprotocol/python-sdk)
- **Claude Desktop:** [Anthropic Documentation](https://claude.ai/docs)

---

## 🔗 Related Projects

- [MCP Specification](https://github.com/modelcontextprotocol/specification)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Claude Desktop](https://claude.ai/download)

---

## 📝 Roadmap

### Version 0.1.0 (Current)
- ✅ Basic HTML rendering
- ✅ JSX transpilation support
- ✅ Static asset upload
- ✅ HTTP preview server
- ✅ MCP protocol implementation

### Version 0.2.0 (Planned)
- ⬜ Live reload on content update
- ⬜ CSS preprocessor support (SASS, LESS)
- ⬜ Template system
- ⬜ Preview history and versioning

### Version 0.3.0 (Future)
- ⬜ WebSocket support for real-time updates
- ⬜ Multi-user support
- ⬜ Collaborative editing
- ⬜ Cloud deployment option

---

## 🤝 Contributing

1. Create an issue describing the change
2. Fork the repository
3. Create a feature branch
4. Make changes following specification
5. Run security scan: `make snyk-test`
6. Run tests: `make test`
7. Update documentation
8. Submit pull request

---

## 📞 Support

**Issues:** [GitHub Issues](https://github.com/Temple-of-Epiphany/mcp-web-pro/issues)
**Security:** See [SECURITY.md](SECURITY.md)
**Email:** colin@bitterfield.com

---

## 📜 License

Private - All Rights Reserved

Copyright (c) 2025 Temple of Epiphany

---

## 🙏 Acknowledgments

- Built on the [Model Context Protocol](https://modelcontextprotocol.io/)
- Uses [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- Inspired by Claude Desktop's extensibility
- Maintained by Colin Bitterfield

---

**Last Updated:** 2025-11-27
**Version:** 0.1.0
**Maintained By:** Colin Bitterfield <colin@bitterfield.com>
