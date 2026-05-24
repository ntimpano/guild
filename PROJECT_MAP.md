# Project Map: guild

## Core Files
- `AGENTS.md` — Global runtime behavior for Guild agents (identity, memory, communication style, persistence)
- `guild-agents.json` — Agent definitions with Flint MCP tool permissions (renamed from nt-* to guild-*)
- `README.md` — Project documentation
- `package.json` — Node.js project (Express 5, TypeScript, ts-node)
- `deploy.sh` — Deployment script to /opt/guild
- `install-agents.sh` — Installation script for OpenCode agents (plus fixed/minimal/new variants)

## Agent Naming Convention
- **Current**: `guild-*` (guild-leader, guild-apply, guild-explore, etc.)
- **Legacy (removed)**: `nt-*` (nt-leader, nt-sdd-apply, etc.) — no longer used anywhere in the repo

## Directory Structure

### `prompts/` — Agent role prompts
- `prompts/sdd/` — SDD workflow prompts (guild-leader, sdd-apply, sdd-explore, etc.)
- `prompts/creative/` — Creative agents (expand, focus, shape, polish, ship)
- `prompts/research/` — Research agents (gather, synthesize, challenge/critic, conclude, document, init)
- `prompts/strategy/` — Strategy agents (brief, communicate, decide, diagnose/explore, options, track)
- `prompts/shared/` — Shared prompts (guild-spark)

### `skills/` — Skill definitions (SKILL.md per skill)
**SDD workflow:**
- sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive, sdd-onboard
- sdd-model-configurator (with webview UI)

**Code quality:**
- judgment-day, security-review, work-unit-commits, chained-pr, branch-pr

**Testing:**
- go-testing, python-testing-tdd

**Documentation:**
- cognitive-doc-design, doc-writer, comment-writer

**Ops:**
- azure-pr-workflow, repo-workflow-ops, issue-creation, bug-fix

**Meta:**
- _shared (persistence-contract, flint-convention, skill-resolver)
- skill-creator, skill-registry

### `commands/` — Slash commands
- sdd-init, sdd-explore, sdd-apply, sdd-verify, sdd-archive, sdd-onboard, sdd-continue, sdd-new, sdd-ff

### `plugins/`
- sdd-model-router — Model routing for SDD phases

## Dependency Chain
```
AGENTS.md (global behavior)
  └── guild-agents.json (tool permissions per agent)
       └── prompts/ (role definitions)
       └── skills/ (task-specific instructions)
            └── _shared/ (persistence-contract, flint-convention, skill-resolver)
```

## Key Patterns
- **Agent names**: `guild-*` convention (formerly `nt-*`, renamed in this commit)
- **SDD workflow**: init → explore → propose → spec → design → tasks → apply → verify → archive
- **Flint persistence**: Skills save artifacts via `flint_local_save` following `_shared/persistence-contract.md` and `_shared/flint-convention.md`
- **Skill resolver**: `_shared/skill-resolver.md` defines how orchestrators inject skills into sub-agents
- **Two platforms**: Works with both OpenCode (via MCP + install script) and Pi (via native agents + skills)
- **Tool permissions**: `guild-agents.json` maps each agent to its allowed Flint MCP tools

## Known Issues
- `install-agents.sh` has known syntax issues; `install-agents-minimal.sh` is the working variant
- Multiple install script variants (fixed, minimal, new) suggest install script consolidation is needed
- `express` and `ts-node` in dependencies suggest a server component or plugin system, but no server entry point is visible

## Last Updated
2026-05-23