# DevSquad GitHub Copilot

GitHub Copilot agents that bring structure to iterative delivery: from business vision through specs, backlog, and implementation.

Every phase includes human checkpoints: agents ask clarifying questions, propose plans for review, and wait for confirmation before executing high-impact changes.

## What You Get

This plugin adds **13 invocable agents**, **13 skills**, and **lifecycle hooks** that guide your team through a structured delivery lifecycle:

`envision` &#8594; `kickoff` &#8594; `specify` &#8594; `plan` &#8594; `decompose` &#8594; `implement` &#8594; `review`

Each phase produces traceable artifacts (specs, ADRs, plans, tasks) that keep the team aligned as the system evolves.

## Quick Start

Open Copilot Chat and select `devsquad` agent to start a guided session. The agent asks clarifying questions, delegates to specialized sub-agents, and maintains context across phases.

You can also invoke a specific agent directly:

| You have... | Start with | Try saying |
|-------------|-----------|------------|
| A product idea without defined scope | `devsquad.envision` | "We need a customer portal for order tracking" |
| A clear vision, ready to structure the backlog | `devsquad.kickoff` | "Structure the backlog from our business vision doc" |
| A defined feature to specify | `devsquad.specify` | "Write a spec for the user authentication feature" |
| A spec ready for technical planning | `devsquad.plan` | "What alternatives should we consider for state management in this workflow?" |
| Tasks ready to implement | `devsquad.implement` | "Implement task 123" |
| An existing backlog that needs organization | `devsquad.refine` | "Analyze the backlog health and flag issues" |
| A plan ready to break into tasks | `devsquad.decompose` | "Decompose the auth spec into work items" |
| A sprint to plan | `devsquad.sprint` | "Prepare sprint 4 planning" |
| Security concerns on design or code | `devsquad.security` | "Run a security review on the payment module" |
| A completed implementation to validate | `devsquad.review` | "Review the code against the spec and plan" |

## Integrations

- **GitHub Issues and Azure Boards**: bidirectional sync for work items, iterations, and capacity
- **Microsoft Learn and Azure**: architecture best practices, documentation lookup, code samples, and retail pricing estimates
- **Git**: branch strategy enforcement, conventional commits, and pull requests with automated review

## Skills

Skills are reusable knowledge packages that agents load automatically behind the scenes to enforce conventions and best practices. They cover architecture decisions, work item management, complexity analysis, documentation style, engineering practices, git workflows, quality gates, and more. See the [full skill catalog](https://github.com/microsoft/devsquad-copilot/blob/main/docs/framework/core-components/custom-agents.md) for details.

## Extensibility

Want to adapt the framework to your stack, domain, or team conventions? Use `devsquad.extend` to create:

- **Skills**: reusable knowledge packages (e.g., coding standards, review checklists, domain rules)
- **Agents**: specialized workflows (e.g., a migration agent, a data pipeline agent)
- **Hooks**: lifecycle scripts that run on session start, after tool use, or on session end
- **Instructions**: path-scoped rules applied automatically when editing matching files

Extensions live in the project repository and are picked up automatically. See the [extensibility guide](https://github.com/microsoft/devsquad-copilot/blob/main/docs/framework/extensibility.md) for details.

## Prerequisites

- Node.js 18+ (for lint hooks and MCP servers)
- VS Code 1.111.0+ with GitHub Copilot set up and signed in. Follow the [official setup guide](https://code.visualstudio.com/docs/copilot/setup) if needed.

For the full documentation, troubleshooting, and contributing guidelines, visit the [repository](https://github.com/microsoft/devsquad-copilot).

## License

[MIT](https://github.com/microsoft/devsquad-copilot/blob/main/LICENSE)
