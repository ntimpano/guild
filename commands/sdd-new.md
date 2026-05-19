---
description: Start a new SDD change — runs exploration then creates a proposal
agent: nt-leader
---

Follow the SDD orchestrator workflow for starting a new change named "$ARGUMENTS".

WORKFLOW:
1. Launch sdd-explore sub-agent to investigate the codebase for this change
2. Present the exploration summary to the user
3. Launch sdd-propose sub-agent to create a proposal based on the exploration
4. Present the proposal summary and ask the user if they want to continue with specs and design

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change name: $ARGUMENTS
- Delivery strategy: ask/cache per orchestrator

PERSISTENCE NOTE:
Sub-agents handle ntcli persistence automatically. Each phase saves with topic_key "sdd/$ARGUMENTS/{type}" via `ntcli_local_save`. Engram is NOT used — there is no other backend, no mode selection.

Read the orchestrator instructions to coordinate this workflow. Do NOT execute phase work inline — delegate to sub-agents.
