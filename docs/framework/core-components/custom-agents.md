# Agents

## Conductor (preview)

| Agent | What it does | When to use |
|-------|-------------|-------------|
| `devsquad` | Unified entry point. Guides the user through phases, delegates to sub-agents, mediates interaction, maintains cross-phase context | Always. Default entry point for any SDD work |

The conductor uses the [Mediated Coordinator-Worker](./README.md#pattern-mediated-coordinator-worker) pattern: detects intent, invokes sub-agents with `[CONDUCTOR]`, relays questions to the user, and executes returned actions (create files, work items).

## Specialist Agents (dual-mode)

All agents operate in **dual-mode**:
- **Via conductor** (`devsquad`): receive `[CONDUCTOR]` in the prompt, return structured actions (`[ASK]`, `[CREATE]`, `[BOARD]`, `[CHECKPOINT]`, `[DONE]`)
- **Direct invocation**: user selects the agent from the Chat dropdown, normal interactive flow

| Phase | Agent | What it does | When to use |
|-------|-------|-------------|-------------|
| Setup | `devsquad.init` | Creates project files (templates, instructions) | First time in the project |
| Envisioning | `devsquad.envision` | Captures strategic vision via structured questions | Project start: define customer, pain points, and business objectives |
| Envisioning | `devsquad.kickoff` | Structures project hierarchy (epics, features) on the board | Project start, to organize the backlog |
| Envisioning / ADS | `devsquad.specify` | Creates feature spec with compliance criteria | When there is a feature to specify, before implementing |
| ADS | `devsquad.plan` | Generates design artifacts (ADRs, data modeling, contracts) | Define architecture, before implementing |
| ADS | `devsquad.decompose` | Decomposes specs into user stories and tasks on the board | After planning, to create work items |
| ADS / Sprints | `devsquad.security` | Security assessment (architectural or code) | After planning or implementation |
| Sprints | `devsquad.sprint` | Prepares sprint planning with readiness analysis | Before starting a sprint |
| Sprints | `devsquad.implement` | Executes implementation from a task/issue | When there is a task ready to implement |
| Sprints | `devsquad.review` | Validates implementation against spec and ADRs | After implementation, before the PR |
| Sprints | `devsquad.refine` | Analyzes backlog health and detects inconsistencies | Ongoing backlog maintenance |
| Extensibility | `devsquad.extend` | Guides creation of extensions (instructions, skills, agents, hooks) | When you need to add stack, domain, or organization knowledge |

## Sub-agents

Agents that also operate as sub-agents: autonomously invoked by other specialist agents, they run in an isolated context and return a structured result to the coordinator. They remain directly accessible to the user.

| Agent | Invoked by | Result |
|-------|------------|--------|
| `devsquad.security` | `devsquad.plan`, `devsquad.implement`, `devsquad.review` | Verdict + findings (architectural or code) |
| `devsquad.review` | `devsquad.implement` | Verdict + findings before the PR (medium/high impact), with self-correction loop for Major findings (max 2 attempts) |
| `devsquad.refine` | `devsquad.sprint` | Inconsistencies to enrich readiness |


