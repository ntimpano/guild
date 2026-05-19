---
name: sdd-init
description: "Initialize Spec-Driven Development context in any project. Detects stack, conventions, testing capabilities, and bootstraps flint persistence. Trigger: When user wants to initialize SDD in a project, or says \"sdd init\" or \"iniciar sdd\"."
license: MIT
metadata:
 author: gentleman-programming
 version: "3.0"
---

## Purpose

You are a sub-agent responsible for initializing the Spec-Driven Development (SDD) context in a project. You detect the project stack, conventions, and testing capabilities, then bootstrap the active persistence backend.

You are an EXECUTOR for this phase, not the orchestrator. Do the initialization work yourself. Do NOT launch sub-agents, do NOT call `delegate` or `task`, and do NOT hand execution back unless you hit a real blocker that must be reported upstream.

## Execution and Persistence Contract

Persistence: this skill saves its artifacts to flint via `flint_local_save` (see `_shared/persistence-contract.md` and `_shared/flint-convention.md`). Engram is NOT used.

## What to Do

### Step 1: Detect Project Context

Read the project to understand:
- Tech stack (check package.json, go.mod, pyproject.toml, etc.)
- Existing conventions (linters, test frameworks, CI)
- Architecture patterns in use

### Step 2: Detect Testing Capabilities

Scan the project for ALL testing infrastructure. This determines what testing modes are available.

```
Detect testing capabilities:
├── Test Runner
│  ├── package.json → devDependencies: vitest, jest, mocha, ava
│  ├── package.json → scripts.test (what command it runs)
│  ├── pyproject.toml / pytest.ini / setup.cfg → pytest
│  ├── go.mod → go test (built-in)
│  ├── Cargo.toml → cargo test (built-in)
│  ├── Makefile → make test
│  └── Result: {framework name, command} or NOT FOUND
│
├── Test Layers
│  ├── Unit: test runner exists → AVAILABLE
│  ├── Integration:
│  │  ├── JS/TS: @testing-library/* in dependencies
│  │  ├── Python: pytest + httpx/requests-mock/factory-boy
│  │  ├── Go: net/http/httptest (built-in)
│  │  ├── .NET: xUnit/NUnit + WebApplicationFactory
│  │  └── Result: AVAILABLE or NOT INSTALLED
│  ├── E2E:
│  │  ├── playwright, cypress, selenium in dependencies
│  │  ├── Python: playwright, selenium
│  │  ├── Go: chromedp
│  │  └── Result: AVAILABLE or NOT INSTALLED
│  └── Each layer → record tool name
│
├── Coverage Tool
│  ├── JS/TS: vitest --coverage, jest --coverage, c8, istanbul/nyc
│  ├── Python: coverage.py, pytest-cov
│  ├── Go: go test -cover (built-in)
│  ├── .NET: coverlet
│  └── Result: {command} or NOT AVAILABLE
│
└── Quality Tools
  ├── Linter: eslint, pylint, ruff, golangci-lint, clippy
  ├── Type checker: tsc --noEmit, mypy, pyright, go vet
  ├── Formatter: prettier, black, gofmt, rustfmt
  └── Each: {command} or NOT AVAILABLE
```

### Step 3: Resolve STRICT TDD MODE

Determine whether Strict TDD Mode should be enabled. The resolution follows a priority chain — first match wins:

```
1. Read from system prompt / agent config (highest priority):
  ├── Search for "strict-tdd-mode" marker in the agent's system prompt file
  │  (e.g., CLAUDE.md, GEMINI.md, .cursorrules, etc.)
  ├── If found and says "enabled" → strict_tdd: true
  ├── If found and says "disabled" → strict_tdd: false
  └── This is the preference set by the user in the nt-cli runtime profile

2. If nothing found AND test runner was detected in Step 2:
  ├── Default: strict_tdd: true (enable if the project CAN do TDD)
  └── This ensures TDD is active even without nt-cli runtime profile setup

3. If no test runner detected:
  ├── strict_tdd: false (cannot enable without test runner)
  └── Include NOTE in summary: "Strict TDD Mode unavailable — no test runner detected"
```

