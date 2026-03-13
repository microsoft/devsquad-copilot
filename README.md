# DevSquad Delivery Framework

A GitHub Copilot delivery framework with guardrails to make AI-assisted development consistent, traceable, and maintainable.

<img src="./docs/framework/images/overview.png" alt="Overview" width="600" />

## Structured Delivery at AI Speed

Shipping reliable enterprise software is a team activity. It requires shared understanding of what is being built, why, and what state it is in. When that understanding breaks down, teams duplicate effort, revisit settled decisions, and lose time aligning across roles.

Faster code production means more decisions per day, more artifacts to track, and more surface area for misalignment between developers, architects, product managers, and stakeholders. Without visibility into progress, rationale, and quality at each stage, speed works against reliability.

## Core Features

### Delivery Lifecycle

A conductor agent guides the workflow from vision through implementation and review; each specialized agent can also be invoked directly. Agents ask before assuming and scale ceremony to change impact.

### Backlog and Sprint Management

Specs decompose into prioritized tasks by user story, synced to GitHub Issues or Azure Boards. Sprint planning covers velocity, capacity, and committed versus stretch scope. Refinement detects inconsistencies and classifies item readiness.

### Security

* **Architectural**: STRIDE threat modeling, trust boundary mapping, attack surface analysis, ADR security implications, and Azure compliance checks. Produces a verdict with a security requirements checklist before implementation begins.

* **Code**: OWASP-categorized vulnerability analysis, credential detection, dependency CVE audit, and GitHub Advanced Security integration. Each finding includes severity, affected code, and remediation examples.

### Integrations

* **GitHub Issues and Azure Boards**: bidirectional sync for work items, iterations, and capacity
* **Microsoft Learn and Azure**: architecture and infra as code best practices, documentation lookup, code samples, and retail pricing estimates
* **Git**: branch strategy enforcement, conventional commits, and pull requests with automated review

### Extensibility

An extension agent guides creation of new skills, agents, hooks, and instructions for specific stacks, domains, or conventions tailored to the project needs.

## Getting Started

### Prerequisites

* Node.js 18+ (for lint hooks and MCP servers)
* **Copilot CLI** or **VS Code** with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension
* **If using VS Code**: enable in extension settings:
  * `github.copilot.advanced.experimental.subagents` (required for sub-agents)
  * `github.copilot.advanced.experimental.memory` (optional, for cross-session memory)

### Installation

#### Option 1: Via Copilot CLI

1. Install the plugin:

   ```bash
   copilot plugin install https://github.com/microsoft/devsquad-copilot.git
   ```

2. To update:

   ```bash
   copilot plugin update devsquad
   ```

3. To uninstall:

   ```bash
   copilot plugin uninstall devsquad
   ```

#### Option 2: Via VS Code Agent Plugins

Add the repository as a plugin marketplace in your settings:

1. Open VS Code settings and add the repository to `chat.plugins.marketplaces`:

   ```jsonc
   // settings.json
   "chat.plugins.marketplaces": [
       "https://github.com/microsoft/devsquad-copilot.git"
   ]
   ```

2. Open the Extensions view (`Ctrl+Shift+X` / `Cmd+Shift+X`), search for `@agentPlugins`, and install the plugin.

3. To manage installed plugins, open the **Agent Plugins - Installed** view in the Extensions sidebar, or select the **gear icon** in the Chat view and choose **Plugins**.

For more details, see the [VS Code Agent Plugins documentation](https://code.visualstudio.com/docs/copilot/customization/agent-plugins).

### Usage

Use the `sdd` agent as a single entry point. It guides through phases, delegates to specialized sub-agents, and maintains context across phases.

To invoke a specific phase directly, use any agent from the [agent catalog](docs/framework/core-components/custom-agents.md).

## Tips for Effective Sessions

* **Run sessions as a group.** Bring people with different perspectives (business,
  architecture, implementation) together rather than running solo. This shortens decision loops and builds shared
  understanding. Rotate who drives between sessions or phases so everyone stays engaged
  and knowledge spreads across the team.

* **Elaborate together.** The agents start by asking clarifying questions about scope,
  constraints, and priorities. Answer as a team, but also bring context the agent would
  not know to ask for: recent decisions, failed approaches, team dependencies, or
  organizational constraints. Once the full picture is clear, let it draft a proposal.
* **Work in short "ask, propose, validate, execute" loops.** The agent asks, the team
  answers. The agent proposes, the team confirms or corrects. The agent executes, the
  team reviews. Repeat. This keeps momentum high without hiding critical decisions.

## Documentation

| Goal | Document |
|------|----------|
| Understand the framework architecture, decisions and use cases | [Framework Architecture](docs/framework/README.md) |
| Understand the approach used by the `extend` agent to guide the creation of skills, agents, instructions or hooks | [Extensibility](docs/framework/extensibility.md) |
| See what changed | [Changelog](CHANGELOG.md) |
