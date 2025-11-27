# Makefile for MCP Web Pro
# Author: Colin Bitterfield <colin@bitterfield.com>
# Version: 0.1.0

.PHONY: help install install-macos install-linux install-windows dev test lint clean uninstall snyk-test

# Default target
help:
	@echo "MCP Web Pro - Makefile Targets"
	@echo "==============================="
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Auto-detect OS and install"
	@echo "  make install-macos    - Install on macOS"
	@echo "  make install-linux    - Install on Linux"
	@echo "  make install-windows  - Install on Windows 11"
	@echo ""
	@echo "Development:"
	@echo "  make dev              - Install development dependencies"
	@echo "  make test             - Run test suite"
	@echo "  make lint             - Run code quality checks"
	@echo "  make snyk-test        - Run Snyk security scan"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean            - Remove generated files"
	@echo "  make uninstall        - Remove installation"
	@echo ""

# Auto-detect OS and install
install:
	@echo "Detecting operating system..."
	@uname_s=$$(uname -s); \
	if [ "$$uname_s" = "Darwin" ]; then \
		$(MAKE) install-macos; \
	elif [ "$$uname_s" = "Linux" ]; then \
		$(MAKE) install-linux; \
	elif [ "$${OS}" = "Windows_NT" ]; then \
		$(MAKE) install-windows; \
	else \
		echo "Unsupported operating system: $$uname_s"; \
		exit 1; \
	fi

# macOS installation
install-macos:
	@echo "Installing MCP Web Pro on macOS..."
	@echo ""

	@# Check Python version
	@echo "Checking Python version..."
	@python3 --version || (echo "Python 3.10+ required" && exit 1)

	@# Create virtual environment
	@echo "Creating virtual environment..."
	@python3 -m venv venv

	@# Activate and install dependencies
	@echo "Installing dependencies..."
	@. venv/bin/activate && pip install --upgrade pip
	@. venv/bin/activate && pip install -r requirements.txt

	@# Create necessary directories
	@echo "Creating directories..."
	@mkdir -p logs previews backups

	@# Set permissions
	@chmod 755 logs previews backups

	@# Display configuration instructions
	@echo ""
	@echo "✅ Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Configure Claude Desktop:"
	@echo "   Edit: ~/Library/Application Support/Claude/claude_desktop_config.json"
	@echo ""
	@echo "2. Add this configuration:"
	@echo '   {'
	@echo '     "mcpServers": {'
	@echo '       "mcp-web-pro": {'
	@echo '         "command": "python",'
	@echo '         "args": ["'$$(pwd)'/src/server.py"],'
	@echo '         "env": {'
	@echo '           "PYTHONUNBUFFERED": "1",'
	@echo '           "MCP_WEB_LOG_LEVEL": "info",'
	@echo '           "MCP_WEB_PREVIEW_PORT": "8080",'
	@echo '           "MCP_WEB_PREVIEW_ROOT": "'$$(pwd)'/previews"'
	@echo '         }'
	@echo '       }'
	@echo '     }'
	@echo '   }'
	@echo ""
	@echo "3. Restart Claude Desktop completely (Cmd+Q)"
	@echo ""

# Linux installation
install-linux:
	@echo "Installing MCP Web Pro on Linux..."
	@echo ""

	@# Check Python version
	@echo "Checking Python version..."
	@python3 --version || (echo "Python 3.10+ required" && exit 1)

	@# Create virtual environment
	@echo "Creating virtual environment..."
	@python3 -m venv venv

	@# Activate and install dependencies
	@echo "Installing dependencies..."
	@. venv/bin/activate && pip install --upgrade pip
	@. venv/bin/activate && pip install -r requirements.txt

	@# Create necessary directories
	@echo "Creating directories..."
	@mkdir -p logs previews backups

	@# Set permissions
	@chmod 755 logs previews backups

	@# Display configuration instructions
	@echo ""
	@echo "✅ Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Configure Claude Desktop:"
	@echo "   Edit: ~/.config/Claude/claude_desktop_config.json"
	@echo "   (Location may vary by distribution)"
	@echo ""
	@echo "2. Add this configuration:"
	@echo '   {'
	@echo '     "mcpServers": {'
	@echo '       "mcp-web-pro": {'
	@echo '         "command": "python",'
	@echo '         "args": ["'$$(pwd)'/src/server.py"],'
	@echo '         "env": {'
	@echo '           "PYTHONUNBUFFERED": "1",'
	@echo '           "MCP_WEB_LOG_LEVEL": "info",'
	@echo '           "MCP_WEB_PREVIEW_PORT": "8080",'
	@echo '           "MCP_WEB_PREVIEW_ROOT": "'$$(pwd)'/previews"'
	@echo '         }'
	@echo '       }'
	@echo '     }'
	@echo '   }'
	@echo ""
	@echo "3. Restart Claude Desktop completely"
	@echo ""

