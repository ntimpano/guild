---
description: Continue the next SDD phase in the dependency chain
agent: guild-leader
---

Follow the SDD orchestrator workflow to continue the active change.

WORKFLOW:
1. Check which artifacts already exist for the active change (proposal, specs, design, tasks) by querying flint
2. Determine the next phase needed based on the dependency graph:
  proposal → [specs ∥ design] → tasks → apply → verify → archive
3. Launch the appropriate sub-agent(s) for the next phase
4. Present the result and ask the user to proceed

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change name: $ARGUMENTS
- Delivery strategy: ask/cache per orchestrator

PERSISTENCE NOTE:
To list existing artifacts for this change, call: `flint_local_recall(query: "sdd/$ARGUMENTS/")`. Sub-agents handle flint persistence automatically. Engram is NOT used.

Read the orchestrator instructions to coordinate this workflow. Do NOT execute phase work inline — delegate to sub-agents.
