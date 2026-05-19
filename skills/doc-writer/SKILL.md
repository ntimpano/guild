---
name: doc-writer
description: >
 Write clear, maintainable technical documentation for code, APIs, modules, and decisions across full-stack projects. Covers inline docs, READMEs, API references, and architectural notes.
 Trigger: When writing or updating documentation, adding docstrings/JSDoc/godoc, creating READMEs, documenting APIs, or the user asks to document something.
license: Apache-2.0
metadata:
 author: nt-cli
 version: "1.0"
---

## When to Use

- Adding or updating inline documentation (docstrings, JSDoc, godoc, etc.)
- Writing or updating a README or module-level doc
- Documenting an API endpoint or interface
- Documenting an architecture decision
- During `sdd-archive` to ensure changes are properly documented

## Adaptation Rule

If you encounter a language or toolchain not covered here, **state it explicitly**, apply the closest analogous doc convention, and flag the gap.

---

## Critical Patterns

### 1. Document the WHY, not the WHAT

Code shows WHAT. Documentation must explain WHY.

```python
# Bad: what (obvious from code)
# Increments counter by 1
counter += 1

# Good: why
# Throttle requests: counter tracks calls in the current window.
# When it reaches MAX_CALLS, the next request will be queued.
counter += 1
```

### 2. Inline Documentation by Language

**TypeScript / JavaScript — JSDoc**
```ts
/**
 * Calculates the retry delay using exponential backoff.
 *
 * @param attempt - Zero-based attempt number (0 = first retry).
 * @param baseMs - Base delay in milliseconds. Defaults to 500.
 * @returns Delay in milliseconds, capped at 30 seconds.
 *
 * @example
 * retryDelay(0) // 500
 * retryDelay(3) // 4000
 */
export function retryDelay(attempt: number, baseMs = 500): number
```

**Python — Google-style docstrings**
```python
def retry_delay(attempt: int, base_ms: int = 500) -> int:
  """Calculates retry delay using exponential backoff.

  Args:
    attempt: Zero-based attempt number (0 = first retry).
    base_ms: Base delay in milliseconds. Defaults to 500.

  Returns:
    Delay in milliseconds, capped at 30 seconds.

  Example:
    >>> retry_delay(0)
    500
    >>> retry_delay(3)
    4000
  """
```

**Go — godoc**
```go
// RetryDelay calculates the retry delay using exponential backoff.
// attempt is zero-based (0 = first retry). Returns delay in milliseconds,
// capped at 30 seconds.
func RetryDelay(attempt int, baseMs int) int
```

**Rust — rustdoc**
```rust
/// Calculates retry delay using exponential backoff.
///
/// `attempt` is zero-based (0 = first retry). Returns delay in milliseconds,
/// capped at 30 seconds.
///
/// # Examples
/// ```
/// assert_eq!(retry_delay(0, 500), 500);
/// ```
pub fn retry_delay(attempt: u32, base_ms: u64) -> u64
```

### 3. README Structure

Use this structure, skip sections that don't apply:

```markdown
# Project / Module Name

One sentence: what this does and who it's for.

## Quick Start
[Minimum steps to get it running — prioritize speed]

## Usage
[Common use cases with examples]

## Configuration
[Environment variables, config files, options]

## API / Interface
[Public surface — inputs, outputs, errors]

## Architecture (if non-obvious)
[Key decisions and why — link to ADRs if they exist]

## Development
[How to run tests, lint, build locally]

## Contributing
[If open source or team project]
```

### 4. API Documentation

For each endpoint/function document:

```
Method + Path (for HTTP) or Signature (for functions)
Purpose: one sentence
Parameters: name, type, required/optional, description
Returns: type and shape
Errors: possible error cases and codes
Example: request + response or call + result
```

### 5. Architecture Decision Records (ADR)

Use when documenting a significant technical decision:

```markdown
# ADR-NNN: Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-NNN

## Context
What situation forced this decision?

## Decision
What was decided?

## Rationale
Why this option over alternatives?

## Consequences
What does this make easier? What does it make harder?
```

### 6. What NOT to document

- Obvious code (don't explain what `i++` does)
- Temporary workarounds without flagging them as such
- Internal implementation details that change frequently (document the interface, not internals)
- Dead code — delete it instead

---

## Output Format

For inline docs: provide the updated code block with docs added.

For READMEs or standalone docs:

```
## Documentation

[Full markdown content]

### Coverage
- [list of what was documented]

### Gaps (if any)
- [things that need docs but were out of scope or lacked enough context]
```

## Rules

- Match the existing doc style of the project if one exists.
- Never write docs for private internals unless explicitly asked.
- Keep examples **runnable** — test them mentally before writing.
- If a function/module is too complex to document simply, flag it as a design smell.
- Always document public APIs, exported functions, and non-obvious behavior.
