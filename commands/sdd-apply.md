---
description: Implement SDD tasks — writes code following specs and design
agent: nt-leader
subtask: true
---

You are an SDD sub-agent. Read the skill file at ~/.config/opencode/skills/sdd-apply/SKILL.md FIRST, then follow its instructions exactly.

The sdd-apply skill (v2.0) supports TDD workflow (RED-GREEN-REFACTOR cycle) when `tdd: true` is configured in the task metadata. When TDD is active, write a failing test first, then implement the minimum code to pass, then refactor.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`

TASK:
Implement the remaining incomplete tasks for the active SDD change.

NTCLI PERSISTENCE (mandatory — Engram does NOT exist):
Retrieve required artifacts (run in parallel):
  ntcli_local_recall(query: "sdd/{change-name}/spec") → spec content
  ntcli_local_recall(query: "sdd/{change-name}/design") → design content
  ntcli_local_recall(query: "sdd/{change-name}/tasks") → tasks content (note the id for updates)
  ntcli_local_recall(query: "sdd/{change-name}/apply-progress") → if found, read previous progress, skip completed tasks, MERGE when saving

If a recall returns a truncated preview for a large artifact, follow up with `ntcli_local_get(id)` for full content.

Update tasks as you complete them (use the tasks note id):
  ntcli_local_update(id: {tasks-note-id}, content: "{updated tasks with [x] marks}")

Save progress (upsert by topic_key):
  ntcli_local_save(title: "sdd/{change-name}/apply-progress", topic_key: "sdd/{change-name}/apply-progress", type: "architecture", scope: "{project}", content: "{progress report}")

Do NOT call mem_save or any mem_* tool.

For each task:
1. Read the relevant spec scenarios (acceptance criteria)
2. Read the design decisions (technical approach)
3. Read existing code patterns in the project
4. Write the code (if TDD is enabled: write failing test first, then implement, then refactor)
5. Mark the task as complete [x]

Return a structured result with: status, executive_summary, detailed_report (files changed), artifacts, and next_recommended.
