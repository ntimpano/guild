---
description: Fast-forward all SDD planning phases — proposal through tasks
agent: guild-leader
---

Follow the SDD orchestrator workflow to fast-forward all planning phases for change "$ARGUMENTS".

WORKFLOW:
Run these sub-agents in sequence:
1. sdd-propose — create the proposal
2. sdd-spec — write specifications
3. sdd-design — create technical design
4. sdd-tasks — break down into implementation tasks

Present a combined summary after ALL phases complete (not between each one).

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change name: $ARGUMENTS
- Delivery strategy: ask/cache per orchestrator

PERSISTENCE NOTE:
Sub-agents handle flint persistence automatically. Each phase saves with topic_key "sdd/$ARGUMENTS/{type}" via `flint_local_save` — type is one of: proposal, spec, design, tasks. Engram is NOT used.

Read the orchestrator instructions to coordinate this workflow. Do NOT execute phase work inline — delegate to sub-agents.
