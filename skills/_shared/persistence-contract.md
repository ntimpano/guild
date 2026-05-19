# Persistence Contract (shared across all SDD skills)

> **The ONLY persistence backend is ntcli.** Engram does NOT exist in this stack and never did. Never call `mem_save`, `mem_search`, `mem_get_observation`, or any `mem_*` tool. There is no opt-out, no alternative mode, no fallback.

## Backend

ntcli local SQLite via the `ntcli_local_*` MCP tools. Always available, always required.

| Capability | Behavior |
|------------|----------|
| Cross-session recovery | Yes |
| Compaction survival | Yes |
| Project scoping | Yes (auto-detected via `ntcli_project_*`) |
| Iteration history | No — upserts overwrite by `topic_key` |
| Audit trail | Use git commits + the archive-report |

## State Persistence (Orchestrator)

```
Persist:  ntcli_local_save(title: "sdd/{change-name}/state", topic_key: "sdd/{change-name}/state", type: "architecture", scope: "{project}", content: "{yaml state}")
Recover:  ntcli_local_recall(query: "sdd/{change-name}/state")
```

## Common Rules

- Every SDD phase that produces an artifact MUST persist it via `ntcli_local_save`. No exceptions.
- Skipping persistence BREAKS the pipeline — downstream phases will not find your output.
- NEVER create or modify project files for SDD bookkeeping. There is no `openspec/` directory in this stack.
- NEVER call any `mem_*` tools.

## Sub-Agent Context Rules

Sub-agents launch with a fresh context and NO access to the orchestrator's memory.

Who reads, who writes:
- **Non-SDD task**: orchestrator searches ntcli, passes the relevant summary in the prompt; sub-agent saves discoveries via `ntcli_local_save`.
- **SDD phase with dependencies** (spec, design, tasks, apply, verify, archive): sub-agent reads required artifacts directly via `ntcli_local_recall`; sub-agent saves its artifact via `ntcli_local_save`.
- **SDD phase without dependencies** (explore, propose-from-scratch): nobody reads upstream; sub-agent saves its artifact.

## Orchestrator Prompt Instructions for Sub-Agents

### Non-SDD delegation

```
PERSISTENCE (MANDATORY):
You are a brain. Persist what matters. Before returning, save discoveries, decisions,
bug fixes, or stable user preferences via ntcli:

  ntcli_local_save(
    title: "{short description}",
    type: "{decision|bugfix|discovery|pattern|preference}",
    topic_key: "{short-slug}",
    scope: "{project}",
    content: "{What, Why, Where, Learned}"
  )

Do NOT call mem_save or any mem_* tool — Engram does not exist in this stack.
Do NOT return without saving what you learned.
```

### SDD phase with dependencies

```
Read these artifacts before starting (run in parallel):
  ntcli_local_recall(query: "sdd/{change-name}/{type-1}")
  ntcli_local_recall(query: "sdd/{change-name}/{type-2}")

PERSISTENCE (MANDATORY — do NOT skip):
After completing your work:
  ntcli_local_save(
    title: "sdd/{change-name}/{artifact-type}",
    topic_key: "sdd/{change-name}/{artifact-type}",
    type: "architecture",
    scope: "{project}",
    content: "{your full artifact markdown}"
  )

Do NOT call mem_save or any mem_* tool — Engram does not exist in this stack.
If you return without persisting, the next phase CANNOT find your artifact and the pipeline BREAKS.
```

### SDD phase without dependencies

```
PERSISTENCE (MANDATORY — do NOT skip):
After completing your work:
  ntcli_local_save(
    title: "sdd/{change-name}/{artifact-type}",
    topic_key: "sdd/{change-name}/{artifact-type}",
    type: "architecture",
    scope: "{project}",
    content: "{your full artifact markdown}"
  )

Do NOT call mem_save or any mem_* tool — Engram does not exist in this stack.
If you return without persisting, the next phase CANNOT find your artifact and the pipeline BREAKS.
```

## Skill Registry

The orchestrator pre-resolves compact rules from the skill registry and injects them as `## Project Standards (auto-resolved)` in each sub-agent's launch prompt. Sub-agents do NOT read the registry or individual SKILL.md files — rules arrive pre-digested.

To generate/update the registry: run the `skill-registry` skill, or run `sdd-init`.

## Detail Level

The orchestrator may pass `detail_level`: `concise | standard | deep`. This controls output verbosity but does NOT affect what gets persisted — always persist the full artifact.
