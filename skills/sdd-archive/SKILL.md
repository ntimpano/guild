---
name: sdd-archive
description: "Sync delta specs to main specs and archive a completed change. Trigger: When the orchestrator launches you to archive a change after implementation and verification."
license: MIT
metadata:
 author: gentleman-programming
 version: "2.0"
---

## Purpose

You are a sub-agent responsible for ARCHIVING. You finalize a completed change by producing an archive report with artifact lineage in flint. You complete the SDD cycle.

## What You Receive

From the orchestrator:
- Change name

## Execution and Persistence Contract

Persistence: this skill saves its artifact to flint via `flint_local_save` (see `_shared/persistence-contract.md` and `_shared/flint-convention.md`). Engram is NOT used.

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Validate Archive Inputs

Confirm all required artifacts exist in flint:
- `sdd/{change-name}/proposal`
- `sdd/{change-name}/spec`
- `sdd/{change-name}/design`
- `sdd/{change-name}/tasks`
- `sdd/{change-name}/verify-report`

If any are missing, return `blocked` and list missing topic keys.

### Step 3: Build Archive Lineage

Prepare an archive lineage section with references to all source topic keys and any related observation IDs returned by flint retrieval.

### Step 4: Verify Archive Readiness

Confirm:
- [ ] Verification verdict is `PASS` or `PASS WITH WARNINGS`
- [ ] No CRITICAL issues remain
- [ ] All required artifact references are included in lineage

### Step 5: Persist Archive Report

**This step is MANDATORY — do NOT skip it.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `archive-report`
- topic_key: `sdd/{change-name}/archive-report`
- type: `architecture`

### Step 6: Return Summary

Return to the orchestrator:

```markdown
## Change Archived

**Change**: {change-name}
**Archived to**: flint `sdd/{change-name}/archive-report`

### Artifact Lineage
| Artifact | Topic key | Reference |
|----------|-----------|-----------|
| Proposal | `sdd/{change-name}/proposal` | {id or found} |
| Spec | `sdd/{change-name}/spec` | {id or found} |
| Design | `sdd/{change-name}/design` | {id or found} |
| Tasks | `sdd/{change-name}/tasks` | {id or found} |
| Verify report | `sdd/{change-name}/verify-report` | {id or found} |

### SDD Cycle Complete
The change has been fully planned, implemented, verified, and archived.
Ready for the next change.
```

## Rules

- NEVER archive a change that has CRITICAL issues in its verification report
- ALWAYS include artifact lineage for proposal/spec/design/tasks/verify-report
- If verification has unresolved CRITICAL issues, STOP and report blocker
- The archive report is an AUDIT TRAIL — never omit source artifact references
- Return envelope per **Section D** from `skills/_shared/sdd-phase-common.md`.
