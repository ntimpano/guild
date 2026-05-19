# ntcli Artifact Convention (reference documentation)

NOTE: Critical ntcli calls (`ntcli_local_recall`, `ntcli_local_save`, `ntcli_local_get`) are inlined directly in each skill's SKILL.md. This document is supplementary reference — sub-agents do NOT need to read it to function.

> **Engram does NOT exist in this stack.** Never call `mem_save`, `mem_search`, `mem_get_observation`, or any `mem_*` tool. The ONLY persistence backend is ntcli local SQLite via the `ntcli_local_*` MCP tools.

## Naming Rules

ALL SDD artifacts persisted to ntcli MUST follow this deterministic naming:

```
title:     sdd/{change-name}/{artifact-type}
topic_key: sdd/{change-name}/{artifact-type}
type:      architecture
scope:     {project name}    # used as the local SQLite scope
```

### Artifact Types

| Artifact Type | Produced By | Description |
|---------------|-------------|-------------|
| `explore` | sdd-explore | Exploration analysis |
| `proposal` | sdd-propose | Change proposal |
| `spec` | sdd-spec | Delta specifications (all domains concatenated) |
| `design` | sdd-design | Technical design |
| `tasks` | sdd-tasks | Task breakdown |
| `apply-progress` | sdd-apply | Implementation progress (one per batch) |
| `verify-report` | sdd-verify | Verification report |
| `archive-report` | sdd-archive | Archive closure with lineage |
| `state` | orchestrator | DAG state for recovery after compaction |

Exception: `sdd-init` uses `sdd-init/{project-name}` as both title and topic_key.

### State Artifact

```
ntcli_local_save(
  title: "sdd/{change-name}/state",
  topic_key: "sdd/{change-name}/state",
  type: "architecture",
  scope: "{project}",
  content: "change: {change-name}\nphase: {last-phase}\nartifacts:\n  proposal: true\n  specs: true\n  design: false\n  tasks: false\ntasks_progress:\n  completed: []\n  pending: []\nlast_updated: {ISO date}"
)
```

Recovery: `ntcli_local_recall("sdd/{change-name}/state")` → parse YAML → restore state.

## Recovery Protocol

```
ntcli_local_recall(query: "sdd/{change-name}/{artifact-type}")
  → returns matching notes with full content (no second call required for short artifacts)
  → for very large artifacts, use ntcli_local_get(id) to fetch full content
```

When retrieving multiple artifacts, run all `ntcli_local_recall` calls in parallel:

```
ntcli_local_recall(query: "sdd/{change-name}/proposal")
ntcli_local_recall(query: "sdd/{change-name}/spec")
ntcli_local_recall(query: "sdd/{change-name}/design")
```

Loading project context:
```
ntcli_local_recall(query: "sdd-init/{project}")
```

## Writing Artifacts

Standard write:
```
ntcli_local_save(
  title: "sdd/{change-name}/{artifact-type}",
  topic_key: "sdd/{change-name}/{artifact-type}",
  type: "architecture",
  scope: "{project}",
  content: "{full markdown content}"
)
```

Concrete example — saving a proposal for `add-dark-mode`:
```
ntcli_local_save(
  title: "sdd/add-dark-mode/proposal",
  topic_key: "sdd/add-dark-mode/proposal",
  type: "architecture",
  scope: "my-app",
  content: "## Proposal\n\nAdd dark mode toggle..."
)
```

Update existing artifact (when you have the note ID):
```
ntcli_local_update(id: {note-id}, content: "{updated full content}")
```

Use `ntcli_local_update` when you have the exact ID. Use `ntcli_local_save` with same `topic_key` for upserts.

### Browsing All Artifacts for a Change

```
ntcli_local_recall(query: "sdd/{change-name}/")
→ Returns all artifacts for that change
```

## Project Scope Resolution

ntcli auto-detects the project from the current working directory via `ntcli_project_probe` / `ntcli_project_current`. The `scope` field on saved notes ties artifacts to a specific project. Use `ntcli_project_current` if you need to confirm the active project before saving.

## Upsert Behavior

Same `topic_key` + `scope` → UPDATE (overwrite), not INSERT. Previous content is replaced. ntcli is working memory, not an audit trail. For iteration history, commit your work to git.

## Why This Convention

- Deterministic titles → recovery works by exact match
- `topic_key` → enables upserts without duplicates
- `sdd/` prefix → namespaces all SDD artifacts
- Single retrieval call (`ntcli_local_recall`) → simpler than legacy two-step flows
- Lineage → archive-report includes all artifact references for complete traceability
