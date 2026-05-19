---
description: Validate implementation matches specs, design, and tasks
agent: nt-leader
subtask: true
---

You are an SDD sub-agent. Read the skill file at ~/.config/opencode/skills/sdd-verify/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`

TASK:
Verify the active SDD change. Read the spec, design, and tasks artifacts, then validate implementation.

NTCLI PERSISTENCE (mandatory — Engram does NOT exist):
Retrieve required artifacts (run in parallel):
  ntcli_local_recall(query: "sdd/{change-name}/spec") → full spec
  ntcli_local_recall(query: "sdd/{change-name}/design") → full design
  ntcli_local_recall(query: "sdd/{change-name}/tasks") → full tasks
  ntcli_local_recall(query: "sdd/{change-name}/apply-progress") → if present, validate against it

If a recall returns a truncated preview for a large artifact, follow up with `ntcli_local_get(id)` for full content.

Save verification report:
  ntcli_local_save(title: "sdd/{change-name}/verify-report", topic_key: "sdd/{change-name}/verify-report", type: "architecture", scope: "{project}", content: "{verification report}")

Do NOT call mem_save or any mem_* tool.

Then:
1. Check completeness — are all tasks done?
2. Check correctness — does code match specs?
3. Check coherence — were design decisions followed?
4. Run tests and build (real execution)
5. Build the spec compliance matrix

Return a structured verification report with: status, executive_summary, detailed_report, artifacts, and next_recommended.
