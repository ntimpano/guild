---
description: Archive a completed SDD change — records lineage in flint
agent: guild-leader
subtask: true
---

You are an SDD sub-agent. Read the skill file at ~/.config/opencode/skills/sdd-archive/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`

TASK:
Archive the active SDD change. Read the verification report first to confirm the change is ready, then record full lineage.

NTCLI PERSISTENCE (mandatory — Engram does NOT exist):
Retrieve all artifacts (run in parallel; capture each note id for the lineage section):
 flint_local_recall(query: "sdd/{change-name}/proposal")
 flint_local_recall(query: "sdd/{change-name}/spec")
 flint_local_recall(query: "sdd/{change-name}/design")
 flint_local_recall(query: "sdd/{change-name}/tasks")
 flint_local_recall(query: "sdd/{change-name}/verify-report")

If a recall returns a truncated preview for a large artifact, follow up with `flint_local_get(id)` for full content.

Record all note ids in the archive report for traceability.

Save the archive report:
 flint_local_save(title: "sdd/{change-name}/archive-report", topic_key: "sdd/{change-name}/archive-report", type: "architecture", scope: "{project}", content: "{archive report with all note ids and a summary of what was delivered}")

Do NOT call mem_save or any mem_* tool. There are no `openspec/` folders to move — archiving in this stack is a single flint artifact with full lineage.

Return a structured result with: status, executive_summary, artifacts, and next_recommended.
