---
name: security-review
description: >
  Perform a structured security review of code changes or modules, covering OWASP Top 10, injection, auth, secrets, and dependency risks across common full-stack languages and frameworks.
  Trigger: When reviewing code for security issues, auditing a PR, running a security pass, or the user asks for a security check.
license: Apache-2.0
metadata:
  author: nt-cli
  version: "1.0"
---

## When to Use

- Before merging code that touches auth, input handling, APIs, or data persistence
- When a PR introduces new dependencies
- When the user asks for a security pass on a file, module, or change
- During `sdd-verify` if the spec includes security requirements

## Adaptation Rule

If you encounter a language, framework, or tool not covered here, **state it explicitly**, apply the closest analogous pattern, and flag the gap for the user to review manually.

---

## Critical Patterns

### 1. Input Validation & Injection
- **Never trust user input** — validate at the boundary, not deep inside.
- SQL: parameterized queries only. No string concatenation. Check ORMs for raw query escape hatches.
- NoSQL (MongoDB, DynamoDB): check for operator injection (`$where`, `$gt` on untrusted data).
- Command injection: no `exec`/`shell` with user-controlled strings. Prefer safe APIs.
- Path traversal: normalize and restrict paths. Check `../` sequences.
- Template injection: never pass user input to template engines unsanitized.

### 2. Authentication & Authorization
- Verify **authn** (who are you) and **authz** (what can you do) are both present on every protected route.
- JWTs: check `alg` is enforced server-side (reject `none`). Verify expiry and signature.
- Sessions: check secure, httpOnly, SameSite flags on cookies.
- Privilege escalation: check that role/scope validation is server-side, never client-side only.
- IDOR: confirm that object IDs are scoped to the authenticated user/org.

### 3. Secrets & Credentials
- No hardcoded secrets, API keys, tokens, or passwords in code or config files.
- `.env` files must never be committed. Check `.gitignore`.
- Secret rotation: flag any long-lived credentials embedded in code.
- Logs: check that sensitive fields (passwords, tokens, PII) are never logged.

### 4. Dependency Risks
- Flag new dependencies added without justification.
- Check for known CVEs if a lockfile diff is available (flag for `npm audit`, `pip-audit`, `govulncheck`, `cargo audit`, etc.).
- Prefer well-maintained, widely-used packages. Flag abandoned or low-adoption deps.
- Check for dependency confusion risk (internal package names that could be squatted).

### 5. Data Exposure
- APIs must not return more fields than needed (over-fetching, internal IDs, PII).
- Error messages must not leak stack traces, internal paths, or DB schema to clients.
- Sensitive data at rest: check encryption requirements are met.
- PII: flag if personal data is stored longer than necessary or without purpose.

### 6. CORS & HTTP Security
- CORS: check that allowed origins are not `*` for credentialed requests.
- Headers: verify `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security` are set where applicable.
- CSRF: check for anti-CSRF tokens on state-changing endpoints (if not using SameSite=Strict).

### 7. Frontend-Specific
- XSS: no `innerHTML`/`dangerouslySetInnerHTML` with untrusted data.
- React/Vue/Angular sanitize by default — flag any explicit bypass.
- LocalStorage: never store tokens or sensitive data there.
- postMessage: validate origin before processing.

### 8. Rate Limiting & DoS
- Check that auth endpoints have rate limiting.
- File uploads: validate type, size, and content. Never execute uploaded files.
- Large payloads: check for body size limits on APIs.

---

## Output Format

Return findings grouped by severity:

```
## Security Review

### 🔴 Critical
- [file:line] Issue description. Why it's critical. Fix suggestion.

### 🟠 High
- [file:line] Issue description. Fix suggestion.

### 🟡 Medium
- [file:line] Issue description. Fix suggestion.

### 🔵 Low / Informational
- [file:line] Note.

### ✅ No issues found in
- [list of areas checked with no findings]

### ⚠️ Outside known patterns
- [anything encountered that doesn't match known stack — flag for manual review]
```

## Rules

- Report findings with **file and line** when possible.
- Always explain **why** something is a risk, not just what.
- Propose a concrete fix, not just "fix this".
- Do NOT auto-fix critical issues without user confirmation.
- If the codebase uses a pattern consistently (even if imperfect), note it as a systemic risk, not individual instances.
