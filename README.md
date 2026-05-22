# Guild: SDD Agents for Pi

Guild provides a set of **Spec-Driven Development (SDD)** agents for [Pi](https://opencode.ai/pi). These agents help you:
- **Explore** codebases (`guild-scout`).
- **Design** specs (`guild-planner`).
- **Implement** changes with TDD (`guild-worker`).
- **Review** and archive results (`guild-reviewer`, `guild-archivist`).

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/ntimpano/guild.git
cd guild
```

### 2. (Optional) Install Flint
Flint is **recommended** for full functionality of Guild agents, but it is not required. To install Flint:
```bash
# Install Flint (recommended)
pip install flint-cli  # Or follow: https://github.com/opencode-ai/flint
```

### 3. Install Agents
Run the installation script to copy Guild agents to Pi's global agent directory:
```bash
./install-agents.sh
```
- The script will warn you if Flint is not installed, but it will still install the agents.
- Without Flint, some agents (e.g., `guild-init`, `guild-archivist`) will have limited functionality.

### 4. Restart Pi
Restart Pi to see the new agents:
```bash
systemctl --user restart pi-agent  # Or restart Pi manually
```

### 5. Verify Installation
List all available agents in Pi:
```bash
pi agent list  # Or use the model-selector TUI
```
You should see the `guild-*` agents in the list.

## Uninstallation
To remove Guild agents from Pi:
```bash
./install-agents.sh --uninstall
```

## Agents Overview
| Agent               | Purpose                                                                                     | Flint Required? |
|--------------------|---------------------------------------------------------------------------------------------|-----------------|
| `guild-init`       | Initialize a new SDD change (create `plan_id`, set context).                                | ✅ Yes           |
| `guild-scout`      | Explore the codebase (map files, dependencies, patterns).                                   | ❌ No            |
| `guild-planner`    | Design a detailed spec (outcome, non-goals, constraints, acceptance criteria).              | ❌ No            |
| `guild-architect`  | Propose architecture for complex changes (dependency diagrams, migration strategies).      | ❌ No            |
| `guild-proposer`   | Generate an implementation plan (tasks, waves, dependencies).                              | ❌ No            |
| `guild-task-breaker` | Decompose a spec into atomic, executable tasks.                                            | ❌ No            |
| `guild-worker`     | Implement tasks with strict TDD (RED → GREEN → REFACTOR).                                  | ❌ No            |
| `guild-reviewer`   | Validate changes against the spec (integration checks, spec drift detection).              | ✅ Yes           |
| `guild-archivist`  | Archive the results of a change (persist in Flint, generate summary, cleanup).             | ✅ Yes           |

## Usage
Run a full SDD workflow with:
```bash
{
  agent: "guild-init",
  task: "Initialize a plan to add OAuth2 support",
  agentScope: "user"
}
```

## License
MIT