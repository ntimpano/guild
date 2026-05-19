---
name: bug-fix
description: >
  Structured workflow for diagnosing, fixing, and verifying bugs across full-stack codebases. Covers root cause analysis, minimal fix strategy, regression prevention, and documentation of the fix.
  Trigger: When fixing a bug, investigating an error, diagnosing unexpected behavior, or the user reports something is broken.
license: Apache-2.0
metadata:
  author: nt-cli
  version: "1.0"
---

## When to Use

- User reports a bug or unexpected behavior
- A failing test needs investigation and fix
- An error/exception needs root cause analysis
- During `sdd-apply` or `sdd-verify` when an implementation issue is found

## Adaptation Rule

If you encounter a language, framework, or runtime not covered here, **state it explicitly**, apply the closest analogous debugging pattern, and flag the gap.

---

## Critical Patterns

### 1. Diagnose First, Fix Second (MANDATORY)

Never jump to a fix without understanding the root cause. Follow this order:

```
1. Reproduce → confirm the bug exists and understand the trigger
2. Isolate → find the smallest failing case
3. Root cause → trace to the actual source, not the symptom
4. Fix → minimal change that addresses root cause
5. Verify → confirm fix, check for regressions
```

### 2. Root Cause Analysis

- Read the full stack trace top-to-bottom. The **first** frame in your code is usually the real source.
- Distinguish between **symptom** (where it crashes) and **cause** (why it happens).
- Common root cause categories:
  - **State mutation**: shared/mutable state modified unexpectedly
  - **Off-by-one**: index errors, boundary conditions, pagination
  - **Async/race condition**: unhandled Promise, missing await, concurrent writes
  - **Type mismatch**: null/undefined, string vs number, wrong shape
  - **Missing guard**: no nil check, no fallback, no error boundary
  - **Wrong assumption**: library behavior differs from expectation (check docs)
  - **Environment difference**: works locally, breaks in CI/prod (env vars, OS, deps)

### 3. Minimal Fix Principle

- Fix the **root cause**, not the symptom.
- Prefer the smallest change that makes the failing case pass.
- Do not refactor while fixing — separate concerns.
- If a proper fix is large, implement a **safe minimal fix** first and flag the refactor as a follow-up.

### 4. Regression Prevention

- Always add or update a test that **reproduces the exact bug**.
- The test must fail before the fix and pass after.
- If no test infrastructure exists, document the manual reproduction steps clearly.
- Check: does the fix break any existing tests?

### 5. Language/Framework Patterns

**JavaScript / TypeScript**
- Async bugs: check missing `await`, unhandled Promise rejections, event loop ordering.
- `undefined` vs `null`: use optional chaining `?.` and nullish coalescing `??` defensively.
- Closures: check stale closures in React hooks (`useEffect` deps array).
- Type errors: check `any` escape hatches masking real type issues.

**Python**
- Mutable defaults: `def f(x=[])` is a classic bug — use `None` + guard.
- Exception swallowing: bare `except:` hides errors — always catch specific types.
- Async: `asyncio` event loop conflicts, missing `await`, `run_until_complete` in wrong context.

**Go**
- Nil pointer: always check for `nil` before dereferencing interfaces or pointers.
- Error ignored: never assign error to `_` in production paths.
- Goroutine leaks: check that goroutines have exit conditions.
- Slice mutation: slices share underlying array — copy when needed.

**React / Frontend**
- Stale state: `setState` is async — never read state immediately after setting it.
- Missing deps in `useEffect`: causes stale closures or infinite loops.
- Key prop: missing or unstable keys cause reconciliation bugs.

**SQL / ORM**
- N+1: check for queries inside loops — use eager loading / joins.
- Transaction scope: check that related writes are in the same transaction.
- Migration safety: check that schema changes are backward compatible with running code.

### 6. Document the Fix

Always leave a trace of what was found and why it was fixed that way:

- Code comment on the fix if the reason isn't obvious.
- Save to memory (`ntcli_local_save`) with root cause, file, and what changed.
- If it's a systemic pattern (e.g., missing null checks everywhere), flag it as a follow-up issue.

---

## Output Format

```
## Bug Fix Report

### Root Cause
[One clear sentence: what caused the bug and why]

### Reproduction
[Minimal steps or test case that triggers the bug]

### Fix Applied
[What was changed, file:line, and why this addresses the root cause]

### Verification
[Test added/updated, or manual steps to confirm the fix]

### Follow-up (if any)
[Systemic issues or refactors deferred]
```

## Rules

- NEVER fix without reproducing first.
- NEVER suppress errors to make tests pass.
- ALWAYS add a test for the bug before fixing it (TDD on bugs).
- If root cause requires a large refactor, do the minimal safe fix first and open a follow-up.
- If the bug is in an unknown framework/library, check the official changelog/issues before guessing.