# Windows installation
install-windows:
	@echo "Installing MCP Web Pro on Windows..."
	@echo ""
	@echo "For Windows installation, please run:"
	@echo "  python -m venv venv"
	@echo "  venv\\Scripts\\activate.bat"
	@echo "  pip install --upgrade pip"
	@echo "  pip install -r requirements.txt"
	@echo ""
	@echo "Then configure Claude Desktop:"
	@echo "  Edit: %APPDATA%\\Claude\\claude_desktop_config.json"
	@echo ""
	@echo "Use forward slashes or escaped backslashes in paths."
	@echo ""

# Development installation
dev:
	@echo "Installing development dependencies..."
	@if [ ! -d "venv" ]; then \
		echo "Virtual environment not found. Run 'make install' first."; \
		exit 1; \
	fi
	@. venv/bin/activate && pip install -r requirements-dev.txt
	@echo "✅ Development dependencies installed"

# Run tests
test:
	@echo "Running tests..."
	@if [ ! -d "venv" ]; then \
		echo "Virtual environment not found. Run 'make install' first."; \
		exit 1; \
	fi
	@. venv/bin/activate && pytest tests/ -v --cov=src --cov-report=term-missing
	@echo "✅ Tests complete"

# Run linters
lint:
	@echo "Running code quality checks..."
	@if [ ! -d "venv" ]; then \
		echo "Virtual environment not found. Run 'make install' first."; \
		exit 1; \
	fi
	@echo ""
	@echo "→ Black (formatting check)..."
	@. venv/bin/activate && black --check src/ tests/ || true
	@echo ""
	@echo "→ isort (import sorting check)..."
	@. venv/bin/activate && isort --check-only src/ tests/ || true
	@echo ""
	@echo "→ Flake8 (style check)..."
	@. venv/bin/activate && flake8 src/ tests/ || true
	@echo ""
	@echo "→ Pylint (static analysis)..."
	@. venv/bin/activate && pylint src/ || true
	@echo ""
	@echo "→ Mypy (type checking)..."
	@. venv/bin/activate && mypy src/ || true
	@echo ""
	@echo "✅ Linting complete"

# Run Snyk security scan
snyk-test:
	@echo "Running Snyk security scan..."
	@echo ""
	@if ! command -v snyk &> /dev/null; then \
		echo "❌ Snyk not found. Install with:"; \
		echo "   npm install -g snyk"; \
		echo "   or: brew install snyk/tap/snyk"; \
		exit 1; \
	fi
	@echo "→ Testing dependencies..."
	@snyk test --severity-threshold=high
	@echo ""
	@echo "→ Testing code..."
	@snyk code test
	@echo ""
	@echo "✅ Security scan complete"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf __pycache__ .pytest_cache .coverage htmlcov
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@rm -rf build dist *.egg-info
	@rm -rf logs/*.log
	@echo "✅ Clean complete"

# Uninstall
uninstall:
	@echo "Uninstalling MCP Web Pro..."
	@rm -rf venv
	@rm -rf logs previews backups
	@$(MAKE) clean
	@echo "✅ Uninstall complete"
	@echo ""
	@echo "Don't forget to remove the MCP configuration from Claude Desktop:"
	@echo "  macOS/Linux: ~/Library/Application Support/Claude/claude_desktop_config.json"
	@echo "  Windows: %APPDATA%\\Claude\\claude_desktop_config.json"
	@echo ""
