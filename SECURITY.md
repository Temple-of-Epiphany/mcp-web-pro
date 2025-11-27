# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities to:

**Email:** colin@bitterfield.com

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:

- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

This information will help us triage your report more quickly.

## Security Update Process

1. **Report Received** - We acknowledge receipt within 48 hours
2. **Assessment** - We assess the vulnerability (typically within 7 days)
3. **Fix Development** - We develop and test a fix
4. **Disclosure** - We coordinate disclosure with the reporter
5. **Release** - We release a security update
6. **Announcement** - We publish a security advisory

## Security Best Practices

### For Users

- Always run MCP Web Pro with the latest version
- Use localhost binding only (do not expose to network)
- Keep preview root directory permissions restricted
- Regularly review preview directory contents
- Use Snyk or similar tools to scan for vulnerabilities

### For Contributors

- Run `make snyk-test` before every commit
- Follow secure coding guidelines
- Never commit secrets, credentials, or PII
- Validate all user inputs
- Use parameterized queries for any database operations
- Keep dependencies up to date

## Known Security Considerations

### Localhost Only

MCP Web Pro is designed for localhost use only. The HTTP server binds to 127.0.0.1 and should never be exposed to external networks.

### No Authentication

Since the server runs on localhost, no authentication is implemented. This is by design and appropriate for the use case.

### File System Access

The server has write access to the configured preview root directory. Ensure this directory:
- Is not a system directory
- Has appropriate permissions
- Is regularly cleaned of old content

### Content Sanitization

HTML and JSX content is not sanitized by default. Users should:
- Only render trusted content
- Be aware of XSS risks in rendered content
- Not execute untrusted JavaScript

## Security Scanning

This project uses:

- **Snyk** - Dependency and code vulnerability scanning
- **Gitleaks** - Secret detection
- **Trivy** - Container and filesystem scanning
- **Dependabot** - Automated dependency updates

All pull requests must pass security scans before merging.

## Disclosure Policy

We follow coordinated disclosure:

1. Security issues are fixed privately
2. Fixes are released without detailed vulnerability information
3. After users have time to update (typically 30 days), full details may be published
4. Credit is given to reporters (unless they prefer to remain anonymous)

## Security Hall of Fame

We appreciate security researchers who help keep MCP Web Pro secure. Contributors who responsibly disclose security issues will be listed here (with their permission):

<!-- Contributors will be listed here -->

---

**Last Updated:** 2025-11-27
**Version:** 0.1.0
**Maintained By:** Colin Bitterfield <colin@bitterfield.com>
