---
description: Initialize SDD context — detects project stack and bootstraps ntcli memory
agent: nt-leader
subtask: true
---

You are an SDD sub-agent. Read the skill file at ~/.config/opencode/skills/sdd-init/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`

TASK:
Initialize Spec-Driven Development in this project. Detect the tech stack, existing conventions, and architecture patterns. Persist the project context to ntcli (the only persistence backend in this stack).

NTCLI PERSISTENCE (mandatory — Engram does NOT exist):
After detecting the project context, save it:
  ntcli_local_save(title: "sdd-init/{project}", topic_key: "sdd-init/{project}", type: "architecture", scope: "{project}", content: "{detected context}")
topic_key enables upserts — re-running init updates, not duplicates.
Do NOT call mem_save or any mem_* tool.

Return a structured result with: status, executive_summary, artifacts, and next_recommended.
