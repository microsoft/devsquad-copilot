# DevSquad GitHub Copilot

A delivery framework for GitHub Copilot that guides teams from **intent** to **implementation**: starting with a clearly defined business purpose and expected outcomes (**why**), translating it into explicit specifications and architecture decisions (**what**), and continuously ensuring the **how** (the code) remains aligned with that intent through ongoing validation.

> [!WARNING]
> This project is under active development. It follows [semantic versioning](https://semver.org/); breaking changes may occur in minor releases until 1.0. See the [changelog](CHANGELOG.md) for release notes.

<img src="./docs/framework/images/overview.png" alt="Overview" width="900" />

AI accelerates code generation, but also accelerates decisions, artifacts, and assumptions. In fast-moving projects, requirements evolve, architecture gets revisited, and parallel work starts from incomplete or stale context. Staying aligned as the system grows is the real challenge.

This framework embeds delivery guardrails directly into the development workflow. AI agents guide each phase, from vision through implementation and review, while every decision is captured in persistent artifacts that any team member can read, question, and build upon.

Following an **Intent-Driven Development** approach, it is designed to be:

* **Intent-first**: every initiative (feature, migration, infrastructure change) traces back to a business need captured in the envisioning document
* **Spec-driven**: specifications act as formal contracts between what stakeholders need and what developers build
* **Human-in-the-loop**: agents ask before assuming and require approval for high-impact changes.

## Core Concepts

### Intent

An **Intent** captures the business vision, pain points, and strategic objectives behind an initiative. It answers the question:

> *Why are we building this?*

Intents are technology-agnostic. They describe the problem space, affected users, and success criteria without prescribing APIs, UI, or implementation details. In the framework, the envisioning document is the intent artifact.

### Specification

A **Specification** is a formal, verifiable description derived from the intent. It answers the question:

> *What must the system do to satisfy the intent?*

* For features, specs define user stories with priority and acceptance scenarios.
* For technical initiatives such as migrations or infrastructure changes, they describe the target state and constraints.

In both cases, specs include test cases that can be independently tested, decomposed into tasks, and validated against the final implementation.

### Architecture Decision Record (ADR)

An **ADR** captures the technical choices that shape implementation. It answers the question:

> *Why did we choose this approach over the alternatives?*

ADRs document ranked priorities, evaluated options, and the reasoning behind each choice. They provide the architectural context that connects what the spec requires to how the code delivers it.

### Intentional AI

Agents follow a Socratic approach: they ask clarifying questions, propose plans for review, and adjust rigor to the scope of the change. A typo fix executes directly. A new function requires a plan and confirmation. A new service requires an ADR and explicit approval.

AI accelerates each step, but humans make the decisions.

### Delivery Lifecycle

The framework connects these concepts into a continuous pipeline:

* **Before coding**: intents and specs are defined, validated, and decomposed into prioritized tasks
* **During coding**: specs and ADRs act as contractual guidance; implementation follows the plan
* **After changes**: review verifies alignment between code and the original spec

Each phase produces persistent artifacts, so a new developer can reconstruct the full reasoning chain by reading the repository.

## Who is this for?

* Multiple developers working on the same product, where handoffs, shared decisions, and backlog coordination are constant.
* Projects that require traceability and cross-role visibility. Persisted artifacts (specs, ADRs, plans) allow the project context resist over time, and reduce onboarding time for new contributors.

## What this is not

This framework is not a vibe-coding tool. It does not accept a single prompt and autonomously produce a finished system. Agents ask clarifying questions, propose plans for review, and wait for approval before acting.

If you are looking for one-shot, fully autonomous code generation without review, this framework will feel like friction, and that friction is intentional.

## Capabilities

### Backlog and Sprint Management

Specs decompose into prioritized tasks by user story and sync to GitHub Issues or Azure Boards. Sprint planning covers velocity, capacity, and committed versus stretch scope. Refinement detects inconsistencies between specs and work items and classifies item readiness.

### Security

* **Architectural**: STRIDE threat modeling, trust boundary mapping, attack surface analysis, and Azure compliance checks. Produces a security requirements checklist before implementation begins.
* **Code**: OWASP-categorized vulnerability analysis, credential detection, dependency CVE audit, and GitHub Advanced Security integration. Each finding includes severity, affected code, and remediation guidance.

### Integrations

| System | What the framework does |
|--------|------------------------|
| GitHub Issues and Azure Boards | Bidirectional sync for work items, iterations, and capacity |
| Microsoft Learn and Azure | Up-to-date documentation lookup, code samples, architecture and infrastructure as code best practices, deployment strategies, and retail pricing estimates |
| Git | Branch strategy enforcement, conventional commits, and pull requests with automated review |

## Getting Started

### Prerequisites

* Node.js 18+ (for lint hooks and MCP servers)
* Development tools (at least one)
  * [VS Code](https://code.visualstudio.com/download) 1.111.0+ with the [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) extension
  * [Copilot CLI](https://github.com/features/copilot/cli) 1.0.6+
* **If using VS Code**: enable in extension settings:
  * `github.copilot.advanced.experimental.memory` (optional, for cross-session memory)

#### Authentication

Sign in to GitHub before first use so the framework can manage issues, pull requests, and board operations.

* **VS Code**: Follow the [Copilot setup guide](https://code.visualstudio.com/docs/copilot/setup) to install the extension and sign in to your GitHub account.
* **Copilot CLI**: Follow the [CLI authentication guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/authenticate-copilot-cli) to authenticate via the GitHub CLI.

### Installation

#### Option 1: Via Copilot CLI

Install the plugin:

   ```bash
   copilot plugin install microsoft/devsquad-copilot
   ```

To update:

   ```bash
   copilot plugin update devsquad
   ```

To uninstall:

   ```bash
   copilot plugin uninstall devsquad
   ```

#### Option 2: Via VS Code

1. Add the following to your VS Code user settings (`Ctrl+Shift+P` / `Cmd+Shift+P` then "Open User Settings (JSON)"):

   ```jsonc
   {
     "chat.plugins.enabled": true,
     "chat.plugins.marketplaces": [
         "microsoft/devsquad-copilot"
     ]
   }
   ```

2. Open the Extensions view (`Ctrl+Shift+X` / `Cmd+Shift+X`), search for `@agentPlugins devsquad`, and install.

3. To manage installed plugins, open the **Agent Plugins - Installed** view in the Extensions sidebar, or select the **gear icon** in the Chat view and choose **Plugins**.

### Usage

#### Option 1: Guided (Recommended)

Use `devsquad` as the entry point. It guides through phases, delegates to specialized sub-agents, and maintains context across phases.

#### Option 2: Direct

Invoke a specific agent based on your current state:

| You have... | Start with |
|-------------|-----------|
| A product idea without defined scope | `devsquad.envision` to capture vision, pains, and objectives |
| A clear vision, ready to structure the backlog | `devsquad.kickoff` to create epics and features |
| A defined feature to specify | `devsquad.specify` to write the spec with requirements and conformance criteria |
| A spec ready for technical planning | `devsquad.plan` to produce ADRs, contracts, and data models |
| Tasks ready to implement | `devsquad.implement` to execute from tasks or work items |
| An existing backlog that needs organization | `devsquad.refine` to detect inconsistencies and classify readiness |

For the full list of agents, see the [agent catalog](docs/framework/core-components/custom-agents.md).

## Extensibility

The `devsquad.extend` agent guides creation of new components tailored to the project. It recommends the right mechanism, scaffolds files, and validates the result.

**Examples of what can be extended:**

| Need | Mechanism | Example prompt |
|------|-----------|----------------|
| Code conventions for a file type | Instruction | `Add a rule that all Python files use Google-style docstrings` |
| Reusable checklist or domain knowledge | Skill | `Create a skill for our API error handling patterns` |
| External tools in existing agents | Tool Extension | `I want the agents to use Confluence and Jira tools` |
| Specialist for complex multi-step tasks | Agent | `Create an agent that handles database migrations` |
| Automated validation after edits | Hook | `Add a hook that validates OpenAPI specs after editing` |

> [!NOTE]
The **Tool Extensions** capability is currently in preview: inject tools from any MCP server into existing plugin agents. The `devsquad.extend` agent handles the full setup: MCP server config, extension YAML, and sync.

For the full technical reference, see the [Extensibility guide](docs/framework/extensibility.md).

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
| See who and what inspired us | [Acknowledgments](ACKNOWLEDGMENTS.md) |
