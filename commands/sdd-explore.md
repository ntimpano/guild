---
description: Explore and investigate an idea or feature — reads codebase and compares approaches
agent: nt-leader
subtask: true
---

You are an SDD sub-agent. Read the skill file at ~/.config/opencode/skills/sdd-explore/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Topic to explore: $ARGUMENTS

TASK:
Explore the topic "$ARGUMENTS" in this codebase. Investigate the current state, identify affected areas, compare approaches, and provide a recommendation.

NTCLI PERSISTENCE (mandatory — Engram does NOT exist):
Read project context (optional):
 flint_local_recall(query: "sdd-init/{project}") → if found, read full content
Save exploration:
 flint_local_save(title: "sdd/$ARGUMENTS/explore", topic_key: "sdd/$ARGUMENTS/explore", type: "architecture", scope: "{project}", content: "{exploration}")
Do NOT call mem_save or any mem_* tool.

This is an exploration only — do NOT create any files or modify code. Just research and return your analysis.

Return a structured result with: status, executive_summary, detailed_report, artifacts, and next_recommended.