**Do NOT ask the user interactively.** The preference is resolved from existing config. If the user wants to change it, they run `nt-cli profile init / profile update` with the TUI.

### Step 4: Initialize Persistence Backend

Initialize persistence by preparing flint artifacts for this project context.

### Step 5: Persist Testing Capabilities

**This step is MANDATORY — do NOT skip it.**

Persist detected testing capabilities as a separate flint observation. This cache prevents re-detection on every `sdd-apply` and `sdd-verify` run.

```
flint_local_save(
 title: "sdd/{project-name}/testing-capabilities",
 topic_key: "sdd/{project-name}/testing-capabilities",
 type: "config",
 scope: "{project-name}",
 content: "{testing capabilities markdown — see format below}"
)
```

**Testing Capabilities format**:

```markdown
## Testing Capabilities

**Strict TDD Mode**: {enabled/disabled}
**Detected**: {date}

### Test Runner
- Command: `{command}`
- Framework: {name}

### Test Layers
| Layer | Available | Tool |
|-------|-----------|------|
| Unit | ✅ / ❌ | {tool or —} |
| Integration | ✅ / ❌ | {tool or —} |
| E2E | ✅ / ❌ | {tool or —} |

### Coverage
- Available: ✅ / ❌
- Command: `{command or —}`

### Quality Tools
| Tool | Available | Command |
|------|-----------|---------|
| Linter | ✅ / ❌ | {command or —} |
| Type checker | ✅ / ❌ | {command or —} |
| Formatter | ✅ / ❌ | {command or —} |
```

### Step 6: Build Skill Registry

Follow the same logic as the `skill-registry` skill (`skills/skill-registry/SKILL.md`):

1. Scan user skills: glob `*/SKILL.md` across ALL known skill directories. **User-level**: `~/.claude/skills/`, `~/.config/opencode/skills/`, `~/.gemini/skills/`, `~/.cursor/skills/`, `~/.copilot/skills/`, parent of this skill file. **Project-level**: `.claude/skills/`, `.gemini/skills/`, `.agent/skills/`, `skills/`. Skip `sdd-*`, `_shared`, `skill-registry`. Deduplicate by name (project-level wins). Read frontmatter triggers.
2. Scan project conventions: check for `agents.md`, `AGENTS.md`, `CLAUDE.md` (project-level), `.cursorrules`, `GEMINI.md`, `copilot-instructions.md` in the project root. If an index file is found (e.g., `agents.md`), READ it and extract all referenced file paths — include both the index and its referenced files in the registry.
3. **ALWAYS write `.atl/skill-registry.md`** in the project root (create `.atl/` if needed).
4. Always save to flint: `flint_local_save(title: "skill-registry", topic_key: "skill-registry", type: "config", scope: "{project-name}", content: "{registry markdown}")`.

See `skills/skill-registry/SKILL.md` for the full registry format and scanning details.

### Step 7: Persist Project Context

**This step is MANDATORY — do NOT skip it.**

```
flint_local_save(
 title: "sdd-init/{project-name}",
 topic_key: "sdd-init/{project-name}",
 type: "architecture",
 scope: "{project-name}",
 content: "{your detected project context from Steps 1-7}"
)
```

### Step 8: Return Summary

```
## SDD Initialized

**Project**: {project name}
**Stack**: {detected stack}
**Persistence**: flint
**Strict TDD Mode**: {enabled ✅ / disabled ❌ / unavailable (no test runner)}

### Testing Capabilities
{same table as above}

### Context Detected
{summary of detected stack and conventions}

### Next Steps
Ready for /sdd-explore <topic> or /sdd-new <change-name>.
```

## Rules

- NEVER create placeholder spec files - specs are created via sdd-spec during a change
- ALWAYS detect the real tech stack, don't guess
- NEVER behave like the orchestrator from this phase - execute directly and return results
- ALWAYS detect testing capabilities — this is not optional
- ALWAYS persist testing capabilities as a separate observation/section — downstream phases depend on it
- If Strict TDD Mode is requested but no test runner exists, set strict_tdd: false and explain why
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, and `risks`
