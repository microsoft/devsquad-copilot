# Agents

## Conductor (preview)

| Agent | What it does | When to use |
|-------|-------------|-------------|
| `sdd` | Unified entry point. Guides the user through phases, delegates to sub-agents, mediates interaction, maintains cross-phase context | Always. Default entry point for any SDD work |

The conductor uses the [Mediated Coordinator-Worker](./README.md#pattern-mediated-coordinator-worker) pattern: detects intent, invokes sub-agents with `[CONDUCTOR]`, relays questions to the user, and executes returned actions (create files, work items).

## Specialist Agents (dual-mode)

All agents operate in **dual-mode**:
- **Via conductor** (`sdd`): receive `[CONDUCTOR]` in the prompt, return structured actions (`[ASK]`, `[CREATE]`, `[BOARD]`, `[CHECKPOINT]`, `[DONE]`)
- **Direct invocation**: user selects the agent from the Chat dropdown, normal interactive flow

| Phase | Agent | What it does | When to use |
|-------|-------|-------------|-------------|
| Setup | `sdd.init` | Creates project files (templates, instructions) | First time in the project |
| Envisioning | `sdd.envision` | Captures strategic vision via structured questions | Project start: define customer, pain points, and business objectives |
| Envisioning | `sdd.kickoff` | Structures project hierarchy (epics, features) on the board | Project start, to organize the backlog |
| Envisioning / ADS | `sdd.specify` | Creates feature spec with compliance criteria | When there is a feature to specify, before implementing |
| ADS | `sdd.plan` | Generates design artifacts (ADRs, data modeling, contracts) | Define architecture, before implementing |
| ADS | `sdd.decompose` | Decomposes specs into user stories and tasks on the board | After planning, to create work items |
| ADS / Sprints | `sdd.security` | Security assessment (architectural or code) | After planning or implementation |
| Sprints | `sdd.sprint` | Prepares sprint planning with readiness analysis | Before starting a sprint |
| Sprints | `sdd.implement` | Executes implementation from a task/issue | When there is a task ready to implement |
| Sprints | `sdd.review` | Validates implementation against spec and ADRs | After implementation, before the PR |
| Sprints | `sdd.refine` | Analyzes backlog health and detects inconsistencies | Ongoing backlog maintenance |
| Extensibility | `sdd.extend` | Guides creation of extensions (instructions, skills, agents, hooks) | When you need to add stack, domain, or organization knowledge |

## Sub-agents

Agents that also operate as sub-agents: autonomously invoked by other specialist agents, they run in an isolated context and return a structured result to the coordinator. They remain directly accessible to the user.

| Agent | Invoked by | Result |
|-------|------------|--------|
| `sdd.security` | `sdd.plan`, `sdd.implement`, `sdd.review` | Verdict + findings (architectural or code) |
| `sdd.review` | `sdd.implement` | Verdict + findings before the PR (medium/high impact), with self-correction loop for Major findings (max 2 attempts) |
| `sdd.refine` | `sdd.sprint` | Inconsistencies to enrich readiness |


